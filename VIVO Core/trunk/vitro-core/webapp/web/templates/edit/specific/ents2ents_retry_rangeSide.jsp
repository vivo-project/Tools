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

<%@ taglib prefix="form" uri="http://vitro.mannlib.cornell.edu/edit/tags" %>

    <tr class="editformcell">
        <td valign="top">
            <b>Subject Individual<sup>*</sup></b><br/>
			<select name="RangeId">
				<form:option name="RangeId"/>
			</select>
			<span class="warning"><form:error name="RangeId"/></span>
        </td>
    </tr>
    <tr class="editformcell">
        <td valign="top" colspan="3">
            <b><form:value name="Prop"/><sup>*</sup></b><br/>
            <b>Subject Individual<sup>*</sup></b><br/>
			<select name="DomainId">
				<form:option name="DomainId"/>
			</select>            <span class="warning"><form:error name="DomainId"/></span>
        </td>
    </tr>
    <tr class="editformcell">
        <td valign="top" colspan="2">
            <b>Sunrise</b><br/>
			<input name="Sunrise" value="<form:value name="Sunrise"/>" />
        </td>
        <td valign="top" colspan="1">
            <b>Sunset</b><br/>
			<input name="Sunset" value="<form:value name="Sunset"/>"/>
        </td>
    </tr>
    <tr class="editformcell">
        <td valign="top">
            <b>Qualifier</b><br/>
			<input name="Qualifier" value="<form:value name="Qualifier"/>"/>
        </td>
    </tr>    
