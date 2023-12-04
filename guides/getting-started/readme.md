# Getting Started

This guide explains how to use `async-webdriver` for controlling a browser.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add async-webdriver
~~~

## Core Concepts

`async-webdriver` is a Ruby implementation of the [WebDriver](https://www.w3.org/TR/webdriver/) protocol. It allows you to control a browser from Ruby code. It is built on top of [async](https://github.com/socketry/async) and [async-http](https://github.com/socketry/async-http). It has several core concepts:

- A {ruby Async::WebDriver::Bridge} can be used to start a web driver process, e.g. `chromedriver`, `geckodriver`, etc. It can be used in isolation, or not at all.
- A {ruby Async::WebDriver::Client} is used to connect to a running web driver and can be used to create new sessions.
- A {ruby Async::WebDriver::Session} represents a single browser session. It is used to control a browser window and navigate to different pages.
- A {ruby Async::WebDriver::Element} represents a single element on a page. It can be used to interact with the element, e.g. click, type, etc.

## Basic Usage

The following example shows how to use `async-webdriver` to open a browser, navigate to a page, and click a button:

~~~ ruby
require 'async/webdriver'

Async do
	bridge = Async::WebDriver::Bridge::Chrome.start
	client = Async::WebDriver::Client.open(bridge.endpoint)
	
	session = client.session(bridge.default_capabilities)
	# Set the implicit wait timeout to 10 seconds since we are dealing with the real internet (which can be slow):
	session.implicit_wait_timeout = 10_000
	
	session.visit('https://google.com')
	
	session.fill_in('q', 'async-webdriver')
	session.click_button("I'm Feeling Lucky")
	
	puts session.title
ensure
	session&.close
	client&.close
	bridge&.close
end
~~~

### Integration vs Unit Testing

`async-webdriver` is designed for integration testing. It is not designed for unit testing (e.g. wrapping a tool like `rack-test` as `capybara` can do). It is designed for testing your application in a real browser and web server. It is designed for testing your application in the same way that a real user would use it. Unfortunately, this style of integration testing is significantly slower than unit testing, but it is also significantly more representative of how your application will behave in production. There are other tools, e.g. [rack-test](https://github.com/rack/rack-test) which provide significantly faster unit testing, but they do not test how your application will behave in an actual web browser. A comprehensive test suite should include both unit tests and integration tests.
