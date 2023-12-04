# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			module Document
				def title
					get("title")
				end
				
				def source
					get("source")
				end
				
				def execute(script, *arguments)
					post("execute/sync", {script: script, args: arguments})
				end
				
				def execute_async(script, *arguments)
					post("execute/async", {script: script, args: arguments})
				end
			end
		end
	end
end
