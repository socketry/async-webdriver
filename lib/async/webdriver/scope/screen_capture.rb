require 'base64'

module Async
	module WebDriver
		module Scope
			module ScreenCapture
				def screenshot
					reply = current_scope.post("screenshot")
					
					return Base64.decode64(reply["value"])
				end
			end
		end
	end
end
