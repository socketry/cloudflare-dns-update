# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2013-2024, by Samuel Williams.

source "https://rubygems.org"

# Specify your gem's dependencies in cloudflare-dns-update.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"
	
	gem "utopia-project"
end

group :test do
	gem "sus"
	gem "covered"
	gem "decode"
	gem "rubocop"
	
	gem "sus-fixtures-async"
end
