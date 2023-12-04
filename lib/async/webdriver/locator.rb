# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'base64'

module Async
	module WebDriver
		class Locator
			def self.wrap(locator = nil, **options)
				if locator.is_a?(Locator)
					locator
				elsif css = options[:css]
					css(css)
				elsif xpath = options[:xpath]
					xpath(xpath)
				elsif link_text = options[:link_text]
					link_text(link_text)
				elsif partial_link_text = options[:partial_link_text]
					partial_link_text(partial_link_text)
				elsif tag_name = options[:tag_name]
					tag_name(tag_name)
				elsif using = options[:using]
					new(using, options[:value])
				else
					raise ArgumentError, "Unable to interpret #{locator.inspect} with #{options.inspect}!"
				end
			end
			
			def self.css(css)
				new("css selector", css)
			end
			
			def self.link_text(text)
				new("link text", text)
			end
			
			def self.partial_link_text(text)
				new("partial link text", text)
			end
			
			def self.tag_name(name)
				new("tag name", name)
			end
			
			def self.xpath(xpath)
				new("xpath", xpath)
			end
			
			def initialize(using, value)
				@using = using
				@value = value
			end
			
			attr :using
			attr :value
			
			def as_json
				{using: @using, value: @value}
			end
			
			def to_json(...)
				as_json.to_json(...)
			end
		end
	end
end
