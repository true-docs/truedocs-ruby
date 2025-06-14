#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: INE Field Extraction with Truedocs Ruby Gem
# This example extracts specific fields from a Mexican INE (voter ID) card
# Run with: ruby examples/ine_field_extraction.rb

require "dotenv/load"

require_relative "../lib/truedocs"

# Configuration
Truedocs.configure do |config|
  config.api_key = ENV["TRUEDOCS_API_KEY"] || "your_api_key_here"
  config.base_url = "https://api.truedocs.mx"
  config.timeout = 60
end

# Create a client instance
client = Truedocs.new

# Path to the INE image file
ine_image_path = File.join(__dir__, "../spec/fixtures/ine-frente.jpeg")

# Fields we want to extract
target_fields = ["SECCION", "CURP"]

begin
  puts "=== INE Field Extraction Example ==="
  puts "Image: #{File.basename(ine_image_path)}"
  puts "Target fields: #{target_fields.join(', ')}"
  puts "=" * 50
  puts

  # Check if the image file exists
  unless File.exist?(ine_image_path)
    puts "❌ Error: INE image file not found at #{ine_image_path}"
    puts "Please ensure the file exists before running this example."
    exit 1
  end

  puts "📄 Processing INE document..."
  puts "🔍 Extracting data from: #{File.basename(ine_image_path)}"
  puts

  # Extract data from the INE document
  # We can specify the fields we want to extract
  response = client.extract_data(ine_image_path, fields: target_fields)
  puts response.inspect

  puts "✅ Extraction completed successfully!"
  puts "=" * 50
  puts

  # Display the extracted fields
  puts "📋 EXTRACTED FIELDS:"
  puts "-" * 30

  target_fields.each do |field|
    field_key = field.downcase.to_sym
    value = response.fields[field_key] || response.fields[field.to_sym] || "Not found"
    
    puts "#{field.ljust(10)}: #{value}"
  end

  puts
  puts "=" * 50

  # Display all available fields if you want to see what else was extracted
  puts "📊 ALL EXTRACTED FIELDS:"
  puts "-" * 30
  
  if response.fields.any?
    response.fields.each do |key, value|
      next if value.nil? || value.to_s.strip.empty?
      puts "#{key.to_s.ljust(15)}: #{value}"
    end
  else
    puts "No fields were extracted."
  end

  puts
  puts "=" * 50
  puts "✨ Example completed successfully!"

rescue Truedocs::AuthenticationError => e
  puts "❌ Authentication Error: #{e.message}"
  puts "Please check your TRUEDOCS_API_KEY environment variable."
rescue Truedocs::ValidationError => e
  puts "❌ Validation Error: #{e.message}"
rescue Truedocs::NetworkError => e
  puts "❌ Network Error: #{e.message}"
  puts "Please check your internet connection."
rescue Truedocs::TimeoutError => e
  puts "❌ Timeout Error: #{e.message}"
  puts "The request took too long. Please try again."
rescue Truedocs::Error => e
  puts "❌ Truedocs Error: #{e.message}"
rescue StandardError => e
  puts "❌ Unexpected Error: #{e.message}"
  puts "Backtrace:"
  puts e.backtrace.first(5).map { |line| "  #{line}" }
end
