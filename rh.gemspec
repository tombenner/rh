require File.expand_path('../lib/rh/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Tom Benner']
  s.email         = ['tombenner@gmail.com']
  s.description = s.summary = %q{Fast Ruby documentation lookup}
  s.homepage      = 'https://github.com/tombenner/rh'

  s.files         = `git ls-files`.split($\)
  s.name          = 'rh'
  s.require_paths = ['lib']
  s.executables   = ['rh']
  s.version       = Rh::VERSION
  s.license       = 'MIT'

  s.add_dependency 'launchy', '~> 2.4'

  s.add_development_dependency 'rspec', '~> 3.1'
end
