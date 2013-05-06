#!/usr/bin/env ruby

class BruteClient
	attr_accessor :user, :pass, :host
	attr_accessor :target, :good
	attr_accessor :passlist

	def initialize(opts={})
		@user = opts[:user] || "testuser"
		@pass = opts[:pass] || "testpass"
		@host = opts[:host] || "localhost"
		@timeout = opts[:timeout] || 3
		@passlist = opts[:passlist] || %w{test password1 letmein! test123 qwerty monkey changeme}
		unless @passlist.kind_of? Array
			raise ArgumentError, "Passlist needs to be an Array"
		end
	end

	# This should be redefined by subclasses, and should return true
	# for successful authentication and false for failed.
	def connect
		raise NoMethodError, "BruteClient#connect() called from subclass"
	end

	def bruteforce
		tries = 0
		max = @passlist.size
		puts "Trying #{max} passwords..."
		@passlist.each do |pw|
			@pass = pw
			puts "*** Success: #{@user}@#{@host}:#{@pass}" if connect
			tries += 1
		end
	end

end
