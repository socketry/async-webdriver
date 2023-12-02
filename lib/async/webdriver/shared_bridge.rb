require_relative 'bridge/chrome'
require_relative 'bridge/firefox'

module Async
	module WebDriver
		class SharedBridge
			def initialize(bridge)
				@bridge = bridge
				@thread = nil
			end
			
			def start
				@thread ||= Thread.new do
					@bridge.start
				ensure
					@bridge.stop
				end
			end
			
			def stop
				@thread&.kill
				@thread = nil
			end
		end
	end
end
