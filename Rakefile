# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

# Default task
task default: %i[spec rubocop]

# RSpec test task
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ["--color", "--format", "documentation"]
end

# RuboCop linting task
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ["--display-cop-names"]
end

# RuboCop auto-correct task
RuboCop::RakeTask.new("rubocop:auto_correct") do |task|
  task.options = ["--auto-correct"]
end

# Test with coverage
desc "Run tests with coverage"
task :coverage do
  ENV["COVERAGE"] = "true"
  Rake::Task[:spec].invoke
end

# Quality checks
desc "Run all quality checks"
task quality: %i[spec rubocop]

# CI task (for continuous integration)
desc "Run CI suite"
task ci: [:quality]

# Development setup
desc "Set up development environment"
task :setup do
  puts "Installing dependencies..."
  sh "bundle install"

  puts "Setting up git hooks..."
  sh "bundle exec pre-commit install" if system("which pre-commit > /dev/null 2>&1")

  puts "✅ Development environment ready!"
  puts
  puts "Quick start:"
  puts "  bundle exec rake spec      # Run tests"
  puts "  bundle exec rake rubocop   # Run linter"
  puts "  bundle exec rake coverage  # Run tests with coverage"
  puts "  bundle exec rake quality   # Run all quality checks"
end

# Documentation tasks
namespace :docs do
  desc "Generate YARD documentation"
  task :generate do
    sh "bundle exec yard doc"
  end

  desc "Serve documentation locally"
  task :serve do
    sh "bundle exec yard server --reload"
  end
end

# Release preparation
namespace :release do
  desc "Prepare for release"
  task :prepare do
    puts "Preparing for release..."

    # Run quality checks
    Rake::Task[:quality].invoke

    # Check if we're on main branch
    current_branch = `git rev-parse --abbrev-ref HEAD`.strip
    unless current_branch == "main"
      puts "❌ Must be on main branch to release"
      exit 1
    end

    # Check if working directory is clean
    unless `git status --porcelain`.strip.empty?
      puts "❌ Working directory must be clean to release"
      exit 1
    end

    puts "✅ Ready for release!"
  end
end

# Console task for debugging
desc "Start an interactive console"
task :console do
  require "irb"
  require_relative "lib/truedocs"

  puts "Loading Truedocs gem..."
  puts "Available: Truedocs.configure, Truedocs.new, etc."
  puts

  IRB.start
end
