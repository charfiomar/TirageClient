package com.omar.client.controllers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.http.Header;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.HttpResponseException;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.client.methods.RequestBuilder;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.message.BasicHeader;
import org.picketbox.util.StringUtil;

import com.fasterxml.jackson.databind.JsonNode;
import com.omar.client.utils.JsonResponseHandler;

@WebServlet("/Authentication")
public class AuthenticationController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private static final String AUTHENTICATION_URL = "http://localhost:8080/TirageService/api/users/login";
	private static HttpClient client;

	static {

		List<Header> defaultHeaders = new ArrayList<>();
		defaultHeaders.add(new BasicHeader(HttpHeaders.CONTENT_TYPE, "application/x-www-form-urlencoded"));

		client = HttpClientBuilder.create().setDefaultHeaders(defaultHeaders).build();
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String username = request.getParameter("username");
		String password = request.getParameter("password");

		if (StringUtil.isNullOrEmpty(username) || StringUtil.isNullOrEmpty(password)) {
			response.sendRedirect("index.jsp");
			return;
		}

		HttpUriRequest authenticationRequest = RequestBuilder.post(AUTHENTICATION_URL).addParameter("login", username)
				.addParameter("password", password).build();

		HttpResponse authenticationResponse = client.execute(authenticationRequest);

		JsonNode authenticationJsonResponse = null;

		ResponseHandler<JsonNode> responseHandler = new JsonResponseHandler();
		try {

			authenticationJsonResponse = responseHandler.handleResponse(authenticationResponse);

		} catch (HttpResponseException e) {
			request.getSession().setAttribute("err", e.getLocalizedMessage());
			response.sendRedirect("index.jsp");
			return;
		}

		if (request.getSession().getAttribute("err") != null) {
			request.getSession().removeAttribute("err");
		}

		boolean isAgent = authenticationJsonResponse.get("isAgent").asBoolean();
		Long id = authenticationJsonResponse.get("id").asLong();
		String token = authenticationJsonResponse.get("jwttoken").asText();

		request.getSession().setAttribute("isAgent", isAgent);
		request.getSession().setAttribute("id", id);
		request.getSession().setAttribute("token", token);

		if (isAgent) {
			response.sendRedirect("agent.jsp");
			return;
		} else {
			response.sendRedirect("enseignant.jsp");
			return;
		}
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		request.getSession().removeAttribute("isAgent");
		request.getSession().removeAttribute("id");
		request.getSession().removeAttribute("token");
		
		response.sendRedirect("index.jsp");
	}
}
