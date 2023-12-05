# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

module Async
	module WebDriver
		module Bridge
			class Driver
				# A group of processes that are all killed when the group is closed.
				class ProcessGroup
					# Spawn a new process group with a given command.
					# @parameter arguments [Array] The command to execute.
					def self.spawn(*arguments)
						# This might be problematic...
						self.new(
							::Process.spawn(*arguments, pgroup: true, out: File::NULL, err: File::NULL)
						)
					end
					
					# Create a new process group from an existing process id.
					# @parameter pid [Integer] The process id.
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
					
					# Close the process group.
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
								rescue Errno::ECHILD
									# Done.
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
					
					# Wait for all processes in the group to exit.
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
end
