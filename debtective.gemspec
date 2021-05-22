# frozen_string_literal: true

require_relative "lib/debtective/version"

Gem::Specification.new do |spec|
  spec.name                  = "debtective"
  spec.version               = Debtective::VERSION
  spec.authors               = ["Edouard Piron"]
  spec.email                 = ["ed.piron@gmail.com"]
  spec.homepage              = "https://github.com/perangusta/debtective"
  spec.summary               = "Collection of tasks to help find out debt."
  spec.description           = "Collection of tasks to help find out debt."
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 2.6"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/perangusta/debtective"
  spec.metadata["changelog_uri"]   = "https://github.com/perangusta/debtective/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.3", ">= 6.1.3.2"
end
