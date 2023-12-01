require_relative 'scope'
require_relative 'client_wrapper'

module Async
	module WebDriver
		class Session
			include ClientWrapper
			include Scope
			
			def initialize(client, id)
				@client = client
				@id = id
			end
			
			attr :client
			attr :id
			
			def session
				self
			end
			
			def full_path(path)
				"/session/#{@id}/#{path}"
			end
			
			def close
				if @client
					@client.delete("/session/#{@id}")
					@client = nil
				end
				
				@id = nil
			end
			
			def title
				reply = get("title")
				
				return reply["value"]
			end
			
			private def timeouts
				get("timeouts")
			end
			
			# The script timeout is the amount of time the driver should wait when executing JavaScript asynchronously.
			# @returns [Integer] The timeout in milliseconds.
			def script_timeout
				timeouts["script"]
			end
			
			# @parameter value [Integer] The timeout in milliseconds.
			def script_timeout=(value)
				post("timeouts", {type: "script", ms: value})
			end
			
			# The implicit wait timeout is the amount of time the driver should wait when searching for elements.
			# @returns [Integer] The timeout in milliseconds.
			def implicit_wait_timeout
				timeouts["implicit"]
			end
			
			# @parameter value [Integer] The timeout in milliseconds.
			def implicit_wait_timeout=(value)
				post("timeouts", {type: "implicit", ms: value})
			end
			
			# The page load timeout is the amount of time the driver should wait when loading a page.
			# @returns [Integer] The timeout in milliseconds.
			def page_load_timeout
				timeouts["pageLoad"]
			end
			
			# @parameter value [Integer] The timeout in milliseconds.
			def page_load_timeout=(value)
				post("timeouts", {type: "page load", ms: value})
			end
			
			# Navigates to the given URL.
			# @parameter url [String] The URL to navigate to.
			def visit(url)
				post("url", {url: url})
			end
			
			def current_url
				get("url")
			end
			
			def back
				post("back")
			end
			
			def forward
				post("forward")
			end
			
			def source
				get("source")
			end
			
			def execute(script, *arguments)
				post("execute", {script: script, args: arguments})
			end
		end
	end
end
