module Async
	module WebDriver
		module Scope
			module Timeouts
				def timeouts
					session.get("timeouts")
				end
				
				# The script timeout is the amount of time the driver should wait when executing JavaScript asynchronously.
				# @returns [Integer] The timeout in milliseconds.
				def script_timeout
					timeouts["script"]
				end
				
				# @parameter value [Integer] The timeout in milliseconds.
				def script_timeout=(value)
					session.post("timeouts", {script: value})
				end
				
				# The implicit wait timeout is the amount of time the driver should wait when searching for elements.
				# @returns [Integer] The timeout in milliseconds.
				def implicit_wait_timeout
					timeouts["implicit"]
				end
				
				# @parameter value [Integer] The timeout in milliseconds.
				def implicit_wait_timeout=(value)
					session.post("timeouts", {implicit: value})
				end
				
				# The page load timeout is the amount of time the driver should wait when loading a page.
				# @returns [Integer] The timeout in milliseconds.
				def page_load_timeout
					timeouts["pageLoad"]
				end
				
				# @parameter value [Integer] The timeout in milliseconds.
				def page_load_timeout=(value)
					session.post("timeouts", {pageLoad: value})
				end
			end
		end
	end
end
