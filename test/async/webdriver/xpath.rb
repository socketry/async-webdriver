require 'async/webdriver/xpath'

describe Async::WebDriver::XPath do
	it "should escape strings" do
		expect(Async::WebDriver::XPath.escape("foo")).to be == "'foo'"
		expect(Async::WebDriver::XPath.escape("foo'bar")).to be == "concat('foo', \"'\", 'bar')"
	end
	
	it "should convert other types to strings" do
		expect(Async::WebDriver::XPath.escape(1)).to be == "1"
		expect(Async::WebDriver::XPath.escape(nil)).to be == ""
	end
end
