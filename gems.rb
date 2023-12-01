# frozen_string_literal: true

source "https://rubygems.org"

# gemspec

gem "async"
gem "async-http"

group :test do
	gem "sus"
	gem "covered"
	
	gem "sus-fixtures-async"
	gem "sus-fixtures-async-http"
end
