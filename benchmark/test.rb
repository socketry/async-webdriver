#!/usr/bin/env ruby

require 'async'
require 'async/http'

APPLICATION_PORT = 9090
WEB_DRIVER_PORT = 4040


Async do
	with_bound_port do |web_driver_port|
		Console.info("Starting driver process...", web_driver_port:)
		pid = Process.spawn("chromedriver", "--port=#{web_driver_port}", "--headless")
	
		application_endpoint = Async::HTTP::Endpoint.parse("http://localhost:#{APPLICATION_PORT}")
		
		Console.info("Starting application server...")
		Async(transient: true) do
			server = Async::HTTP::Server.for(application_endpoint) do |request|
				Protocol::HTTP::Response[200, {}, ["Hello World"]]
			end
			
			server.run
		end
		
		endpoint = Async::HTTP::Endpoint.parse("http://localhost:#{web_driver_port}")
		client = Async::HTTP::Client.new(endpoint)
		
		begin
			Console.info("Waiting for driver to start...")
			response = client.get("/status")
			status = JSON.parse(response.read)
			Console.info(client, status: status)
		rescue Errno::ECONNREFUSED
			retry
		end
		
		Console.info("Creating session...")
		response = client.post("/session", [], JSON.dump({desiredCapabilities: {browserName: "chrome"}}))
		session = JSON.parse(response.read)
		
		Console.info("Visiting application...")
		response = client.post("/session/#{session['sessionId']}/url", [], JSON.dump({url: "http://localhost:#{APPLICATION_PORT}"}))
		Console.info(client, response: response.read)
		
		Console.info("Fetching body element...")
		response = client.post("/session/#{session['sessionId']}/element", [], JSON.dump({using: "tag name", value: "body"}))
		body = response.read
		
		binding.irb
	ensure
		Process.kill("TERM", pid)
		Process.wait(pid)
	end
end