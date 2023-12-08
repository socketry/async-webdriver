# Sus Integration

This guide will show you how to integrate `async-webdriver` with the sus test framework.

## Usage

Sus has out of the box support for `async-webdriver`. You can use it like this:

```shell
$ bundle add sus-fixtures-async-http sus-fixtures-async-webdriver protocol-rack
$ bundle update
```

Then write your integration test:

```ruby
# test/my_integration_test.rb

require 'sus/fixtures/async/http/server_context'
require 'sus/fixtures/async/webdriver/session_context'

require 'protocol/rack/adapter'
require 'rack/builder'

describe "my website" do
	include Sus::Fixtures::Async::HTTP::ServerContext
	include Sus::Fixtures::Async::WebDriver::SessionContext
	
	def middleware
		Protocol::Rack::Adapter.new(app)
	end
	
	def app
		Rack::Builder.load_file(File.expand_path('../config.ru', __dir__))
	end
	
	it "has a title" do
		navigate_to('/')
		
		expect(session.document_title).to be == "Example"
	end
	
	it "has a paragraph" do
		navigate_to('/')
		
		expect(session).to have_element(tag_name: "p")
	end
end
```

For more information, refer to the [sus-fixtures-async-webdriver](https://github.com/socketry/sus-fixtures-async-webdriver) documentation.
