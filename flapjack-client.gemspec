# -*- encoding: utf-8 -*-
#require File.expand_path('../lib/flapjack/client/version', __FILE__)
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flapjack/client/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Jestin Woods"]
  gem.email         = ["jestin.woods@jivesoftware.com"]
  gem.summary       = %q{Command line client for Flapjack.}
  gem.description   = %q{Command line client for Flapjack that relies heavily on Flapjack-Diner.}
  gem.homepage      = ""
  gem.license       = "MIT"

	gem.files         = `git ls-files`.split($\) - ['Gemfile.lock']
	gem.executables   = ["flappy"]
  gem.test_files    = gem.files.grep(%r{^(test|gem|features)/})
  gem.name          = "flapjack-client"
  gem.require_paths = ["lib"]
  gem.version       = Flapjack::Client::VERSION

  gem.add_runtime_dependency "flapjack-diner"
  gem.add_runtime_dependency "thor"
end
