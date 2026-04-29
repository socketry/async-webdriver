# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2026, by Samuel Williams.

module Async
	module WebDriver
		module Bridge
			# Represents an instance of a locally running driver (usually with a process group).
			class Driver
				# Initialize a driver wrapper.
				# @parameter options [Hash] Driver configuration options.
				def initialize(**options)
					@options = options
					@count = 0
					@closed = false
				end
				
				# @returns [Integer] The number of concurrent sessions the driver can sustain.
				def concurrency
					@options.fetch(:concurrency, 128)
				end
				
				attr :count
				
				# @attribute [Hash] The status of the driver after a connection has been established.
				attr :status
				
				# @returns [Boolean] Whether the driver can still be used.
				def viable?
					!@closed
				end
				
				# @returns [Boolean] Whether the driver has been closed.
				def closed?
					@closed
				end
				
				# Mark the driver as closed.
				def close
					@closed = true
				end
				
				# @returns [Boolean] Whether the driver may be returned to a pool.
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
				
				# @returns [Integer] The port the driver listens on.
				def port
					@port ||= @options.fetch(:port, self.ephemeral_port)
				end
				
				# @returns [Async::HTTP::Endpoint] The HTTP endpoint exposed by the driver.
				def endpoint
					Async::HTTP::Endpoint.parse("http://localhost", port: self.port)
				end
				
				# @returns [Client] A client connected to the driver endpoint.
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
