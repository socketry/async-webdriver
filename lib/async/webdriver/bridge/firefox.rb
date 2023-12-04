# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'generic'
require_relative 'process_group'

module Async
	module WebDriver
		module Bridge
			class Firefox < Generic
				def initialize(path: "geckodriver")
					super()
					
					@path = path
					@process = nil
				end
				
				def version
					::IO.popen([@path, "--version"]) do |io|
						return io.read
					end
				rescue Errno::ENOENT
					return nil
				end
				
				def arguments
					[
						"--port", self.port.to_s,
					].compact
				end
				
				def start
					@process ||= ProcessGroup.spawn(@path, *arguments)
					
					super
				end
				
				def close
					super
					
					if @process
						@process.close
						@process = nil
					end
				end
				
				def default_capabilities(headless: true)
					{
						alwaysMatch: {
							browserName: "firefox",
							"moz:firefoxOptions": {
								"args": [headless ? "-headless" : nil].compact,
							}
						}
					}
				end
			end
		end
	end
end
