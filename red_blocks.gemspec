# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'red_blocks/version'

Gem::Specification.new do |spec|
  spec.name          = "red_blocks"
  spec.version       = RedBlocks::VERSION
  spec.authors       = ["Altech"]
  spec.email         = ["takeno.sh@gmail.com"]

  spec.summary       = 'Object-oriented abstraction of Redis sorted set.'
  spec.description   = 'This module provides classes of redis sorted set'\
    ' to implement fast ranking, search, filtering'\
    ' with coherent cache management policy.'
  spec.homepage      = "https://github.com/Altech/red_blocks"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency "redis", ">= 3.3", "< 5.0"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "mock_redis", "~> 0.17"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
end
