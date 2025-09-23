# frozen_string_literal: true

require_relative "lib/async/webdriver/version"

Gem::Specification.new do |spec|
	spec.name = "async-webdriver"
	spec.version = Async::WebDriver::VERSION
	
	spec.summary = "A native library implementing the W3C WebDriver client specification."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/async-webdriver"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/async-webdriver/",
		"funding_uri" => "https://github.com/sponsors/ioquatix",
		"source_code_uri" => "https://github.com/socketry/async-webdriver.git",
	}
	
	spec.files = Dir.glob(["{context,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.2"
	
	spec.add_dependency "async-actor", "~> 0.1"
	spec.add_dependency "async-http", "~> 0.61"
	spec.add_dependency "async-pool", "~> 0.4"
	spec.add_dependency "async-websocket", "~> 0.25"
	spec.add_dependency "base64", "~> 0.2"
end
