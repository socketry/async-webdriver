# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			# Helpers for working with frames.
			module Frames
				# Switch to the given frame.
				#
				# @parameter frame [Element] The frame to switch to.
				# @raises [NoSuchFrameError] If the frame does not exist.
				def switch_to_frame(frame)
					session.post("frame", {id: frame})
				end
				
				# Switch back to the parent frame.
				#
				# You should use this method to switch back to the parent frame after switching to a child frame.
				def switch_to_parent_frame
					session.post("frame/parent")
				end
			end
		end
	end
end
