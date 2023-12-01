require_relative 'scope'

module Async
	module WebDriver
		class Session
			def initialize(client, session_id)
				@client = client
				@session_id = session_id
			end
			
			def close
				if @client
					@client.delete("/session/#{@session_id}")
					@client = nil
				end
				
				@session_id = nil
			end
			
			def capabilities
				reply = get("capabilities")
				
				return reply["value"]
			end
			
			def title
				reply = get("title")
				
				return reply["value"]
			end
			
			private def timeouts
				reply = get("timeouts")
				
				return reply["timeouts"]
			end
			
			def script_timeout
				timeouts["script"]
			end
			
			def script_timeout=(value)
				post("timeouts", {type: "script", ms: value})
			end
			
			def implicit_wait_timeout
				timeouts["implicit"]
			end
			
			def implicit_wait_timeout=(value)
				post("timeouts", {type: "implicit", ms: value})
			end
			
			def page_load_timeout
				timeouts["pageLoad"]
			end
			
			def page_load_timeout=(value)
				post("timeouts", {type: "page load", ms: value})
			end
			
			def visit(url)
				response = @client.post("/session/#{@session_id}/url", [], JSON.dump({url: url}))
				Console.info(client, response: response.read)
			end
			
			def current_url
				reply = get("url")
				
				return reply["value"]
			end
			
			def back
				post("back")
			end
			
			def forward
				post("forward")
			end
			
			def source
				reply = get("source")
				
				return reply["value"]
			end
			
			def execute(script, *arguments)
				reply = post("execute", {script: script, args: arguments})
				
				return reply["value"]
			end
			
			include Scope
			
			private
			
			def get(path)
				response = @client.get("/session/#{@session_id}/#{path}")
				reply = JSON.parse(response.read)
				
				return reply
			end
			
			def post(path, request = nil)
				response = @client.post("/session/#{@session_id}/#{path}", [], request ? JSON.dump(request) : nil)
				reply = JSON.parse(response.read)
				
				return reply
			end
		end
	end
end
