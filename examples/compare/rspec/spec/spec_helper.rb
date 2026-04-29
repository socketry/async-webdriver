# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

# Selenium WebDriver / RSpec spec helper for the comparison benchmark.
#
# Requirements: chromedriver on PATH.
# Run with: bundle exec rspec

require "webrick"
require "selenium-webdriver"
require_relative "../../app"

# Start a WEBrick server serving the same app as the Sus suite.
SERVER = WEBrick::HTTPServer.new(
	Port: 0,
	Logger: WEBrick::Log.new(File::NULL),
	AccessLog: [],
)

SERVER.mount_proc("/") do |req, res|
	status, headers, body = App.response_for(req.path)
	res.status = status
	headers.each{|k, v| res[k] = v}
	res.body = body.join
end

Thread.new{SERVER.start}
at_exit {SERVER.shutdown}

APP_URL = "http://localhost:#{SERVER.config[:Port]}"

sleep 0.1 # Give WEBrick a moment to bind

RSpec.configure do |config|
	# Each describe block gets its own Chrome session for isolation,
	# matching the per-describe-block pool checkout in the Sus suite.
	# Sessions run SEQUENTIALLY — one finishes before the next starts.
	config.before(:context) do
		options = Selenium::WebDriver::Chrome::Options.new
		options.add_argument("--headless=new")
		self.class.instance_variable_set(:@driver, Selenium::WebDriver.for(:chrome, options: options))
	end
	
	config.after(:context) do
		self.class.instance_variable_get(:@driver)&.quit
	end
	
	config.before do
		@driver = self.class.instance_variable_get(:@driver)
	end
end
