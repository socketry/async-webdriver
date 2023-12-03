require 'base64'

module Async
	module WebDriver
		module Scope
			module Elements
				def find_element(using, value)
					current_scope.post("element", {using: using, value: value})
				end
				
				def find_element_by_css(css)
					find_element("css selector", css)
				end
				
				def find_element_by_link_text(text)
					find_element("link text", text)
				end
				
				def find_element_by_partial_link_text(text)
					find_element("partial link text", text)
				end
				
				def find_element_by_tag_name(name)
					find_element("tag name", name)
				end
				
				def find_element_by_xpath(xpath)
					find_element("xpath", xpath)
				end
				
				def find_elements(using, value)
					current_scope.post("elements", {using: using, value: value})
				end
				
				def find_elements_by_css(css)
					elements("css selector", css)
				end
				
				def find_elements_by_link_text(text)
					elements("link text", text)
				end
				
				def find_elements_by_partial_link_text(text)
					elements("partial link text", text)
				end
				
				def find_elements_by_tag_name(name)
					elements("tag name", name)
				end
				
				def find_elements_by_xpath(xpath)
					elements("xpath", xpath)
				end
			end
		end
	end
end
