# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

# Async::WebDriver test suite for the comparison benchmark.
#
# Run with:
#   bundle exec sus test/suite.rb          # sequential
#   bundle exec sus-parallel test/suite.rb # concurrent (shows the real speedup)
#
# Requirements: chromedriver or geckodriver on PATH.
# Safari is NOT suitable for this benchmark — it only supports one concurrent
# session, so concurrent tests will fail. Use Chrome or Firefox instead.

require "sus/fixtures/async/reactor_context"
require "sus/fixtures/async/http/server_context"
require "async/webdriver"
require "async/webdriver/installer"

require_relative "../../app"

BRIDGE = Async::WebDriver::Bridge::Chrome.for(:stable)

POOL = Async::WebDriver::Bridge::Pool.new(BRIDGE)

at_exit {POOL.close}

# One shared session pool for the whole suite. Within each describe block,
# the session is checked out from the pool and returned after each test.
# With sus-parallel, multiple describe blocks run concurrently against the
# pool — Chrome supports many concurrent sessions, so the pool serves them all.
module SessionContext
	include Sus::Fixtures::Async::ReactorContext
	include Sus::Fixtures::Async::HTTP::ServerContext
	
	def app
		proc{|request| Protocol::HTTP::Response[*App.response_for(request.path)]}
	end
	
	def session
		@session ||= POOL.session
	end
	
	def after(error = nil)
		@session&.close
		@session = nil
		super
	end
end

describe "home page" do
	include SessionContext
	
	it "has the right title" do
		session.visit(bound_url)
		expect(session.document_title).to be == "Home"
	end
	
	it "has a welcome heading" do
		session.visit(bound_url)
		expect(session.find_element_by_css("#heading").text).to be == "Welcome"
	end
	
	it "has a tagline" do
		session.visit(bound_url)
		expect(session.find_element_by_css("#tagline").text).to be =~ /fast/
	end
	
	it "has navigation links" do
		session.visit(bound_url)
		expect(session.find_element_by_css("#about-link").text).to be == "About"
		expect(session.find_element_by_css("#contact-link").text).to be == "Contact"
	end
end

describe "about page" do
	include SessionContext
	
	it "has the right title" do
		session.visit("#{bound_url}/about")
		expect(session.document_title).to be == "About"
	end
	
	it "has the right heading" do
		session.visit("#{bound_url}/about")
		expect(session.find_element_by_css("#heading").text).to be == "About Us"
	end
	
	it "has a description" do
		session.visit("#{bound_url}/about")
		expect(session.find_element_by_css("#description").text).to be =~ /Ruby/
	end
	
	it "links back to home" do
		session.visit("#{bound_url}/about")
		session.find_element_by_css("#home-link").click
		expect(session.document_title).to be == "Home"
	end
end

describe "contact page" do
	include SessionContext
	
	it "has the right title" do
		session.visit("#{bound_url}/contact")
		expect(session.document_title).to be == "Contact"
	end
	
	it "has a contact form" do
		session.visit("#{bound_url}/contact")
		expect(session.find_element_by_css("#contact-form")).not.to be_nil
	end
	
	it "shows confirmation on submit" do
		session.visit("#{bound_url}/contact")
		session.find_element_by_css("#name").send_keys("Alice")
		session.find_element_by_css("#email").send_keys("alice@example.com")
		session.find_element_by_css("#message").send_keys("Hello!")
		session.find_element_by_css("#send-btn").click
		expect(session.find_element_by_css("#confirmation").text).to be =~ /Thank you/
	end
	
	it "hides the form after submit" do
		session.visit("#{bound_url}/contact")
		session.find_element_by_css("#send-btn").click
		expect(session.execute("return document.getElementById('contact-form').style.display")).to be == "none"
	end
end

describe "navigation" do
	include SessionContext
	
	it "can navigate from home to about" do
		session.visit(bound_url)
		session.find_element_by_css("#about-link").click
		expect(session.document_title).to be == "About"
	end
	
	it "can navigate from home to contact" do
		session.visit(bound_url)
		session.find_element_by_css("#contact-link").click
		expect(session.document_title).to be == "Contact"
	end
	
	it "can navigate back to home from about" do
		session.visit("#{bound_url}/about")
		session.find_element_by_css("#home-link").click
		expect(session.document_title).to be == "Home"
	end
	
	it "remembers browser history" do
		session.visit(bound_url)
		session.visit("#{bound_url}/about")
		session.navigate_back
		expect(session.document_title).to be == "Home"
	end
end
