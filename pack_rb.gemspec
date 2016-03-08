# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pack_rb/version'

Gem::Specification.new do |spec|
  spec.name          = "pack_rb"
  spec.version       = PackRb::VERSION
  spec.authors       = ["Jonathan Niesen"]
  spec.email         = ["jon.niesen@gmail.com"]

  spec.summary       = %q{A Packer CLI wrapper.}
  spec.description   = ['A gem for driving the Packer command line tool',
                        'from within your Ruby project.'].join(' ')
  spec.homepage      = "https://github.com/manheim/pack_rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do
    |f| f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_development_dependency "guard", "~> 2.13"
  spec.add_development_dependency "guard-bundler", "~> 2.1"
  spec.add_development_dependency "guard-rspec", "~> 4.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
