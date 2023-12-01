require_relative 'browser/chrome'
require_relative 'browser/firefox'

module Async
	module WebDriver
		module Browser
			ALL = [
				Browser::Chrome,
				Browser::Firefox,
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
