#!/usr/bin/env ruby

require 'brute_client'
require 'net/ssh'

class SshClient < BruteClient

	def connect
		@target.close rescue nil
		puts "Trying %s:%s@%s" % [@user, @pass, @host]
		begin
			@target = Net::SSH.start(@host, @user, :password => @pass)
			@good = true
		rescue
			@good = false
		end
	end

end
