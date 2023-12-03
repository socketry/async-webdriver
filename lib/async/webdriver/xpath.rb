module Async
	module WebDriver
		module XPath
			def self.escape(value)
				case value
				when String
					if value.include?("'")
						"concat('#{value.split("'").join("', \"'\", '")}')"
					else
						"'#{value}'"
					end
				else
					value.to_s
				end
			end
		end
	end
end
