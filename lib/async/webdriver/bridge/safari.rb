# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require_relative "generic"
require_relative "process_group"

module Async
	module WebDriver
		module Bridge
			# A bridge to the Safari browser using `safaridriver`.
			#
			# ``` ruby
			# begin
			# 	bridge = Async::WebDriver::Bridge::Safari.start
			# 	client = Async::WebDriver::Client.open(bridge.endpoint)
			# ensure
			# 	bridge&.close
			# end
			# ```
			class Safari < Generic
				def path
					@options.fetch(:path, "safaridriver")
				end
				
				# @returns [String] The version of the `safaridriver` executable.
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
					
					# @returns [Array(String)] The arguments to pass to the `safaridriver` executable.
					def arguments(**options)
						[
							options.fetch(:path, "safaridriver"),
							"--port=#{self.port}",
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
				
				# The default capabilities for the Safari browser which need to be provided when requesting a new session.
				# @parameter headless [Boolean] Whether to run the browser in headless mode.
				# @returns [Hash] The default capabilities for the Safari browser.
				def default_capabilities(headless: self.headless?)
					{
						alwaysMatch: {
							browserName: "safari",
						},
					}
				end
			end
		end
	end
end
