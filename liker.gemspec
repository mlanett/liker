# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "liker/version"

Gem::Specification.new do |s|
  s.name        = "liker"
  s.version     = Liker::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mark Lanett"]
  s.email       = ["mark.lanett@gmail.com"]
  s.summary     = %q{Microsite with Like buttons}

  s.rubyforge_project = "liker"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency( "rack-fiber_pool" )
  s.add_dependency( "sinatra" )
  s.add_dependency( "thin" )
end
