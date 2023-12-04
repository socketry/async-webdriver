require 'base64'

module Async
	module WebDriver
		module Scope
			module Elements
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
