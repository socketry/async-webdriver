# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "async/actor"
require "async/pool"

require_relative "../session"

module Async
	module WebDriver
		module Bridge
			# A pool of sessions, constructed from a bridge, which instantiates drivers as needed. Drivers are capable of supporting 1 ore more sessions.
			#
			# ``` ruby
			# begin
			# 	bridge = Async::WebDriver::Bridge::Pool.new(Async::WebDriver::Bridge::Chrome.new)
			# 	session = bridge.session
			#   # ...
			#   session.close
			# ensure
			# 	bridge&.close
			# end
			# ```
			class Pool
				class BridgeController
					def initialize(bridge, capabilities: bridge.default_capabilities)
						@bridge = bridge
						@capabilities = capabilities
						@pool = Async::Pool::Controller.new(self)
					end
					
					class SessionCache
						def initialize(driver, capabilities)
							@driver = driver
							@capabilities = capabilities
							
							@client = driver.client
							@sessions = []
						end
						
						def viable?
							@driver&.viable?
						end
						
						def reusable?
							@driver&.reusable?
						end
						
						def close
							if @driver
								@driver.close
								@driver = nil
							end
							
							if @client
								@client.close
								@client = nil
							end
							
							if @sessions
								@sessions = nil
							end
						end
						
						def concurrency
							@driver.concurrency
						end
						
						def acquire
							if @sessions.empty?
								session = @client.post("session", {capabilities: @capabilities})
								
								if session.nil?
									raise Async::WebDriver::Error, "Failed to create session with capabilities: #{@capabilities.inspect}"
								end
								
								session[:cache] = self
								session[:endpoint] = @driver.endpoint
								
								return session
							else
								return @sessions.pop
							end
						end
						
						def release(session)
							@sessions.push(session)
						end
					end
					
					# Constructor for the pool.
					def call
						SessionCache.new(@bridge.start, @capabilities)
					end
					
					def acquire
						session_cache = @pool.acquire
						
						return session_cache.acquire
					end
					
					def release(session)
						session_cache = session[:cache]
						
						session_cache.release(session)
						
						@pool.release(session_cache)
					end
					
					def retire(session)
						session_cache = session[:cache]
						
						session_cache.release(session)
						
						@pool.retire(session_cache)
					end
					
					def close
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
