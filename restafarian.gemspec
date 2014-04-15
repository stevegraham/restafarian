$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "restafarian/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "restafarian"
  s.version     = Restafarian::VERSION
  s.authors     = ["Stevie Graham"]
  s.email       = ["sjtgraham@mac.com"]
  s.homepage    = "https://github.com/stevegraham/restafarian"
  s.summary     = "A tool for implementing real REST HTTP APIs."
  s.description = "Expose fully RESTful HTTP APIs including code-on-demand " +
    "so client can intelligent present most appropriate UI element for each " +
    "property & perform arbitrary, non-authorative, client-side validations " +
    "before submitting data to the API server."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  # s.add_dependency "rails", "~> 4.0.1"
  # s.add_dependency "uncle", "~> 0.0.4"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails", "~> 2.14.0"
  s.add_development_dependency "rack-test", "~> 0.6.2"
end
