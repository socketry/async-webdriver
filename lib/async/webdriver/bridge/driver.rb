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
				
				def initialize(**options)
					@options = options
					@count = 0
					@closed = false
				end
				
				def concurrency
					@options.fetch(:concurrency, nil)
				end
				
				attr :count
				
				def viable?
					!@closed
				end
				
				def closed?
					@closed
				end
				
				def close
					@closed = true
				end
				
				def reusable?
					@options.fetch(:reusable, !@closed)
				end
				
				# Generate a port number for the driver to listen on if it was not specified.
				# @returns [Integer] An ephemeral port number.
				def ephemeral_port
					address = ::Addrinfo.tcp("localhost", 0)
					
					address.bind do |socket|
						# We assume that it's unlikely the port will be reused any time soon...
						return socket.local_address.ip_port
					end
				end
				
				def port
					@port ||= @options.fetch(:port, self.ephemeral_port)
				end
				
				def endpoint
					Async::HTTP::Endpoint.parse("http://localhost", port: self.port)
				end
				
				# Start the driver.
				# @parameter retries [Integer] The number of times to retry before giving up.
				def start(retries: 100)
					Console.debug(self, "Waiting for driver to start...")
					count = 0
					
					Async::HTTP::Client.open(endpoint) do |client|
						begin
							response = client.get("/status")
							@status = JSON.parse(response.read)["value"]
							Console.debug(self, "Successfully connected to driver.", status: @status)
						rescue Errno::ECONNREFUSED
							if count < retries
								count += 1
								sleep(0.001 * count)
								Console.debug(self, "Driver not ready, retrying...")
								retry
							else
								raise
							end
						end
					end
				end
			end
		end
	end
end
