# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Bridge
			class Pool
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
								Console.info(self, "Pooled session #{session["sessionId"]}")
								@sessions << session
							end
						ensure
							Console.info(self, "Exiting pool thread...")
							client&.close
							@bridge.close
						end
					end
				end
				
				def session(&block)
					start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
					@waiting << true
					
					reply = @sessions.pop
					
					duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
					Console.debug(self, "Got session #{reply["sessionId"]}", duration:)
					Session.open(@bridge.endpoint, reply["sessionId"], reply["capabilities"], &block)
				end
			end
		end
	end
end
