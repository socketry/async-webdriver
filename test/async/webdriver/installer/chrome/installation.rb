# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "async/webdriver/installer/chrome/installation"
require "tmpdir"

describe Async::WebDriver::Installer::Chrome::Installation do
	let(:platform) {Async::WebDriver::Installer::Chrome::Platform.current}
	let(:state) {Dir.mktmpdir("async-webdriver-test-")}
	
	def after(error = nil)
		FileUtils.rm_rf(state)
		super
	end
	
	with ".find" do
		it "returns nil when nothing is installed" do
			expect(subject.find(:stable, platform, state: state)).to be_nil
		end
		
		it "returns nil for an exact version that is not installed" do
			expect(subject.find("999.0.0.0", platform, state: state)).to be_nil
		end
	end
	
	with ".install" do
		it "installs stable and returns an Installation" do
			installation = subject.install(:stable, state: state)
			
			expect(installation).to be_a(subject)
			expect(installation.version).to match(/\A\d+\.\d+\.\d+\.\d+\z/)
			expect(installation.platform).to be == platform
			expect(File.exist?(installation.browser_path)).to be == true
			expect(File.exist?(installation.driver_path)).to be == true
		end
		
		it "creates a channel symlink" do
			subject.install(:stable, state: state)
			expect(File.symlink?(File.join(state, platform, "stable"))).to be == true
		end
		
		it "is idempotent — second call returns without re-downloading" do
			first  = subject.install(:stable, state: state)
			second = subject.install(:stable, state: state)
			expect(second.version).to be == first.version
		end
	end
	
	with ".find after .install" do
		it "resolves the channel symlink without a network request" do
			subject.install(:stable, state: state)
			installation = subject.find(:stable, platform, state: state)
			
			expect(installation).to be_a(subject)
			expect(File.exist?(installation.browser_path)).to be == true
		end
	end
end
