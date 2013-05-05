#!/usr/bin/env ruby

# Setup

require '../lib/port_scanner'

def usage
	puts "  Usage: #{$0} net.work.octets portnum <thread>"
	puts "  Example: #{$0} 10.0.0 80 # Scan port 80 on 10.0.0.0..255 serially"
	puts "  Example: #{$0} 10.0.0 22 # Scan port 22 on 10.0.0.0..255 threaded"
	exit 1
end

@net = ARGV[0]
@port = ARGV[1]
@thread = ARGV[2]
usage unless @net =~ /^\d+\.\d+\.\d+$/
usage unless @port =~ /^\d+/
start = Time.now

# Actually run the scan

p = PortScanner.new(@net, @port)
p.mode = @thread ? :thread : nil
p.scan
finish = Time.now
puts "Time elapsed: %.02f seconds" % [finish - start]

