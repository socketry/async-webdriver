# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'sus/fixtures/async/reactor_context'
require 'sus/fixtures/async/http/server_context'

require 'async/webdriver'

ASession = Sus::Shared("a session") do
	include Sus::Fixtures::Async::ReactorContext
	include Sus::Fixtures::Async::HTTP::ServerContext
	
	let(:webdriver_client) {Async::WebDriver::Client.open(bridge.endpoint)}
	let(:session) {webdriver_client.session(bridge.default_capabilities)}
	
	it "should have a session" do
		expect(session).to be_a(Async::WebDriver::Session)
	end
	
	it "can visit url" do
		session.visit(bound_url)
		expect(session.source).to be =~ /Hello World/
	end
	
	it "should have timeouts" do
		expect(session.script_timeout).to be_a(Integer)
		expect(session.implicit_wait_timeout).to be_a(Integer)
		expect(session.page_load_timeout).to be_a(Integer)
	end
	
	it "should be able to set timeouts" do
		session.script_timeout = 1000
		session.implicit_wait_timeout = 1000
		session.page_load_timeout = 1000
		
		expect(session.script_timeout).to be == 1000
		expect(session.implicit_wait_timeout).to be == 1000
		expect(session.page_load_timeout).to be == 1000
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
		
		it_behaves_like ASession
	end
end
