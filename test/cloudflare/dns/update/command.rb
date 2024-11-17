# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2024, by Samuel Williams.

require "cloudflare/dns/update/command"
require "cloudflare/a_connection"

describe Cloudflare::DNS::Update::Command::Top do
	include_context Cloudflare::AConnection
	
	let(:configuration_path) {File.join(__dir__, "test.yaml")}
	let(:command) {subject.new(["-c", configuration_path])}
	let(:subdomain) {"test-#{SecureRandom.hex(4)}"}
	
	before do
		@dns_record = zone.dns_records.create("A", subdomain, "127.0.0.1", ttl: 240, proxied: false)
	end
	
	after do
		@dns_record&.delete
	end
	
	it "should update dns record" do
		command.connection = connection
		
		command.configuration_store.transaction do |configuration|
			configuration[:content_command] = "curl -s ipinfo.io/ip"
			configuration[:zone] = zone.value
			configuration[:domains] = [@dns_record.value]
		end
		
		content = command.update_domains
		
		response = @dns_record.with.content
		
		expect(response.result[:content]).to be == content
	end
end
