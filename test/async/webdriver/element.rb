# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'sus/fixtures/async/reactor_context'
require 'sus/fixtures/async/http/server_context'

require 'async/webdriver'

AnElement = Sus::Shared("an element") do
	include Sus::Fixtures::Async::ReactorContext
	include Sus::Fixtures::Async::HTTP::ServerContext
	
	let(:webdriver_client) {Async::WebDriver::Client.open(bridge.endpoint)}
	let(:session) {webdriver_client.session(bridge.default_capabilities)}
	
	let(:app) do
		proc do |request|
			Protocol::HTTP::Response[200, [], [<<-HTML]]
				<html>
					<body>
						<div id="foo" class="test">Hello World</div>
						<a href="foo-bar">Foo Bar</a>
						<ul>
							<li>One</li>
							<li>Two</li>
							<li>Three</li>
						</ul>
						<a href="bar-baz">Bar Baz</a>
					</body>
				</html>
			HTML
		end
	end
	
	with '#attributes' do
		it "should return attributes" do
			session.visit(bound_url)
			
			element = session.find_element_by_css("#foo")
			expect(element.attributes.to_h).to be == {"id" => "foo", "class" => "test"}
		end
		
		it "should set attributes" do
			session.visit(bound_url)
			
			element = session.find_element_by_css("#foo")
			element.attributes["class"] = "bar"
			
			expect(element.attributes.to_h).to be == {"id" => "foo", "class" => "bar"}
		end
		
		it "should return attribute values" do
			session.visit(bound_url)
			
			element = session.find_element_by_css("#foo")
			expect(element.attributes["id"]).to be == "foo"
		end
		
		it "can check if attribute exists" do
			session.visit(bound_url)
			
			element = session.find_element_by_css("#foo")
			expect(element.attributes.key?("id")).to be == true
			expect(element.attributes.key?("class")).to be == true
			expect(element.attributes.key?("href")).to be == false
		end
	end
	
	with Async::WebDriver::Scope::Elements do
		it "should find elements using css selector" do
			session.visit(bound_url)
			
			element = session.find_element_by_css("#foo")
			expect(element).to be_a(Async::WebDriver::Element)
			expect(element.text).to be == "Hello World"
		end
		
		it "should find elements using xpath selector" do
			session.visit(bound_url)
			
			element = session.find_element_by_xpath("//div[@id='foo']")
			expect(element).to be_a(Async::WebDriver::Element)
			expect(element.text).to be == "Hello World"
		end
		
		it "should find elements using link text" do
			session.visit(bound_url)
			
			element = session.find_element_by_link_text("Foo Bar")
			expect(element).to be_a(Async::WebDriver::Element)
			expect(element.tag_name).to be == "a"
			expect(element.text).to be == "Foo Bar"
		end
		
		it "should find elements using partial link text" do
			session.visit(bound_url)
			
			element = session.find_element_by_partial_link_text("Foo")
			expect(element).to be_a(Async::WebDriver::Element)
			expect(element.tag_name).to be == "a"
			expect(element.text).to be == "Foo Bar"
		end
		
		it "should find elements using tag name" do
			session.visit(bound_url)
			
			element = session.find_element_by_tag_name("div")
			expect(element).to be_a(Async::WebDriver::Element)
			expect(element.tag_name).to be == "div"
			expect(element.text).to be == "Hello World"
		end
		
		it "should find elements using css selector" do
			session.visit(bound_url)
			
			elements = session.find_elements_by_css("li")
			expect(elements).to be_a(Array)
			expect(elements.size).to be == 3
			expect(elements.first).to be_a(Async::WebDriver::Element)
			expect(elements.first.text).to be == "One"
		end
		
		it "should find elements using xpath selector" do
			session.visit(bound_url)
			
			elements = session.find_elements_by_xpath("//li")
			expect(elements).to be_a(Array)
			expect(elements.size).to be == 3
			expect(elements.first).to be_a(Async::WebDriver::Element)
			expect(elements.first.text).to be == "One"
		end
		
		it "should find elements using link text" do
			session.visit(bound_url)
			
			elements = session.find_elements_by_link_text("Foo Bar")
			expect(elements).to be_a(Array)
			expect(elements.size).to be == 1
			expect(elements.first).to be_a(Async::WebDriver::Element)
			expect(elements.first.tag_name).to be == "a"
			expect(elements.first.text).to be == "Foo Bar"
		end
		
		it "should find elements using partial link text" do
			session.visit(bound_url)
			
			elements = session.find_elements_by_partial_link_text("Bar")
			expect(elements).to be_a(Array)
			expect(elements.size).to be == 2
			expect(elements.first).to be_a(Async::WebDriver::Element)
			expect(elements.first.tag_name).to be == "a"
			expect(elements.first.text).to be == "Foo Bar"
		end
	end
	
	with Async::WebDriver::Scope::Fields do
		let(:app) do
			proc do |request|
				Protocol::HTTP::Response[200, [], [<<-HTML]]
					<html>
						<body>
							<form>
								<input type="text" name="foo" value="Hello World"/>
								<select name="bar">
									<option value="one">One</option>
									<option value="two">Two</option>
									<option value="three">Three</option>
								</select>
								<textarea name="baz">Hello World</textarea>
								<input type="hidden" name="qux" value="Hello World"/>
								<input type="submit" value="Submit"/>
							</form>
						</body>
					</html>
				HTML
			end
		end
		
		it "should fill in text fields" do
			session.visit(bound_url)
			
			session.fill_in("foo", "Goodbye World")
			
			element = session.find_element_by_xpath("//input[@name='foo']")
			expect(element.property("value")).to be == "Goodbye World"
		end
		
		it "should fill in text areas" do
			session.visit(bound_url)
			
			session.fill_in("baz", "Goodbye World")
			
			element = session.find_element_by_xpath("//textarea[@name='baz']")
			expect(element.property("value")).to be == "Goodbye World"
		end
		
		it "should fill in select fields" do
			session.visit(bound_url)
			
			session.fill_in("bar", "Two")
			
			element = session.find_element_by_xpath("//select[@name='bar']")
			expect(element.property("value")).to be == "two"
		end
		
		it "should click buttons" do
			session.visit(bound_url)
			
			session.click_button("Submit")
		end
	end
end

Async::WebDriver::Bridge.each do |klass|
	name = klass.name.split("::").last
	
	describe(klass, unique: name) do
		def bridge
			@bridge ||= subject.start
		end
		
		def after
			@bridge&.close
			super
		end
		
		it_behaves_like AnElement
	end
end
