#!/usr/bin/env ruby

require 'brute_client'
require 'pg' # From RubyGems

class PostgresClient < BruteClient

	def connect
		@target.close rescue nil
		puts "Trying template1/%s:%s@%s" % [@user, @pass, @host]
		begin
		@target = PG::Connection.open(
			:dbname => 'template1',
			:host   => @host,
			:user   => @user,
			:password => @pass
		)
			@good = true
		rescue
			@good = false
		end
	end

end
