# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: sidamo 0.8.1 ruby lib

Gem::Specification.new do |s|
  s.name = "sidamo"
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Ryan Koopmans"]
  s.date = "2015-06-11"
  s.description = "Evaluate Coffeescript within Ruby.  Uses V8 via http://github.com/cowboyd/therubyracer."
  s.email = "koops@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/sidamo.rb",
    "sidamo.gemspec",
    "spec/fixtures/tripler.coffee",
    "spec/sidamo_spec.rb",
    "spec/spec_helper.rb",
    "src/coffee-script.js"
  ]
  s.homepage = "http://github.com/koops/sidamo"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Evaluate Coffeescript within Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<therubyracer>, ["= 0.12.1"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1.0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
    else
      s.add_dependency(%q<therubyracer>, ["= 0.12.1"])
      s.add_dependency(%q<rspec>, ["~> 3.1.0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
    end
  else
    s.add_dependency(%q<therubyracer>, ["= 0.12.1"])
    s.add_dependency(%q<rspec>, ["~> 3.1.0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
  end
end

