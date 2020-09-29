lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'poker_engine/version'

Gem::Specification.new do |spec|
  spec.name = 'poker-engine'
  spec.version = PokerEngine::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.author = 'Kamen Kanev'
  spec.email = 'kamen.e.kanev@gmail.com'
  spec.homepage = 'https://github.com/kanevk/poker-engine'
  spec.summary = 'Poker library introducing the game logic into a simple interface.'
  spec.description = <<-DESC
    Poker library introducing the game logic with a simple interface. Currently offering only 6-max Holdem games.
  DESC
  spec.metadata = { 'github' => 'https://github.com/kanevk/poker-engine' }
  spec.license = 'MIT'

  spec.files = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE', '*.md']
  spec.bindir = 'bin'

  spec.add_runtime_dependency 'hamster', '~> 3.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'colorize', '~> 0.8'
  spec.add_development_dependency 'pry-byebug', '~> 3.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.48'
end
