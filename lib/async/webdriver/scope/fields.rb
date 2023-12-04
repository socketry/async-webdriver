require 'base64'

require_relative '../xpath'

module Async
	module WebDriver
		module Scope
			module Fields
				def find_field(name)
					current_scope.find_element_by_xpath("//*[@name=#{XPath::escape(name)}]")
				end
				
				def fill_in(name, value)
					element = find_field(name)
					
					if element.tag_name == "input" || element.tag_name == "textarea"
						element.clear
					end
					
					element.send_keys(value)
				end
				
				def click_button(label)
					element = current_scope.find_element_by_xpath("//button[text()=#{XPath::escape(label)}] | //input[@type='submit' and @value=#{XPath::escape(label)}] | //input[@type='button' and @value=#{XPath::escape(label)}]")
					
					element.click
				end
				
				def check(field_name, value = true)
					element = current_scope.find_element(xpath: "//input[@type='checkbox' and @name='#{field_name}']")
					
					if element.checked? != value
						element.click
					end
				end
			end
		end
	end
end
