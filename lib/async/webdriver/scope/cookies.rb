# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			# Helpers for working with cookies.
			module Cookies
				# Get all cookies.
				def cookies
					session.get("cookie")
				end
				
				# Get a cookie by name.
				# @parameter name [String] The name of the cookie.
				def cookie(name)
					session.get("cookie/#{name}")
				end
				
				# Add a cookie.
				# @parameter name [String] The name of the cookie.
				# @parameter value [String] The value of the cookie.
				# @parameter options [Hash] Additional options.
				def add_cookie(name, value, **options)
					session.post("cookie", {name: name, value: value}.merge(options))
				end
				
				# Delete a cookie by name.
				# @parameter name [String] The name of the cookie.
				def delete_cookie(name)
					session.delete("cookie/#{name}")
				end
				
				# Delete all cookies.
				def delete_all_cookies
					session.delete("cookie")
				end
			end
		end
	end
end
