#!/usr/bin/env ruby

require 'brute_client'
require 'pg' # From RubyGems

class PostgresClient < BruteClient

	attr_accessor :db

	def connect
		@target.close rescue nil
		puts "Trying %s/%s:%s@%s" % [@db, @user, @pass, @host]
		begin
		@target = PG::Connection.open(
			:dbname => @db,
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
