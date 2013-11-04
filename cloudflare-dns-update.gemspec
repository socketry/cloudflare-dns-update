# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudflare/dns/update/version'

Gem::Specification.new do |spec|
	spec.name          = "cloudflare-dns-update"
	spec.version       = CloudFlare::DNS::Update::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]
	spec.description   = <<-EOF
	Provides a client tool for updating CloudFlare records, with a specific
	emphasis on updating IP addresses for domain records. This provides
	dyndns-like functionality.
	EOF
	spec.summary       = "A dyndns client for CloudFlare."
	spec.homepage      = ""
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_development_dependency "bundler", "~> 1.3"
	spec.add_development_dependency "rake"
	
	spec.add_dependency "trollop"
	spec.add_dependency "cloudflare"
end
