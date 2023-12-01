# frozen_string_literal: true

module Async
	module WebDriver
		module Browser
			class ProcessGroup
				def self.spawn(*arguments)
					# This might be problematic...
					self.new(
						::Process.spawn(*arguments, pgroup: true, out: File::NULL, err: File::NULL)
					)
				end
				
				def initialize(pid)
					@pid = pid
					
					@status_task = Async(transient: true) do
						@status = ::Process.wait(@pid)
						
						unless @status.success?
							Console.error(self, "Process exited unexpectedly: #{@status}")
						end
					ensure
						self.close
					end
				end
				
				def close
					if @status_task
						@status_task.stop
						@status_task = nil
					end
					
					if @pid
						::Process.kill("INT", -@pid)
						
						Async do |task|
							task.with_timeout(1) do
								::Process.wait(@pid)
							rescue Async::TimeoutError
								Console.info(self, "Killing pid #{@pid}...")
								::Process.kill("KILL", -@pid)
							end
						end.wait
						
						wait_all(-@pid)
						@pid = nil
					end
				end
				
				protected
				
				def wait_all(pgid)
					while true
						pid, status = ::Process.wait2(pgid, ::Process::WNOHANG)
						
						break unless pid
					end
				rescue Errno::ECHILD
					# Done.
				end
			end
		end
	end
end
