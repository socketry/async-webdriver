# Async::WebDriver

Provides a client implementation of the W3C WebDriver specification with support for Chrome and Firefox.

[![Development Status](https://github.com/socketry/async-webdriver/workflows/Test/badge.svg)](https://github.com/socketry/async-webdriver/actions?workflow=Test)

## Motivation

In the past, I've used [selenium-webdriver](https://github.com/SeleniumHQ/selenium) for testing web applications. However, I found it to be slow. I wanted to improve the performance of my tests, so I decided to write a new implementation from scratch. The W3C WebDriver specification is quite simple, so it wasn't too difficult to implement, and I was able to get a significant performance improvement, between 2x-10x depending on the usage. Specifically, most test suites can take advantage of pre-warmed sessions, which can minimise the overhead of each test running in a new session. Additionally, I'd like to explore reusing sessions between tests, which could provide even more performance improvements.

In addition, building on top of [async](https://github.com/socketry/async) allows us to take advantage of [async-http](https://github.com/socketry/async-http) and run the web server in the same reactor as the test itself, which can provide a performance improvement over [capybara](https://github.com/teamcapybara/capybara) which usually needs to start a separate server process. This also makes it possible to share a single database transaction between the client and server, which can significantly reduce the overhead of "cleaning" the database after each test, and improve the opportunity for parallelisation.

## Usage

Please see the [project documentation](https://socketry.github.io/async-webdriver/) for more details.

  - [Getting Started](https://socketry.github.io/async-webdriver/guides/getting-started/index) - This guide explains how to use `async-webdriver` for controlling a browser.

  - [GitHub Actions Integrations](https://socketry.github.io/async-webdriver/guides/github-actions-integration/index) - This guide explains how to use `async-webdriver` with GitHub Actions.

  - [Sus Integration](https://socketry.github.io/async-webdriver/guides/sus-integration/index) - This guide will show you how to integrate `async-webdriver` with the sus test framework.

## See Also

  - [sus-fixtures-async-webdriver](https://github.com/socketry/sus-fixtures-async-webdriver) - STandard fixtures for testing web applications with `async-webdriver`.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

This project uses the [Developer Certificate of Origin](https://developercertificate.org/). All contributors to this project must agree to this document to have their contributions accepted.

### Contributor Covenant

This project is governed by the [Contributor Covenant](https://www.contributor-covenant.org/). All contributors and participants agree to abide by its terms.
