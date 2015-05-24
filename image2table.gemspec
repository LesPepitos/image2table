# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'image2table/version'

Gem::Specification.new do |spec|
  spec.name          = "image2table"
  spec.version       = Image2table::VERSION
  spec.authors       = ["shakaman"]
  spec.email         = ["mbenadon@shakaman.com"]
  spec.summary       = ""
  spec.description   = "Tool to convert image to table html"
  spec.homepage      = "https://github.com/shakaman/image2table"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",  "~> 1.7"
  spec.add_development_dependency "rspec",    "~> 3.2"
end
