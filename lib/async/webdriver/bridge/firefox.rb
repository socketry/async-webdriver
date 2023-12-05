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
				# Create a new bridge to Firefox.
				# @parameter path [String] The path to the `geckodriver` executable.
				def initialize(path: "geckodriver")
					super()
					
					@path = path
					@process = nil
				end
				
				# @returns [String] The version of the `geckodriver` executable.
				def version
					::IO.popen([@path, "--version"]) do |io|
						return io.read
					end
				rescue Errno::ENOENT
					return nil
				end
				
				# Limited concurrency.
				def concurrency
					1
				end
				
				# @returns [Array(String)] The arguments to pass to the `geckodriver` executable.
				def arguments
					[
						"--port", self.port.to_s,
					].compact
				end
				
				# Start the driver.
				def start
					@process ||= ProcessGroup.spawn(@path, *arguments)
					
					super
				end
				
				# Close the driver.
				def close
					super
					
					if @process
						@process.close
						@process = nil
					end
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
