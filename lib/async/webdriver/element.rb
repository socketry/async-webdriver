require_relative 'scope'

module Async
	module WebDriver
		class Element
			def initialize(client, element_id)
				@client = client
				@element_id = element_id
			end
			
			include Scope
			
			def selected?
				reply = get("selected")
				
				return reply["value"]
			end
			
			def enabled?
				reply = get("enabled")
				
				return reply["value"]
			end
			
			
			
			private
			
			def post(path, request)
				response = @client.post("/session/#{@session_id}/element/#{@element_id}/#{path}", [], JSON.dump(request))
				reply = JSON.parse(response.read)
				
				return reply
			end
			
			def get(path)
				response = @client.get("/session/#{@session_id}/element/#{@element_id}/#{path}")
				reply = JSON.parse(response.read)
				
				return reply
			end
		end
	end
end
