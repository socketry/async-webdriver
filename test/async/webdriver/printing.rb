# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "sus/fixtures/async/reactor_context"
require "sus/fixtures/async/http/server_context"

require "async/webdriver"
require "pool_context"

APrinting = Sus::Shared("printing") do
	include Sus::Fixtures::Async::ReactorContext
	include Sus::Fixtures::Async::HTTP::ServerContext

	let(:app) do
		proc do |request|
			Protocol::HTTP::Response[200, [], [<<~HTML]]
				<html>
					<head>
						<title>Print Test Page</title>
						<style>
							body { font-family: Arial, sans-serif; margin: 20px; }
							h1 { color: #333; }
							.page-break { page-break-after: always; }
						</style>
					</head>
					<body>
						<div class="page-break">
							<h1>Page 1</h1>
							<p>This is the first page of the print test.</p>
						</div>
						<div>
							<h1>Page 2</h1>
							<p>This is the second page of the print test.</p>
						</div>
					</body>
				</html>
			HTML
		end
	end

	with "#print" do
		it "returns valid PDF binary data" do
			session.visit(bound_url)

			pdf_data = session.print

			expect(pdf_data).to be_a(String)
			expect(pdf_data.length).to be > 0
			# PDF files begin with the %PDF magic bytes
			expect(pdf_data[0, 4]).to be == "%PDF"
		end

		it "accepts orientation option" do
			session.visit(bound_url)

			portrait  = session.print(orientation: "portrait")
			landscape = session.print(orientation: "landscape")

			expect(portrait).to be_a(String)
			expect(portrait[0, 4]).to be == "%PDF"
			expect(landscape).to be_a(String)
			expect(landscape[0, 4]).to be == "%PDF"
		end

		it "accepts page_ranges option" do
			session.visit(bound_url)

			pdf_data = session.print(page_ranges: ["1"])

			expect(pdf_data).to be_a(String)
			expect(pdf_data[0, 4]).to be == "%PDF"
		end

		it "accepts scale option" do
			session.visit(bound_url)

			pdf_data = session.print(scale: 0.5)

			expect(pdf_data).to be_a(String)
			expect(pdf_data[0, 4]).to be == "%PDF"
		end

		it "accepts margin option" do
			session.visit(bound_url)

			pdf_data = session.print(margin: {top: 2, bottom: 2, left: 2, right: 2})

			expect(pdf_data).to be_a(String)
			expect(pdf_data[0, 4]).to be == "%PDF"
		end

		it "accepts page size option" do
			session.visit(bound_url)

			# A4 dimensions in cm
			pdf_data = session.print(page: {width: 21.0, height: 29.7})

			expect(pdf_data).to be_a(String)
			expect(pdf_data[0, 4]).to be == "%PDF"
		end
	end
end

Async::WebDriver::Bridge.each do |klass|
	name = klass.name.split("::").last

	describe(klass, unique: name) do
		include PoolContext

		if klass <= Async::WebDriver::Bridge::Safari
			include Sus::Fixtures::Async::ReactorContext
			include Sus::Fixtures::Async::HTTP::ServerContext

			let(:app) do
				proc { |request| Protocol::HTTP::Response[200, [], ["<html><body></body></html>"]] }
			end

			it "raises UnknownCommandError (Safari does not support the print endpoint)" do
				session.visit(bound_url)
				expect { session.print }.to raise_exception(Async::WebDriver::UnknownCommandError)
			end
		else
			it_behaves_like APrinting
		end
	end
end
