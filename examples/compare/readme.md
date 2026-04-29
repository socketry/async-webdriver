# Comparison: Async::WebDriver vs Selenium

Both suites run **identical tests** against the same simple multi-page HTML application:

- 4 describe groups (home, about, contact, navigation)
- 4 tests each = **16 tests total**
- Same browser operations: navigate, find elements, click links, fill forms

## Requirements

Install Chrome for Testing via the built-in installer:

``` ruby
require "async/webdriver/installer"
Async::WebDriver::Installer::Chrome.install(:stable)
```

Or use `Async::WebDriver::Bridge::Chrome.for(:stable)` directly — it installs on first use.

## Setup

```sh
# Sus / Async::WebDriver
cd sus && bundle install

# RSpec / Selenium
cd rspec && bundle install
```

## Running

```sh
# Selenium — sequential (one ChromeDriver session per describe block)
cd rspec
time bundle exec rspec

# Async::WebDriver — sequential (pool keeps Chrome alive, sessions reused)
cd sus
time bundle exec sus test/suite.rb

# Async::WebDriver — concurrent (all describe blocks run in parallel)
cd sus
time bundle exec sus-parallel test/suite.rb
```

## Results

```
Selenium / RSpec    sequential   4.31s
Async::WebDriver    sequential   2.05s   (~2× faster)
Async::WebDriver    sus-parallel 4.07s   (slower — separate processes, each starts Chrome)
```

## Why async-webdriver is faster sequentially

The pool keeps a **single Chrome process alive** for the entire run and reuses the
same session across all 16 tests. Selenium creates and tears down a fresh ChromeDriver
session for each of the 4 describe groups, paying startup overhead four times.

## Why sus-parallel is slower here

`sus-parallel` forks separate OS processes. Each process gets its own copy of the
pool constant and starts its own Chrome — negating the reuse benefit. The concurrency
advantage of async-webdriver shows inside a **single process** using `Async`, where
many concurrent fibers share one pool. For this kind of in-process concurrency,
look at `async-webdriver` with `Async::Barrier` rather than `sus-parallel`.
