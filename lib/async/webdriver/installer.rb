# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require_relative "installer/chrome"

module Async
	module WebDriver
		# Browser installation and management for automated testing.
		#
		# Each browser has its own sub-module with browser-specific platform detection,
		# version resolution, and download logic:
		#
		# - {Installer::Chrome} — Chrome for Testing, via the Chrome for Testing JSON API.
		module Installer
		end
	end
end
