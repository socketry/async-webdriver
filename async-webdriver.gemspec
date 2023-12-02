# frozen_string_literal: true

require_relative "lib/async/webdriver/version"

Gem::Specification.new do |spec|
	spec.name = "async-webdriver"
	spec.version = Async::WebDriver::VERSION
	
	spec.summary = "A native library implementing the W3C WebDriver client specification."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/async-webdriver"
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.0"
	
	spec.add_dependency "async-http", "~> 0.42"
end
