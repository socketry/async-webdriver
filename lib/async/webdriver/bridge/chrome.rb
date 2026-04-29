# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2026, by Samuel Williams.

require_relative "generic"
require_relative "process_group"

module Async
	module WebDriver
		module Bridge
			# A bridge to the Chrome browser using `chromedriver`.
			#
			# ``` ruby
			# begin
			# 	bridge = Async::WebDriver::Bridge::Chrome.start
			# 	client = Async::WebDriver::Client.open(bridge.endpoint)
			# ensure
			# 	bridge&.close
			# end
			# ```
			class Chrome < Generic
				# @returns [String] The path to the `chromedriver` executable.
				def driver_path
					@options.fetch(:driver_path, "chromedriver")
				end
				
				# @returns [String] The version of the `chromedriver` executable.
				def version
					::IO.popen([self.driver_path, "--version"]) do |io|
						return io.read
					end
				rescue Errno::ENOENT
					return nil
				end
				
				# A locally managed `chromedriver` process.
				class Driver < Bridge::Driver
					# Initialize a managed Chrome driver process.
					# @parameter options [Hash] Driver configuration options.
					def initialize(**options)
						super(**options)
						@process_group = nil
					end
					
					# @returns [Array(String)] The arguments to pass to the `chromedriver` executable.
					def arguments(**options)
						[
							options.fetch(:driver_path, "chromedriver"),
							"--port=#{self.port}",
						].compact
					end
					
					# Start the managed Chrome driver process and wait for readiness.
					def start
						@process_group = ProcessGroup.spawn(*arguments(**@options))
						
						super
					end
					
					# Stop the managed Chrome driver process.
					def close
						if @process_group
							@process_group.close
							@process_group = nil
						end
						
						super
					end
				end
				
				# Start the driver, forwarding the bridge's own options to the driver process
				# so that a custom `:driver_path` reaches the chromedriver executable.
				def start(**options)
					Driver.new(**@options, **options).tap(&:start)
				end
				
				# Ensure the given version of Chrome for Testing is installed and return a
				# fully configured {Chrome} bridge pointing at it.
				#
				# Delegates to {Async::WebDriver::Installer::Chrome.install} for version
				# resolution and download, then wraps the result in a configured bridge.
				#
				# @parameter version [Symbol | String] `:stable`, `:beta`, `:dev`, `:canary`,
				#   a major version string like `"148"`, or an exact version like `"148.0.7778.56"`.
				# @parameter state [String] Root of the state directory.
				#   Default: `~/.local/state/async-webdriver` (XDG-compliant).
				# @parameter options [Hash] Additional options forwarded to {.new} (e.g. `headless: false`).
				# @returns [Chrome] A configured bridge.
				def self.for(version = :stable, state: Installer::Chrome::DEFAULT_STATE, **options)
					require_relative "../installer/chrome"
					installation = Installer::Chrome.find(version, state: state) || Installer::Chrome.install(version, state: state)
					new(driver_path: installation.driver_path, browser_path: installation.browser_path, **options)
				end
				
				# Download and install a specific version of Chrome for Testing if not already present.
				#
				# Useful in CI setup steps or bake tasks that want to pre-download before
				# entering the Async reactor.
				#
				# @parameter version [Symbol | String] Version specifier — see {.for}.
				# @parameter state [String] Root of the state directory.
				# @returns [Installer::Chrome::Installation] The installation details.
				def self.install(version = :stable, state: Installer::Chrome::DEFAULT_STATE)
					require_relative "../installer/chrome"
					Installer::Chrome.install(version, state: state)
				end
				
				# The path to the Chrome browser executable. If `nil`, ChromeDriver uses its own discovery.
				# @returns [String | Nil]
				def browser_path
					@options[:browser_path]
				end
				
				# The default capabilities for the Chrome browser which need to be provided when requesting a new session.
				# @parameter headless [Boolean] Whether to run the browser in headless mode.
				# @parameter browser_path [String | Nil] Path to the Chrome browser executable. Overrides ChromeDriver's default discovery, useful for pointing at a specific Chrome for Testing installation.
				# @returns [Hash] The default capabilities for the Chrome browser.
				def default_capabilities(headless: self.headless?, browser_path: self.browser_path)
					chrome_options = {
						args: [headless ? "--headless=new" : nil].compact,
					}
					
					chrome_options[:binary] = browser_path if browser_path
					
					{
						alwaysMatch: {
							browserName: "chrome",
							"goog:chromeOptions": chrome_options,
							webSocketUrl: true,
						},
					}
				end
			end
		end
	end
end
