#!/usr/bin/env ruby

# Setup

require '../lib/port_scanner'
require 'packetfu'

# Reopen the class and redefine the port scanner.

class PortScanner

	alias :full_connect :connect

	attr_accessor :type

	def connect(i)
		@type == :ack ? ack(i) : full_connect(i)
	end

	def ack(i)
		this_packet = create_ack_template
		addr = [@net,i].join(".")
		this_packet.ip_daddr = addr
		this_packet.recalc
	 	this_packet.to_w
	end

	def create_ack_template
		unless @ack_template
			config = PacketFu::Utils.whoami?
			@ack_template = PacketFu::TCPPacket.new(:config => config)
			@ack_template.tcp_dst = @port.to_i
			@ack_template.tcp_flags.ack = 1
		end
		return @ack_template
	end

	def listen_for_replies
		@cap = PacketFu::Capture.new(
			:filter => "tcp and src port #{@port}",
			:start => true
		)
	end

	def collect_results
		puts "Collecting results"
		@cap.save
		@cap.array.each do |p|
			pkt = PacketFu::Packet.parse(p)
			@listeners << pkt.ip_saddr
		end
		list_listeners
	end

	def ack_scan
		@type = :ack
		listen_for_replies
		scan
		collect_results
	end

end

# Now for the rest of setup.

def usage
	puts "  Usage: #{$0} net.work.octets portnum"
	puts "  Example: #{$0} 10.0.0 80 # Ack port 80 on 10.0.0.0..255"
	exit 1
end

@net = ARGV[0]
@port = ARGV[1]
usage unless @net =~ /^\d+\.\d+\.\d+$/
usage unless @port =~ /^\d+/
start = Time.now

# Actually run the scan

p = PortScanner.new(@net, @port)
# Threading doesn't matter much
p.ack_scan
finish = Time.now
puts "Time elapsed: %.02f seconds" % [finish - start]

