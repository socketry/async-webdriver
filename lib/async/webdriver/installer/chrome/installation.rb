# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "fileutils"
require "tempfile"
require_relative "platform"
require_relative "releases"

module Async
	module WebDriver
		module Installer
			module Chrome
				# Represents a Chrome for Testing installation on disk, and provides class-level
				# methods for resolving, locating, and downloading installations.
				#
				# Installations are stored under the state directory, organised as:
				#
				# 	{state}/{platform}/{version}/
				# 	  chrome/       ← extracted chrome zip contents
				# 	  chromedriver/ ← extracted chromedriver zip contents
				class Installation
					# Look up an existing installation, or download and install a fresh one.
					#
					# @parameter version [Symbol | String] Channel or version specifier — see {Async::WebDriver::Bridge::Chrome.for}.
					# @parameter state [String] Root of the state directory.
					# @returns [Installation]
					def self.install(version, state:)
						platform = Platform.current
						release = Releases.resolve(version, platform)
						
						existing = find(release[:version], platform, state: state)
						return existing if existing
						
						Console.info(self, "Installing Chrome for Testing #{release[:version]}...", platform: platform)
						
						dir = installation_dir(release[:version], platform, state: state)
						FileUtils.mkdir_p(dir)
						
						begin
							download_and_extract(release[:chrome_url], File.join(dir, "chrome"))
							download_and_extract(release[:chromedriver_url], File.join(dir, "chromedriver"))
							
							installation = find(release[:version], platform, state: state) or
								raise "Installation failed: binaries not found after extraction"
							
							Console.info(self, "Installed Chrome for Testing #{release[:version]}.", platform: platform)
							
							installation
						rescue
							FileUtils.rm_rf(dir)
							raise
						end
					end
					
					# Find an already-installed version, without hitting the network.
					#
					# @parameter version [String] Exact version, e.g. `"148.0.7778.56"`.
					# @parameter platform [String] Platform string, e.g. `"mac-arm64"`.
					# @parameter state [String] Root of the state directory.
					# @returns [Installation | Nil]
					def self.find(version, platform, state:)
						dir = installation_dir(version, platform, state: state)
						
						browser_path = File.join(dir, "chrome", Platform.chrome_binary(platform))
						driver_path = File.join(dir, "chromedriver", Platform.chromedriver_binary(platform))
						
						return nil unless File.exist?(browser_path) && File.exist?(driver_path)
						
						new(
							browser_path: browser_path,
							driver_path: driver_path,
							version: version,
							platform: platform,
						)
					end
					
					# @parameter browser_path [String] Absolute path to the Chrome browser executable.
					# @parameter driver_path [String] Absolute path to the chromedriver executable.
					# @parameter version [String] Exact version string.
					# @parameter platform [String] Platform string.
					def initialize(browser_path:, driver_path:, version:, platform:)
						@browser_path = browser_path
						@driver_path = driver_path
						@version = version
						@platform = platform
					end
					
					# @attribute [String] Absolute path to the Chrome browser executable.
					attr :browser_path
					
					# @attribute [String] Absolute path to the chromedriver executable.
					attr :driver_path
					
					# @attribute [String] Exact installed version, e.g. `"148.0.7778.56"`.
					attr :version
					
					# @attribute [String] Platform, e.g. `"mac-arm64"`.
					attr :platform
					
					private_class_method def self.installation_dir(version, platform, state:)
						File.join(state, platform, version)
					end
					
					private_class_method def self.download_and_extract(url, dest)
						require "async/http/internet"
						
						Tempfile.create(["async-webdriver-", ".zip"]) do |tmp|
							tmp.binmode
							
							Sync do
								internet = Async::HTTP::Internet.new
								begin
									Console.debug(self, "Downloading...", url: url)
									response = internet.get(url)
									tmp.write(response.read)
									tmp.flush
								ensure
									internet.close
								end
							end
							
							FileUtils.mkdir_p(dest)
							system("unzip", "-q", "-o", tmp.path, "-d", dest) or
								raise "Failed to extract #{url}"
							
							# Remove macOS quarantine attributes added to files downloaded via code.
							if RUBY_PLATFORM.include?("darwin")
								system("xattr", "-r", "-d", "com.apple.quarantine", dest)
							end
						end
					end
				end
			end
		end
	end
end
