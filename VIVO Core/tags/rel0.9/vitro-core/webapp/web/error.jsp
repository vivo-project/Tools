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

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page isErrorPage="true" %>
<%@ page import="com.oreilly.servlet.ServletUtils,edu.cornell.mannlib.vitro.webapp.web.*" %>
<%@page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.ApplicationBean"%>
<%@page import="edu.cornell.mannlib.vitro.webapp.beans.Portal"%>
<%
            VitroRequest vreq = new VitroRequest(request);
            ApplicationBean appBean = vreq.getAppBean();
            Portal portal = vreq.getPortal();

            String themeDir = portal!=null ? portal.getThemeDir() : Portal.DEFAULT_THEME_DIR_FROM_CONTEXT;                        
                        
            
            request.setAttribute("bodyJsp", "/errorbody.jsp");
            request.setAttribute("title", "Error");
            request.setAttribute("css", "");
            request.setAttribute("portalBean", portal);
            request.setAttribute("appBean", appBean);            
            request.setAttribute("themeDir", themeDir);            
            %>
            
<jsp:include page="/templates/page/doctype.jsp"/>
<head>
  <jsp:include page="/templates/page/headContent.jsp"/>
</head>
<body> <!-- generated by error.jsp -->
<div id="wrap">
    <jsp:include page="/${themeDir}jsp/identity.jsp" flush="true"/>
    
    <div id="contentwrap">
    
        <jsp:include page="/${themeDir}jsp/menu.jsp" flush="true"/>
                
       
        <p>There was an error in the system; please try again later.</p>
        
        <div>
            <h3>Exception: </h3><%= exception %>
        </div>

    <div>    
    <% try{ %>      
       <h3>Trace:</h3><pre><%= ServletUtils.getStackTraceAsString(exception) %></pre>
    <% }catch (Exception e){ %>
       No trace is available.
    <% } %>
    </div>

    <div>
    <% try{ %>      
    <h3>Request Info:</h3><%= MiscWebUtils.getReqInfo(request) %>
    <% }catch (Exception e){ %>
       No request information is available.
    <% } %>
    </div>
    
    
    </div> <!-- contentwrap -->
    <jsp:include page="/${themeDir}jsp/footer.jsp" flush="true"/>
</div> <!-- wrap -->
</body>
</html>
