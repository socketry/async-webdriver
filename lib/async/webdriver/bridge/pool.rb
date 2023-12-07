# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'async/actor'
require 'async/pool'

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
				class BridgeController
					def initialize(bridge, capabilities: bridge.default_capabilities)
						@driver = bridge.start
						@client = Client.open(driver.endpoint)
						@capabilities = capabilities
					end
					
					def concurrency
						@driver.concurrency || 8
					end
					
					# Allocate a new session.
					def call
						client.post("session", {capabilities: @capabilities})
					end
				end
				
				# Create a new session pool and start it.
				# @parameter bridge [Bridge] The bridge to use to create sessions.
				# @parameter capabilities [Hash] The capabilities to use when creating sessions.
				# @returns [Pool] The pool.
				def self.start(bridge, **options)
					self.new(bridge, **options)
				end
				
				# Initialize the session pool.
				# @parameter bridge [Bridge] The bridge to use to create sessions.
				# @parameter capabilities [Hash] The capabilities to use when creating sessions.
				# @parameter initial [Integer] The initial number of sessions to keep open.
				def initialize(bridge, **options)
					@bridge = bridge
					@controller = Async::Actor.new(BridgeController.new(bridge, **options))
				end
				
				# Close the session pool.
				def close
					@controller.close
				end
				
				class ReusableSession < Session
					def initialize(pool, driver, ...)
						super(...)
						
						@pool = pool
						@driver = driver
					end
					
					def close
						unless @pool.reuse(self, @driver)
							super
						end
					end
				end
				
				# Open a session.
				def session(&block)
					@controller.acquire do |driver|
						driver.session
					end
					
					session = ReusableSession.open(@bridge.endpoint, reply["sessionId"], reply["capabilities"])
					
					return session unless block_given?
					
					begin
						yield session
					ensure
						session&.close
					end
				end
				
				def reuse(session)
					session.reset!
					
					@controller.
					
					@sessions << {"sessionId" => session.id, "capabilities" => session.capabilities}
					
					return true
				end
			end
		end
	end
end
