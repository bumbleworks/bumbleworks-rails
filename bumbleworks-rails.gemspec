$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bumbleworks/rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bumbleworks-rails"
  s.version     = Bumbleworks::Rails::VERSION
  s.authors     = ["Ravi Gadad"]
  s.email       = ["ravi@gadad.net"]
  s.homepage    = ""
  s.summary     = "Rails Engine for integrating Bumbleworks into Rails."
  s.description = "Rails Engine for integrating Bumbleworks into Rails."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.2"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end