# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/filter_param/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-filter-param"
  spec.version       = Rack::FilterParam::VERSION
  spec.authors       = ["Rob Watson"]
  spec.email         = ["rob@mixlr.com"]

  spec.summary       = "Rack middleware to filter params from HTTP requests"
  spec.homepage      = "https://github.com/rfwatson"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rack-test', '~> 0.6'
  spec.add_development_dependency 'json', '~> 2'
  spec.add_development_dependency 'byebug', '~> 9'
end
