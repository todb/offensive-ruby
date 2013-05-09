#!/usr/bin/env ruby

require 'brute_client'
require 'net/telnet'

class TelnetClient < BruteClient

	def connect
		@target.close rescue nil
		puts "Trying %s:%s@%s" % [@user, @pass, @host]
		@target = Net::Telnet.new( "Host" => @host, "Timeout" => @timeout)
		begin
			@target.login(@user, @pass)
			@good = true
		rescue
			@good = false
		end
	end

end
