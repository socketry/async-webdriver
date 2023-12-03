require 'base64'

module Async
	module WebDriver
		module Print
			# Print the current page and return the result as a Base64 encoded string containing a PDF representation of the paginated document.
			def print(page_ranges: nil, total_pages: nil)
				reply = current_scope.post("print", {pageRanges: page_ranges, totalPages: total_pages}.compact)
				
				return Base64.decode64(reply["value"])
			end
		end
	end
end
