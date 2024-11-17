# frozen_string_literal: true

require_relative "lib/cloudflare/dns/update/version"

Gem::Specification.new do |spec|
	spec.name = "cloudflare-dns-update"
	spec.version = Cloudflare::DNS::Update::VERSION
	
	spec.summary = "A dyndns client for Cloudflare."
	spec.authors = ["Samuel Williams", "Hirofumi Wakasugi", "John Labovitz", "Olle Jonsson"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/cloudflare-dns-update",
		"source_code_uri" => "https://github.com/socketry/cloudflare-dns-update",
	}
	
	spec.files = Dir.glob(["{bin,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["cloudflare-dns-update"]
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "cloudflare", "~> 4.0"
	spec.add_dependency "samovar", "~> 2.0"
	spec.add_dependency "tty-prompt", "~> 0.21"
end
