# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2026, by Samuel Williams.

require "base64"

module Async
	module WebDriver
		module Scope
			# Helpers for printing the current page to PDF.
			module Printing
				# Print the current page as a PDF and return the raw binary data.
				#
				# All margin and page measurements are in centimetres. The W3C WebDriver
				# default page size is US Letter (21.59 × 27.94 cm) with 1 cm margins.
				#
				# @parameter orientation [String | Nil] `"portrait"` or `"landscape"`. Default: `"portrait"`.
				# @parameter scale [Float | Nil] Scaling factor between 0.1 and 2.0. Default: `1.0`.
				# @parameter background [Boolean | Nil] Whether to print background graphics and colours. Default: `false`.
				# @parameter page [Hash | Nil] Page dimensions in cm. Keys: `:width`, `:height`.
				# @parameter margin [Hash | Nil] Page margins in cm. Keys: `:top`, `:bottom`, `:left`, `:right`.
				# @parameter page_ranges [Array(String) | Nil] Page ranges to print, e.g. `["1-5", "8"]`. Default: all pages.
				# @parameter shrink_to_fit [Boolean | Nil] Whether to shrink content to fit the page. Default: `true`.
				# @returns [String] The raw PDF binary data.
				def print(orientation: nil, scale: nil, background: nil, page: nil, margin: nil, page_ranges: nil, shrink_to_fit: nil)
					parameters = {
						orientation: orientation,
						scale: scale,
						background: background,
						page: page,
						margin: margin,
						pageRanges: page_ranges,
						shrinkToFit: shrink_to_fit,
					}.compact
					
					# Synchronise with Chrome's rendering pipeline before issuing the print
					# command. The underlying CDP call (Page.printToPDF) is synchronous: if
					# the renderer process has not yet fully initialised its print pipeline
					# by the time the command arrives, Chrome returns JSON-RPC error -32000
					# ("Printing failed") with no retry. A JavaScript round-trip forces
					# ChromeDriver to wait for the renderer to be live (a JS execution
					# context must exist), which also guarantees the print pipeline is ready.
					# Without this, fast-loading pages can trigger the race intermittently.
					session.execute("return document.readyState")
					
					reply = session.post("print", parameters)
					
					return Base64.decode64(reply)
				end
			end
		end
	end
end
