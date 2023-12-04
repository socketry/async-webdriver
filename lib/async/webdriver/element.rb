# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'request_helper'

require_relative 'scope'

module Async
	module WebDriver
		# An element represents a DOM element. This class is used to interact with the DOM.
		class Element
			# Attributes associated with an element.
			class Attributes
				include Enumerable
				
				def initialize(element)
					@element = element
					@keys = nil
				end
				
				# Get the value of an attribute.
				# @parameter name [String] The name of the attribute.
				# @returns [Object] The value of the attribute with the given name.
				def [](name)
					@element.attribute(name)
				end
				
				# Set the value of an attribute.
				# @parameter name [String] The name of the attribute.
				# @parameter value [Object] The value of the attribute.
				def []=(name, value)
					@element.set_attribute(name, value)
				end
				
				# Get the names of all attributes.
				def keys
					@element.execute("return this.getAttributeNames()")
				end
				
				# Check if an attribute exists.
				# @parameter name [String] The name of the attribute.
				# @returns [Boolean] True if the attribute exists.
				def key?(name)
					@element.execute("return this.hasAttribute(...arguments)", name)
				end
				
				# Iterate over all attributes.
				# @yields {|name, value| ...} The name and value of each attribute.
				# 	@parameter name [String] The name of the attribute.
				# 	@parameter value [Object] The value of the attribute.
				def each(&block)
					return to_enum unless block_given?
					
					keys.each do |key|
						yield key, self[key]
					end
				end
			end
			
			# Initialize the element.
			# @parameter session [Session] The session the element belongs to.
			# @parameter id [String] The element identifier.
			def initialize(session, id)
				@session = session
				@delegate = session.delegate
				@id = id
				
				@attributes = nil
				@properties = nil
			end
			
			# @returns [Hash] The JSON representation of the element.
			def as_json
				{ELEMENT_KEY => @id}
			end
			
			# @returns [String] The JSON representation of the element.
			def to_json(...)
				as_json.to_json(...)
			end
			
			# @attribute [Session] The session the element belongs to.
			attr :session
			
			# @attribute [Protocol::HTTP::Middleware] The underlying HTTP client (or wrapper).
			attr :delegate
			
			# @attribute [String] The element identifier.
			attr :id
			
			# The path used for making requests to the web driver bridge.
			# @parameter path [String | Nil] The path to append to the request path.
			# @returns [String] The path used for making requests to the web driver bridge.
			def request_path(path = nil)
				if path
					"/session/#{@session.id}/element/#{@id}/#{path}"
				else
					"/session/#{@session}/element/#{@id}"
				end
			end
			
			include RequestHelper
			
			# The current scope to use for making subsequent requests.
			# @returns [Element] The element.
			def current_scope
				self
			end
			
			include Scope::Alerts
			include Scope::Cookies
			include Scope::Elements
			include Scope::Fields
			include Scope::Printing
			include Scope::ScreenCapture
			
			# Execute a script in the context of the element. `this` will be the element.
			# @parameter script [String] The script to execute.
			# @parameter arguments [Array] The arguments to pass to the script.
			def execute(script, *arguments)
				@session.execute("return (function(){#{script}}).call(...arguments)", self, *arguments)
			end
			
			# Execute a script in the context of the element. `this` will be the element.
			# @parameter script [String] The script to execute.
			# @parameter arguments [Array] The arguments to pass to the script.
			def execute_async(script, *arguments)
				@session.execute_async("return (function(){#{script}}).call(...arguments)", self, *arguments)
			end
			
			# Get the value of an attribute.
			#
			# Given an attribute name, e.g. `href`, this method will return the value of the attribute, as if you had executed the following JavaScript:
			#
			# ```js
			# element.getAttribute("href")
			# ```
			#
			# @parameter name [String] The name of the attribute.
			# @returns [Object] The value of the attribute.
			def attribute(name)
				get("attribute/#{name}")
			end
			
			# Set the value of an attribute.
			# @parameter name [String] The name of the attribute.
			# @parameter value [Object] The value of the attribute.
			def set_attribute(name, value)
				execute("this.setAttribute(...arguments)", name, value)
			end
			
			# Get attributes associated with the element.
			# @returns [Attributes] The attributes associated with the element.
			def attributes
				@attributes ||= Attributes.new(self)
			end
			
			# Get the value of a property.
			#
			# Given a property name, e.g. `offsetWidth`, this method will return the value of the property, as if you had executed the following JavaScript:
			#
			# ```js
			# element.offsetWidth
			# ```
			#
			# @parameter name [String] The name of the property.
			# @returns [Object] The value of the property.
			def property(name)
				get("property/#{name}")
			end
			
			# Get the value of a CSS property.
			#
			# Given a CSS property name, e.g. `width`, this method will return the value of the property, as if you had executed the following JavaScript:
			#
			# ```js
			# window.getComputedStyle(element).width
			# ```
			#
			# @parameter name [String] The name of the CSS property.
			# @returns [String] The value of the CSS property.
			def css(name)
				get("css/#{name}")
			end
			
			# Get the text content of the element.
			#
			# This method will return the text content of the element, as if you had executed the following JavaScript:
			#
			# ```js
			# element.textContent
			# ```
			#
			# @returns [String] The text content of the element.
			def text
				get("text")
			end
			
			# Get the element's tag name.
			#
			# This method will return the tag name of the element, as if you had executed the following JavaScript:
			#
			# ```js
			# element.tagName
			# ```
			#
			# @returns [String] The tag name of the element.
			def tag_name
				get("name")
			end
			
			# A struct representing the size of an element.
			Rectangle = Struct.new(:x, :y, :width, :height)
			
			# Get the element's bounding rectangle.
			# @returns [Rectangle] The element's bounding rectangle.
			def rectangle
				get("rect").tap do |reply|
					Rectangle.new(reply["x"], reply["y"], reply["width"], reply["height"])
				end
			end
			
			# Whether the element is selected OR checked.
			# @returns [Boolean] True if the element is selected OR checked.
			def selected?
				get("selected")
			end
			
			alias checked? selected?
			
			# Whether the element is enabled.
			# @returns [Boolean] True if the element is enabled.
			def enabled?
				get("enabled")
			end
			
			# Whether the element is displayed.
			# @returns [Boolean] True if the element is displayed.
			def displayed?
				get("displayed")
			end
			
			# Click the element.
			def click
				post("click")
			end
			
			# Clear the element.
			def clear
				post("clear")
			end
			
			# Send keys to the element. Simulates a user typing keys while the element is focused.
			def send_keys(text)
				post("value", {text: text})
			end
			
			FRAME_TAGS = ["frame", "iframe"].freeze
			
			# Whether the element is a frame.
			def frame?
				FRAME_TAGS.include?(self.tag_name)
			end
		end
	end
end
