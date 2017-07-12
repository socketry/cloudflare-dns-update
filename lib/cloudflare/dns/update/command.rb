# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'samovar'
require 'yaml/store'
require 'tty/prompt'

require 'open3'
require 'json'

require 'cloudflare'
require_relative 'version'

module Cloudflare::DNS::Update
	module Command
		def self.parse(*args)
			Top.parse(*args)
		end
		
		# The top level utopia command.
		class Top < Samovar::Command
			self.description = "Update remote DNS records according to locally run commands."
			
			options do
				option '-c/--configuration <path>', "Use the specified configuration file."
				option '-f/--force', "Force push updates to cloudflare even if content hasn't changed.", default: false
				option '--verbose | --quiet', "Verbosity of output for debugging.", key: :logging
				option '-h/--help', "Print out help information."
				option '-v/--version', "Print out the application version."
			end
			
			def verbose?
				@options[:logging] == :verbose
			end

			def quiet?
				@options[:logging] == :quiet
			end

			def logger
				@logger ||= Logger.new($stderr).tap do |logger|
					if verbose?
						logger.level = Logger::DEBUG
					elsif quiet?
						logger.level = Logger::WARN
					else
						logger.level = Logger::INFO
					end
				end
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
					unless configuration[:key]
						prompt.puts "This configuration file appears to be new, we require some details."
						configuration[:key] = prompt.mask("Cloudflare Key:")
						configuration[:email] = prompt.ask("Cloudflare Email:")
					end
					
					key = configuration[:key]
					email = configuration[:email]
					
					@connection = Cloudflare.connect(key: key, email: email)
				end
			end
			
			def initialize_zone
				configuration_store.transaction do |configuration|
					unless configuration[:zone]
						zone = prompt.select("What zone do you want to update?", @connection.zones.all)
						
						configuration[:zone] = zone.record
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
						
						dns_records = prompt.multi_select("What records do you want to update (select 1 or more)?", zone.dns_records.all)
						
						domains = configuration[:domains] = dns_records.map(&:record)
					end
				end
			end
			
			def initialize_command
				configuration_store.transaction do |configuration|
					unless configuration[:content_command]
						configuration[:content_command] = prompt.ask("What command to get content for record?", default: 'curl -s ipinfo.io/ip')
					end
				end
			end
			
			def update_domains
				configuration_store.transaction do |configuration|
					logger.debug "Executing content command: #{configuration[:content_command]}"
					content, status = Open3.capture2(configuration[:content_command])
					
					unless status.success?
						raise RuntimeError.new("Content command failed with non-zero output: #{status}")
					end
					
					unless zone = @connection.zones.find_by_id(configuration[:zone][:id])
						raise RuntimeError.new("Couldn't load zone #{configuration[:zone].inspect} from API!")
					end
					
					# Make sure there is no trailing space:
					content.chomp!
					
					if content != configuration[:content] || @options[:force]
						logger.info "Content changed #{content.inspect}, updating records..."
						
						configuration[:domains].each do |record|
							domain = zone.dns_records.find_by_id(record[:id])
							
							changes = {
								type: domain.record[:type],
								name: domain.record[:name],
								content: content
							}
							
							response = domain.put(changes.to_json, content_type: 'application/json')
							
							if response.successful?
								logger.info "Updated domain content to #{content}."
								record[:content] = content
							else
								logger.warn "Failed to update domain content to #{content}: #{response.errors.join(', ')}!"
							end
						end
						
						# Save the last value of content:
						configuration[:content] = content
					else
						logger.debug "Content hasn't changed."
					end
					
					return content
				end
			end
			
			def invoke(program_name: File.basename($0))
				if @options[:version]
					puts VERSION
				elsif @options[:help]
					print_usage(program_name)
				else
					connect!
					
					initialize_zone
					initialize_domains
					initialize_command
					
					update_domains
				end
			end
		end
	end
end
