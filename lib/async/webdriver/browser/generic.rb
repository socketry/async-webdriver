require 'socket'
require 'async/http/endpoint'
require 'async/http/client'

require_relative '../client_wrapper'
require_relative '../session'

module Async
	module WebDriver
		module Browser
			# Generic W3C WebDriver implementation.
			class Generic
				def initialize(port: nil)
					@port = port
					@client = nil
				end
				
				include ClientWrapper
				
				def version
					nil
				end
				
				def supported?
					version != nil
				end
				
				# Start the driver.
				def start
				end
				
				# Close the driver and any associated resources.
				def close
					if @client
						@client.close
						@client = nil
					end
				end
				
				# @returns [Integer] The port the driver is listening on.
				def port
					unless @port
						address = ::Addrinfo.tcp("localhost", 0)
						address.bind do |socket|
							# We assume that it's unlikely the port will be reused any time soon...
							@port = socket.local_address.ip_port
						end
					end
					
					return @port
				end
				
				# @returns [Async::HTTP::Endpoint] The endpoint the driver is listening on.
				def endpoint
					Async::HTTP::Endpoint.parse("http://localhost:#{port}")
				end
				
				def status
					get("status")
				end
				
				# @returns [Async::HTTP::Client] The client to use to communicate with the driver.
				def make_client
					start
					
					Async::HTTP::Client.new(endpoint).tap do |client|
						begin
							Console.debug("Waiting for driver to start...")
							status = client.get("/status")
							status = JSON.parse(status.read)
							Console.debug(client, status: status)
						rescue Errno::ECONNREFUSED
							retry
						end
					end
				end
				
				# @returns [Async::HTTP::Client] The client to use to communicate with the driver.
				def client
					@client ||= make_client
				end
				
				# @parameter id [String] The session ID.
				# @returns [Async::WebDriver::Session] A new session with the given ID.
				def make_session(id, capabilities)
					Session.new(client, id)
				end
				
				def desired_capabilities
					{}
				end
				
				def extract_session_id(reply)
					reply["value"]["sessionId"]
				end
				
				def extract_capabilities(reply)
					reply["value"]["capabilities"]
				end
				
				# Requests a new session from the driver.
				# @returns [Async::WebDriver::Session] A new session.
				def session(desired_capabilities = self.desired_capabilities)
					post("session", {capabilities: desired_capabilities}) do |reply|
						make_session(extract_session_id(reply), extract_capabilities(reply))
					end
				end
			end
		end
	end
end