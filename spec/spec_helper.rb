
require 'covered/rspec'
require "cloudflare/rspec/connection"

JOB_ID = ENV.fetch('INVOCATION_ID', 'testing').hash
NAMES = %w{alligator ant bear bee bird camel cat cheetah chicken chimpanzee cow crocodile deer dog dolphin duck eagle elephant fish fly fox frog giraffe goat goldfish hamster hippopotamus horse kangaroo kitten lion lobster monkey octopus owl panda pig puppy rabbit rat scorpion seal shark sheep snail snake spider squirrel tiger turtle wolf zebra}
ZONE_NAME = "#{NAMES[JOB_ID % NAMES.size]}.com"

RSpec.shared_context Cloudflare::Zone do
	let(:zones) {connection.zones}
	
	let(:account) {connection.accounts.first}
	let(:zone) {@zone = zones.find_by_name(ZONE_NAME) || zones.create(ZONE_NAME, account)}
	
	let(:subdomain) {"cloudflare-dns-update-#{JOB_ID}"}
end

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = ".rspec_status"

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end
