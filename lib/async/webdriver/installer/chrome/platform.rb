# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

module Async
	module WebDriver
		module Installer
			module Chrome
				# Platform detection for Chrome for Testing downloads.
				#
				# Maps Ruby's `RUBY_PLATFORM` to the platform strings used by the
				# Chrome for Testing JSON API and zip file naming conventions.
				module Platform
					# Ordered list of (pattern, platform) pairs. First match wins.
					PLATFORM_MAP = [
						[/arm.*darwin|darwin.*arm|aarch64.*darwin|darwin.*aarch64/, "mac-arm64"],
						[/darwin/, "mac-x64"],
						[/aarch64.*linux|linux.*aarch64/, "linux-arm64"],
						[/linux/, "linux64"],
						[/x64.*mingw|mingw.*x64/, "win64"],
						[/mingw/, "win32"],
					].freeze
					
					# Detect the current platform.
					# @returns [String] e.g. `"mac-arm64"`, `"linux64"`.
					# @raises [RuntimeError] If the platform is not recognised.
					def self.current
						PLATFORM_MAP.each do |pattern, platform|
							return platform if RUBY_PLATFORM.match?(pattern)
						end
						raise "Unsupported platform: #{RUBY_PLATFORM}"
					end
					
					# Relative path to the Chrome binary inside the extracted chrome zip.
					# @parameter platform [String]
					# @returns [String]
					def self.chrome_binary(platform)
						case platform
						when "mac-arm64"
							"chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"
						when "mac-x64"
							"chrome-mac-x64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"
						when "linux64"
							"chrome-linux64/chrome"
						when "linux-arm64"
							"chrome-linux-arm64/chrome"
						when "win64"
							"chrome-win64/chrome.exe"
						when "win32"
							"chrome-win32/chrome.exe"
						else
							raise "Unknown platform: #{platform}"
						end
					end
					
					# Relative path to the chromedriver binary inside the extracted chromedriver zip.
					# @parameter platform [String]
					# @returns [String]
					def self.chromedriver_binary(platform)
						case platform
						when "mac-arm64"
							"chromedriver-mac-arm64/chromedriver"
						when "mac-x64"
							"chromedriver-mac-x64/chromedriver"
						when "linux64"
							"chromedriver-linux64/chromedriver"
						when "linux-arm64"
							"chromedriver-linux-arm64/chromedriver"
						when "win64"
							"chromedriver-win64/chromedriver.exe"
						when "win32"
							"chromedriver-win32/chromedriver.exe"
						else
							raise "Unknown platform: #{platform}"
						end
					end
				end
			end
		end
	end
end
