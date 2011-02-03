#!/bin/bash

# Copyright (c) 2010 Christopher Haines, Dale Scheppler, Nicholas Skaggs, Stephen V. Williams.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the new BSD license
# which accompanies this distribution, and is available at
# http://www.opensource.org/licenses/bsd-license.html
# 
# Contributors:
#     Christopher Haines, Dale Scheppler, Nicholas Skaggs, Stephen V. Williams - initial API and implementation

# Set working directory
set -e

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR
cd ..

HARVESTER_TASK=pubmed

if [ -f scripts/env ]; then
  . scripts/env
else
  exit 1
fi

#variables for model arguments
HCONFIG="config/jenaModels/h2.xml"
INPUT="-i $HCONFIG -IdbUrl=jdbc:h2:XMLVault/h2Pubmed/all/store -ImodelName=Pubmed"
OUTPUT="-o $HCONFIG -OdbUrl=jdbc:h2:XMLVault/h2Pubmed/all/store -OmodelName=Pubmed"
VIVO="-v $VIVOCONFIG"
SCORE="-s $HCONFIG -SdbUrl=jdbc:h2:XMLVault/h2Pubmed/score/store -SmodelName=Pubmed"
MATCHOUTPUT="-o $HCONFIG -OdbUrl=jdbc:h2:XMLVault/h2Pubmed/match/store -OmodelName=Pubmed"
MATCHINPUT="-i $HCONFIG -IdbUrl=jdbc:h2:XMLVault/h2Pubmed/match/store -ImodelName=Pubmed"

#clear old fetches
rm -rf XMLVault/h2Pubmed/XML

# Execute Fetch for Pubmed
$PubmedFetch -X config/tasks/PubmedFetch.xml

# backup fetch
date=`date +%Y-%m-%d_%T`
tar -czpf backups/.$date.tar.gz XMLVault/h2Pubmed/XML
rm -rf backups/pubmed.xml.latest.tar.gz
ln -s pubmed.xml.$date.tar.gz backups/pubmed.xml.latest.tar.gz
# uncomment to restore previous fetch
#tar -xzpf backups/pubmed.xml.latest.tar.gz XMLVault/h2Pubmed/XML

# clear old translates
rm -rf XMLVault/h2Pubmed/RDF

# Execute Translate using the PubmedToVIVO.xsl file
$XSLTranslator -i config/recordHandlers/Pubmed-XML-h2RH.xml -x config/datamaps/PubmedToVivo.xsl -o config/recordHandlers/Pubmed-RDF-h2RH.xml

# backup translate
date=`date +%Y-%m-%d_%T`
tar -czpf backups/pubmed.rdf.$date.tar.gz XMLVault/h2Pubmed/RDF
rm -rf backups/pubmed.rdf.latest.tar.gz
ln -s pubmed.rdf.$date.tar.gz backups/pubmed.rdf.latest.tar.gz
# uncomment to restore previous translate
#tar -xzpf backups/pubmed.rdf.latest.tar.gz XMLVault/h2Pubmed/RDF

# Clear old H2 models
rm -rf XMLVault/h2Pubmed/all
rm -rf XMLVault/h2Pubmed/temp

# Execute Transfer to import from record handler into local temp model
$Transfer $OUTPUT -h config/recordHandlers/Pubmed-RDF-h2RH.xml

# backup H2 translate Models
date=`date +%Y-%m-%d_%T`
tar -czpf backups/pubmed.all.$date.tar.gz XMLVault/h2Pubmed/all
rm -rf backups/pubmed.all.latest.tar.gz
ln -s ps.all.$date.tar.gz backups/pubmed.all.latest.tar.gz
# uncomment to restore previous H2 translate models
#tar -xzpf backups/pubmed.all.latest.tar.gz XMLVault/h2Pubmed/all

# clear old score models
rm -rf XMLVault/h2Pubmed/score

# Execute Score to disambiguate data in "scoring" JENA model
# Execute match to match and link data into "vivo" JENA model
LEVDIFF="org.vivoweb.harvester.score.algorithm.NormalizedLevenshteinDifference"
WORKEMAIL="-AwEmail=$LEVDIFF -FwEmail=http://vivoweb.org/ontology/core#workEmail -WwEmail=0.1 -PwEmail=http://vivoweb.org/ontology/score#workEmail"
FNAME="-AfName=$LEVDIFF -FfName=http://xmlns.com/foaf/0.1/firstName -WfName=0.3 -PfName=http://vivoweb.org/ontology/score#foreName"
LNAME="-AlName=$LEVDIFF -FlName=http://xmlns.com/foaf/0.1/lastName -WlName=0.5 -PlName=http://xmlns.com/foaf/0.1/lastName"
MNAME="-AmName=$LEVDIFF -FmName=http://vivoweb.org/ontology/core#middleName -WmName=0.1 -PmName=http://vivoweb.org/ontology/core#middleName"
mkdir XMLVault/h2Pubmed/temp/
TEMP="-t XMLVault/h2Pubmed/temp/"

