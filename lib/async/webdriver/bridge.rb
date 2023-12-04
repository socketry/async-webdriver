# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'bridge/chrome'
require_relative 'bridge/firefox'

require_relative 'error'

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
			
			# The environment variable used to select a bridge.
			#
			# ```
			# ASYNC_WEBDRIVER_BRIDGE=Chrome
			# ASYNC_WEBDRIVER_BRIDGE=Firefox
			# ```
			ASYNC_WEBDRIVER_BRIDGE = 'ASYNC_WEBDRIVER_BRIDGE'
			
			class UnsupportedError < Error
			end
			
			# @returns [Bridge] The default bridge to use.
			def self.default(env = ENV)
				if name = env[ASYNC_WEBDRIVER_BRIDGE]
					self.const_get(name).new
				else
					ALL.each do |klass|
						instance = klass.new
						return instance if instance.supported?
					end
					
					raise UnsupportedError, "No supported bridge found!"
				end
			end
		end
	end
end
