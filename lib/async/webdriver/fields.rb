require 'base64'

require_relative 'xpath'

module Async
	module WebDriver
		module Fields
			def fill_in(name, value)
				element = find_element_by_xpath("//*[@name=#{XPath::escape(name)}]")
				
				if element.tag_name == "input" || element.tag_name == "textarea"
					element.clear
				end
				
				element.send_keys(value)
			end
			
			def submit_form
				element = find_element_by_xpath("//input[@type='submit']")
				
				element.click
			end
		end
	end
end
