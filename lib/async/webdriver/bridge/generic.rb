# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'socket'
require 'async/http/endpoint'
require 'async/http/client'

module Async
	module WebDriver
		module Bridge
			# Generic W3C WebDriver implementation.
			class Generic
				def self.start(**options)
					self.new(**options).tap do |bridge|
						bridge.start
					end
				end
				
				def initialize(port: nil)
					@port = port
					@status = nil
				end
				
				attr :status
				
				def version
					nil
				end
				
				def supported?
					version != nil
				end
				
				# Start the driver.
				def start(retries: 100)
					Console.info(self, "Waiting for driver to start...")
					count = 0
					
					Async::HTTP::Client.open(endpoint) do |client|
						begin
							response = client.get("/status")
							@status = JSON.parse(response.read)["value"]
							Console.info(self, "Successfully connected to driver.", status: @status)
						rescue Errno::ECONNREFUSED
							if count < retries
								count += 1
								sleep(0.001 * count)
								Console.info(self, "Driver not ready, retrying...")
								retry
							end
						end
					end
				end
				
				# Close the driver and any associated resources.
				def close
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
			end
		end
	end
end
