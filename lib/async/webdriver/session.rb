# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'request_helper'
require_relative 'element'

require_relative 'scope'

module Async
	module WebDriver
		# A session represents a single browser session, potentially with multiple windows. It is the primary interface for interacting with a browser.
		#
		# ``` ruby
		# begin
		# 	bridge = Async::WebDriver::Bridge::Pool.start(Async::WebDriver::Bridge::Chrome.new)
		# 	session = bridge.session
		# 	session.navigate_to("https://google.com")
		# 	# ...
		# ensure
		# 	bridge&.close
		# end
		# ```
		class Session
			# Open a new session.
			# @parameter endpoint [Async::HTTP::Endpoint] The endpoint to connect to.
			# @yields {|session| ...} The session will be closed automatically if you provide a block.
			# 	@parameter session [Session] The session.
			# @returns [Session] The session if no block is given.
			def self.open(endpoint, *arguments, **options)
				client = self.new(
					Async::HTTP::Client.open(endpoint, **options),
					*arguments
				)
				
				return client unless block_given?
				
				begin
					yield client
				ensure
					client.close
				end
			end
			
			# Initialize the session.
			# @parameter delegate [Protocol::HTTP::Middleware] The underlying HTTP client (or wrapper).
			# @parameter id [String] The session identifier.
			# @parameter capabilities [Hash] The capabilities of the session.
			def initialize(delegate, id, capabilities)
				@delegate = delegate
				@id = id
				@capabilities = capabilities
			end
			
			def inspect
				"\#<#{self.class} id=#{@id.inspect}>"
			end
			
			# @attribute [Protocol::HTTP::Middleware] The underlying HTTP client (or wrapper).
			attr :delegate
			
			# @attribute [String] The session identifier.
			attr :id
			
			# @attribute [Hash] The capabilities of the session.
			attr :capabilities
			
			# The path used for making requests to the web driver bridge.
			# @parameter path [String | Nil] The path to append to the request path.
			# @returns [String] The path used for making requests to the web driver bridge.
			def request_path(path = nil)
				if path
					"/session/#{@id}/#{path}"
				else
					"/session/#{@id}"
				end
			end
			
			include RequestHelper
			
			# Close the session.
			def close
				if @delegate
					self.delete
					@delegate = nil
				end
			end
			
			# @returns [Session] The session.
			def session
				self
			end
			
			# @returns [Session] The current scope.
			def current_scope
				self
			end
			
			# Execute a script in the current document.
			# @parameter script [String] The script to execute.
			# @parameter arguments [Array] The arguments to pass to the script.
			# @returns [Object] The result of the script.
			def execute(script, *arguments)
				post("execute/sync", {script: script, args: arguments})
			end
			
			# Execute a script in the current document asynchronously.
			# @parameter script [String] The script to execute.
			# @parameter arguments [Array] The arguments to pass to the script.
			# @returns [Object] The result of the script.
			def execute_async(script, *arguments)
				post("execute/async", {script: script, args: arguments})
			end
			
			include Scope::Alerts
			include Scope::Cookies
			include Scope::Document
			include Scope::Elements
			include Scope::Fields
			include Scope::Frames
			include Scope::Navigation
			include Scope::Printing
			include Scope::ScreenCapture
			include Scope::Timeouts
		end
	end
end
