# frozen_string_literal: true

require "spec_helper"

RSpec.describe "home page" do
	it "has the right title" do
		@driver.navigate.to(APP_URL)
		expect(@driver.title).to eq("Home")
	end
	
	it "has a welcome heading" do
		@driver.navigate.to(APP_URL)
		expect(@driver.find_element(css: "#heading").text).to eq("Welcome")
	end
	
	it "has a tagline" do
		@driver.navigate.to(APP_URL)
		expect(@driver.find_element(css: "#tagline").text).to match(/fast/)
	end
	
	it "has navigation links" do
		@driver.navigate.to(APP_URL)
		expect(@driver.find_element(css: "#about-link").text).to eq("About")
		expect(@driver.find_element(css: "#contact-link").text).to eq("Contact")
	end
end

RSpec.describe "about page" do
	it "has the right title" do
		@driver.navigate.to("#{APP_URL}/about")
		expect(@driver.title).to eq("About")
	end
	
	it "has the right heading" do
		@driver.navigate.to("#{APP_URL}/about")
		expect(@driver.find_element(css: "#heading").text).to eq("About Us")
	end
	
	it "has a description" do
		@driver.navigate.to("#{APP_URL}/about")
		expect(@driver.find_element(css: "#description").text).to match(/Ruby/)
	end
	
	it "links back to home" do
		@driver.navigate.to("#{APP_URL}/about")
		@driver.find_element(css: "#home-link").click
		expect(@driver.title).to eq("Home")
	end
end

RSpec.describe "contact page" do
	it "has the right title" do
		@driver.navigate.to("#{APP_URL}/contact")
		expect(@driver.title).to eq("Contact")
	end
	
	it "has a contact form" do
		@driver.navigate.to("#{APP_URL}/contact")
		expect(@driver.find_element(css: "#contact-form")).not_to be_nil
	end
	
	it "shows confirmation on submit" do
		@driver.navigate.to("#{APP_URL}/contact")
		@driver.find_element(css: "#name").send_keys("Alice")
		@driver.find_element(css: "#email").send_keys("alice@example.com")
		@driver.find_element(css: "#message").send_keys("Hello!")
		@driver.find_element(css: "#send-btn").click
		expect(@driver.find_element(css: "#confirmation").text).to match(/Thank you/)
	end
	
	it "hides the form after submit" do
		@driver.navigate.to("#{APP_URL}/contact")
		@driver.find_element(css: "#send-btn").click
		display = @driver.execute_script("return document.getElementById('contact-form').style.display")
		expect(display).to eq("none")
	end
end

RSpec.describe "navigation" do
	it "can navigate from home to about" do
		@driver.navigate.to(APP_URL)
		@driver.find_element(css: "#about-link").click
		expect(@driver.title).to eq("About")
	end
	
	it "can navigate from home to contact" do
		@driver.navigate.to(APP_URL)
		@driver.find_element(css: "#contact-link").click
		expect(@driver.title).to eq("Contact")
	end
	
	it "can navigate back to home from about" do
		@driver.navigate.to("#{APP_URL}/about")
		@driver.find_element(css: "#home-link").click
		expect(@driver.title).to eq("Home")
	end
	
	it "remembers history" do
		@driver.navigate.to(APP_URL)
		@driver.navigate.to("#{APP_URL}/about")
		@driver.navigate.back
		expect(@driver.title).to eq("Home")
	end
end
