# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "sus/fixtures/async/reactor_context"
require "sus/fixtures/async/http/server_context"

require "async/webdriver"
require "pool_context"

AScreenCapture = Sus::Shared("screen capture") do
	include Sus::Fixtures::Async::ReactorContext
	include Sus::Fixtures::Async::HTTP::ServerContext
	
	let(:app) do
		proc do |request|
			Protocol::HTTP::Response[200, [], [<<~HTML]]
				<html>
					<head>
						<title>Test Page</title>
						<style>
							body { 
								font-family: Arial, sans-serif; 
								background-color: #f0f0f0; 
								margin: 20px;
							}
							#main { 
								background-color: white; 
								padding: 20px; 
								border-radius: 5px;
								width: 300px;
								height: 200px;
							}
						</style>
					</head>
					<body>
						<div id="main">
							<h1>Screenshot Test</h1>
							<p>This is a test page for taking screenshots.</p>
							<button id="test-button">Click Me</button>
						</div>
					</body>
				</html>
			HTML
		end
	end
	
	with "#screenshot (session)" do
		it "should take a screenshot of the page" do
			session.visit(bound_url)
			
			screenshot_data = session.screenshot
			
			# Should return binary data (not base64 encoded)
			expect(screenshot_data).to be_a(String)
			expect(screenshot_data.length).to be > 0
			
			# Check if it looks like PNG data (PNG files start with specific bytes)
			png_header = "\x89PNG\r\n\x1a\n".b
			expect(screenshot_data[0, 8]).to be == png_header
		end
		
		it "should return different screenshots for different pages" do
			session.visit(bound_url)
			screenshot1 = session.screenshot
			
			# Navigate to a different URL (about:blank)
			session.navigate_to("about:blank")
			screenshot2 = session.screenshot
			
			# Screenshots should be different
			expect(screenshot1).not.to be == screenshot2
		end
	end
	
	with "#screenshot (element)" do
		it "should take a screenshot of a specific element" do
			session.visit(bound_url)
			
			element = session.find_element_by_css("#main")
			screenshot_data = element.screenshot
			
			# Should return binary data (not base64 encoded)
			expect(screenshot_data).to be_a(String)
			expect(screenshot_data.length).to be > 0
			
			# Check if it looks like PNG data
			png_header = "\x89PNG\r\n\x1a\n".b
			expect(screenshot_data[0, 8]).to be == png_header
		end
		
		it "should return different sized screenshots for different elements" do
			session.visit(bound_url)
			
			# Take screenshot of a large element
			main_element = session.find_element_by_css("#main")
			main_screenshot = main_element.screenshot
			
			# Take screenshot of a smaller element
			button_element = session.find_element_by_css("#test-button")
			button_screenshot = button_element.screenshot
			
			# Screenshots should be different
			expect(main_screenshot).not.to be == button_screenshot
			
			# Both should be valid PNG data
			png_header = "\x89PNG\r\n\x1a\n".b
			expect(main_screenshot[0, 8]).to be == png_header
			expect(button_screenshot[0, 8]).to be == png_header
		end
	end
end

Async::WebDriver::Bridge.each do |klass|
	name = klass.name.split("::").last
	pool = Async::WebDriver::Bridge::Pool.new(klass.new)
	
	describe(klass, unique: name) do
		include PoolContext
		
		it_behaves_like AScreenCapture
	end
end