# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'version'
require_relative 'error'

module Async
	module WebDriver
		# Wraps the HTTP client to provide a consistent interface.
		module RequestHelper
			# The web element identifier is the string constant "element-6066-11e4-a52e-4f735466cecf".
			ELEMENT_KEY = "element-6066-11e4-a52e-4f735466cecf"
			
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
			
			def unwrap_object(value)
				if value.is_a?(Hash) and value.key?(ELEMENT_KEY)
					Element.new(self.session, value[ELEMENT_KEY])
				else
					value
				end
			end
			
			def unwrap_objects(value)
				case value
				when Hash
					value.transform_values!(&method(:unwrap_object))
				when Array
					value.map!(&method(:unwrap_object))
				end
			end
			
			def extract_value(reply)
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
				reply = JSON.load(response.read, self.method(:unwrap_objects))
				
				return extract_value(reply)
			end
			
			def post(path, arguments = {}, &block)
				Console.debug(self, "POST #{request_path(path)}", arguments: arguments)
				response = @delegate.post(request_path(path), POST_HEADERS, arguments ? JSON.dump(arguments) : nil)
				reply = JSON.load(response.read, self.method(:unwrap_objects))
				
				return extract_value(reply, &block)
			end
			
			def delete(path = nil)
				Console.debug(self, "DELETE #{request_path(path)}")
				response = @delegate.delete(request_path(path), POST_HEADERS)
				reply = JSON.load(response.read, self.method(:unwrap_objects))
				
				return extract_value(reply)
			end
		end
	end
end
