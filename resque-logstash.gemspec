# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/logstash/version'

Gem::Specification.new do |spec|
  spec.name          = "resque-logstash"
  spec.version       = Resque::Plugins::Logstash::VERSION
  spec.authors       = ["Eugene Pimenov"]
  spec.email         = ["eugene@libc.st"]
  spec.description   = %q{Measure duration of a resque job and log it in the logstash}
  spec.summary       = %q{A really simple logstash logger for resque}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_dependency 'resque', '~> 1.24'
  spec.add_dependency 'logstash-event', '~> 1.2'
end
