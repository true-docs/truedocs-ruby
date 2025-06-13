# frozen_string_literal: true

require_relative "lib/truedocs/version"

Gem::Specification.new do |spec|
  spec.name = "truedocs"
  spec.version = Truedocs::VERSION
  spec.authors = ["Truedocs Team"]
  spec.email = ["rod@truedocs.mx"]

  spec.summary = "Ruby client for the Truedocs document processing API"
  spec.description = "A comprehensive Ruby gem for interacting with Truedocs AI-powered document processing services"
  spec.homepage = "https://github.com/true-docs/truedocs-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://api.truedocs.mx/docs"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-multipart", "~> 1.0"
  spec.add_dependency "faraday-retry", "~> 2.0"
  spec.add_dependency "marcel", "~> 1.0" # MIME type detection

  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.57"
  spec.add_development_dependency "rubocop-rspec", "~> 2.25"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "vcr", "~> 6.1"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "yard", "~> 0.9"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
