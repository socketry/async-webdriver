# Comparison: Async::WebDriver vs Selenium

This example runs the **same 16 tests** against a simple multi-page HTML application
using two different stacks:

| | `sus/` | `rspec/` |
|---|---|---|
| Test framework | [Sus](https://github.com/socketry/sus) | [RSpec](https://rspec.info) |
| WebDriver client | **Async::WebDriver** | [Selenium](https://selenium.dev) |
| HTTP app server | Async::HTTP (non-blocking) | WEBrick (blocking) |
| Browser | Chrome for Testing | Chrome for Testing |
| Session per group | Pool checkout (reused) | Fresh ChromeDriver session |

The application has four pages — home, about, contact, and navigation — with 4 tests
each covering titles, headings, links, form submission, and browser history.

## Setup

Chrome for Testing is installed automatically on first use via the built-in installer.
No separate download step is needed.

```sh
cd sus   && bundle install
cd rspec && bundle install
```

## Running

```sh
# Async::WebDriver — sequential
cd sus
time bundle exec sus test/suite.rb

# Async::WebDriver — parallel (sus-parallel forks separate processes)
cd sus
time bundle exec sus-parallel test/suite.rb

# Selenium — sequential
cd rspec
time bundle exec rspec
```

## Results

Measured on macOS (Apple Silicon), Chrome for Testing 148, 16 tests:

```
Async::WebDriver   sus            2.05s   ✅ fastest
Selenium           rspec          4.31s   ~2× slower
Async::WebDriver   sus-parallel   4.07s   slower than sequential (see below)
```

## Why async-webdriver is faster sequentially

The `POOL` constant in `sus/test/suite.rb` keeps a **single Chrome process alive**
for the entire run, checking sessions in and out as tests need them. Every test reuses
the same browser — no per-group startup or teardown cost.

Selenium (in the RSpec suite) creates and destroys a fresh ChromeDriver session for
each of the four `describe` blocks. That's four full browser-session round-trips paid
as overhead, in addition to the actual test work.

## Why `sus-parallel` is slower here

`sus-parallel` forks separate **OS processes**. Each fork gets its own copy of the
`POOL` constant and starts its own Chrome instance, paying four startup costs instead
of one — the opposite of what we want.

The in-process concurrency of Async::WebDriver is best demonstrated with
`Async::Barrier`, where many fibers share one pool inside a single process. See
[`benchmark/test-pool.rb`](../../benchmark/test-pool.rb) for an example.
