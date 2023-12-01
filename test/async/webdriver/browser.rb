
require 'sus/fixtures/async/reactor_context'

require 'async/webdriver/session'
require 'async/webdriver/browser'

ABrowser = Sus::Shared("a browser") do
	include Sus::Fixtures::Async::ReactorContext
	
	with "#status" do
		it "is ready" do
			expect(browser.status).to have_keys("ready" => be == true)
		end
	end
end

Async::WebDriver::Browser.each do |klass|
	name = klass.name.split("::").last
	
	describe(klass, unique: name) do
		def browser
			@browser ||= subject.new
		end
		
		def after
			@browser&.close
			super
		end
		
		it_behaves_like ABrowser
	end
end
