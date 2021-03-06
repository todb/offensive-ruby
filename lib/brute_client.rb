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
		# Use a more realistic set of top passwords http://xato.net/wp-content/xup/diff.png
		@passlist = opts[:passlist] || %w{password 123456 qwerty test123 dragon pussy 696969 letmein baseball}
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
		max = @passlist.size
		puts "Trying #{max} password#{max > 1 ? 's' : ''}..."
		@passlist.each do |pw|
			@pass = pw
			puts "*** Success: #{@user}@#{@host}:#{@pass}" if connect
		end
	end

end
