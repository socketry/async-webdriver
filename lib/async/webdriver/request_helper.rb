# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'version'
require_relative 'error'

module Async
	module WebDriver
		# Wraps the HTTP client to provide a consistent interface.
		module RequestHelper
			CONTENT_TYPE = "application/json"
			
			GET_HEADERS = [
				["user-agent", "Async::WebDriver/#{VERSION}"],
				["accept", CONTENT_TYPE],
			].freeze
			
			POST_HEADERS = GET_HEADERS + [
				["content-type", "#{CONTENT_TYPE}; charset=UTF-8"],
			].freeze
			
			def request_path(path = nil)
				if path
					"/#{path}"
				else
					"/"
				end
			end
			
			def extract_value(reply)
				Console.debug(self, "Extracting value...", reply: reply)
				value = reply["value"]
				
				if value.is_a?(Hash) and error = value["error"]
					raise ERROR_CODES.fetch(error, Error), value["message"]
				end
				
				if block_given?
					return yield(reply)
				else
					return value
				end
			end
			
			def get(path)
				Console.debug(self, "GET #{request_path(path)}")
				response = @delegate.get(request_path(path), GET_HEADERS)
				reply = JSON.parse(response.read)
				
				return extract_value(reply)
			end
			
			def post(path, arguments = {}, &block)
				Console.debug(self, "POST #{request_path(path)}", arguments:)
				response = @delegate.post(request_path(path), POST_HEADERS, arguments ? JSON.dump(arguments) : nil)
				reply = JSON.parse(response.read)
				
				return extract_value(reply, &block)
			end
			
			def delete(path = nil)
				Console.debug(self, "DELETE #{request_path(path)}")
				response = @delegate.delete(request_path(path), POST_HEADERS)
				reply = JSON.parse(response.read)
				
				return extract_value(reply)
			end
		end
	end
end
