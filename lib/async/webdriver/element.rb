# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'request_helper'

require_relative 'scope'

module Async
	module WebDriver
		class Element
			class Attributes
				include Enumerable
				
				def initialize(element)
					@element = element
					@keys = nil
				end
				
				def [](name)
					@element.attribute(name)
				end
				
				def []=(name, value)
					@element.set_attribute(name, value)
				end
				
				def keys
					@element.execute("return this.getAttributeNames()")
				end
				
				def key?(name)
					@element.execute("return this.hasAttribute(...arguments)", name)
				end
				
				def each(&block)
					return to_enum unless block_given?
					
					keys.each do |key|
						yield key, self[key]
					end
				end
			end
			
			include Scope
			include RequestHelper
			
			def initialize(session, id)
				@session = session
				@delegate = session.delegate
				@id = id
				
				@attributes = nil
				@properties = nil
			end
			
			def as_json
				{ELEMENT_KEY => @id}
			end
			
			def to_json(...)
				as_json.to_json(...)
			end
			
			attr :session
			attr :delegate
			attr :id
			
			def request_path(path = nil)
				if path
					"/session/#{@session.id}/element/#{@id}/#{path}"
				else
					"/session/#{@session}/element/#{@id}"
				end
			end
			
			def children
				post("elements", {using: "xpath", value: "./*"})
			end
			
			def parent
				post("element", {using: "xpath", value: ".."})
			end
			
			def execute(script, *arguments)
				@session.execute("return (function(){#{script}}).call(...arguments)", self, *arguments)
			end
			
			def execute_async(script, *arguments)
				@session.execute_async("return (function(){#{script}}).call(...arguments)", self, *arguments)
			end
			
			def attribute(name)
				get("attribute/#{name}")
			end
			
			def set_attribute(name, value)
				execute("this.setAttribute(...arguments)", name, value)
			end
			
			def attributes
				@attributes ||= Attributes.new(self)
			end
			
			def property(name)
				get("property/#{name}")
			end
			
			def css(name)
				get("css/#{name}")
			end
			
			def text
				get("text")
			end
			
			def tag_name
				get("name")
			end
			
			Rectangle = Data.define(:x, :y, :width, :height)
			
			def rectangle
				get("rect").tap do |reply|
					Rectangle.new(reply["x"], reply["y"], reply["width"], reply["height"])
				end
			end
			
			def selected?
				get("selected")
			end
			
			def enabled?
				get("enabled")
			end
			
			def displayed?
				get("displayed")
			end
			
			def click
				post("click")
			end
			
			def clear
				post("clear")
			end
			
			def send_keys(text)
				post("value", {text:})
			end
		end
	end
end
