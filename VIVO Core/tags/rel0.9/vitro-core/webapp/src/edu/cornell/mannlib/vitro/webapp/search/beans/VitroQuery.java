package edu.cornell.mannlib.vitro.webapp.search.beans;

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

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.flags.PortalFlag;
import edu.cornell.mannlib.vitro.webapp.search.SearchException;
import org.joda.time.DateTime;

public abstract class VitroQuery {
    /**
     * The parameter name for http requests.
     */
    public static final String QUERY_PARAMETER_NAME = "querytext";
    public static final String QUERY_PARAMETER_EARLIEST = "earliest";
    public static final String QUERY_PARAMETER_LATEST = "latest";
    public static final String QUERY_PARAMETER_IGNORE_TIMESTAMP= "ignore_timestamp";

    DateTime earliest;
    DateTime latest;
    Map parameters = null;
    PortalFlag portalState = null;

    /**
     * Make a VitroQuery with the request parameters and portalState
     * saves for when the query needs to be created.
     */
    public VitroQuery(VitroRequest request, PortalFlag portalState){
        this.portalState = portalState;
        parameters =request.getParameterMap();
        if( parameters == null )
            parameters = Collections.EMPTY_MAP;
    }

    /**
     * Gets the parameters that were passed into this query from the
     * HttpRequest so they can be displayed to the user on return to a
     * search form.
     *
     * @return
     */
    public Map getParameters(){
        return parameters;
    }

    public PortalFlag getPortalState(){
        return portalState;
    }

    public abstract String getTerms();

    /**
     * This is intended to return an specilized query object
     * for your implementation of the search.
     * @return
     */
    public abstract Object getQuery() throws SearchException;
}
