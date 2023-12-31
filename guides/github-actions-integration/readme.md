# GitHub Actions Integrations

This guide explains how to use `async-webdriver` with GitHub Actions.

We recommend using the [browser-actions](https://github.com/browser-actions) for setting up `chromedriver` and `geckodriver`. They are pre-configured to work with `async-webdriver` and are easy to use.

## Pipeline Configuration

The following example shows how to setup both `chromedriver` and `geckodriver` in a single pipeline:

~~~ yaml
name: Test

on: [push, pull_request]

permissions:
  contents: read

env:
  CONSOLE_OUTPUT: XTerm

jobs:
  test:
    name: ${{matrix.ruby}} on ${{matrix.os}}
    runs-on: ${{matrix.os}}-latest
    continue-on-error: ${{matrix.experimental}}
    
    strategy:
      matrix:
        os:
          - ubuntu
          - macos
        
        ruby:
          - "3.0"
          - "3.1"
          - "3.2"
        
        experimental: [false]
        
        include:
          - os: ubuntu
            ruby: truffleruby
            experimental: true
          - os: ubuntu
            ruby: jruby
            experimental: true
          - os: ubuntu
            ruby: head
            experimental: true
    
    steps:
    - uses: actions/checkout@v3
    - uses: ruby/setup-ruby@v1
      with:
        ruby-version: ${{matrix.ruby}}
        bundler-cache: true
    
    - uses: browser-actions/setup-chrome@v1
    - uses: browser-actions/setup-firefox@v1
    - uses: browser-actions/setup-geckodriver@latest
      with:
        token: ${{secrets.GITHUB_TOKEN}}
    
    - name: Run tests
      timeout-minutes: 10
      run: bundle exec bake test
~~~
