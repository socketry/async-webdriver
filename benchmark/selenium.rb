#!/usr/bin/env ruby

require 'async'
require 'async/http'
require 'selenium/webdriver'

APPLICATION_PORT = 9090
WEB_DRIVER_PORT = 4040

Async do
	Console.info("Starting driver process...")
	web_driver = Selenium::WebDriver.for(:chrome)
	
	application_endpoint = Async::HTTP::Endpoint.parse("http://localhost:#{APPLICATION_PORT}")
	
	Console.info("Starting application server...")
	Async(transient: true) do
		server = Async::HTTP::Server.for(application_endpoint) do |request|
			Protocol::HTTP::Response[200, {}, ["Hello World"]]
		end
		
		server.run
	end
	
	Console.info("Visiting application...")
	web_driver.navigate.to("http://localhost:#{APPLICATION_PORT}")
	
	Console.info("Fetching body element...")
	body = web_driver.find_element(tag_name: "body")
	
	binding.irb
ensure
	Process.kill("TERM", pid)
	Process.wait(pid)
end