# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.
# Copyright, 2023, by John Labovitz.

require "samovar"
require "yaml/store"
require "tty/prompt"

require "open3"
require "json"

require "cloudflare"
require_relative "version"

module Cloudflare::DNS::Update
	module Command
		def self.call(*arguments)
			Top.call(*arguments)
		end
		
		# The top level utopia command.
		class Top < Samovar::Command
			self.description = "Update remote DNS records according to locally run commands."
			
			options do
				option "-c/--configuration <path>", "Use the specified configuration file.", default: "dns.conf"
				option "-f/--force", "Force push updates to cloudflare even if content hasn't changed.", default: false
				option "-v/--version", "Print out the application version."
			end
			
			def prompt
				@prompt ||= TTY::Prompt.new
			end
			
			def configuration_store
				@store ||= YAML::Store.new(@options[:configuration])
			end
			
			attr_accessor :connection
			
			def connect!
				configuration_store.transaction do |configuration|
					unless configuration[:token]
						prompt.puts "This configuration does not contain authorization token, we require some details."
						configuration[:token] = prompt.mask("Cloudflare token:")
					end
					
					@connection = Cloudflare.connect(token: configuration[:token])
				end
				
				return @connection unless block_given?
				
				begin
					yield @connection
				rescue Interrupt
					# Exit gracefully
				ensure
					@connection.close
				end
			end
			
			def initialize_zone
				configuration_store.transaction do |configuration|
					unless configuration[:zone]
						zone = prompt.select("What zone do you want to update?", @connection.zones)
						
						configuration[:zone] = zone.value
					end
				end
			end
			
			def initialize_domains
				configuration_store.transaction do |configuration|
					domains = configuration[:domains]
					
					while domains.nil? || domains.empty?
						prompt.puts "Getting list of domains for #{configuration[:zone][:name]}..."
						
						zone_id = configuration[:zone][:id]
						zone = @connection.zones.find_by_id(zone_id)
						
						dns_records = prompt.multi_select("What records do you want to update (select 1 or more)?", zone.dns_records)
						
						domains = configuration[:domains] = dns_records.map(&:value)
					end
				end
			end
			
			def initialize_command
				configuration_store.transaction do |configuration|
					unless configuration[:content_command]
						configuration[:content_command] = prompt.ask("What command to get content for record?", default: "curl -s ipinfo.io/ip")
					end
				end
			end
			
			def update_domain(zone, record, content)
				if content != record[:content] || @options[:force]
					Console.info "Content changed #{content.inspect}, updating records..."
					
					domain = zone.dns_records.find_by_id(record[:id])
						
					begin
						domain.update_content(content)
						
						Console.info "Updated domain: #{record[:name]} #{record[:type]} #{content}"
						record[:content] = content
					rescue => error
						Console.warn("Failed to update domain: #{record[:name]} #{record[:type]} #{content}", error)
					end
				else
					Console.debug "Content hasn't changed: #{record[:name]} #{record[:type]} #{content}"
				end
			end
			
			def update_domains(content = nil)
				configuration_store.transaction do |configuration|
					unless content
						Console.debug "Executing content command: #{configuration[:content_command]}"
						content, status = Open3.capture2(configuration[:content_command])
						
						unless status.success?
							raise RuntimeError.new("Content command failed with non-zero output: #{status}")
						end
						
						# Make sure there is no trailing space:
						content.chomp!
						
						configuration[:content] = content
					end
					
					unless zone = @connection.zones.find_by_id(configuration[:zone][:id])
						raise RuntimeError.new("Couldn't load zone #{configuration[:zone].inspect} from API!")
					end
					
					configuration[:domains].each do |record|
						update_domain(zone, record, content)
					end
				end
				
				return content
			end
			
			def call
				if @options[:version]
					puts VERSION
				elsif @options[:help]
					print_usage
				else
					Sync do
						connect! do
							initialize_zone
							initialize_domains
							initialize_command
							
							update_domains
						end
					end
				end
			end
		end
	end
end
