
require 'cloudflare/dns/update/command'

RSpec.describe Cloudflare::DNS::Update::Command::Top, order: :defined do
	include_context Cloudflare::RSpec::Connection
	
	let(:configuration_path) {File.join(__dir__, 'test.yaml')}
	
	subject{described_class.new(["-c", configuration_path])}
	
	let(:zone) {connection.zones.all.first}
	let(:name) {"dyndns"}
	let(:qualified_name) {"dyndns.#{zone.record[:name]}"}
	
	it "should create dns record" do
		response = zone.dns_records.post({
			type: "A",
			name: name,
			content: "127.0.0.1",
			ttl: 240,
			proxied: false
		}.to_json, content_type: 'application/json')
		
		expect(response).to be_successful
	end
	
	let(:dns_record) {zone.dns_records.find_by_name(qualified_name)}
	
	it "should update dns record" do
		subject.connection = connection
		
		puts 
		
		subject.configuration_store.transaction do |configuration|
			configuration[:content_command] = 'curl -s ipinfo.io/ip'
			configuration[:zone] = zone.record
			configuration[:domains] = [dns_record.record]
		end
		
		content = subject.update_domains
		
		response = dns_record.get
		
		expect(response.result[:content]).to be == content
	end
	
	it "should delete dns record" do
		expect(dns_record.delete).to be_successful
	end
end
