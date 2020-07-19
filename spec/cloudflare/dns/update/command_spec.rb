
require 'cloudflare/dns/update/command'

RSpec.describe Cloudflare::DNS::Update::Command::Top, order: :defined, timeout: 60 do
	include_context Cloudflare::RSpec::Connection
	
	let(:configuration_path) {File.join(__dir__, 'test.yaml')}
	
	subject{described_class.new(["-c", configuration_path])}
	
	let(:zone) {connection.zones.first}
	let!(:name) {"dyndns-#{ENV['INVOCATION_ID']}"}
	let!(:qualified_name) {"#{name}.#{zone.name}"}
	
	it "should create dns record" do
		zone.dns_records.create("A", name, "127.0.0.1", ttl: 240, proxied: false)
	end
	
	let(:dns_record) {zone.dns_records.find_by_name(qualified_name)}
	
	it "should update dns record" do
		subject.connection = connection
		
		subject.configuration_store.transaction do |configuration|
			configuration[:content_command] = 'curl -s ipinfo.io/ip'
			configuration[:zone] = zone.value
			configuration[:domains] = [dns_record.value]
		end
		
		content = subject.update_domains
		
		response = dns_record.get
		
		expect(response.result[:content]).to be == content
	end
	
	it "should delete dns record" do
		expect(dns_record.delete).to be_success
	end
end
