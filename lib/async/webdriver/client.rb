# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require_relative "request_helper"
require_relative "session"

module Async
	module WebDriver
		# A client for the WebDriver protocol.
		#
		# If you have a running web driver server, you can connect to it like so (assuming it is running on port 4444):
		#
		# ``` ruby
		# begin
		# 	client = Async::WebDriver::Client.open(Async::HTTP::Endpoint.parse("http://localhost:4444"))
		# 	session = client.session
		# ensure
		# 	client&.close
		# end
		# ```
		class Client
			include RequestHelper
			
			# Open a new session.
			# @parameter endpoint [Async::HTTP::Endpoint] The endpoint to connect to.
			# @yields {|client| ...} The client will be closed automatically if you provide a block.
			# 	@parameter client [Client] The client.
			# @returns [Client] The client if no block is given.
			def self.open(endpoint, **options)
				client = self.new(
					Async::HTTP::Client.open(endpoint, **options)
				)
				
				return client unless block_given?
				
				begin
					yield client
				ensure
					client.close
				end
			end
			
			# Initialize the client.
			# @parameter delegate [Protocol::HTTP::Middleware] The underlying HTTP client (or wrapper).
			def initialize(delegate)
				@delegate = delegate
			end
			
			# Close the client.
			def close
				@delegate.close
			end
			
			# Request a new session.
			# @returns [Session] The session if no block is given.
			# @yields {|session| ...} The session will be closed automatically if you provide a block.
			# 	@parameter session [Session] The session.
			def session(capabilities, &block)
				reply = post("session", {capabilities: capabilities})
				
				session = Session.new(@delegate, reply["sessionId"], reply["capabilities"])
				
				return session unless block_given?
				
				begin
					yield session
				ensure
					session.close
				end
			end
		end
	end
end
