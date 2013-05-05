#!/usr/bin/env ruby

require 'socket'
require 'timeout'

def usage
	puts "  Usage: #{$0} net.work.octets portnum"
	puts "  Example: #{$0} 10.0.0 80 # Scan port 80 on 10.0.0.0..255"
	exit 1
end

@net = ARGV[0]
@port = ARGV[1]
@thread = ARGV[2]
usage unless @net =~ /^\d+\.\d+\.\d+$/
usage unless @port =~ /^\d+/
start = Time.now

class PortScanner

	attr_accessor :net, :port, :mode

	def initialize(net, port)
		@net = net
		@port = port
		@range = 0..255
		@listeners = []
	end

	def scan
		puts "Scanning port #{@port} on #{@net}.#{@range}:"
		print "Mode: "
		if @mode == :thread
			puts "Thread"
			threaded_scan
		else
			puts "Serial"
			serial_scan
		end
	end

	def connect(i)
		addr = [@net,i].join(".")
		socket = TCPSocket.new(addr,@port) rescue nil
		if socket
			socket.close
			if Thread.current == Thread.main
				puts "#{addr}:#{@port} listening" if Thread.current == Thread.main
			else
				@listeners << addr
			end
		end
	end

	def serial_scan
		@range.each do |i|
			connect(i)
		end
	end

	def threaded_scan
		threads = []
		@range.each do |i|
			threads << Thread.new do
				connect(i)
			end
		end
		sleep 5
		threads.join

		@listeners.sort.each do |ip|
			puts "#{ip}:#{@port} listening"
		end
		puts "Listeners: #{@listeners.size}"
	end
end

# Run it all

p = PortScanner.new(@net, @port)
p.mode = @thread ? :thread : nil
p.scan
finish = Time.now
puts "Time elapsed: %.02f seconds" % [finish - start]


