/*******************************************************************************
 * Copyright (c) 2010 Christopher Haines, Dale Scheppler, Nicholas Skaggs, Stephen V. Williams. All rights reserved.
 * This program and the accompanying materials are made available under the terms of the new BSD license which
 * accompanies this distribution, and is available at http://www.opensource.org/licenses/bsd-license.html Contributors:
 * Christopher Haines, Dale Scheppler, Nicholas Skaggs, Stephen V. Williams - initial API and implementation
 ******************************************************************************/
package org.vivoweb.test.harvester.fetch;

import java.io.BufferedWriter;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileWriter;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import junit.framework.TestCase;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.fetch.PubmedFetch;
import org.vivoweb.harvester.util.InitLog;
import org.vivoweb.harvester.util.repo.Record;
import org.vivoweb.harvester.util.repo.RecordHandler;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * @author Dale Scheppler (dscheppler@ctrip.ufl.edu)
 * @author Christopher Haines (hainesc@ctrip.ufl.edu)
 */
public class PubmedFetchTest extends TestCase {
	/**
	 * SLF4J Logger
	 */
	private static Logger log = LoggerFactory.getLogger(PubmedFetchTest.class);
	/** */
	private File configFile;
	/** */
	private RecordHandler rh;
	
	@Override
	protected void setUp() throws Exception {
		InitLog.initLogger(PubmedFetchTest.class);
		this.configFile = File.createTempFile("rhConfig", "xml");
		BufferedWriter bw = new BufferedWriter(new FileWriter(this.configFile));
		bw.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<RecordHandler type=\"org.vivoweb.harvester.util.repo.JDBCRecordHandler\">\n	<Param name=\"jdbcDriverClass\">org.h2.Driver</Param>\n	<Param name=\"connLine\">jdbc:h2:mem:TestPMSFetchRH</Param>\n	<Param name=\"username\">sa</Param>\n	<Param name=\"password\"></Param>\n	<Param name=\"tableName\">recordTable</Param>\n	<Param name=\"dataFieldName\">dataField</Param>\n</RecordHandler>");
		bw.close();
		this.rh = null;
	}
	
	@Override
	protected void tearDown() throws Exception {
		if(this.rh != null) {
			this.rh.close();
		}
	}
	
	/**
	 * Test method for {@link org.vivoweb.harvester.fetch.PubmedFetch#main(java.lang.String[]) main(String... args)}.
	 */
	public final void testPubmedFetchMain() {
		try {
			this.rh = RecordHandler.parseConfig(this.configFile.getAbsolutePath());
			
			//test 1 record
			PubmedFetch.main(new String[]{"-m", "test@test.com", "-t", "1:8000[dp]", "-n", "1", "-b", "1", "-o", this.configFile.getAbsolutePath()});
			assertTrue(this.rh.iterator().hasNext());
			DocumentBuilder docB = DocumentBuilderFactory.newInstance().newDocumentBuilder();
			for(Record r : this.rh) {
				Document doc = docB.parse(new ByteArrayInputStream(r.getData().getBytes()));
				Element elem = doc.getDocumentElement();
				traverseNodes(elem.getChildNodes());
			}
			
			//test 0 records, batch 1
			PubmedFetch.main(new String[]{"-m", "test@test.com", "-t", "1:8000[dp]", "-n", "0", "-b", "1", "-o", this.configFile.getAbsolutePath()});
			assertTrue(this.rh.iterator().hasNext());
			
			//test 1 records, batch 0
			PubmedFetch.main(new String[]{"-m", "test@test.com", "-t", "1:8000[dp]", "-n", "0", "-b", "1", "-o", this.configFile.getAbsolutePath()});
			assertTrue(this.rh.iterator().hasNext());

			//test 0 records, batch 0
			PubmedFetch.main(new String[]{"-m", "test@test.com", "-t", "1:8000[dp]", "-n", "0", "-b", "0", "-o", this.configFile.getAbsolutePath()});
			assertTrue(this.rh.iterator().hasNext());
			
			//test 1200 records, batch 500
			PubmedFetch.main(new String[]{"-m", "test@test.com", "-t", "1:8000[dp]", "-n", "1200", "-b", "500", "-o", this.configFile.getAbsolutePath()});
			assertTrue(this.rh.iterator().hasNext());
		} catch(Exception e) {
			log.error(e.getMessage(), e);
			fail(e.getMessage());
		}
	}
	
	/**
	 * @param nodeList the nodes
	 */
	private void traverseNodes(NodeList nodeList) {
		for(int x = 0; x < nodeList.getLength(); x++) {
			Node child = nodeList.item(x);
			String name = child.getNodeName();
			if(!name.contains("#text")) {
				log.info(name);
				traverseNodes(child.getChildNodes());
			}
		}
	}
}