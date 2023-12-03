# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'retrieval'
require_relative 'screen_capture'
require_relative 'fields'

module Async
	module WebDriver
		module Scope
			def current_scope
				self
			end
			
			# These modules are named after the relevant sections in the W3C specification.
			
			include Retrieval
			include ScreenCapture
			include	Fields
		end
	end
end
