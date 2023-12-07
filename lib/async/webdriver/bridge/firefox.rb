# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'generic'
require_relative 'process_group'

module Async
	module WebDriver
		module Bridge
			# A bridge to the Firefox browser using `geckodriver`.
			#
			# ``` ruby
			# begin
			# 	bridge = Async::WebDriver::Bridge::Firefox.start
			# 	client = Async::WebDriver::Client.open(bridge.endpoint)
			# ensure
			# 	bridge&.close
			# end
			class Firefox < Generic
				def path
					@options.fetch(:path, "geckodriver")
				end
				
				# @returns [String] The version of the `geckodriver` executable.
				def version
					::IO.popen([self.path, "--version"]) do |io|
						return io.read
					end
				rescue Errno::ENOENT
					return nil
				end
				
				class Driver < Bridge::Driver
					def initialize(**options)
						super(**options)
						@process_group = nil
					end
					
					def concurrency
						1
					end
					
					# @returns [Array(String)] The arguments to pass to the `chromedriver` executable.
					def arguments(**options)
						[
							options.fetch(:path, "geckodriver")
							"--port", self.port.to_s,
						].compact
					end
					
					def start
						@process_group = ProcessGroup.spawn(*arguments(**@options))
						
						super
					end
					
					def close
						if @process_group
							@process_group.close
							@process_group = nil
						end
						
						super
					end
				end
				
				# Start the driver.
				def start(**options)
					Driver.new(**options).tap(&:start)
				end
				
				# The default capabilities for the Firefox browser which need to be provided when requesting a new session.
				# @parameter headless [Boolean] Whether to run the browser in headless mode.
				# @returns [Hash] The default capabilities for the Firefox browser.
				def default_capabilities(headless: true)
					{
						alwaysMatch: {
							browserName: "firefox",
							"moz:firefoxOptions": {
								args: [headless ? "-headless" : nil].compact,
							}
						}
					}
				end
			end
		end
	end
end
