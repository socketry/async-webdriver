#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "async"
require "async/http"
require "selenium/webdriver"

APPLICATION_PORT = 9090
WEB_DRIVER_PORT = 4040

Async do
	application_endpoint = Async::HTTP::Endpoint.parse("http://localhost:#{APPLICATION_PORT}")
	Console.info("Starting application server...")
	Async(transient: true) do
		server = Async::HTTP::Server.for(application_endpoint) do |request|
			Protocol::HTTP::Response[200, {}, ["Hello World"]]
		end
		
		server.run
	end
	
	8.times do
		Console.info("Starting driver process...")
		web_driver = Selenium::WebDriver.for(:chrome)
		8.times do
			Console.info("Visiting application...")
			web_driver.navigate.to("http://localhost:#{APPLICATION_PORT}")
		end
	ensure
		web_driver.quit
	end
end
