# Releases

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
