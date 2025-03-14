# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "socket"
require "async/http/endpoint"
require "async/http/client"

module Async
	module WebDriver
		module Bridge
			# Generic W3C WebDriver implementation.
			class Generic
				def initialize(**options)
					@options = options
				end
				
				# @returns [String | Nil] The version of the driver.
				def version
					nil
				end
				
				# @returns [Boolean] Is the driver supported/working?
				def supported?
					version != nil
				end
				
				def headless?
					@options.fetch(:headless, true)
				end
			end
		end
	end
end
