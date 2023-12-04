# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			module Alerts
				def dismiss_alert
					session.post("alert/dismiss")
				end
				
				def accept_alert
					session.post("alert/accept")
				end
				
				def alert_text
					session.get("alert/text")
				end
				
				def send_alert_text(text)
					session.post("alert/text", {text: text})
				end
			end
		end
	end
end
