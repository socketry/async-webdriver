# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025-2026, by Samuel Williams.

# Install Chrome for Testing and its matching ChromeDriver.
#
# Downloads the requested version from the Chrome for Testing infrastructure
# and caches it in `~/.local/state/async-webdriver/` (XDG `$XDG_STATE_HOME`).
# Subsequent calls with the same version are a no-op.
#
# @parameter version [String] The version to install: a channel (`stable`, `beta`, `dev`, `canary`),
#   a major version (e.g. `148`), or an exact version (e.g. `148.0.7778.56`). Default: `stable`.
def install(version: "stable")
	require "async/webdriver/installer/chrome"
	
	version = version.to_sym if %w[stable beta dev canary].include?(version)
	
	installation = Async::WebDriver::Installer::Chrome.install(version)
	
	Console.info(self, "Chrome for Testing is ready.",
		version:      installation.version,
		platform:     installation.platform,
		browser_path: installation.browser_path,
		driver_path:  installation.driver_path,
	)
end
