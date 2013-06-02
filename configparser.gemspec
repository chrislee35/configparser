# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'configparser/version'

Gem::Specification.new do |spec|
	spec.name          = "configparser"
	spec.version       = Configparser::VERSION
	spec.authors       = ["chrislee35"]
	spec.email         = ["rubygems@chrislee.dhs.org"]
	spec.description   = %q{parses configuration files compatable with Python's ConfigParser}
	spec.summary       = %q{parses configuration files compatable with Python's ConfigParser}
	spec.homepage      = "https://github.com/chrislee35/configparser"
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_development_dependency "bundler", "~> 1.3"
	spec.add_development_dependency "rake"

	spec.signing_key   = "#{File.dirname(__FILE__)}/../gem-private_key.pem"
	spec.cert_chain    = ["#{File.dirname(__FILE__)}/../gem-public_cert.pem"]

	spec.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
end
