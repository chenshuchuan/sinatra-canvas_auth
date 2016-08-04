# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinatra/canvas_auth'

Gem::Specification.new do |spec|
  spec.name          = "sinatra-canvas_auth"
  spec.version       = Sinatra::CanvasAuth::VERSION
  spec.author        = "Connor Ford"
  spec.email         = "connor.ford@ucdenver.edu"
  spec.summary       = %q{Canvas LMS OAuth flow for Sinatra}
  spec.homepage      = "https://github.com/cuonline"
  spec.license       = "MIT"

  spec.files = Dir['lib/**/*', 'README.md']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "sinatra", "~> 1.4"
  spec.add_runtime_dependency "rest-client", "~> 1.8"
end