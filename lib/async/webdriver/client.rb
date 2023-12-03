# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

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
			
			def session(capabilities, &block)
				start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
				reply = post("session", {capabilities: capabilities})
				
				duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
				Console.debug(self, "Got session #{reply["sessionId"]}", duration: duration)
				
				session = Session.new(@delegate, reply["sessionId"], reply["value"])
				
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
