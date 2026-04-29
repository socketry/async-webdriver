# Releases

## Unreleased

  - Add `Async::WebDriver::Installer::Chrome` for automatic Chrome for Testing installation and management. `Installer::Chrome.install(version)` resolves the version via the Chrome for Testing JSON API, caches binaries in `~/.local/state/async-webdriver/` (XDG `$XDG_STATE_HOME`), and returns an `Installation` with paths to both the Chrome and ChromeDriver binaries. The namespace is designed to accommodate additional browsers (e.g. `Installer::Firefox`) in the future.
  - Add `Bridge::Chrome.for(version)` as a convenience shorthand: installs the requested version if needed, then returns a fully configured `Chrome` bridge. Versions can be a channel symbol (`:stable`, `:beta`, `:dev`, `:canary`), a major version string (`"148"`), or an exact version string (`"148.0.7778.56"`).
  - Add `Bridge::Chrome.install(version)` for pre-downloading in CI setup steps or bake tasks, before entering the Async reactor.
  - Fix `Bridge::Chrome#start`, `Bridge::Firefox#start`, and `Bridge::Safari#start` not forwarding the bridge's own options (including `:driver_path`) to the driver process.
  - Rename `path:` to `driver_path:` on `Bridge::Chrome`, `Bridge::Firefox`, and `Bridge::Safari` for consistency. Add `browser_path:` to `Bridge::Chrome` (mapped to `goog:chromeOptions.binary`) in place of the former `binary:` option, consistent with `Installer::Chrome::Installation#browser_path` and `#driver_path`.

## v0.11.0

  - Add `Scope::Window` with `#window_rect`, `#resize_window`, `#set_window_rect`, `#maximize_window`, `#minimize_window`, and `#fullscreen_window`.
  - Expand `Scope::Printing#print` with full W3C WebDriver parameters: `orientation`, `scale`, `background`, `page`, `margin`, `page_ranges`, and `shrink_to_fit`.

## v0.10.0

  - Introduce `Scope#wait_for_navigation` to properly wait for page navigations to complete.

## v0.9.0

  - Fix `Scope#screenshot` to use the correct HTTP method (`GET` instead of `POST`).

## v0.8.0

  - Fix `fill_in` `<select>` on Safari.
  - `Element#tag_name` now normalizes the tag name to lowercase (Safari returns uppercase while other browsers return lowercase).
