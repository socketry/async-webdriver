#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "async/http/server"
require_relative "../lib/async/webdriver"

APPLICATION_PORT = 9090

Async do
	Console.info("Starting application server...")
	application_endpoint = Async::HTTP::Endpoint.parse("http://localhost:#{APPLICATION_PORT}")
	server_task = Async(transient: true) do
		server = Async::HTTP::Server.for(application_endpoint) do |request|
			Protocol::HTTP::Response[200, {}, ["Hello World"]]
		end
		
		server.run
	end
	
	bridge = Async::WebDriver::Bridge::Chrome.new
	pool = Async::WebDriver::Bridge::Pool.new(bridge)
	
	8.times do
		pool.session do |session|
			8.times do
				Console.info("Visiting application...")
				reply = session.visit("http://localhost:#{APPLICATION_PORT}")
			end
		end
	end
ensure
	pool&.close
	server_task&.stop
end
