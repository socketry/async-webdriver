# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			module Frames
				def switch_to_frame(frame)
					session.post("frame", {id: frame})
				end
				
				def switch_to_parent_frame
					session.post("frame/parent")
				end
			end
		end
	end
end
