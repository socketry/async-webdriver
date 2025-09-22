# Debugging

This guide explains how to debug WebDriver issues by capturing HTML source and screenshots when tests fail.

## Overview

When WebDriver tests fail, it's often helpful to capture the current state of the page to understand what went wrong. The most useful debugging artifacts are:

- **HTML Source**: Shows the current DOM structure, helpful for understanding why element selectors might be failing
- **Screenshots**: Provides a visual representation of what the browser is actually showing

## Core Concepts

`async-webdriver` provides built-in methods for capturing debugging information:

- {ruby Async::WebDriver::Session#document_source} returns the HTML source of the current page.
- {ruby Async::WebDriver::Session#screenshot} captures a screenshot of the entire page.
- {ruby Async::WebDriver::Element#screenshot} captures a screenshot of a specific element.

## Basic Debugging

### Capturing HTML Source

To save the current page HTML to a file:

```ruby
require "async/webdriver"

Async::WebDriver::Bridge::Pool.open do |pool|
	pool.session do |session|
		session.visit("https://example.com")
		
		# Save HTML source for debugging
		html = session.document_source
		File.write("debug.html", html)
		
		puts "HTML saved to debug.html"
	end
end
```

### Capturing Screenshots

To save a screenshot of the current page:

```ruby
require "async/webdriver"

Async::WebDriver::Bridge::Pool.open do |pool|
	pool.session do |session|
		session.visit("https://example.com")
		
		# Take a screenshot (returns PNG binary data)
		screenshot_data = session.screenshot
		File.binwrite("debug.png", screenshot_data)
		
		puts "Screenshot saved to debug.png"
	end
end
```

### Element Screenshots

To capture a screenshot of a specific element:

```ruby
require "async/webdriver"

Async::WebDriver::Bridge::Pool.open do |pool|
	pool.session do |session|
		session.visit("https://example.com")
		
		# Find an element and screenshot it
		element = session.find_element_by_tag_name("body")
		element_screenshot = element.screenshot
		File.binwrite("element-debug.png", element_screenshot)
		
		puts "Element screenshot saved to element-debug.png"
	end
end
```

## Debugging Failed Element Searches

A common debugging scenario is when `find_element` fails. Here's how to capture debugging information:

```ruby
require "async/webdriver"

def debug_element_search(session, locator_type, locator_value)
	begin
		# Use the correct locator format for async-webdriver
		locator = {using: locator_type, value: locator_value}
		element = session.find_element(locator)
		puts "✅ Element found: #{locator_type}=#{locator_value}"
		return element
	rescue Async::WebDriver::NoSuchElementError => e
		puts "❌ Element not found: #{locator_type}=#{locator_value}"
		
		# Capture debugging information
		timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
		
		# Save HTML source
		html = session.document_source
		html_file = "debug-#{timestamp}.html"
		File.write(html_file, html)
		puts "📄 HTML saved to #{html_file}"
		
		# Save screenshot
		screenshot_data = session.screenshot
		screenshot_file = "debug-#{timestamp}.png"
		File.binwrite(screenshot_file, screenshot_data)
		puts "📸 Screenshot saved to #{screenshot_file}"
		
		# Re-raise the original error
		raise e
	end
end

# Usage example
Async::WebDriver::Bridge::Pool.open do |pool|
	pool.session do |session|
		session.visit("https://example.com")
		
		# This will save debug files if the element isn't found
		button = debug_element_search(session, "id", "submit-button")
	end
end
```

## Advanced Debugging Techniques

### Configuring Timeouts for Debugging

WebDriver uses different timeout settings that affect how long operations wait:

```ruby
require "async/webdriver"

Async::WebDriver::Bridge::Pool.open do |pool|
	pool.session do |session|
		# Configure timeouts for debugging (values in milliseconds)
		session.implicit_wait_timeout = 10_000  # 10 seconds for element finding
		session.page_load_timeout = 30_000      # 30 seconds for page loads
		session.script_timeout = 5_000          # 5 seconds for JavaScript execution
		
		puts "Current timeouts: #{session.timeouts}"
		
		# Now element finding will wait up to 10 seconds
		session.visit("https://example.com")
		element = session.find_element(:id, "dynamic-content")  # Will wait up to 10s
	end
end
```

### Wait and Debug Pattern

Sometimes elements appear after a delay. Here's how to debug timing issues:

```ruby
require "async/webdriver"

def wait_and_debug(session, locator_type, locator_value, timeout: 10000)
	# Set implicit wait timeout (in milliseconds)
	original_timeout = session.implicit_wait_timeout
	session.implicit_wait_timeout = timeout
	
	start_time = Time.now
	
	begin
		# Try to find the element (will use implicit wait timeout)
		locator = {using: locator_type, value: locator_value}
		session.find_element(locator)
	rescue Async::WebDriver::NoSuchElementError => error
		elapsed = Time.now - start_time
		puts "⏰ Timeout after #{elapsed.round(2)}s waiting for #{locator_type}=#{locator_value}"
		
		# Capture final state
		timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
		
		html = session.document_source
		File.write("timeout-debug-#{timestamp}.html", html)
		
		screenshot_data = session.screenshot
		File.binwrite("timeout-debug-#{timestamp}.png", screenshot_data)
		
		puts "📄 Final HTML saved to timeout-debug-#{timestamp}.html"
		puts "📸 Final screenshot saved to timeout-debug-#{timestamp}.png"
		
		raise
	ensure
		# Restore original timeout
		session.implicit_wait_timeout = original_timeout
	end
end
```

### Multi-Step Debugging

For complex test scenarios, capture state at multiple points:

```ruby
require "async/webdriver"

class DebugHelper
	def initialize(test_name)
		@test_name = test_name
		@step = 0
	end
	
	def capture_state(session, description)
		@step += 1
		timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
		prefix = "#{@test_name}-step#{@step}-#{timestamp}"
		
		# Save HTML
		html = session.document_source
		html_file = "#{prefix}-#{description}.html"
		File.write(html_file, html)
		
		# Save screenshot
		screenshot_data = session.screenshot
		screenshot_file = "#{prefix}-#{description}.png"
		File.binwrite(screenshot_file, screenshot_data)
		
		puts "🔍 Step #{@step}: #{description}"
		puts "   📄 #{html_file}"
		puts "   📸 #{screenshot_file}"
	end
end

# Usage example
debug = DebugHelper.new("login-test")

Async::WebDriver::Bridge::Pool.open do |pool|
	pool.session do |session|
		debug.capture_state(session, "initial-page")
		
		session.visit("https://example.com/login")
		debug.capture_state(session, "login-page-loaded")
		
		session.find_element_by_id("username").send_keys("user@example.com")
		debug.capture_state(session, "username-entered")
		
		session.find_element_by_id("password").send_keys("password")
		debug.capture_state(session, "password-entered")
		
		session.find_element_by_id("submit").click
		debug.capture_state(session, "form-submitted")
	end
end
```
