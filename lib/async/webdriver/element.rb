require_relative 'scope'
require_relative 'request_helper'

module Async
	module WebDriver
		class Element
			include Scope
			include RequestHelper
			
			def initialize(session, id)
				@session = session
				@delegate = session.delegate
				@id = id
			end
			
			attr :session
			attr :delegate
			attr :id
			
			def full_path(path = nil)
				if path
					"/session/#{@session.id}/element/#{@id}/#{path}"
				else
					"/session/#{@session}/element/#{@id}"
				end
			end
			
			def selected?
				get("selected")
			end
			
			def enabled?
				get("enabled")
			end
		end
	end
end
