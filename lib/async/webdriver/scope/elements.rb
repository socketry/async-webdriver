require 'base64'

module Async
	module WebDriver
		module Scope
			module Elements
				class Locator
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
				
				def find_element(locator)
					current_scope.post("element", locator)
				end
				
				def find_element_by_css(css)
					find_element({using: "css selector", value: css})
				end
				
				def find_element_by_link_text(text)
					find_element({using: "link text", value: text})
				end
				
				def find_element_by_partial_link_text(text)
					find_element({using: "partial link text", value: text})
				end
				
				def find_element_by_tag_name(name)
					find_element({using: "tag name", value: name})
				end
				
				def find_element_by_xpath(xpath)
					find_element({using: "xpath", value: xpath})
				end
				
				def find_elements(locator)
					current_scope.post("elements", locator)
				end
				
				def find_elements_by_css(css)
					find_elements({using: "css selector", value: css})
				end
				
				def find_elements_by_link_text(text)
					find_elements({using: "link text", value: text})
				end
				
				def find_elements_by_partial_link_text(text)
					find_elements({using: "partial link text", value: text})
				end
				
				def find_elements_by_tag_name(name)
					find_elements({using: "tag name", value: name})
				end
				
				def find_elements_by_xpath(xpath)
					find_elements({using: "xpath", value: xpath})
				end
				
				def children
					find_elements_by_xpath("./child::*")
				end
			end
		end
	end
end
