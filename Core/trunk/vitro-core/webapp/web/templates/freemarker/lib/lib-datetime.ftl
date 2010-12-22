<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Macros and functions for datetime formatting. 

     Currently these do more than format the datetime string, they actually select the precision as well. This should change in a future
     implementation; see NIHVIVO-1567. We want the Java code to apply the precision to the datetime string to pass only the
     meaningful data to the templates. The templates can format as they like, so these functions/macros would do display formatting
     but not data extraction.
 -->

<#-- Function xsdDateTimeToYear 
     
     Display an XSD datetime string as a year.
     
     Example: 1983-12-07T17:15:28Z displays as 1983
-->

<#function xsdDateTimeToYear datetime>
    <#return datetime?date("yyyy")?string("yyyy") >
</#function>