# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		# Helpers for working with XPath.
		module XPath
			# Escape a value for use in XPath.
			#
			# XPath 1.0  does not provide any standard mechanism for escaping quotes, so we have to do it ourselves using `concat`.
			#
			# @parameter value [String | Numeric] The value to escape.
			def self.escape(value)
				case value
				when String
					if value.include?("'")
						"concat('#{value.split("'").join("', \"'\", '")}')"
					else
						"'#{value}'"
					end
				else
					value.to_s
				end
			end
		end
	end
end
