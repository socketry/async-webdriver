require_relative 'bridge/chrome'
require_relative 'bridge/firefox'

module Async
	module WebDriver
		# A bridge is a process that can be used to communicate with a browser.
		# It is not needed in all cases, but is useful when you want to run integration tests without any external drivers/dependencies.
		# As starting a bridge can be slow, it is recommended to use a shared bridge when possible.
		module Bridge
			ALL = [
				Bridge::Chrome,
				Bridge::Firefox,
			]
			
			def self.each(&block)
				return enum_for(:each) unless block_given?
				
				ALL.each do |klass|
					next unless klass.new.supported?
					yield klass
				end
			end
		end
	end
end
