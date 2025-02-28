# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

module PoolContext
	class Cache
		def initialize
			@pools = {}
			@guard = Thread::Mutex.new
		end
		
		def pool_for_class(klass)
			@guard.synchronize do
				@pools[klass] ||= Async::WebDriver::Bridge::Pool.new(klass.new)
			end
		end
		
		def close
			@guard.synchronize do
				@pools.each_value(&:close)
				@pools.clear
			end
		end
	end
	
	CACHE = Cache.new
	
	def pool
		@pool ||= CACHE.pool_for_class(subject)
	end
	
	def session
		@session ||= pool.session
	end
	
	def after(error = nil)
		@session&.close
		super
	end
end
