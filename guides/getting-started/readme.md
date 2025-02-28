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
	bridge = Async::WebDriver::Bridge::Chrome.new(headless: false)
	
	driver = bridge.start
	client = Async::WebDriver::Client.open(driver.endpoint)
	
	session = client.session(bridge.default_capabilities)
	# Set the implicit wait timeout to 10 seconds since we are dealing with the real internet (which can be slow):
	session.implicit_wait_timeout = 10_000
	
	session.visit('https://google.com')
	
	session.fill_in('q', 'async-webdriver')
	session.click_button("I'm Feeling Lucky")
	
	puts session.document_title
ensure
	session&.close
	client&.close
	driver&.close
end
~~~

### Using a Pool to Manage Sessions

If you are running multiple tests in parallel, you may want to use a session pool to manage the sessions. This can be done as follows:

~~~ ruby
require 'async/webdriver'

Async do
	bridge = Async::WebDriver::Bridge::Pool.new(Async::WebDriver::Bridge::Chrome.new(headless: false))
	
	session = bridge.session
	# Set the implicit wait timeout to 10 seconds since we are dealing with the real internet (which can be slow):
	session.implicit_wait_timeout = 10_000
	
	session.visit('https://google.com')
	
	session.fill_in('q', 'async-webdriver')
	session.click_button("I'm Feeling Lucky")
	
	puts session.document_title
ensure
	session&.close
	bridge&.close
end
~~~

The sessions will be cached and reused if possible.

## Integration vs Unit Testing

`async-webdriver` is designed for integration testing. It is not designed for unit testing (e.g. wrapping a tool like `rack-test` as `capybara` can do). It is designed for testing your application in a real browser and web server. It is designed for testing your application in the same way that a real user would use it. Unfortunately, this style of integration testing is significantly slower than unit testing, but it is also significantly more representative of how your application will behave in production. There are other tools, e.g. [rack-test](https://github.com/rack/rack-test) which provide significantly faster unit testing, but they do not test how your application will behave in an actual web browser. A comprehensive test suite should include both unit tests and integration tests.

### Headless Mode

During testing, often you will want to see the real browser window to determine if the test is working correctly. By default, for performance reasons, `async-webdriver` will run the browser in headless mode. This means that the browser will not be visible on the screen. If you want to see the browser window, you can disable headless mode by setting the `headless` option to `false`:

~~~ shell
$ ASYNC_WEBDRIVER_BRIDGE_HEADLESS=false ./webdriver-script.rb
~~~
