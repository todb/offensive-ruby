#!/usr/bin/env ruby

class Netmask

	attr_accessor :addr, :mask
	attr_accessor :network, :bits

	def initialize(addr="1.2.3.4",mask="255.255.255.0")
		@addr = addr
		@mask = mask
		set_network_and_bits
	end

	def set_network_and_bits
		set_network
		set_bits
		return self
	end

	alias :calc :set_network_and_bits

	def octets(addr)
		case addr
		when String
			oct = addr.split(".")
			oct.map {|o| o.to_i}
		when Integer
			[addr].pack("N").unpack("C4")
		else
			raise ArgumentError, "Not a string or integer"
		end
	end

	def integer(addr)
		octets(addr).pack("C4").unpack("N").first
	end

	def set_network
		net = integer(addr) & integer(mask)
		@network = octets(net).join(".")
	end

	def set_bits
		binary = "%032b" % integer(mask) # More accurate for sub-8-bit masks
		if binary =~ /01/
			raise ArgumentError, "Invalid netmask: #{@mask} (#{binary})"
		else
			@bits = binary.scan("1").size
		end
	end

end
