# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			# Helpers for working with alerts.
			#
			# ``` ruby
			# session.dismiss_alert
			# session.accept_alert
			# session.alert_text
			# session.set_alert_text("Hello, World!")
			# ```
			module Alerts
				# Dismiss the current alert.
				def dismiss_alert
					session.post("alert/dismiss")
				end
				
				# Accept the current alert.
				def accept_alert
					session.post("alert/accept")
				end
				
				# Get the text of the current alert.
				def alert_text
					session.get("alert/text")
				end
				
				# Set the text input of the current alert.
				def set_alert_text(text)
					session.post("alert/text", {text: text})
				end
			end
		end
	end
end
