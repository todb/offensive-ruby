#!/usr/bin/env ruby

$:.unshift File.expand_path("../lib")
require 'telnet_client'

user = ARGV[0]
host = ARGV[1]

unless ARGV[1]
	puts "Usage: #{$0} username targethost"
	exit 1
end

client = TelnetClient.new(:timeout => 1)
client.host = host
client.user = user
client.bruteforce
