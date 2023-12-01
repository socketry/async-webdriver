module Async
	module WebDriver
		module Scope
			def element(using, value)
				reply = post("element", {using: using, value: value})
				
				return Element.new(self.session, JSON.parse(body)["element-6066-11e4-a52e-4f735466cecf"])
			end
			
			def element_by_css(css)
				find_element("css selector", css)
			end
			
			def element_by_link_text(text)
				find_element("link text", text)
			end
			
			def element_by_partial_link_text(text)
				find_element("partial link text", text)
			end
			
			def element_by_tag_name(name)
				find_element("tag name", name)
			end
			
			def element_by_xpath(xpath)
				find_element("xpath", xpath)
			end
			
			def elements(using, value)
				reply = post("elements", {using: using, value: value})
				
				return reply["value"].map do |element|
					Element.new(self, element["element-6066-11e4-a52e-4f735466cecf"])
				end
			end
			
			def elements_by_css(css)
				elements("css selector", css)
			end
			
			def elements_by_link_text(text)
				elements("link text", text)
			end
			
			def elements_by_partial_link_text(text)
				elements("partial link text", text)
			end
			
			def elements_by_tag_name(name)
				elements("tag name", name)
			end
			
			def elements_by_xpath(xpath)
				elements("xpath", xpath)
			end
		end
	end
end
