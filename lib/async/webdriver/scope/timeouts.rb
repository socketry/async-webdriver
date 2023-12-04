# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			# Helpers for working with timeouts.
			#
			# If your tests are failing because the page is not loading fast enough, you can increase the page load timeout:
			#
			# ``` ruby
			# session.script_timeout = 1000 # 1 second
			# session.implicit_wait_timeout = 10_000 # 10 seconds
			# session.page_load_timeout = 60_000 # 60 seconds
			# ```
			module Timeouts
				# Get the current timeouts.
				# @returns [Hash] The timeouts.
				def timeouts
					session.get("timeouts")
				end
				
				# The script timeout is the amount of time the driver should wait when executing JavaScript asynchronously.
				# @returns [Integer] The timeout in milliseconds.
				def script_timeout
					timeouts["script"]
				end
				
				# Set the script timeout.
				# @parameter value [Integer] The timeout in milliseconds.
				def script_timeout=(value)
					session.post("timeouts", {script: value})
				end
				
				# The implicit wait timeout is the amount of time the driver should wait when searching for elements.
				# @returns [Integer] The timeout in milliseconds.
				def implicit_wait_timeout
					timeouts["implicit"]
				end
				
				# Set the implicit wait timeout.
				# @parameter value [Integer] The timeout in milliseconds.
				def implicit_wait_timeout=(value)
					session.post("timeouts", {implicit: value})
				end
				
				# The page load timeout is the amount of time the driver should wait when loading a page.
				# @returns [Integer] The timeout in milliseconds.
				def page_load_timeout
					timeouts["pageLoad"]
				end
				
				# Set the page load timeout.
				# @parameter value [Integer] The timeout in milliseconds.
				def page_load_timeout=(value)
					session.post("timeouts", {pageLoad: value})
				end
			end
		end
	end
end
