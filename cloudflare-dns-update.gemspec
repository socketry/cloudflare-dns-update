
require_relative "lib/cloudflare/dns/update/version"

Gem::Specification.new do |spec|
	spec.name = "cloudflare-dns-update"
	spec.version = Cloudflare::DNS::Update::VERSION
	
	spec.summary = "A dyndns client for Cloudflare."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.files = Dir.glob('{bin,lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["cloudflare-dns-update"]
	
	spec.required_ruby_version = ">= 2.5"
	
	spec.add_dependency "cloudflare", "~> 4.0"
	spec.add_dependency "samovar", "~> 2.0"
	spec.add_dependency "tty-prompt", "~> 0.21"
	
	spec.add_development_dependency "async-rspec"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rake"
	spec.add_development_dependency "rspec", "~> 3.6"
end
