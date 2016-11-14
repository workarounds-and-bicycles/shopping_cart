# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shopping_cart/version'

Gem::Specification.new do |spec|
  spec.name          = 'shopping_cart'
  spec.version       = ShoppingCart::VERSION
  spec.authors       = ['Dmitry Sharikov']
  spec.email         = ['sirgreatest@gmail.com']

  spec.summary       = %q{Simple shopping cart crafted on ruby and redis}
  spec.description   = %q{This guy can run on any ruby(MRI) framework}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'please push it to rubygems.org'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'redis', '~> 3.2'
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'fakeredis', '~> 0.6.0'
end
