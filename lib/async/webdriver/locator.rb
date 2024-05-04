# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		# A locator is used to find elements in the DOM.
		#
		# You can use the following convenience methods to create locators:
		#
		# ``` ruby
		# Locator.css("main#content")
		# Locator.xpath("//main[@id='content']")
		# Locator.link_text("Home")
		# Locator.partial_link_text("Ho")
		# Locator.tag_name("main")
		# ```
		#
		# You can also use the `Locator.wrap` method to create locators from a hash:
		#
		# ``` ruby
		# Locator.wrap(css: "main#content")
		# Locator.wrap(xpath: "//main[@id='content']")
		# Locator.wrap(link_text: "Home")
		# Locator.wrap(partial_link_text: "Ho")
		# Locator.wrap(tag_name: "main")
		# ```
		#
		# For more information, see: <https://w3c.github.io/webdriver/#locator-strategies>.
		class Locator
			# A convenience wrapper for specifying locators.
			#
			# You may provide either:
			# 1. A locator instance, or
			# 2. A single option `css:`, `xpath:`, `link_text:`, `partial_link_text:` or `tag_name:`, or 
			# 3. A `using:` and `value:` option which will be used directly.
			#
			# @parameter locator [Locator] A locator to use directly.
			# @option css [String] A CSS selector.
			# @option xpath [String] An XPath expression.
			# @option link_text [String] The exact text of a link.
			# @option partial_link_text [String] A partial match for the text of a link.
			# @option tag_name [String] The name of a tag.
			# @option using [String] The locator strategy to use.
			# @option value [String] The value to use with the locator strategy.
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
			
			# A convenience wrapper for specifying CSS locators.
			def self.css(css)
				new("css selector", css)
			end
			
			# A convenience wrapper for specifying link text locators.
			def self.link_text(text)
				new("link text", text)
			end
			
			# A convenience wrapper for specifying partial link text locators.
			def self.partial_link_text(text)
				new("partial link text", text)
			end
			
			# A convenience wrapper for specifying tag name locators.
			def self.tag_name(name)
				new("tag name", name)
			end
			
			# A convenience wrapper for specifying XPath locators.
			def self.xpath(xpath)
				new("xpath", xpath)
			end
			
			# Initialize the locator.
			#
			# A locator strategy must usually be one of the following:
			# - `css selector`: Used to find elements via CSS selectors.
			# - `link text`: Used to find anchor elements by their link text.
			# - `partial link text`: Used to find anchor elements by their partial link text.
			# - `tag name`: Used to find elements by their tag name.
			# - `xpath`: Used to find elements via XPath expressions. 
			#
			# @parameter using [String] The locator strategy to use.
			# @parameter value [String] The value to use with the locator strategy.
			def initialize(using, value)
				@using = using
				@value = value
			end
			
			# @attribute [String] The locator strategy to use.
			attr :using
			
			# @attribute [String] The value to use with the locator strategy.
			attr :value
			
			# @returns [Hash] A JSON representation of the locator.
			def as_json
				{using: @using, value: @value}
			end
			
			# @returns [String] A JSON representation of the locator.
			def to_json(...)
				as_json.to_json(...)
			end
		end
	end
end
