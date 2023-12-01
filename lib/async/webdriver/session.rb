require_relative 'scope'

module Async
	module WebDriver
		class Session
			def initialize(client, session_id)
				@client = client
				@session_id = session_id
			end
			
			def visit(url)
				response = @client.post("/session/#{@session_id}/url", [], JSON.dump({url: url}))
				Console.info(client, response: response.read)
			end
			
			include Scope
			
			def source
				reply = get("source")
				
				return reply["value"]
			end
			
			def execute(script, *arguments)
				reply = post("execute", {script: script, args: arguments})
				
				return reply["value"]
			end
			
			private
			
			def get(path)
				response = @client.get("/session/#{@session_id}/#{path}")
				reply = JSON.parse(response.read)
				
				return reply
			end
			
			def post(path, request)
				response = @client.post("/session/#{@session_id}/#{path}", [], JSON.dump(request))
				reply = JSON.parse(response.read)
				
				return reply
			end
		end
	end
end
