require_relative 'generic'

module Async
	module WebDriver
		module Browser
			class Firefox
				def initialize(path: "geckodriver", headless: true)
					@path = path
					@headless = headless
				end
				
				def arguments
					[
						"--port=#{self.port}",
						@headless ? "--headless" : nil,
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