# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'base64'

require_relative '../xpath'

module Async
	module WebDriver
		module Scope
			# Helpers for working with forms and form fields.
			module Fields
				# Find a field with the given name.
				# @parameter name [String] The name of the field.
				# @returns [Element] The field.
				# @raises [NoSuchElementError] If the field does not exist.
				def find_field(name)
					current_scope.find_element_by_xpath("//*[@name=#{XPath::escape(name)}]")
				end
				
				# Fill in a field with the given name.
				#
				# Clears the field before filling it in.
				#
				# @parameter name [String] The name of the field.
				# @parameter value [String] The value to fill in.
				# @raises [NoSuchElementError] If the field does not exist.
				def fill_in(name, value)
					element = find_field(name)
					
					if element.tag_name == "input" || element.tag_name == "textarea"
						element.clear
					end
					
					element.send_keys(value)
				end
				
				# Click a button with the given label.
				# @parameter label [String] The label of the button.
				# @raises [NoSuchElementError] If the button does not exist.
				def click_button(label)
					element = current_scope.find_element_by_xpath("//button[text()=#{XPath::escape(label)}] | //input[@type='submit' and @value=#{XPath::escape(label)}] | //input[@type='button' and @value=#{XPath::escape(label)}]")
					
					element.click
				end
				
				# Check a checkbox with the given name.
				#
				# Does not modify the checkbox if it is already in the desired state.
				#
				# @parameter field_name [String] The name of the checkbox.
				# @parameter value [Boolean] The value to set the checkbox to.
				# @raises [NoSuchElementError] If the checkbox does not exist.
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
