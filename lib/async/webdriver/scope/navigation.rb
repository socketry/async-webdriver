# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "uri"
require "async/clock"

module Async
	module WebDriver
		module Scope
			# Helpers for navigating the browser.
			#
			# ⚠️ **Important**: Navigation operations (and events that trigger navigation) may result in race conditions if not properly synchronized. Consult the "Navigation Timing" Guide in the documentation for more details.
			module Navigation
				# Navigate to the given URL.
				# @parameter url [String] The URL to navigate to.
				def navigate_to(url)
					session.post("url", {url: url})
				end
				
				alias visit navigate_to
				
				# Get the current URL.
				# @returns [String] The current URL.
				def current_url
					session.get("url")
				end
				
				# Get the path component of the current URL.
				# @returns [String] The current path.
				def current_path
					URI.parse(current_url).path
				end
				
				# Navigate back in the browser history.
				def navigate_back
					session.post("back")
				end
				
				# Navigate forward in the browser history.
				def navigate_forward
					session.post("forward")
				end
				
				# Refresh the current page.
				def refresh
					session.post("refresh")
				end
				
				# Wait for navigation to complete with custom conditions.
				#
				# This method helps avoid race conditions by polling the browser state until your specified conditions are met.
				#
				# @parameter timeout [Float] Maximum time to wait in seconds (default: 10.0).
				# @yields {|current_url| ...} Yields the current URL to the block, when the ready state is "complete".
				# @yields {|current_url, ready_state| ...} Yields both the current URL and ready state to the block, allowing more complex conditions.
				def wait_for_navigation(timeout: 10.0, &block)
					clock = Clock.start
					duration = [timeout / 100.0, 0.005].max
					
					while true
						current_url = session.current_url
						ready_state = session.execute("return document.readyState;")
						
						if block.arity > 1
							break if yield(current_url, ready_state)
						else
							break if ready_state == "complete" && yield(current_url)
						end
						
						if clock.total > timeout
							raise TimeoutError, "Timed out waiting for navigation to complete (current_url: #{current_url}, ready_state: #{ready_state})"
						end
						
						Console.debug(self, "Waiting for navigation...", ready_state: ready_state, location: current_url, elapsed: clock.total)
						sleep(duration)
					end
				end
			end
		end
	end
end
