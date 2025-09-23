# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "sus/fixtures/async/reactor_context"
require "sus/fixtures/async/http/server_context"

require "async/webdriver"
require "pool_context"

NavigationScope = Sus::Shared("navigation scope") do
	include Sus::Fixtures::Async::ReactorContext
	include Sus::Fixtures::Async::HTTP::ServerContext
	
	let(:app) do
		proc do |request|
			case request.path
			when "/form-page"
				# Page with a form that sets a cookie when submitted:
				Protocol::HTTP::Response[200, {
					"set-cookie" => "submitted=false; Path=/"
				}, [<<-HTML]]
					<html>
						<head><title>Form Page</title></head>
						<body>
							<h1>Submit Form</h1>
							<form action="/submit" method="post">
								<input type="text" name="data" value="test">
								<button type="submit">Submit</button>
							</form>
						</body>
					</html>
				HTML
			when "/submit"
				# Add a delay to make the race condition more likely:
				sleep(0.1)
				
				# Form submission endpoint that sets a cookie and redirects:
				Protocol::HTTP::Response[302, {
					"location" => "/success",
					"set-cookie" => "submitted=true; Path=/"
				}, []]
			when "/success"
				# Success page after form submission
				Protocol::HTTP::Response[200, [], [<<-HTML]]
					<html>
						<head><title>Success</title></head>
						<body>
							<h1>Form Submitted Successfully</h1>
							<p>Cookie should be set</p>
						</body>
					</html>
				HTML
			when "/other-page"
				# Another page to navigate to
				Protocol::HTTP::Response[200, [], [<<-HTML]]
					<html>
						<head><title>Other Page</title></head>
						<body>
							<h1>Other Page</h1>
							<p>This is a different page</p>
						</body>
					</html>
				HTML
			else
				# Default home page
				Protocol::HTTP::Response[200, [], [<<-HTML]]
					<html>
						<head><title>Home Page</title></head>
						<body><h1>Home</h1></body>
					</html>
				HTML
			end
		end
	end
	
	it "races on navigation" do
		session.navigate_to("#{bound_url}/form-page")
		
		session.click_button("Submit")
		
		# Use wait_for_navigation to properly wait for the form submission to complete and the redirect to occur:
		session.wait_for_navigation do |current_url|
			current_url.end_with?("/success")
		end
		# If you remove the redirect, the above wait_for_navigation is not needed.
		
		# This alone is insufficient, the above wait_for_navigation ensures the page is loaded:
		session.find_element_by_xpath("//h1[text()='Form Submitted Successfully']")
		# Without the above wait_for_navigation, I have observed this to hang.
		
		session.navigate_to("#{bound_url}/other-page")
		
		cookie = session.cookies.find {|cookie| cookie['name'] == 'submitted'}
		
		expect(cookie).not.to be_nil
		expect(cookie['value']).to be == 'true'
	end
end

Async::WebDriver::Bridge.each do |klass|
	name = klass.name.split("::").last
	pool = Async::WebDriver::Bridge::Pool.new(klass.new)
	
	describe(klass, unique: name) do
		include PoolContext
		
		it_behaves_like NavigationScope
	end
end
