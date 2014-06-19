# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "inquisitive"
  spec.version       = "2.0.0"
  spec.authors       = ["Chris Keele"]
  spec.email         = ["dev@chriskeele.com"]
  spec.summary       = "Predicate methods for those curious about their datastructures."
  spec.description   = <<-DESC
    Predicate methods for those curious about their datastructures.
    
    Provides String, Array, and Hash subclasses with dynamic predicate methods that
    allow you to interrogate the contents of the most common Ruby datastructures
    in a readable, friendly fashion.
    
    Also allows you to auto-instanciate and read inquisitive datastructures straight
    from your `ENV` hash.
  DESC
  spec.homepage      = "https://github.com/rawsugar/inquisitive"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",   ">= 1.3"
  spec.add_development_dependency "rake",      ">= 10.0"
  spec.add_development_dependency "minitest",  ">= 5.0"
end
