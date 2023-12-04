# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Bridge
			# A pool of sessions.
			#
			# ``` ruby
			# begin
			# 	bridge = Async::WebDriver::Bridge::Pool.start(Async::WebDriver::Bridge::Chrome.new)
			# 	session = bridge.session
			# ensure
			# 	bridge&.close
			# end
			# ```
			class Pool
				# Create a new session pool and start it.
				# @parameter bridge [Bridge] The bridge to use to create sessions.
				# @parameter capabilities [Hash] The capabilities to use when creating sessions.
				# @returns [Pool] The pool.
				def self.start(bridge, **options)
					self.new(bridge, **options).tap do |pool|
						pool.start
					end
				end
				
				# Initialize the session pool.
				# @parameter bridge [Bridge] The bridge to use to create sessions.
				# @parameter capabilities [Hash] The capabilities to use when creating sessions.
				# @parameter minimum [Integer] The minimum number of sessions to keep open.
				def initialize(bridge, capabilities: bridge.default_capabilities, minimum: 2)
					@bridge = bridge
					@capabilities = capabilities
					@minimum = minimum
					
					@thread = nil
					
					@waiting = Thread::Queue.new
					@sessions = Thread::Queue.new
				end
				
				# Close the session pool.
				def close
					if @waiting
						@waiting.close
					end
					
					if @thread
						@thread.join
						@thread = nil
					end
					
					if @sessions
						@sessions.close
					end
				end
				
				private def prepare_session(client)
					client.post("session", {capabilities: @capabilities})
				end
				
				# Start the session pool.
				def start
					@thread ||= Thread.new do
						Sync do
							@bridge.start
							
							client = Client.open(@bridge.endpoint)
							
							@minimum.times do
								@waiting << true
							end
							
							while @waiting.pop
								session = prepare_session(client)
								@sessions << session
							end
						ensure
							client&.close
							@bridge.close
						end
					end
				end
				
				# Open a session.
				def session(&block)
					@waiting << true
					
					reply = @sessions.pop
					
					session = Session.open(@bridge.endpoint, reply["sessionId"], reply["capabilities"])
					
					return session unless block_given?
					
					begin
						yield session
						
						# Try to reuse the session for extreme performance:
						reuse(session)
						session = nil
					ensure
						session&.close
					end
				end
				
				def reuse(session)
					session.reset!
					
					@sessions << {"sessionId" => session.id, "capabilities" => session.capabilities}
				end
			end
		end
	end
end
