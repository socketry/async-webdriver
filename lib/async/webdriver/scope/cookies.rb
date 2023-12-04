# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			module Cookies
				def cookies
					session.get("cookie")
				end
				
				def cookie(name)
					session.get("cookie/#{name}")
				end
				
				def add_cookie(name, value, **options)
					session.post("cookie", {name: name, value: value}.merge(options))
				end
				
				def delete_cookie(name)
					session.delete("cookie/#{name}")
				end
				
				def delete_all_cookies
					session.delete("cookie")
				end
			end
		end
	end
end
