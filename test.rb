#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'async/http/server'
require_relative 'lib/async/webdriver'

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
	
	bridge = Async::WebDriver::Bridge.default
	Console.info("Starting driver process...")
	driver = bridge.start
	
	1.times do
		Async::WebDriver::Client.open(driver.endpoint) do |client|
			Console.info("Creating session...")
			client.session(bridge.default_capabilities) do |session|
				binding.irb
			end
		end
	end
ensure
	driver&.close
	server_task&.stop
end
