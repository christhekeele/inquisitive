# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "inquisitive"
  spec.version       = "1.0.0"
  spec.authors       = ["Chris Keele"]
  spec.email         = ["dev@chriskeele.com"]
  spec.description   = "Predicate methods for those curious about their datastructures."
  spec.summary       = "Predicate methods for those curious about their datastructures."
  spec.homepage      = "https://github.com/rawsugar/inquisitive"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",   ">= 1.3"
  spec.add_development_dependency "rake",      ">= 10.0"
  spec.add_development_dependency "minitest",  ">= 5.0"
  spec.add_development_dependency "simplecov", ">= 0.7"
end
