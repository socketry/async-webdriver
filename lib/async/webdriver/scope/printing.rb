# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "base64"

module Async
	module WebDriver
		module Scope
			# Helpers for working with printing.
			module Printing
				# Print the current page and return the result as a Base64 encoded string containing a PDF representation of the paginated document.
				def print(page_ranges: nil, total_pages: nil)
					reply = session.post("print", {pageRanges: page_ranges, totalPages: total_pages}.compact)
					
					return Base64.decode64(reply["value"])
				end
			end
		end
	end
end
