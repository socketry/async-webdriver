require_relative 'scope'
require_relative 'client_wrapper'

module Async
	module WebDriver
		class Element
			include Scope
			include ClientWrapper
			
			def initialize(session, id)
				@session = session
				@client = session.client
				@id = id
			end
			
			attr :session
			attr :client
			attr :id
			
			def full_path(path)
				"/session/#{@session.id}/element/#{@id}/#{path}"
			end
			
			def selected?
				reply = get("selected")
				
				return reply["value"]
			end
			
			def enabled?
				reply = get("enabled")
				
				return reply["value"]
			end
		end
	end
end
