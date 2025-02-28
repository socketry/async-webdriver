# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'sus/fixtures/async/reactor_context'

require 'async/webdriver/session'
require 'async/webdriver/bridge'

ABridge = Sus::Shared("a bridge") do
	include Sus::Fixtures::Async::ReactorContext
	
	with "a driver" do
		with "#status" do
			it "should be ready" do
				expect(driver.status).to have_keys("ready" => be == true)
			end
		end
	end
end

Async::WebDriver::Bridge.each do |klass|
	name = klass.name.split("::").last
	
	describe(klass, unique: name) do
		def bridge
			@bridge ||= subject.new
		end
		
		def driver
			@driver ||= bridge.start
		end
		
		def after(error = nil)
			@driver&.close
			super
		end
		
		it_behaves_like ABridge
	end
end
