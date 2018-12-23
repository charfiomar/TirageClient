package com.omar.client.utils;

import java.io.IOException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpResponseException;
import org.apache.http.client.ResponseHandler;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

public class JsonResponseHandler implements ResponseHandler<JsonNode> {

	
	@Override
	public JsonNode handleResponse(HttpResponse response) throws ClientProtocolException, IOException {

		StatusLine status = response.getStatusLine();
		HttpEntity entity = response.getEntity();

		if (status.getStatusCode() >= 300) {
			JsonNode node = new ObjectMapper().readTree(entity.getContent());
			throw new HttpResponseException(status.getStatusCode(), node.get("message").asText());
		}

		if (entity == null) {
			throw new ClientProtocolException("Response contains no content");
		}

		JsonNode node = new ObjectMapper().readTree(entity.getContent());

		((ObjectNode) node).put("jwttoken", response.getLastHeader(HttpHeaders.AUTHORIZATION).getValue());

		return node;
	}

}
