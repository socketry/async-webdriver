# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			# Helpers for managing the browser window size and position.
			module Window
				# Get the current window rect (position and size).
				# @returns [Hash] The window rect with keys `"x"`, `"y"`, `"width"`, `"height"`.
				def window_rect
					session.get("window/rect")
				end
				
				# Set the window rect (position and/or size).
				# @parameter x [Integer | Nil] The x position of the window.
				# @parameter y [Integer | Nil] The y position of the window.
				# @parameter width [Integer | Nil] The width of the window in CSS pixels.
				# @parameter height [Integer | Nil] The height of the window in CSS pixels.
				def set_window_rect(x: nil, y: nil, width: nil, height: nil)
					session.post("window/rect", {x: x, y: y, width: width, height: height}.compact)
				end
				
				# Resize the browser window to the given dimensions.
				# @parameter width [Integer] The new width in CSS pixels.
				# @parameter height [Integer] The new height in CSS pixels.
				def resize_window(width, height)
					set_window_rect(width: width, height: height)
				end
				
				# Maximize the browser window.
				def maximize_window
					session.post("window/maximize")
				end
				
				# Minimize the browser window.
				def minimize_window
					session.post("window/minimize")
				end
				
				# Make the browser window fullscreen.
				def fullscreen_window
					session.post("window/fullscreen")
				end
			end
		end
	end
end
