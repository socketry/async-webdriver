# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require_relative "version"
require_relative "error"

module Async
	module WebDriver
		# Wraps the HTTP client to provide a consistent interface.
		module RequestHelper
			# The web element identifier is the string constant "element-6066-11e4-a52e-4f735466cecf".
			ELEMENT_KEY = "element-6066-11e4-a52e-4f735466cecf"
			
			# The content type for requests and responses.
			CONTENT_TYPE = "application/json"
			
			# Headers to send with GET requests.
			GET_HEADERS = [
				["user-agent", "Async::WebDriver/#{VERSION}"],
				["accept", CONTENT_TYPE],
			].freeze
			
			# Headers to send with POST requests.
			POST_HEADERS = GET_HEADERS + [
				["content-type", "#{CONTENT_TYPE}; charset=UTF-8"],
			].freeze
			
			# The path used for making requests to the web driver bridge.
			# @parameter path [String | Nil] The path to append to the request path.
			# @returns [String] The path used for making requests to the web driver bridge.
			def request_path(path = nil)
				if path
					"/#{path}"
				else
					"/"
				end
			end
			
			# Unwrap JSON objects into their corresponding Ruby objects.
			#
			# If the value is a Hash and represents an element, then it will be unwrapped into an {ruby Element}.
			#
			# @parameter value [Hash | Array | Object] The value to unwrap.
			# @returns [Object] The unwrapped value.
			def unwrap_object(value)
				if value.is_a?(Hash) and value.key?(ELEMENT_KEY)
					value = Element.new(self.session, value[ELEMENT_KEY])
				end
				
				return value
			end
			
			# Used by `JSON.load` to unwrap objects.
			def unwrap_objects(value)
				case value
				when Hash
					value.transform_values!(&method(:unwrap_object))
				when Array
					value.map!(&method(:unwrap_object))
				end
				
				return value
			end
			
			# Extract the value from the reply.
			#
			# If the value is a Hash and represents an error, then it will be raised as an appropriate subclass of {ruby Error}.
			#
			# @parameter reply [Hash] The reply from the server.
			# @returns [Object] The value of the reply.
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
			
			# Make a GET request to the bridge and extract the value.
			# @parameter path [String | Nil] The path to append to the request path.
			# @returns [Object | Nil] The value of the reply.
			def get(path)
				Console.debug(self, "GET #{request_path(path)}")
				response = @delegate.get(request_path(path), GET_HEADERS)
				reply = JSON.load(response.read, self.method(:unwrap_objects))
				
				return extract_value(reply)
			end
			
			# Make a POST request to the bridge and extract the value.
			# @parameter path [String | Nil] The path to append to the request path.
			# @parameter arguments [Hash | Nil] The arguments to send with the request.
			# @returns [Object | Nil] The value of the reply.
			def post(path, arguments = {}, &block)
				Console.debug(self, "POST #{request_path(path)}", arguments: arguments)
				response = @delegate.post(request_path(path), POST_HEADERS, arguments ? JSON.dump(arguments) : nil)
				reply = JSON.load(response.read, self.method(:unwrap_objects))
				
				return extract_value(reply, &block)
			end
			
			# Make a DELETE request to the bridge and extract the value.
			# @parameter path [String | Nil] The path to append to the request path.
			# @returns [Object | Nil] The value of the reply, if any.
			def delete(path = nil)
				Console.debug(self, "DELETE #{request_path(path)}")
				response = @delegate.delete(request_path(path), POST_HEADERS)
				reply = JSON.load(response.read, self.method(:unwrap_objects))
				
				return extract_value(reply)
			end
		end
	end
end
