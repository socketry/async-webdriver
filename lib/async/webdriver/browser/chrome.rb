require_relative 'generic'
require_relative 'process_group'

module Async
	module WebDriver
		module Browser
			class Chrome < Generic
				def initialize(path: "chromedriver", headless: true)
					super()
					
					@path = path
					@headless = headless
					@process = nil
				end
				
				attr :pid
				
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
						@headless ? "--headless" : nil,
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
				
				def desired_capabilities
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