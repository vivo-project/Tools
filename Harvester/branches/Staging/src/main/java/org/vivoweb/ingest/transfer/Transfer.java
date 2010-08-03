/*******************************************************************************
 * Copyright (c) 2010 Christopher Haines, Dale Scheppler, Nicholas Skaggs, Stephen V. Williams.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the new BSD license
 * which accompanies this distribution, and is available at
 * http://www.opensource.org/licenses/bsd-license.html
 * 
 * Contributors:
 *     Christopher Haines, Dale Scheppler, Nicholas Skaggs, Stephen V. Williams - initial API and implementation
 ******************************************************************************/
package org.vivoweb.ingest.transfer;

import java.io.IOException;
import javax.xml.parsers.ParserConfigurationException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.vivoweb.ingest.util.args.ArgDef;
import org.vivoweb.ingest.util.args.ArgList;
import org.vivoweb.ingest.util.args.ArgParser;
import org.vivoweb.ingest.util.repo.JenaConnect;
import org.xml.sax.SAXException;
import com.hp.hpl.jena.rdf.model.Model;

/**
 * Transfer data from one Jena model to another
 * @author Christopher Haines (hainesc@ctrip.ufl.edu)
 */
public class Transfer {
	/**
	 * Log4J Logger
	 */
	private static Log log = LogFactory.getLog(Transfer.class);
	/**
	 * Model to read records from
	 */
	private Model input;
	/**
	 * Model to write records to
	 */
	private Model output;
	
	/**
	 * input model name
	 */
	private String inputModelName;
	/**
	 * output model name
	 */
	private String outputModelName;
	
	/**
	 * Constructor
	 * @param in input Model
	 * @param out output Model
	 * @param inName input model name
	 * @param outName output model name
	 */
	public Transfer(Model in, Model out, String inName, String outName) {
	  this.input = in;
	  this.output = out;
	  this.inputModelName = inName;
	  this.outputModelName = outName;
	}
	
	/**
	 * Constructor
	 * @param argList parsed argument list
	 * @throws IOException error creating task
	 */
	public Transfer(ArgList argList) throws IOException {
		String inConfig = argList.get("i");
		String outConfig = argList.get("o");
		try {
			//connect to proper model, if specified on command line
			if (this.inputModelName != null) {
				this.input = (new JenaConnect(JenaConnect.parseConfig(inConfig),this.inputModelName)).getJenaModel();
			} else {
				this.input = JenaConnect.parseConfig(inConfig).getJenaModel();
			}
			//connect to proper model, if specified on command line
			if (this.outputModelName != null) {
				this.output = (new JenaConnect(JenaConnect.parseConfig(outConfig),this.outputModelName)).getJenaModel();
			} else {
				this.output = JenaConnect.parseConfig(outConfig).getJenaModel();
			}
		} catch(ParserConfigurationException e) {
			throw new IOException(e.getMessage(),e);
		} catch(SAXException e) {
			throw new IOException(e.getMessage(),e);
		}
	}
	
	/**
	 * Copy data from input to output
	 */
	private void transfer() {
		this.output.add(this.input);
	}
	
	/**
	 * Executes the task
	 */
	public void executeTask() {
		transfer();
	}
	
	/**
	 * Get the ArgParser for this task
	 * @return the ArgParser
	 */
	private static ArgParser getParser() {
		ArgParser parser = new ArgParser("Transfer");
		parser.addArgument(new ArgDef().setShortOption('i').setLongOpt("input").withParameter(true, "CONFIG_FILE").setDescription("config file for input jena model").setRequired(true));
		parser.addArgument(new ArgDef().setShortOption('o').setLongOpt("output").withParameter(true, "CONFIG_FILE").setDescription("config file for output jena model").setRequired(false));
		parser.addArgument(new ArgDef().setShortOption('I').setLongOpt("input").withParameter(true, "MODEL_NAME").setDescription("model name for input (overrides config file)").setRequired(false));
		parser.addArgument(new ArgDef().setShortOption('O').setLongOpt("output").withParameter(true, "MODEL_NAME").setDescription("model name for output (overrides config file)l").setRequired(false));
		return parser;
	}
	
	/**
	 * Main method
	 * @param args commandline arguments
	 */
	public static void main(String... args) {
		log.info("Transfer: Start");
		try {
			new Transfer(new ArgList(getParser(), args)).executeTask();
		} catch(IllegalArgumentException e) {
			System.out.println(getParser().getUsage());
		} catch(Exception e) {
			log.fatal(e.getMessage(),e);
		}
		log.info("Transfer: End");
	}
}
