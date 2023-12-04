# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'generic'
require_relative 'process_group'

module Async
	module WebDriver
		module Bridge
			# A bridge to the Chrome browser using `chromedriver`.
			class Chrome < Generic
				# Create a new bridge to Chrome.
				# @parameter path [String] The path to the `chromedriver` executable.
				def initialize(path: "chromedriver")
					super()
					
					@path = path
					@process = nil
				end
				
				# @returns [String] The version of the `chromedriver` executable.
				def version
					::IO.popen([@path, "--version"]) do |io|
						return io.read
					end
				rescue Errno::ENOENT
					return nil
				end
				
				# @returns [Array(String)] The arguments to pass to the `chromedriver` executable.
				def arguments
					[
						"--port=#{self.port}",
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
				
				# The default capabilities for the Chrome browser which need to be provided when requesting a new session.
				# @parameter headless [Boolean] Whether to run the browser in headless mode.
				# @returns [Hash] The default capabilities for the Chrome browser.
				def default_capabilities(headless: true)
					{
						alwaysMatch: {
							browserName: "chrome",
							"goog:chromeOptions": {
								args: [headless ? "--headless" : nil].compact,
							}
						},
					}
				end
			end
		end
	end
end
