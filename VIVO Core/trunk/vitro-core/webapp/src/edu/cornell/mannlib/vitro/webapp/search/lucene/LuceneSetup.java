/*
Copyright (c) 2010, Cornell University
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of Cornell University nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package edu.cornell.mannlib.vitro.webapp.search.lucene;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.search.BooleanQuery;

import edu.cornell.mannlib.vitro.webapp.ConfigurationProperties;
import edu.cornell.mannlib.vitro.webapp.beans.BaseResourceBean.RoleLevel;
import edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory;
import edu.cornell.mannlib.vitro.webapp.dao.filtering.WebappDaoFactoryFiltering;
import edu.cornell.mannlib.vitro.webapp.dao.filtering.filters.VitroFilterUtils;
import edu.cornell.mannlib.vitro.webapp.dao.filtering.filters.VitroFilters;
import edu.cornell.mannlib.vitro.webapp.search.beans.Searcher;
import edu.cornell.mannlib.vitro.webapp.search.indexing.IndexBuilder;

/**
 * Setup objects for lucene searching and indexing.
 *
 * The indexing and search objects, IndexBuilder and Searcher are found by the
 * controllers IndexController and SearchController through the servletContext.
 * This object will have the method contextInitialized() called when the tomcat
 * server starts this webapp.
 *
 *  The contextInitialized() will try to find the lucene index directory,
 *  make a LueceneIndexer and a LuceneSearcher.  The LuceneIndexer will
 *  also get a list of Obj2Doc objects so it can translate object to lucene docs.
 *
 * To execute this at context creation put this in web.xml:
    <listener>
        <listener-class>
            edu.cornell.mannlib.vitro.search.setup.LuceneSetup
        </listener-class>
    </listener>

 * @author bdc34
 *
 */
public class LuceneSetup implements javax.servlet.ServletContextListener {
        private static String indexDir = null;
        private static final Log log = LogFactory.getLog(LuceneSetup.class.getName());
        
        /**
         * Gets run to set up DataSource when the webapp servlet context gets created.
         */
        @SuppressWarnings("unchecked")
        public void contextInitialized(ServletContextEvent sce) {
        	try {
	            ServletContext context = sce.getServletContext();
	            log.info("**** Running "+this.getClass().getName()+".contextInitialized()");
	
	            indexDir = getIndexDirName();
	            log.info("Directory of full text index: " + indexDir );
	
	            setBoolMax();
	
	            //these should really be set as annotation properties.
	            HashSet dataPropertyBlacklist = new HashSet<String>();
	            context.setAttribute(SEARCH_DATAPROPERTY_BLACKLIST, dataPropertyBlacklist);	            
	            HashSet objectPropertyBlacklist = new HashSet<String>();
	            objectPropertyBlacklist.add("http://www.w3.org/2002/07/owl#differentFrom");
	            context.setAttribute(SEARCH_OBJECTPROPERTY_BLACKLIST, objectPropertyBlacklist);
	            
	            //Here we want to put the LuceneIndex object into the application scope.
	            //This will attempt to create a new directory and empty index if there is none.
                LuceneIndexer indexer = new LuceneIndexer(indexDir, null, getAnalyzer());
                context.setAttribute(ANALYZER, getAnalyzer());
                context.setAttribute(INDEX_DIR, indexDir);
                indexer.addObj2Doc(new Entity2LuceneDoc());
                context.setAttribute(LuceneIndexer.class.getName(),indexer);
                
	            //Here we want to put the LuceneSearcher in the application scope.
	            // the queries need to know the analyzer to use so that the same one can be used
	            // to analyze the fields in the incoming user query terms.
	            LuceneSearcher searcher = new LuceneSearcher(
	                    new LuceneQueryFactory(getAnalyzer(), indexDir),
	                    indexDir);
	            searcher.addObj2Doc(new Entity2LuceneDoc());
	            context.setAttribute(Searcher.class.getName(), searcher);		           
	            indexer.addSearcher(searcher);	            
	            
	            //This is where the builder gets the list of places to try to 
	            //get objects to index. It is filtered so that non-public text
	            //does not get into the search index.            
	            WebappDaoFactory wadf = 
	                (WebappDaoFactory) context.getAttribute("webappDaoFactory");
	            VitroFilters vf = 
	                VitroFilterUtils.getDisplayFilterByRoleLevel(RoleLevel.PUBLIC, wadf); 
	            wadf = new WebappDaoFactoryFiltering(wadf,vf);
	            
	            List sources = new ArrayList();
	            sources.add(wadf.getIndividualDao());
	
	            IndexBuilder builder = new IndexBuilder(context,indexer,sources);
	
	            // here we add the IndexBuilder with the LuceneIndexer
	            // to the servlet context so we can access it later in the webapp.
	            context.setAttribute(IndexBuilder.class.getName(),builder);
	
	            log.debug("**** End of "+this.getClass().getName()+".contextInitialized()");
        	} catch (Throwable t) {
        		log.error(t);
        		System.out.println("***** Error setting up Lucene search *****");
        		t.printStackTrace(); // because Tomcat doesn't display listener errors in catalina.out, at least by default
        	}
        }

        /**
         * Gets run when the webApp Context gets destroyed.
         */
        public void contextDestroyed(ServletContextEvent sce) {
            log.info("**** Running "+this.getClass().getName()+".contextDestroyed()");
        }

        /**
         * In wild card searches the query is first broken into many boolean searches
         * OR'ed together.  So if there is a query that would match a lot of records
         * we need a high max boolean limit for the lucene search.
         *
         * This sets some static method in the lucene library to achieve this.
         */
        public static void setBoolMax() {
            BooleanQuery.setMaxClauseCount(16384);
        }
        
	/**
	 * Gets the name of the directory to store the lucene index in. The
	 * {@link ConfigurationProperties} should have a property named
	 * 'LuceneSetup.indexDir' which has the directory to store the lucene index
	 * for this clone in. If the property is not found, an exception will be
	 * thrown.
	 * 
	 * @return a string that is the directory to store the lucene index.
	 * @throws IllegalStateException
	 *             if the property is not found.
	 * @throws IOException
	 *             if the directory doesn't exist and we fail to create it.
	 */
	private String getIndexDirName()
			throws IOException {
		String dirName = ConfigurationProperties
				.getProperty("LuceneSetup.indexDir");
		if (dirName == null) {
			throw new IllegalStateException(
					"LuceneSetup.indexDir not found in properties file.");
		}

		File dir = new File(dirName);
		if (!dir.exists()) {
			boolean created = dir.mkdir();
			if (!created) {
				throw new IOException(
						"Unable to create Lucene index directory at '" + dir
								+ "'");
			}
		}

		return dirName;
	}

    /**
     * Gets the analyzer that will be used when building the indexing
     * and when analyzing the incoming search terms.
     *
     * @return
     */
    private Analyzer getAnalyzer() {
        return new VitroAnalyzer();
    }
    

    public static final String ANALYZER= "lucene.analyzer";
    public static final String INDEX_DIR = "lucene.indexDir";
    public static final String SEARCH_DATAPROPERTY_BLACKLIST = 
        "search.dataproperty.blacklist";
    public static final String SEARCH_OBJECTPROPERTY_BLACKLIST = 
        "search.objectproperty.blacklist";

}