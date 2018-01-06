require File.expand_path('../lib/poker_engine', __FILE__)

Gem::Specification.new do |spec|
  spec.name        = 'poker-engine'
  spec.version     = PokerEngine::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ['Kamen Kanev']
  spec.email       = ['kamen.e.kanev@gmail.com']
  spec.homepage    = ''
  spec.summary     = 'Poker engine'
  spec.description = ''

  spec.required_rubygems_version = '>= 1.3.6'

  spec.rubyforge_project         = 'poker-engine'

  # If you have other dependencies, add them here
  # spec.add_dependency 'another', '~> 1.2'

  # If you need to check in files that aren't .rb files, add them here
  spec.files        = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE', '*.md']
  spec.require_path = 'lib'

  # spec.add_runtime_dependency 'danger', '~> 3.0'
  spec.add_runtime_dependency 'hamster'

  # General ruby development
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.48'
  spec.add_development_dependency 'pry'

  # If you need an executable, add it here
  # spec.executables = ['newgem']

  # If you have C extensions, uncomment this line
  # spec.extensions = 'ext/extconf.rb'
end
