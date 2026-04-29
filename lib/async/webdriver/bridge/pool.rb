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
				# Controls pooled drivers and cached sessions.
				class BridgeController
					# Initialize the bridge controller.
					# @parameter bridge [Bridge] The bridge used to create drivers.
					# @parameter capabilities [Hash] Capabilities used for new sessions.
					def initialize(bridge, capabilities: bridge.default_capabilities)
						@bridge = bridge
						@capabilities = capabilities
						@pool = Async::Pool::Controller.new(self)
					end
					
					# Caches sessions created from a single driver instance.
					class SessionCache
						# Initialize a session cache for one driver instance.
						# @parameter driver [Driver] The driver backing cached sessions.
						# @parameter capabilities [Hash] Capabilities for newly created sessions.
						def initialize(driver, capabilities)
							@driver = driver
							@capabilities = capabilities
							
							@client = driver.client
							@sessions = []
						end
						
						# @returns [Boolean] Whether the underlying driver remains usable.
						def viable?
							@driver&.viable?
						end
						
						# @returns [Boolean] Whether cached sessions may be reused.
						def reusable?
							@driver&.reusable?
						end
						
						# Close the cached sessions, driver, and HTTP client.
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
						
						# @returns [Integer] The number of concurrently usable sessions.
						def concurrency
							@driver.concurrency
						end
						
						# Acquire a cached or newly created session payload.
						# @returns [Hash] A WebDriver session payload.
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
						
						# Return a session payload to the cache.
						# @parameter session [Hash] The session payload to cache.
						def release(session)
							@sessions.push(session)
						end
					end
					
					# Constructor for the pool.
					def call
						SessionCache.new(@bridge.start, @capabilities)
					end
					
					# Acquire a session payload from the pool.
					# @returns [Hash] The acquired session payload.
					def acquire
						session_cache = @pool.acquire
						
						return session_cache.acquire
					end
					
					# Return a session payload to the pool.
					# @parameter session [Hash] The session payload to release.
					def release(session)
						session_cache = session[:cache]
						
						session_cache.release(session)
						
						@pool.release(session_cache)
					end
					
					# Retire a session payload and its cache from the pool.
					# @parameter session [Hash] The session payload to retire.
					def retire(session)
						session_cache = session[:cache]
						
						session_cache.release(session)
						
						@pool.retire(session_cache)
					end
					
					# Close the underlying driver pool.
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
				
				# A pooled session wrapper that returns sessions to the cache on close.
				class CachedWrapper < Session
					# @returns [Pool] The pool responsible for reusing this session.
					def pool
						@options[:pool]
					end
					
					# @returns [Hash] The raw session payload returned by the bridge.
					def payload
						@options[:payload]
					end
					
					# Return the session to the pool when possible.
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
				
				# Reset and return a session to the pool.
				# @parameter session [CachedWrapper] The session to reuse.
				# @returns [Boolean] Always returns `true` once the session is released.
				def reuse(session)
					session.reset!
					
					@controller.release(session.payload)
					
					return true
				end
			end
		end
	end
end