$Score $VIVO $INPUT $TEMP $SCORE $WORKEMAIL $LNAME $FNAME $MNAME
$Match $INPUT $SCORE $MATCHOUTPUT -t 0.7 -r
 
# back H2 score models
date=`date +%Y-%m-%d_%T`
tar -czpf backups/pubmed.scored.$date.tar.gz XMLVault/h2Pubmed/score
rm -rf backups/pubmed.scored.latest.tar.gz
ln -s ps.scored.$date.tar.gz backups/pubmed.scored.latest.tar.gz
# uncomment to restore previous H2 score models
#tar -xzpf backups/pubmed.scored.latest.tar.gz XMLVault/h2Pubmed/score

#remove score statements
$Qualify $MATCHINPUT -n http://vivoweb.org/ontology/score -p

# Execute ChangeNamespace to get into current namespace
$ChangeNamespace $VIVO $MATCHINPUT -n $NAMESPACE -o http://vivoweb.org/harvest/pubmedPub/
$ChangeNamespace $VIVO $MATCHINPUT -n $NAMESPACE -o http://vivoweb.org/harvest/pubmedAuthorship/
$ChangeNamespace $VIVO $MATCHINPUT -n $NAMESPACE -o http://vivoweb.org/harvest/pubmedAuthor/
$ChangeNamespace $VIVO $MATCHINPUT -n $NAMESPACE -o http://vivoweb.org/harvest/pubmedJournal/

# Backup pretransfer vivo database, symlink latest to latest.sql
date=`date +%Y-%m-%d_%T`
mysqldump -h $SERVER -u $USERNAME -p$PASSWORD $DBNAME > backups/$DBNAME.pubmed.pretransfer.$date.sql
rm -rf backups/$DBNAME.pubmed.pretransfer.latest.sql
ln -s $DBNAME.pubmed.pretransfer.$date.sql backups/$DBNAME.pubmed.pretransfer.latest.sql

#Update VIVO, using previous model as comparison. On first run, previous model won't exist resulting in all statements being passed to VIVO
VIVOMODELNAME="modelName=http://vivoweb.org/ingest/pubmed"
INMODELNAME="modelName=Pubmed"
INURL="dbUrl=jdbc:h2:XMLVault/h2Pubmed/match/store"
ADDFILE="XMLVault/update_Additions.rdf.xml"
SUBFILE="XMLVault/update_Subtractions.rdf.xml"
  
# Find Subtractions
$Diff -m $VIVOCONFIG -M$VIVOMODELNAME -s $HCONFIG -S$INURL -S$INMODELNAME -d $SUBFILE
# Find Additions
$Diff -m $HCONFIG -M$INURL -M$INMODELNAME -s $VIVOCONFIG -S$VIVOMODELNAME -d $ADDFILE
# Apply Subtractions to Previous model
$Transfer -o $VIVOCONFIG -O$VIVOMODELNAME -r $SUBFILE -m
# Apply Additions to Previous model
$Transfer -o $VIVOCONFIG -O$VIVOMODELNAME -r $ADDFILE
# Apply Subtractions to VIVO
$Transfer -o $VIVOCONFIG -r $SUBFILE -m
# Apply Additions to VIVO
$Transfer -o $VIVOCONFIG -r $ADDFILE

# Backup posttransfer vivo database, symlink latest to latest.sql
date=`date +%Y-%m-%d_%T`
mysqldump -h $SERVER -u $USERNAME -p$PASSWORD $DBNAME > backups/$DBNAME.pubmed.posttransfer.$date.sql
rm -rf backups/$DBNAME.pubmed.posttransfer.latest.sql
ln -s $DBNAME.pubmed.posttransfer.$date.sql backups/$DBNAME.pubmed.posttransfer.latest.sql

#Restart Tomcat
#Tomcat must be restarted in order for the harvested data to appear in VIVO
echo $HARVESTER_TASK ' completed successfully'
/etc/init.d/tomcat stop
/etc/init.d/apache2 reload
/etc/init.d/tomcat start