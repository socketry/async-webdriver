# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
end

group :test do
	gem "sus"
	gem "covered"
	
	gem "sus-fixtures-async"
	gem "sus-fixtures-async-http"
end
