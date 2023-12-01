
require 'sus/fixtures/async/reactor_context'

require 'async/webdriver/session'
require 'async/webdriver/browser'

ASession = Sus::Shared("a session") do
	include Sus::Fixtures::Async::ReactorContext
	
	let(:session) {@browser.session}
	
	it "should have a session" do
		expect(session).to be_a(Async::WebDriver::Session)
	end
	
	it "should have a title" do
		expect(session.title).to be_a(String)
	end
	
	# it "should have capabilities" do
	# 	expect(session.capabilities).to be_a(Hash)
	# end
	
	# it "should have timeouts" do
	# 	expect(session.timeouts).to be_a(Hash)
	# 	expect(session.script_timeout).to be_a(Integer)
	# 	expect(session.implicit_wait_timeout).to be_a(Integer)
	# 	expect(session.page_load_timeout).to be_a(Integer)
	# end
	
	# it "should be able to set timeouts" do
	# 	session.script_timeout = 1000
	# 	session.implicit_wait_timeout = 1000
	# 	session.page_load_timeout = 1000
		
	# 	expect(session.script_timeout).to be == 1000
	# 	expect(session.implicit_wait_timeout).to be == 1000
	# 	expect(session.page_load_timeout).to be == 1000
	# end
	
	# it "should be able to navigate to a page" do
	# 	session.navigate("https://google.com")
	# 	expect(session.title).to be == "Google"
	# end
end

Async::WebDriver::Browser.constants.each do |name|
	klass = Async::WebDriver::Browser.const_get(name)
	next unless klass.new.supported?
	
	describe(klass, unique: name) do
		def before
			@browser = subject.new
		end
		
		def after
			@browser&.close
		end
		
		attr :browser
		
		it_behaves_like ASession
	end
end
