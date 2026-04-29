# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "async/webdriver/installer/chrome/releases"
require "async/webdriver/installer/chrome/platform"

describe Async::WebDriver::Installer::Chrome::Releases do
	let(:platform) {Async::WebDriver::Installer::Chrome::Platform.current}
	
	with ".resolve" do
		it "resolves :stable to a version hash" do
			result = subject.resolve(:stable, platform)
			expect(result).to have_keys(:version, :chrome_url, :chromedriver_url)
			expect(result[:version]).to match(/\A\d+\.\d+\.\d+\.\d+\z/)
		end
		
		it "resolves 'stable' string the same as :stable" do
			expect(subject.resolve("stable", platform)).to be == subject.resolve(:stable, platform)
		end
		
		it "resolves a major version string" do
			major = subject.resolve(:stable, platform)[:version].split(".").first
			result = subject.resolve(major, platform)
			expect(result[:version]).to start_with("#{major}.")
		end
		
		it "raises for an unknown channel" do
			expect{subject.resolve(:nightly, platform)}.to raise_exception(ArgumentError)
		end
	end
end
