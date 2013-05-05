#!/usr/bin/env ruby

require 'rexml/document'

class Host

	attr_accessor :address, :services

	def initialize
		@address = {:mac => nil, :ip => nil}
		@services = []
		return self
	end

end

class Service
	attr_accessor :port, :protocol, :name

	def initialize(port, protocol, name)
		@port     = port
		@protocol = protocol
		@name     = name
		return self
	end
end

class NmapParser
	attr_accessor :fname, :data, :fsize
	attr_accessor :hosts, :host_count, :services, :service_count
	attr_accessor :ips, :macs

	def initialize(fname)
		@fname = fname
		@hosts = []
		self.read
		self.parse
		return self
	end

	def read
		@data = File.open(@fname, 'rb') {|f| f.read}
		@fsize = @data.size
	end

	def parse
		read unless @data
		collect_hosts
	end

	def collect_hosts
		doc = REXML::Document.new(@data)
		@host_count = 0
		@service_count = 0
		doc.each_element("//host") do |host|
			next if host.elements['status'].attributes['state'] == 'down'
			@host_count += 1
			this_host = Host.new
			collect_addresses(host, this_host)
			collect_services(host, this_host)
			@ips = hosts.map {|h| h.address[:ip]}
			@macs = hosts.map {|h| h.address[:mac]}
		end
		@host_count
	end

	def collect_addresses(host, this_host)
		host.each_element("address") do |address|
			addrtype = address.attributes['addrtype']
			addr = address.attributes['addr']
			case addrtype
			when 'mac'
				this_host.address[:mac] = addr
			when 'ipv4'
				this_host.address[:ip] = addr
			end
		end
		@hosts << this_host
	end

	def collect_services(host, this_host)
		host.each_element("ports") do |ports|
			ports.each_element do |port|
				next unless port.name == "port"
				next unless port.elements["state"].attributes['state'] == "open"
				@service_count += 1
				number = port.attributes['portid'].to_i
				proto  = port.attributes['protocol']
				name   = port.elements['service'].attributes['name']
				this_service = Service.new(number, proto, name)
				this_host.services << this_service
			end
		end
	end

	def services
		@services = []
		@hosts.each do |host|
			host.services.each do |service|
				@services << {
					:ip       => host.address[:ip],
					:port     => service.port,
					:protocol => service.protocol
				}
			end
		end
		@services
	end

	def host(addr)
		@hosts.select {|h| h.address.values.include? addr}.first
	end

	# Redefine to_s to avoid object inspection cluttered with
	# unparsed data.
	def to_s
		obj = [self.class.to_s,self.object_id].join(":")
		attrs = [:@fname, :@fsize, :@host_count, :@service_count]
		attrs = attrs.map {|a| "#{a}=#{self.instance_variable_get(a).inspect}"}
		"#<#{obj} #{attrs.join(' ')}>"
	end

end
