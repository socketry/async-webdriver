# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'scope'
require_relative 'request_helper'

module Async
	module WebDriver
		class Session
			include RequestHelper
			include Scope
			
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
			
			attr :id
			attr :capabilities
			
			def session
				self
			end
			
			def full_path(path = nil)
				if path
					"/session/#{@id}/#{path}"
				else
					"/session/#{@id}"
				end
			end
			
			def close
				if @delegate
					self.delete
				end
				
				@id = nil
			end
			
			def title
				reply = get("title")
				
				return reply["value"]
			end
			
			def timeouts
				get("timeouts")
			end
			
			# The script timeout is the amount of time the driver should wait when executing JavaScript asynchronously.
			# @returns [Integer] The timeout in milliseconds.
			def script_timeout
				timeouts["script"]
			end
			
			# @parameter value [Integer] The timeout in milliseconds.
			def script_timeout=(value)
				post("timeouts", {script: value})
			end
			
			# The implicit wait timeout is the amount of time the driver should wait when searching for elements.
			# @returns [Integer] The timeout in milliseconds.
			def implicit_wait_timeout
				timeouts["implicit"]
			end
			
			# @parameter value [Integer] The timeout in milliseconds.
			def implicit_wait_timeout=(value)
				post("timeouts", {implicit: value})
			end
			
			# The page load timeout is the amount of time the driver should wait when loading a page.
			# @returns [Integer] The timeout in milliseconds.
			def page_load_timeout
				timeouts["pageLoad"]
			end
			
			# @parameter value [Integer] The timeout in milliseconds.
			def page_load_timeout=(value)
				post("timeouts", {pageLoad: value})
			end
			
			# Navigates to the given URL.
			# @parameter url [String] The URL to navigate to.
			def visit(url)
				post("url", {url: url})
			end
			
			def current_url
				get("url")
			end
			
			def back
				post("back")
			end
			
			def forward
				post("forward")
			end
			
			def source
				get("source")
			end
			
			def execute(script, *arguments)
				post("execute", {script: script, args: arguments})
			end
			
			def execute_async(script, *arguments)
				post("execute_async", {script: script, args: arguments})
			end
		end
	end
end
