# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'request_helper'
require_relative 'element'

require_relative 'scope'

module Async
	module WebDriver
		class Session
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
			
			def request_path(path = nil)
				if path
					"/session/#{@id}/#{path}"
				else
					"/session/#{@id}"
				end
			end
			
			include RequestHelper
			
			def close
				if @delegate
					self.delete
					@delegate = nil
				end
			end
			
			def session
				self
			end
			
			def current_scope
				self
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
