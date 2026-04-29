# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.

require "sus/fixtures/async/reactor_context"
require "sus/fixtures/async/http/server_context"

require "async/webdriver"
require "pool_context"

AWindow = Sus::Shared("window") do
	include Sus::Fixtures::Async::ReactorContext
	include Sus::Fixtures::Async::HTTP::ServerContext
	
	let(:app) do
		proc do |request|
			Protocol::HTTP::Response[200, [], ["<html><body><h1>Window Test</h1></body></html>"]]
		end
	end
	
	with "#window_rect" do
		it "returns a hash with x, y, width, and height keys" do
			session.visit(bound_url)
			
			rect = session.window_rect
			
			expect(rect).to be_a(Hash)
			expect(rect["width"]).to be_a(Numeric)
			expect(rect["height"]).to be_a(Numeric)
			expect(rect["x"]).to be_a(Numeric)
			expect(rect["y"]).to be_a(Numeric)
		end
	end
	
	with "#resize_window" do
		it "changes the window dimensions" do
			session.visit(bound_url)
			
			session.resize_window(1024, 768)
			rect = session.window_rect
			
			expect(rect["width"]).to be == 1024
			expect(rect["height"]).to be == 768
		end
		
		it "can be resized multiple times" do
			session.visit(bound_url)
			
			session.resize_window(800, 600)
			rect = session.window_rect
			expect(rect["width"]).to be == 800
			expect(rect["height"]).to be == 600
			
			session.resize_window(1280, 900)
			rect = session.window_rect
			expect(rect["width"]).to be == 1280
			expect(rect["height"]).to be == 900
		end
	end
	
	with "#set_window_rect" do
		it "accepts width and height keyword arguments" do
			session.visit(bound_url)
			
			session.set_window_rect(width: 900, height: 700)
			rect = session.window_rect
			
			expect(rect["width"]).to be == 900
			expect(rect["height"]).to be == 700
		end
	end
	
	with "#maximize_window" do
		it "maximizes the window" do
			session.visit(bound_url)
			
			# Shrink first so maximise has something to do
			session.resize_window(400, 300)
			
			session.maximize_window
			rect = session.window_rect
			
			expect(rect["width"]).to be > 400
			expect(rect["height"]).to be > 300
		end
	end
	
	with "#fullscreen_window" do
		it "makes the window fullscreen" do
			session.visit(bound_url)
			
			session.resize_window(800, 600)
			
			begin
				session.fullscreen_window
			rescue Async::WebDriver::UnknownCommandError, Async::WebDriver::TimeoutError
				skip "Fullscreen window is not supported in this environment."
			end
			
			rect = session.window_rect
			
			# Fullscreen dimensions should be at least as large as the pre-fullscreen size
			expect(rect["width"]).to be >= 800
			expect(rect["height"]).to be >= 600
		end
	end
end

Async::WebDriver::Bridge.each do |klass|
	name = klass.name.split("::").last
	pool = Async::WebDriver::Bridge::Pool.new(klass.new)
	
	describe(klass, unique: name) do
		include PoolContext
		
		it_behaves_like AWindow
	end
end
