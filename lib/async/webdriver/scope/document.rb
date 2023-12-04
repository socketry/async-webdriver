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
				def document_title
					session.get("title")
				end
				
				# Get the current document source.
				# @returns [String] The document source.
				def document_source
					session.get("source")
				end
			end
		end
	end
end
