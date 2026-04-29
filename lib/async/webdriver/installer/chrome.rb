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
			# Installations are cached in `~/.local/state/async-webdriver/` by default
			# (respects `$XDG_STATE_HOME`).
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
				# Default state directory, following the XDG Base Directory Specification.
				DEFAULT_STATE = File.expand_path(
					File.join(ENV.fetch("XDG_STATE_HOME", "~/.local/state"), "async-webdriver")
				).freeze
				
				# Ensure the given version is installed and return an {Installation}.
				#
				# Checks the local cache first; downloads from the Chrome for Testing
				# infrastructure only when the version is not already present.
				#
				# @parameter version [Symbol | String] Version specifier.
				# @parameter state [String] Root of the state directory.
				# @returns [Installation]
				def self.install(version = :stable, state: DEFAULT_STATE)
					Installation.install(version, state: state)
				end
				
				# Find an already-installed version or channel without hitting the network.
				#
				# @parameter version [Symbol | String] Channel or exact version string.
				# @parameter state [String] Root of the state directory.
				# @returns [Installation | Nil]
				def self.find(version, state: DEFAULT_STATE)
					Installation.find(version, Platform.current, state: state)
				end
			end
		end
	end
end
