# Comparison: Async::WebDriver vs Selenium

Both suites run **identical tests** against the same simple multi-page HTML application:

- 4 describe groups (home, about, contact, navigation)
- 4 tests each = **16 tests total**
- Same browser operations: navigate, find elements, click links, fill forms

## Requirements

**chromedriver** must be on your PATH. See the main readme for installation instructions.

> Safari is not suitable for this benchmark — it only allows one concurrent session,
> so the parallel benefit cannot be demonstrated.

## Setup

```sh
# Sus / Async::WebDriver
cd sus
bundle install

# RSpec / Selenium
cd rspec
bundle install
```

## Running

```sh
# Selenium — sequential (one Chrome session per describe block, started/stopped each time)
cd rspec
time bundle exec rspec

# Async::WebDriver — sequential (pool keeps Chrome alive and reuses sessions)
cd sus
time bundle exec sus test/suite.rb

# Async::WebDriver — concurrent (pool serves all four describe blocks in parallel)
cd sus
time bundle exec sus-parallel test/suite.rb
```

## What the comparison shows

| | Selenium + RSpec | Async::WebDriver + Sus |
|---|---|---|
| Session per group | New ChromeDriver session (startup cost each time) | Pool checkout (reused, no startup) |
| HTTP server | WEBrick (blocking threads) | Async::HTTP (non-blocking fibers) |
| Test execution | Sequential | Sequential or concurrent (`sus-parallel`) |

**Sequential**: async-webdriver is marginally faster due to session reuse and the
async HTTP stack — the browser is the bottleneck either way.

**Concurrent** (`sus-parallel`): async-webdriver runs all four describe blocks at the
same time inside a single process, sharing one Chrome pool. Wall-clock time drops to
roughly the duration of the slowest group rather than the sum of all groups.
Selenium would need separate processes (e.g. `parallel_tests`) and separate
ChromeDriver instances to achieve the same, with significantly more overhead.
