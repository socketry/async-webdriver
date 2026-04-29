# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "async/webdriver/installer/chrome/platform"

describe Async::WebDriver::Installer::Chrome::Platform do
	with ".current" do
		it "detects the current platform" do
			platform = subject.current
			expect(platform).to be_a(String)
			known_platforms = ["mac-arm64", "mac-x64", "linux64", "linux-arm64", "win64", "win32"]
			expect(known_platforms).to be(:include?, platform)
		end
	end
	
	with ".chrome_binary" do
		it "returns a path for the current platform" do
			expect(subject.chrome_binary(subject.current)).to be_a(String)
		end
		
		it "raises for an unknown platform" do
			expect { subject.chrome_binary("bogus") }.to raise_exception(RuntimeError)
		end
	end
	
	with ".chromedriver_binary" do
		it "returns a path for the current platform" do
			expect(subject.chromedriver_binary(subject.current)).to be_a(String)
		end
		
		it "raises for an unknown platform" do
			expect { subject.chromedriver_binary("bogus") }.to raise_exception(RuntimeError)
		end
	end
end
