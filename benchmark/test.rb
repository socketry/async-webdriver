#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "async/webdriver"

Async do
	bridge = Async::WebDriver::Bridge::Pool.new(Async::WebDriver::Bridge::Chrome.new(headless: false))
	
	session = bridge.session
	# Set the implicit wait timeout to 10 seconds since we are dealing with the real internet (which can be slow):
	session.implicit_wait_timeout = 10_000
	
	session.visit("https://google.com")
	
	session.fill_in("q", "async-webdriver")
	session.click_button("I'm Feeling Lucky")
	
	puts session.document_title
ensure
	session&.close
	bridge&.close
end
