$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "survey/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "survey"
  s.version     = Survey::VERSION
  s.authors     = ["Mindfire Solutions Pvt Ltd"]
  s.email       = ["anyone@mindfiresolutions.com"]
  s.homepage    = "http://mindfiresolutions.com"
  s.summary     = "This is an integratable survey module"
  s.description = "This is an integratable survey module."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.3"
  s.add_dependency "nested_form"
  s.add_dependency "jquery-datatables-rails"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
