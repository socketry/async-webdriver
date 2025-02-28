# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

module Async
	module WebDriver
		module Scope
			# Helpers for finding elements.
			module Elements
				# Find an element using the given locator. If no element is found, an exception is raised.
				# @parameter locator [Locator] The locator to use.
				# @returns [Element] The element.
				# @raises [NoSuchElementError] If the element does not exist.
				def find_element(locator)
					current_scope.post("element", locator)
				end
				
				# Find an element using the given CSS selector.
				# @parameter css [String] The CSS selector to use.
				# @returns [Element] The element.
				# @raises [NoSuchElementError] If the element does not exist.
				def find_element_by_css(css)
					find_element({using: "css selector", value: css})
				end
				
				# Find an element using the given link text.
				# @parameter text [String] The link text to use.
				# @returns [Element] The element.
				# @raises [NoSuchElementError] If the element does not exist.
				def find_element_by_link_text(text)
					find_element({using: "link text", value: text})
				end
				
				# Find an element using the given partial link text.
				# @parameter text [String] The partial link text to use.
				# @returns [Element] The element.
				# @raises [NoSuchElementError] If the element does not exist.
				def find_element_by_partial_link_text(text)
					find_element({using: "partial link text", value: text})
				end
				
				# Find an element using the given tag name.
				# @parameter name [String] The tag name to use.
				# @returns [Element] The element.
				# @raises [NoSuchElementError] If the element does not exist.
				def find_element_by_tag_name(name)
					find_element({using: "tag name", value: name})
				end
				
				# Find an element using the given XPath expression.
				# @parameter xpath [String] The XPath expression to use.
				# @returns [Element] The element.
				# @raises [NoSuchElementError] If the element does not exist.
				def find_element_by_xpath(xpath)
					find_element({using: "xpath", value: xpath})
				end
				
				# Find all elements using the given locator. If no elements are found, an empty array is returned.
				# @parameter locator [Locator] The locator to use.
				# @returns [Array(Element)] The elements.
				def find_elements(locator)
					current_scope.post("elements", locator)
				end
				
				# Find all elements using the given CSS selector.
				# @parameter css [String] The CSS selector to use.
				# @returns [Array(Element)] The elements.
				def find_elements_by_css(css)
					find_elements({using: "css selector", value: css})
				end
				
				# Find all elements using the given link text.
				# @parameter text [String] The link text to use.
				# @returns [Array(Element)] The elements.
				def find_elements_by_link_text(text)
					find_elements({using: "link text", value: text})
				end
				
				# Find all elements using the given partial link text.
				# @parameter text [String] The partial link text to use.
				# @returns [Array(Element)] The elements.
				def find_elements_by_partial_link_text(text)
					find_elements({using: "partial link text", value: text})
				end
				
				# Find all elements using the given tag name.
				# @parameter name [String] The tag name to use.
				# @returns [Array(Element)] The elements.
				def find_elements_by_tag_name(name)
					find_elements({using: "tag name", value: name})
				end
				
				# Find all elements using the given XPath expression.
				# @parameter xpath [String] The XPath expression to use.
				# @returns [Array(Element)] The elements.
				def find_elements_by_xpath(xpath)
					find_elements({using: "xpath", value: xpath})
				end
				
				# Find all children of the current element.
				# @returns [Array(Element)] The children of the current element.
				def children
					find_elements_by_xpath("./child::*")
				end
			end
		end
	end
end
