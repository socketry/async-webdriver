# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Bridge
			class Pool
				def self.start(bridge, **options)
					self.new(bridge, **options).tap do |pool|
						pool.start
					end
				end
				
				def initialize(bridge, capabilities: bridge.default_capabilities, minimum: 2)
					@bridge = bridge
					@capabilities = capabilities
					@minimum = minimum
					
					@thread = nil
					
					@waiting = Thread::Queue.new
					@sessions = Thread::Queue.new
				end
				
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
				
				def prepare_session(client)
					client.post("session", {capabilities: @capabilities})
				end
				
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
				
				def session(&block)
					@waiting << true
					
					reply = @sessions.pop
					
					Session.open(@bridge.endpoint, reply["sessionId"], reply["capabilities"], &block)
				end
			end
		end
	end
end
