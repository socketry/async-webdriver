# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'async/actor'
require 'async/pool'

require_relative '../session'

module Async
	module WebDriver
		module Bridge
			# A pool of sessions, constructed from a bridge, which instantiates drivers as needed. Drivers are capable of supporting 1 ore more sessions.
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
				class BridgeController
					def initialize(bridge, capabilities: bridge.default_capabilities)
						@bridge = bridge
						@capabilities = capabilities
						@pool = Async::Pool::Controller.new(@bridge.method(:start))
						
						# This is a buffer of sessions that have been released but not yet reused.
						@sessions = []
					end
					
					def acquire
						if @sessions.empty?
							driver = @pool.acquire
							client = driver.client
							
							session = client.post("session", {capabilities: @capabilities})
							
							# This is not thread safe and is just an opaque token for later releasing the session.
							session[:driver] = driver
							session[:endpoint] = driver.endpoint
							
							return session
						else
							return @sessions.pop
						end
					end
					
					def release(session)
						@sessions.push(session)
					end
					
					def retire(session)
						@pool.retire(session[:driver])
					end
					
					def close
						if @sessions
							@sessions.each do |session|
								retire(session)
							end
							@sessions = nil
						end
						
						if @pool
							@pool.close
							@pool = nil
						end
					end
				end
				
				# Initialize the session pool.
				# @parameter bridge [Bridge] The bridge to use to create sessions.
				def initialize(...)
					@controller = Async::Actor.new(BridgeController.new(...))
				end
				
				# Close the session pool.
				def close
					@controller.close
				end
				
				class CachedWrapper < Session
					def pool
						@options[:pool]
					end
					
					def payload
						@options[:payload]
					end
					
					def close
						unless self.pool.reuse(self)
							super
						end
					end
				end
				
				# Open a session.
				def session(&block)
					payload = @controller.acquire
					
					session = CachedWrapper.open(payload[:endpoint], payload["sessionId"], payload["capabilities"], pool: self, payload: payload)
					
					return session unless block_given?
					
					begin
						yield session
					ensure
						session&.close
					end
				end
				
				def reuse(session)
					session.reset!
					
					@controller.release(session.payload)
					
					return true
				end
			end
		end
	end
end
