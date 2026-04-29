# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "fileutils"
require "tempfile"
require_relative "platform"
require_relative "releases"

module Async
	module WebDriver
		module Installer
			module Chrome
				# Represents a Chrome for Testing installation on disk, and provides class-level
				# methods for resolving, locating, and downloading installations.
				#
				# Installations are stored under the cache_path directory, organised as:
				#
				# 	{cache_path}/{platform}/{version}/
				# 	  chrome/       ← extracted chrome zip contents
				# 	  chromedriver/ ← extracted chromedriver zip contents
				#
				# Channel names (e.g. `stable`) are stored as symlinks pointing at the
				# specific version directory, so that {find} can resolve them without
				# hitting the network. {install} always re-checks the API and updates
				# the symlink if the channel has moved on to a newer version.
				class Installation
					# Look up an existing installation, or download and install a fresh one.
					#
					# For channel specifiers (`:stable`, `:beta`, etc.), always hits the
					# Chrome for Testing API to resolve the current version, downloads if
					# needed, and updates the channel symlink. For exact versions, checks
					# the local cache only.
					#
					# @parameter version [Symbol | String] Channel or version specifier.
					# @parameter cache_path [String] Root of the cache directory.
					# @returns [Installation]
					def self.install(version, cache_path:)
						platform = Platform.current
						release = Releases.resolve(version, platform)
						
						unless installation = find(release[:version], platform, cache_path: cache_path)
							Console.info(self, "Installing Chrome for Testing #{release[:version]}...", platform: platform)
							
							dir = installation_dir(release[:version], platform, cache_path: cache_path)
							FileUtils.mkdir_p(dir)
							
							begin
								download_and_extract(release[:chrome_url], File.join(dir, "chrome"))
								download_and_extract(release[:chromedriver_url], File.join(dir, "chromedriver"))
								
								installation = find(release[:version], platform, cache_path: cache_path) or
									raise "Installation failed: binaries not found after extraction"
								
								Console.info(self, "Installed Chrome for Testing #{release[:version]}.", platform: platform)
							rescue
								FileUtils.rm_rf(dir)
								raise
							end
						end
						
						# Update the channel symlink so subsequent find(:stable) calls
						# resolve locally without a network request.
						if channel = channel_name(version)
							update_channel_symlink(channel, release[:version], platform, cache_path: cache_path)
						end
						
						return installation
					end
					
					# Find an already-installed version or channel, without hitting the network.
					#
					# For channel names (`:stable`, `"stable"`, etc.), resolves the local
					# symlink. For exact versions, checks the installation directory directly.
					#
					# @parameter version [Symbol | String] Channel or exact version string.
					# @parameter platform [String] Platform string, e.g. `"mac-arm64"`.
					# @parameter cache_path [String] Root of the cache directory.
					# @returns [Installation | Nil]
					def self.find(version, platform, cache_path:)
						if channel = channel_name(version)
							find_channel(channel, platform, cache_path: cache_path)
						else
							find_version(version, platform, cache_path: cache_path)
						end
					end
					
					# @parameter browser_path [String] Absolute path to the Chrome browser executable.
					# @parameter driver_path [String] Absolute path to the chromedriver executable.
					# @parameter version [String] Exact version string.
					# @parameter platform [String] Platform string.
					def initialize(browser_path:, driver_path:, version:, platform:)
						@browser_path = browser_path
						@driver_path = driver_path
						@version = version
						@platform = platform
					end
					
					# @attribute [String] Absolute path to the Chrome browser executable.
					attr :browser_path
					
					# @attribute [String] Absolute path to the chromedriver executable.
					attr :driver_path
					
					# @attribute [String] Exact installed version, e.g. `"148.0.7778.56"`.
					attr :version
					
					# @attribute [String] Platform, e.g. `"mac-arm64"`.
					attr :platform
					
					private_class_method def self.channel_name(version)
						Releases::CHANNELS.key(version.to_s.capitalize) && version.to_s.downcase
					end
					
					private_class_method def self.find_channel(channel, platform, cache_path:)
						symlink = channel_symlink(channel, platform, cache_path: cache_path)
						return nil unless File.symlink?(symlink)
						
						# Derive the version from the symlink target name.
						version = File.basename(File.readlink(symlink))
						find_version(version, platform, cache_path: cache_path)
					end
					
					private_class_method def self.find_version(version, platform, cache_path:)
						dir = installation_dir(version, platform, cache_path: cache_path)
						
						browser_path = File.join(dir, "chrome", Platform.chrome_binary(platform))
						driver_path = File.join(dir, "chromedriver", Platform.chromedriver_binary(platform))
						
						return nil unless File.exist?(browser_path) && File.exist?(driver_path)
						
						new(
							browser_path: browser_path,
							driver_path: driver_path,
							version: version,
							platform: platform,
						)
					end
					
					private_class_method def self.update_channel_symlink(channel, version, platform, cache_path:)
						symlink = channel_symlink(channel, platform, cache_path: cache_path)
						target = installation_dir(version, platform, cache_path: cache_path)
						
						# Remove stale symlink if it points elsewhere.
						if File.symlink?(symlink) && File.readlink(symlink) != target
							File.unlink(symlink)
						end
						
						File.symlink(target, symlink) unless File.symlink?(symlink)
					end
					
					private_class_method def self.channel_symlink(channel, platform, cache_path:)
						File.join(cache_path, platform, channel.to_s)
					end
					
					private_class_method def self.installation_dir(version, platform, cache_path:)
						File.join(cache_path, platform, version)
					end
					
					private_class_method def self.download_and_extract(url, dest)
						require "async/http/internet"
						
						Tempfile.create(["async-webdriver-", ".zip"]) do |tmp|
							tmp.binmode
							
							Sync do
								internet = Async::HTTP::Internet.new
								begin
									Console.debug(self, "Downloading...", url: url)
									response = internet.get(url)
									tmp.write(response.read)
									tmp.flush
								ensure
									internet.close
								end
							end
							
							FileUtils.mkdir_p(dest)
							system("unzip", "-q", "-o", tmp.path, "-d", dest) or
								raise "Failed to extract #{url}"
							
							# Remove macOS quarantine attributes added to files downloaded via code.
							if RUBY_PLATFORM.include?("darwin")
								system("xattr", "-r", "-d", "com.apple.quarantine", dest)
							end
						end
					end
				end
			end
		end
	end
end
