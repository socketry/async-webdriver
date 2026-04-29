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
			# Resolve the cache path for the given sub-directory.
			#
			# Follows the XDG Base Directory Specification, using `$XDG_CACHE_HOME`
			# (default: `~/.cache`) as the root, with `async-webdriver.rb` as the
			# application directory.
			#
			# @parameter subdirectory [String | Nil] Optional sub-directory, e.g. `"chrome"`.
			# @parameter env [Hash] Environment to read `XDG_CACHE_HOME` from. Default: `ENV`.
			# @returns [String] Absolute path.
			def self.cache_path(subdirectory = nil, env = ENV)
				base = File.expand_path("async-webdriver.rb", env.fetch("XDG_CACHE_HOME", "~/.cache"))
				subdirectory ? File.join(base, subdirectory) : base
			end
		end
	end
end
