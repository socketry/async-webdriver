require_relative 'request_helper'
require_relative 'session'

module Async
	module WebDriver
		class Client
			include RequestHelper
			
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
			
			def initialize(delegate)
				@delegate = delegate
			end
			
			def close
				@delegate.close
			end
			
			# @parameter id [String] The session ID.
			# @returns [Async::WebDriver::Session] A new session with the given ID.
			def make_session(id, capabilities)
				Session.new(@delegate, id, capabilities)
			end
			
			def session(capabilities)
				reply = post("session", {capabilities: capabilities})
				
				session = make_session(reply["sessionId"], reply["capabilities"])
				
				return session unless block_given?
				
				begin
					yield session
				ensure
					session.close
				end
			end
			
			def desired_capabilities
				{}
			end
		end
	end
end
