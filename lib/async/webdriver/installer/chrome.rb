# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require_relative "chrome/platform"
require_relative "chrome/releases"
require_relative "chrome/installation"

module Async
	module WebDriver
		module Installer
			# Installer for Chrome for Testing, the purpose-built Chrome variant
			# designed for automated testing.
			#
			# Versions can be specified as:
			# - A channel symbol: `:stable`, `:beta`, `:dev`, `:canary`
			# - A major version string: `"148"` (resolves to the latest patch)
			# - An exact version string: `"148.0.7778.56"`
			#
			# Installations are cached in `~/.cache/async-webdriver.rb/` by default
			# (respects `$XDG_CACHE_HOME`).
			#
			# ## Example
			#
			# ``` ruby
			# installation = Async::WebDriver::Installer::Chrome.install(:stable)
			# bridge = Async::WebDriver::Bridge::Chrome.new(
			#   driver_path:  installation.driver_path,
			#   browser_path: installation.browser_path,
			# )
			# ```
			#
			# Or via the convenience shorthand on the bridge:
			#
			# ``` ruby
			# bridge = Async::WebDriver::Bridge::Chrome.for(:stable)
			# ```
			module Chrome
				# Default cache directory, following the XDG Base Directory Specification.
				DEFAULT_CACHE = File.expand_path("async-webdriver.rb", ENV.fetch("XDG_CACHE_HOME", "~/.cache")).freeze
				
				# Ensure the given version is installed and return an {Installation}.
				#
				# Checks the local cache first; downloads from the Chrome for Testing
				# infrastructure only when the version is not already present.
				#
				# @parameter version [Symbol | String] Version specifier.
				# @parameter cache [String] Root of the cache directory.
				# @returns [Installation]
				def self.install(version = :stable, cache: DEFAULT_CACHE)
					Installation.install(version, cache: cache)
				end
				
				# Find an already-installed version or channel without hitting the network.
				#
				# @parameter version [Symbol | String] Channel or exact version string.
				# @parameter cache [String] Root of the cache directory.
				# @returns [Installation | Nil]
				def self.find(version, cache: DEFAULT_CACHE)
					Installation.find(version, Platform.current, cache: cache)
				end
			end
		end
	end
end
