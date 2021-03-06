package edu.indiana.slis.swl.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import edu.indiana.slis.swl.service.SparqlQueryService;
import edu.indiana.slis.swl.utils.SPARQL;

public class GetProperty extends HttpServlet {
	
	private String db;
	private ServletContext context;

	/**
	 * Constructor of the object.
	 */
	public GetProperty() {
		super();
	}

	/**
	 * Destruction of the servlet. <br>
	 */
	public void destroy() {
		super.destroy(); // Just puts "destroy" string in log
		// Put your code here
	}

	/**
	 * The doGet method of the servlet. <br>
	 *
	 * This method is called when a form has its tag value method equals to get.
	 * 
	 * @param request the request send by the client to the server
	 * @param response the response send by the server to the client
	 * @throws ServletException if an error occurred
	 * @throws IOException if an error occurred
	 */
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		this.process(request, response);
	}

	/**
	 * The doPost method of the servlet. <br>
	 *
	 * This method is called when a form has its tag value method equals to post.
	 * 
	 * @param request the request send by the client to the server
	 * @param response the response send by the server to the client
	 * @throws ServletException if an error occurred
	 * @throws IOException if an error occurred
	 */
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		this.process(request, response);
	}

	/**
	 * Initialization of the servlet. <br>
	 *
	 * @throws ServletException if an error occurs
	 */
	public void init() throws ServletException {
		this.context = getServletContext();
		this.db = context.getRealPath("/") + this.context.getInitParameter("db");
	}
	
	public void process(HttpServletRequest request, HttpServletResponse response)
	throws ServletException, IOException {
		
		String subject = request.getParameter("subject");
		
		SparqlQueryService service = new SparqlQueryService(this.db);
		
		if(subject == null || subject.equals("")){
			subject = "?sub";
		}
		
		List properties = service.getProperty(subject);
		
		String xml = SPARQL.composeXML(properties);
		try {
			response.setContentType("text/xml");
			response.setCharacterEncoding("UTF-8");
			PrintWriter writer = response.getWriter();
			writer.write(xml);
			writer.flush();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
