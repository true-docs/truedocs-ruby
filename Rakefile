# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

# Default task
task default: %i[spec api:test]

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

# Real API testing tasks
namespace :api do
  desc "Test against real API and record VCR cassettes"
  task :record do
    puts "🎬 Recording real API responses with VCR..."
    puts "Make sure TRUEDOCS_API_KEY is set in your .env file"
    puts

    # Set VCR to record new episodes
    ENV["VCR_RECORD_MODE"] = "new_episodes"
    
    # Run only the real API recording spec
    sh "bundle exec rspec spec/integration/real_api_recording_spec.rb --format documentation"
    
    puts
    puts "✅ VCR cassettes recorded!"
    puts "Check spec/fixtures/vcr_cassettes/real_api/ for the recorded responses"
  end

  desc "Test against real API (no recording)"
  task :test do
    puts "🧪 Testing against real API..."
    puts "Make sure TRUEDOCS_API_KEY is set in your .env file"
    puts

    # Run the existing integration tests
    sh "bundle exec rspec spec/integration/v2_api_compatibility_spec.rb --format documentation"
  end

  desc "Clean VCR cassettes"
  task :clean do
    puts "🧹 Cleaning VCR cassettes..."
    sh "rm -rf spec/fixtures/vcr_cassettes/real_api/"
    puts "✅ VCR cassettes cleaned!"
  end

  desc "Show VCR cassettes"
  task :cassettes do
    puts "📼 VCR Cassettes:"
    if Dir.exist?("spec/fixtures/vcr_cassettes")
      Dir.glob("spec/fixtures/vcr_cassettes/**/*.yml").each do |file|
        size = File.size(file)
        puts "  #{file} (#{size} bytes)"
      end
    else
      puts "  No cassettes found"
    end
  end
end
