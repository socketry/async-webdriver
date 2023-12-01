module Async
	module WebDriver
		module Browser
			# Generic W3C WebDriver implementation.
			class Generic
				def initialize
					@socket = nil
					@client = nil
				end
				
				# Start the driver.
				def start
				end
				
				# Close the driver and any associated resources.
				def close
					if @socket
						@socket.close
						@socket = nil
					end
					
					if @client
						@client.close
						@client = nil
					end
				end
				
				# @returns [Integer] The port the driver is listening on.
				def port
					unless @socket
						address = Addrinfo.tcp("localhost", 0)
						@socket = address.bind
					end
					
					return @socket.local_address.ip_port
				end
				
				# @returns [Async::HTTP::Endpoint] The endpoint the driver is listening on.
				def endpoint
					Async::HTTP::Endpoint.parse("http://localhost:#{port}")
				end
				
				# @returns [Async::HTTP::Client] The client to use to communicate with the driver.
				def make_client
					start
					
					Async::HTTP::Client.new(endpoint)
				end
				
				# @returns [Async::HTTP::Client] The client to use to communicate with the driver.
				def client
					@client ||= make_client
				end
				
				# @parameter id [String] The session ID.
				# @returns [Async::WebDriver::Session] A new session with the given ID.
				def make_session(id)
					Session.new(client, id)
				end
				
				# Requests a new session from the driver.
				# @returns [Async::WebDriver::Session] A new session.
				def session
					response = client.post("/session", [], JSON.dump({desiredCapabilities: {browserName: "chrome"}}))
					
					message = JSON.parse(response.read)
					
					return make_session(message["sessionId"])
				end
			end
		end
	end
end