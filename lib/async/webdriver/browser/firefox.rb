require_relative 'generic'

module Async
	module WebDriver
		module Browser
			class Firefox < Generic
				def initialize(path: "geckodriver")
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
					@pid ||= ::Process.spawn(@path, *arguments)
					
					super
				end
				
				def close
					super
					
					if @pid
						::Process.kill("TERM", @pid)
						::Process.wait(@pid)
						@pid = nil
					end
				end
			end
		end
	end
end