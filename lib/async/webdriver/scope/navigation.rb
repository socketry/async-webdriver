require 'uri'

module Async
	module WebDriver
		module Scope
			module Navigation
				def navigate_to(url)
					session.post("url", {url: url})
				end
				
				alias visit navigate_to
				
				def current_url
					session.get("url")
				end
				
				def current_path
					URI.parse(current_url).path
				end
				
				def navigate_back
					session.post("back")
				end
				
				def navigate_forward
					session.post("forward")
				end
				
				def refresh
					session.post("refresh")
				end
			end
		end
	end
end
