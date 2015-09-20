# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'constant_enum/version'

Gem::Specification.new do |spec|
  spec.name          = "constant-enum"
  spec.version       = ConstantEnum::VERSION
  spec.authors       = ["Nate Wiger"]
  spec.email         = ["nwiger@gmail.com"]

  spec.summary       = %q{ActiveRecord-like model for constant data.}
  spec.description   = %q{ActiveRecord-like model for constant data. Designed to work well with ActiveRecord enums.}
  spec.homepage      = "https://github.com/nateware/constant-enum"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
