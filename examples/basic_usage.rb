#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Basic Truedocs Ruby Gem Usage
# Run with: ruby examples/basic_usage.rb

require_relative "../lib/truedocs"

# Configuration
Truedocs.configure do |config|
  config.api_key = ENV["TRUEDOCS_API_KEY"] || "your_api_key_here"
  config.base_url = "https://api.truedocs.mx"
  config.timeout = 60
end

# Create a client instance
Truedocs.new

begin
  puts "=== Truedocs Ruby Gem Example ==="
  puts

  # Example 1: Document Classification
  puts "1. Document Classification"
  puts "   client.classify_document('path/to/document.pdf')"
  puts

  # Example 2: Data Extraction
  puts "2. Data Extraction"
  puts "   client.extract_data('path/to/document.pdf')"
  puts

  # Example 3: Document Verification (Sync)
  puts "3. Document Verification (Synchronous)"
  puts "   client.verify_document('path/to/document.pdf', 'constancia_de_situacion_fiscal')"
  puts

  # Example 4: Document Verification (Async)
  puts "4. Document Verification (Asynchronous)"
  puts "   job = client.verify_document('path/to/document.pdf', 'constancia_de_situacion_fiscal', async: true)"
  puts "   result = client.wait_for_job(job.job_id)"
  puts

  # Example 5: Document Matching
  puts "5. Document Matching (String Search)"
  puts "   client.match_document('path/to/document.pdf', 'identifier', threshold: 80, top_k: 5)"
  puts

  # Example 6: Document Query
  puts "6. Document Query"
  puts "   client.query_document('path/to/document.pdf', 'What is the expiration date?')"
  puts

  # Example 7: Ask AI About Document
  puts "7. AI-Powered Document Questions"
  puts "   client.ask_document('path/to/document.pdf', 'Is this document valid?')"
  puts

  # Example 8: Document Validation
  puts "8. Document Validation"
  puts "   client.validate_document('path/to/document.pdf', 'DidExpire')"
  puts

  # Example 9: Job Status Checking
  puts "9. Job Status Checking"
  puts "   status = client.get_job_status('job_id_here')"
  puts

  # Example 10: Feedback
  puts "10. Providing Feedback"
  puts "    client.feedback(is_positive: true, endpoint: 'classify', description: 'Great results!')"
  puts

  puts "=== To run these examples with real files, replace the file paths and ensure you have a valid API key ==="
rescue Truedocs::Error => e
  puts "Truedocs Error: #{e.message}"
rescue StandardError => e
  puts "Error: #{e.message}"
end
