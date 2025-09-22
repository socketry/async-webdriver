# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "base64"

module Async
	module WebDriver
		module Scope
			# Helpers for working with screen capture.
			module ScreenCapture
				# Take a screenshot of the current page or element.
				# @returns [String] The screenshot as a Base64 encoded string.
				def screenshot
					reply = current_scope.get("screenshot")
					
					return Base64.decode64(reply)
				end
			end
		end
	end
end
