<%--
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
--%>

<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditN3Utils"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.RdfLiteralHash" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.Controllers" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jstl/functions" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>

<%
    org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger("edu.cornell.mannlib.vitro.jsp.edit.forms.datapropStmtDelete");

    if( session == null)
        throw new Error("need to have session");
    if (!VitroRequestPrep.isSelfEditing(request) && !LoginFormBean.loggedIn(request, LoginFormBean.NON_EDITOR)) {%>
        <c:redirect url="<%= Controllers.LOGIN %>" />
<%  }

    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");
    String datapropKeyStr  = request.getParameter("datapropKey");
    int dataHash = 0;
    if (datapropKeyStr!=null && datapropKeyStr.trim().length()>0) {
        try {
            dataHash = Integer.parseInt(datapropKeyStr);
        } catch (NumberFormatException ex) {
            throw new JspException("Cannot decode incoming datapropKey String value "+datapropKeyStr+" as an integer hash in datapropStmtDelete.jsp");
        }
    }

    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();
    String editorUri = EditN3Utils.getEditorUri(request,session,application);        
    wdf = wdf.getUserAwareDaoFactory(editorUri);
    
    DataProperty prop = wdf.getDataPropertyDao().getDataPropertyByURI(predicateUri);
    if( prop == null ) throw new Error("In datapropStmtDelete.jsp, could not find property " + predicateUri);
    request.setAttribute("propertyName",prop.getPublicName());

    Individual subject = wdf.getIndividualDao().getIndividualByURI(subjectUri);
    if( subject == null ) throw new Error("could not find subject " + subjectUri);
    request.setAttribute("subjectName",subject.getName());

    String dataValue=null;
   // DataPropertyStatement dps=EditConfiguration.findDataPropertyStatementViaHashcode(subject,predicateUri,dataHash);
     DataPropertyStatement dps= RdfLiteralHash.getDataPropertyStmtByHash(subject,dataHash);
    if( log.isDebugEnabled() ){
        log.debug("attempting to delete dataPropertyStatement: subjectURI <" + dps.getIndividualURI() +">");
        log.debug( "predicateURI <" + dps.getDatapropURI() + ">");
        log.debug( "literal \"" + dps.getData() + "\"" );
        log.debug( "lang @" + (dps.getLanguage() == null ? "null" : dps.getLanguage()));
        log.debug( "datatype ^^" + (dps.getDatatypeURI() == null ? "null" : dps.getDatatypeURI() ));       
    }
    if( dps.getIndividualURI() == null || dps.getIndividualURI().trim().length() == 0){
        log.debug("adding missing subjectURI to DataPropertyStatement" );
        dps.setIndividualURI( subjectUri );
    }
    if( dps.getDatapropURI() == null || dps.getDatapropURI().trim().length() == 0){
        log.debug("adding missing datapropUri to DataPropertyStatement");
        dps.setDatapropURI( predicateUri );
    }
    
    if (dps!=null) {
        dataValue = dps.getData().trim();
        if( request.getParameter("y") != null ) { //do the delete
            wdf.getDataPropertyStatementDao().deleteDataPropertyStatement(dps);%>

			<%-- grab the predicate URI and trim it down to get the Local Name so we can send the user back to the appropriate property --%>
		    <c:set var="predicateUri" value="${param.predicateUri}" />
		    <c:set var="localName" value="${fn:substringAfter(predicateUri, '#')}" />
            <c:url var="redirectUrl" value="../entity">
                <c:param name="uri" value="${param.subjectUri}"/>
            </c:url>
            <c:redirect url="${redirectUrl}${'#'}${localName}"/>

<%      } else { %>
            <jsp:include page="${preForm}"/>
            <form action="editDatapropStmtRequestDispatch.jsp" method="get">
			    <label for="submit"><h2>Are you sure you want to delete the following entry from <em>${propertyName}</em>?</h2></label>
                <div class="toBeDeleted dataProp"><%=dataValue%></div>
                <input type="hidden" name="subjectUri"   value="${param.subjectUri}"/>
                <input type="hidden" name="predicateUri" value="${param.predicateUri}"/>
                <input type="hidden" name="datapropKey"  value="${param.datapropKey}"/>
                <input type="hidden" name="y"            value="1"/>
                <input type="hidden" name="cmd"          value="delete"/>
                <v:input type="submit" id="submit" value="Delete" cancel="${param.subjectUri}" />
            </form>
            <jsp:include page="${postForm}"/>
<%      }
     } else {
           throw new Error("In datapropStmtDelete.jsp, no match via hashcode to existing datatype property "+predicateUri+" for subject "+subject.getName()+"\n");
     }%>