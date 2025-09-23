# Releases

## Unreleased

  - Introduce `Scope#wait_for_navigation` to properly wait for page navigations to complete.

## v0.9.0

  - Fix `Scope#screenshot` to use the correct HTTP method (`GET` instead of `POST`).

## v0.8.0

  - Fix `fill_in` `<select>` on Safari.
  - `Element#tag_name` now normalizes the tag name to lowercase (Safari returns uppercase while other browsers return lowercase).
