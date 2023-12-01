#!/usr/bin/env ruby

require 'async/http/server'
require_relative 'lib/async/webdriver'

APPLICATION_PORT = 9090

Async do
	browser = Async::WebDriver::Browser::Chrome.new
	
	Console.info("Starting driver process...")
	browser.start
	
	application_endpoint = Async::HTTP::Endpoint.parse("http://localhost:#{APPLICATION_PORT}")
	
	Console.info("Starting application server...")
	Async(transient: true) do
		server = Async::HTTP::Server.for(application_endpoint) do |request|
			Protocol::HTTP::Response[200, {}, ["Hello World"]]
		end
		
		server.run
	end
	
	session = browser.session
	
	Console.info("Visiting application...")
	reply = session.visit("http://localhost:#{APPLICATION_PORT}")
	Console.info("Reply", reply)
	
	binding.irb
ensure
	browser&.close
end
