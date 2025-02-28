# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "uri"

module Async
	module WebDriver
		module Scope
			# Helpers for navigating the browser.
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
			end
		end
	end
end
