# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Bridge
			# Represents an instance of a locally running driver (usually with a process group).
			class Driver
				def initialize(**options)
					@options = options
					@count = 0
					@closed = false
				end
				
				def concurrency
					@options.fetch(:concurrency, 128)
				end
				
				attr :count
				
				# @attribute [Hash] The status of the driver after a connection has been established.
				attr :status
				
				def viable?
					!@closed
				end
				
				def closed?
					@closed
				end
				
				def close
					@closed = true
				end
				
				def reusable?
					@options.fetch(:reusable, !@closed)
				end
				
				# Generate a port number for the driver to listen on if it was not specified.
				# @returns [Integer] An ephemeral port number.
				def ephemeral_port
					address = ::Addrinfo.tcp("localhost", 0)
					
					address.bind do |socket|
						# We assume that it's unlikely the port will be reused any time soon...
						return socket.local_address.ip_port
					end
				end
				
				def port
					@port ||= @options.fetch(:port, self.ephemeral_port)
				end
				
				def endpoint
					Async::HTTP::Endpoint.parse("http://localhost", port: self.port)
				end
				
				def client
					Client.open(self.endpoint)
				end
				
				# Start the driver.
				# @parameter retries [Integer] The number of times to retry before giving up.
				def start(retries: 100)
					endpoint = self.endpoint
					
					Console.debug(self, "Waiting for driver to start...", endpoint: endpoint)
					count = 0
					
					Async::HTTP::Client.open(endpoint) do |client|
						begin
							response = client.get("/status")
							@status = JSON.parse(response.read)["value"]
							Console.debug(self, "Successfully connected to driver.", status: @status)
						rescue Errno::ECONNREFUSED
							if count < retries
								count += 1
								sleep(0.01 * count)
								Console.debug(self, "Driver not ready, retrying...")
								retry
							else
								raise
							end
						end
					end
				end
			end
		end
	end
end
