<!--
  Copyright (c) 2010 Christopher Haines, James Pence, Dale Scheppler, Nicholas Skaggs, Stephen V. Williams.
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the new BSD license
  which accompanies this distribution, and is available at
  http://www.opensource.org/licenses/bsd-license.html
  
  Contributors:
      Christopher Haines, James Pence, Dale Scheppler, Nicholas Skaggs, Stephen V. Williams - initial API and implementation
-->
<!-- <?xml version="1.0"?> -->
<!-- Header information for the Style Sheet
	The style sheet requires xmlns for each prefix you use in constructing
	the new elements
-->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:core="http://vivoweb.org/ontology/core#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:score='http://vivoweb.org/ontology/score#'
	xmlns:bibo='http://purl.org/ontology/bibo/'
	xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#'>

	<!-- This will create indenting in xml readers -->
	<xsl:output method="xml" indent="yes"/>

	<!-- The main Article Set of all pubmed citations loaded 
		This serves as the header of the RDF file produced
	 -->
	<rdf:RDF xmlns:owlPlus='http://www.w3.org/2006/12/owl2-xml#'
			xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
			xmlns:skos='http://www.w3.org/2008/05/skos#'
			xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#'
			xmlns:owl='http://www.w3.org/2002/07/owl#'
			xmlns:vocab='http://purl.org/vocab/vann/'
			xmlns:swvocab='http://www.w3.org/2003/06/sw-vocab-status/ns#'
			xmlns:dc='http://purl.org/dc/elements/1.1/'
			xmlns:vitro='http://vitro.mannlib.cornell.edu/ns/vitro/0.7#' 
			xmlns:core='http://vivoweb.org/ontology/core#'
			xmlns:foaf='http://xmlns.com/foaf/0.1/'
			xmlns:score='http://vivoweb.org/ontology/score#'
			xmlns:xs='http://www.w3.org/2001/XMLSchema#'>
	 
	 
	<xsl:template match="modsCollectionDefinition">  <!--Match name=modsCollection type=modsCollectionDefinition -->
		<xsl:apply-templates select="modsDefinition" />		<!-- Match name=mods type=modsDefinition-->
	</xsl:template>

	<xsl:template match="modsDefinition">
		<rdf:Description rdf:about="@ID" >
			<xsl:apply-templates select="titleInfo" />
			<xsl:apply-templates select="//name[@type='personal']" />	
			<bibo:abstract><xsl:value-of select="abstract" /></bibo:abstract>
		</rdf:Description>
	</xsl:template>
	
	<!-- Title  
		SubElements:  title, subTitle, partNumber, partName, nonSort
	-->
	<xsl:template match="titleInfo">
		<xsl:apply-templates select="title" />
	</xsl:template>
	<xsl:template match="title">
		<core:Title><xsl:value-of select="." /></core:Title>
		<rdf:label><xsl:value-of select="." /></rdf:label>
	</xsl:template>
	
	
	<!-- Names  
		SubElements: namePart, displayForm, affiliation, role, description
	-->
	<xsl:template match="//name[@type='personal']">
		<rdf:Description rdf:about="">
		</rdf:Description>
	</xsl:template>
	
	<!-- Type of Resource typeOfResource
		Enumerated Values: text, cartographic, notated music, sound recording-musical, sound recording-nonmusical, sound recording, still image, moving image, three dimensional object, software, mixed material
		Attributes: collection(bool), manuscript(bool), displayLabel, usage, altRepGroup	
	-->
	
	<!-- Genre genre
		Attributes: displayLabel, usage, allRepGroup
	-->

	<!-- Origin Info originInfo
		SubElements: place, publisher, dateIssued, dateCreated, dateCaptured, dateModified, copyrightDate, dateOther, editon, issuance, frequency
	 -->
	 
	 <!-- language
	 	Attributes:
	 	SubElements: languageTerm, scriptTerm
	 -->
	  
	 <!-- physicalDescription
	 	Attributes:
	 	Subelements: form, reformattingQualitity, internetMediaType, extent, digitalOrigin, note
	  -->

	<!-- abstract -->
	
	<!-- tableOfContents -->
	
	<!-- targetAudience -->
	
	<!-- note -->
	
	<!-- subject
		Attributes:
		Subelements:
	 -->

	<!-- classification -->

	<!-- relatedItem -->

	<!-- identifier -->

	<!-- location -->

	<!-- accessCondition -->

	<!-- part -->

	<!-- extension -->

	<!-- recordInfo -->



	</rdf:RDF>
	

</xsl:stylesheet>
	
	
	