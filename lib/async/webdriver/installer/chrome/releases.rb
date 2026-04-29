# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "json"

module Async
	module WebDriver
		module Installer
			module Chrome
				# Resolves Chrome for Testing version specifiers and download URLs using the
				# public Chrome for Testing JSON API.
				module Releases
					# Returns the latest known-good version for each release channel.
					CHANNELS_URL = "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json"
					
					# Returns every known-good version with its download URLs.
					VERSIONS_URL = "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"
					
					# Maps symbolic channel names to the API's title-case keys.
					CHANNELS = {
						stable: "Stable",
						beta:   "Beta",
						dev:    "Dev",
						canary: "Canary",
					}.freeze
					
					# Resolve a version specifier and platform to a version string and download URLs.
					#
					# @parameter version [Symbol | String] `:stable`, `:beta`, `:dev`, `:canary`,
					#   a major version string like `"148"`, or an exact version like `"148.0.7778.56"`.
					# @parameter platform [String] A Chrome for Testing platform string, e.g. `"mac-arm64"`.
					# @returns [Hash] `{ version:, chrome_url:, chromedriver_url: }`
					def self.resolve(version, platform)
						case version
						when Symbol                    then resolve_channel(version, platform)
						when /\A(stable|beta|dev|canary)\z/ then resolve_channel(version.to_sym, platform)
						when /\A\d+\z/                 then resolve_major(version, platform)
						else                                resolve_exact(version, platform)
						end
					end
					
					private
					
					def self.fetch_json(url)
						require "async/http/internet"
						
						Sync do
							internet = Async::HTTP::Internet.new
							begin
								response = internet.get(url)
								JSON.parse(response.read)
							ensure
								internet.close
							end
						end
					end
					
					def self.resolve_channel(channel, platform)
						key = CHANNELS.fetch(channel) do
							raise ArgumentError, "Unknown channel #{channel.inspect}. Expected one of: #{CHANNELS.keys.inspect}"
						end
						
						data = fetch_json(CHANNELS_URL)
						entry = data.dig("channels", key) or raise "Channel #{key} not found in API response"
						
						extract(entry, platform)
					end
					
					def self.resolve_major(major, platform)
						data = fetch_json(VERSIONS_URL)
						
						entry = data["versions"]
							.select{|v| v["version"].start_with?("#{major}.")}
							.max_by{|v| Gem::Version.new(v["version"])}
						
						raise "No version found for major version #{major}" unless entry
						
						extract(entry, platform)
					end
					
					def self.resolve_exact(version, platform)
						data = fetch_json(VERSIONS_URL)
						
						entry = data["versions"].find{|v| v["version"] == version}
						raise "Version #{version} not found" unless entry
						
						extract(entry, platform)
					end
					
					def self.extract(entry, platform)
						version   = entry["version"]
						downloads = entry["downloads"]
						
						chrome_url = downloads["chrome"]
							&.find{|d| d["platform"] == platform}
							&.dig("url")
						
						chromedriver_url = downloads["chromedriver"]
							&.find{|d| d["platform"] == platform}
							&.dig("url")
						
						raise "No Chrome download for platform #{platform} in version #{version}" unless chrome_url
						raise "No ChromeDriver download for platform #{platform} in version #{version}" unless chromedriver_url
						
						{version: version, chrome_url: chrome_url, chromedriver_url: chromedriver_url}
					end
				end
			end
		end
	end
end
