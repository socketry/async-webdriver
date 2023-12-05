# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Bridge
			class Queue
				def initialize(minimum: 1, concurrency: 2, maximum: nil)
					@minimum = minimum
					@concurrency = concurrency
					@maximum = maximum
					
					if @minimum > @concurrency
						@minimum = @concurrency
					end
					
					if @concurrency and (@maximum.nil? or @maximum > @concurrency)
						@maximum = @concurrency
					end
					
					@ready = Array.new
					
					@guard = Thread::Mutex.new
					@waiting = Thread::ConditionVariable.new
					@desired = Thread::ConditionVariable.new
					@count = 0
				end
				
				# Wait until an item is requested.
				def enqueue
					@guard.synchronize do
						while @count >= @concurrency
							@desired.wait(@guard)
							
							# We are closing.
							return nil if @ready.nil?
						end
						
						while @count < @minimum
							item = yield
							@count += 1
							@ready.push(item)
						end
					end
				end
				
				# Return an item to the queue to be reused.
				def reuse(item)
					@guard.synchronize do
						if @ready
							@ready.push(item)
							@waiting.signal
						end
					end
				end
				
				def retire
					@guard.synchronize do
						@count -= 1
						@desired.signal
					end
				end
				
				# Take an item from the queue.
				def pop
					@guard.synchronize do
						while @ready&.empty?
							@desired.signal
							@waiting.wait(@guard)
						end
						
						@ready&.shift
					end
				end
				
				def close
					@guard.synchronize do
						@ready = nil
						@waiting.broadcast
						@desired.broadcast
					end
				end
			end
			
			# A pool of sessions.
			#
			# ``` ruby
			# begin
			# 	bridge = Async::WebDriver::Bridge::Pool.start(Async::WebDriver::Bridge::Chrome.new)
			# 	session = bridge.session
			# ensure
			# 	bridge&.close
			# end
			# ```
			class Pool
				# Create a new session pool and start it.
				# @parameter bridge [Bridge] The bridge to use to create sessions.
				# @parameter capabilities [Hash] The capabilities to use when creating sessions.
				# @returns [Pool] The pool.
				def self.start(bridge, **options)
					self.new(bridge, **options).tap do |pool|
						pool.start
					end
				end
				
				# Initialize the session pool.
				# @parameter bridge [Bridge] The bridge to use to create sessions.
				# @parameter capabilities [Hash] The capabilities to use when creating sessions.
				# @parameter initial [Integer] The initial number of sessions to keep open.
				def initialize(bridge, capabilities: bridge.default_capabilities, minimum: 1, maximum: nil)
					@bridge = bridge
					@capabilities = capabilities
					
					@queue = Queue.new(minimum: minimum, maximum: maximum, concurrency: bridge.concurrency)
					
					@thread = nil
				end
				
				# Close the session pool.
				def close
					if @thread
						@thread.join
						@thread = nil
					end
					
					if @queue
						@queue.close
						@queue = nil
					end
				end
				
				# Start the session pool.
				def start
					@thread ||= Thread.new do
						Sync do
							@bridge.start
							
							client = Client.open(@bridge.endpoint)
							
							while true
								@queue.enqueue do
									client.post("session", {capabilities: @capabilities})
								end
							end
						ensure
							client&.close
							@bridge.close
						end
					end
				end
				
				class ReusableSession < Session
					def initialize(pool, ...)
						super(...)
						
						@pool = pool
					end
					
					def close
						unless @pool.reuse(self)
							super
						end
					end
				end
				
				# Open a session.
				def session(&block)
					@guard.synchronize do
						@desired += 1
					end
					
					reply = @sessions.pop
					
					session = ReusableSession.open(@bridge.endpoint, reply["sessionId"], reply["capabilities"])
					
					return session unless block_given?
					
					begin
						yield session
					ensure
						session&.close
					end
				end
				
				def reuse(session)
					if @sessions
						session.reset!
						
						@sessions << {"sessionId" => session.id, "capabilities" => session.capabilities}
						
						return true
					end
				end
			end
		end
	end
end
