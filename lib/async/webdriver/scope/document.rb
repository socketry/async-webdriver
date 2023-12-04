# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			# Helpers for working with the document.
			module Document
				# Get the current document title.
				# @returns [String] The document title.
				def title
					get("title")
				end
				
				# Get the current document source.
				# @returns [String] The document source.
				def source
					get("source")
				end
				
				# Execute a script in the current document.
				# @parameter script [String] The script to execute.
				# @parameter arguments [Array] The arguments to pass to the script.
				# @returns [Object] The result of the script.
				def execute(script, *arguments)
					post("execute/sync", {script: script, args: arguments})
				end
				
				# Execute a script in the current document asynchronously.
				# @parameter script [String] The script to execute.
				# @parameter arguments [Array] The arguments to pass to the script.
				# @returns [Object] The result of the script.
				def execute_async(script, *arguments)
					post("execute/async", {script: script, args: arguments})
				end
			end
		end
	end
end
