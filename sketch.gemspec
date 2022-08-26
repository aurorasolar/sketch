# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "sketch-in-ruby"
  s.version     = '1.0.0'
  s.authors     = ["Brandon Fosdick", "Meseker Yohannes"]
  s.email       = ["myohannes@aurorasolar.com"]
  s.homepage    = "https://github.com/aurorasolar/sketch"
  s.summary     = %q{2D mechanical sketches}
  s.description = %q{Sketches used in the creation of mechanical designs}
  s.required_ruby_version = ">= 2.7.5", "< 3.2"

  s.rubyforge_project = "sketch"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'geometry-in-ruby', '~> 1.0'

  s.add_development_dependency 'minitest'
end
