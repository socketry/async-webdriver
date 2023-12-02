# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'generic'
require_relative 'process_group'

module Async
	module WebDriver
		module Bridge
			class Chrome < Generic
				def initialize(path: "chromedriver", headless: true)
					super()
					
					@path = path
					@headless = headless
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
						"--port=#{self.port}",
						@headless ? "--headless=new" : nil,
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
				
				def default_capabilities
					{
						alwaysMatch: {
							browserName: "chrome",
						}
					}
				end
			end
		end
	end
end
