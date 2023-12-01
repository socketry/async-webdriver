require_relative 'generic'
require_relative 'process_group'

module Async
	module WebDriver
		module Browser
			class Firefox < Generic
				def initialize(path: "geckodriver")
					super()
					
					@path = path
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
				
				def desired_capabilities
					{
						alwaysMatch: {
							browserName: "firefox",
						}
					}
				end
			end
		end
	end
end