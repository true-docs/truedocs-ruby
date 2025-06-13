# Truedocs Ruby Gem

[![Gem Version](https://badge.fury.io/rb/truedocs.svg)](https://badge.fury.io/rb/truedocs)
[![Build Status](https://github.com/true-docs/truedocs-ruby/workflows/CI/badge.svg)](https://github.com/true-docs/truedocs-ruby/actions)
[![Coverage Status](https://coveralls.io/repos/github/true-docs/truedocs-ruby/badge.svg)](https://coveralls.io/github/true-docs/truedocs-ruby)

The official Ruby client for the [Truedocs API](https://truedocs.mx) - AI-powered document processing, verification, and analysis services.

## Features

- 🔍 **Document Classification** - Automatically identify document types
- 📄 **Data Extraction** - Extract structured data from documents using AI
- ✅ **Document Verification** - Verify document authenticity with official sources
- 🔍 **Document Matching** - Search for strings within documents with similarity matching
- 💬 **AI-Powered Queries** - Ask natural language questions about documents
- ⚡ **Async Processing** - Handle long-running operations with job polling
- 🛡️ **Built-in Error Handling** - Comprehensive error types and handling
- 🚀 **Modern Ruby** - Supports Ruby 3.0+ with clean, idiomatic code

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'truedocs'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install truedocs
```

## Configuration

### Global Configuration

Configure the gem globally:

```ruby
require 'truedocs'

Truedocs.configure do |config|
  config.api_key = 'your_api_key_here'
  config.base_url = 'https://api.truedocs.mx'  # Optional, uses default
  config.timeout = 60                          # Optional, default is 60 seconds
  config.retries = 3                          # Optional, default is 3 retries
end
```

### Environment Variables

You can also use environment variables:

```bash
export TRUEDOCS_API_KEY="your_api_key_here"
export TRUEDOCS_URL="https://api.truedocs.mx"  # Optional
```

### Per-Client Configuration

Create clients with specific configurations:

```ruby
client = Truedocs.new(
  api_key: 'specific_api_key',
  timeout: 120,
  retries: 5
)
```

## Quick Start

```ruby
require 'truedocs'

# Configure the gem
Truedocs.configure do |config|
  config.api_key = ENV['TRUEDOCS_API_KEY']
end

# Create a client
client = Truedocs.new

# Classify a document
result = client.classify_document('path/to/document.pdf')
puts "Document type: #{result.document_type}"
puts "Confidence: #{result.confidence}"

# Extract data from document
extraction = client.extract_data('path/to/document.pdf')
puts "Extracted fields: #{extraction.extracted_fields}"

# Verify a document
verification = client.verify_document('path/to/document.pdf', 'constancia_de_situacion_fiscal')
puts "Verified: #{verification.verified?}"
```

## API Reference

### Document Classification

Automatically identify the type of document:

```ruby
result = client.classify_document('path/to/document.pdf')

# Access results
puts result.document_type    # e.g., "constancia_de_situacion_fiscal"
puts result.confidence       # e.g., 0.95
puts result.predictions      # Array of all predictions
```

### Data Extraction

Extract structured data from documents:

```ruby
# Extract all available fields
result = client.extract_data('path/to/document.pdf')

# Extract specific fields
result = client.extract_data('path/to/document.pdf', fields: ['rfc', 'nombre'])

# Access extracted data
puts result.extracted_fields     # Hash of field => value
puts result.confidence_scores    # Hash of field => confidence
puts result.text_blocks         # Raw text blocks detected
```

### Document Verification

#### Synchronous Verification

```ruby
result = client.verify_document('path/to/document.pdf', 'constancia_de_situacion_fiscal')

puts result.verified?               # true/false
puts result.verification_result     # 'verified' or error message
puts result.verification_details    # Additional verification info
```

#### Asynchronous Verification

For long-running verifications:

```ruby
# Start async verification
job = client.verify_document(
  'path/to/document.pdf', 
  'constancia_de_situacion_fiscal',
  async: true,
  callback_url: 'https://your-app.com/webhook'  # Optional
)

puts "Job ID: #{job.job_id}"

# Wait for completion (polling)
result = client.wait_for_job(job.job_id)
puts "Final result: #{result.verification_result}"

# Or check status manually
status = client.get_job_status(job.job_id)
puts "Status: #{status.status}"       # 'pending', 'in_progress', 'completed', 'failed'
puts "Progress: #{status.progress}"   # Progress percentage
```

### Document Matching

Search for a string within a document with similarity matching:

```ruby
# Basic string search
result = client.match_document('path/to/document.pdf', 'VIAJERO')

puts result.confidence          # Overall confidence score
puts result.has_matches?        # true if any matches found
puts result.matches.length      # Number of matches found
puts result.top_match          # Best matching result

# Advanced search with threshold and top_k parameters
result = client.match_document(
  'path/to/document.pdf',
  'VIAJERO',
  threshold: 80,    # Similarity threshold (0-100)
  top_k: 5          # Maximum number of results to return
)

# Access individual matches
result.matches.each do |match|
  puts match[:line]        # The matched line of text
  puts match[:similarity]  # Similarity score (0-100)
end

puts result.lines              # Array of all matched lines
puts result.similarities       # Array of all similarity scores
puts result.average_similarity # Average similarity of all matches
```

### Document Querying

Ask natural language questions about documents:

```ruby
result = client.query_document('path/to/document.pdf', 'What is the expiration date?')

puts result.answer           # Natural language answer
puts result.confidence       # Confidence in the answer
puts result.sources          # Source information used
```

### AI-Powered Document Questions

Get AI-powered answers about document content:

```ruby
result = client.ask_document('path/to/document.pdf', 'Is this document still valid?')

puts result.answer           # AI-generated answer
puts result.confidence       # Confidence score
puts result.context          # Context used for the answer
```

### Document Validation

Validate documents using specific validation rules:

```ruby
result = client.validate_document('path/to/document.pdf', 'DidExpire')

puts result.valid?               # true/false
puts result.validation_result    # Validation outcome
puts result.validation_details   # Detailed validation info
puts result.warnings            # Any warnings found
```

### Job Management

#### Polling Jobs

```ruby
# Simple polling (blocks until complete)
result = client.wait_for_job('job_id')

# Advanced polling with custom settings
result = client.poll_job('job_id', interval: 5, timeout: 300) do |job|
  puts "Job status: #{job.status} (#{job.progress}%)"
end
```

#### Job Status

```ruby
job = client.get_job_status('job_id')

puts job.job_id         # Job identifier
puts job.status         # Current status
puts job.result         # Result (when completed)
puts job.progress       # Progress percentage
puts job.created_at     # Job creation time
puts job.completed_at   # Job completion time

# Status check methods
puts job.pending?       # true if status == 'pending'
puts job.in_progress?   # true if status == 'in_progress'
puts job.completed?     # true if status == 'completed'
puts job.failed?        # true if status == 'failed'
```

### Feedback

Provide feedback to improve the service:

```ruby
client.feedback(
  is_positive: true,
  endpoint: 'classify',
  description: 'Classification was very accurate!',
  job_id: 'job_123',        # Optional
  document_id: 'doc_456'    # Optional
)
```

## File Handling

The gem supports multiple file input types:

```ruby
# File path (string)
client.classify_document('/path/to/document.pdf')

# File object
file = File.open('/path/to/document.pdf', 'rb')
client.classify_document(file)

# Already prepared multipart data
client.classify_document({ document: prepared_data })
```

### Supported File Types

- **Images**: JPEG, PNG, TIFF
- **Documents**: PDF
- **Maximum size**: 10MB per file

## Error Handling

The gem provides comprehensive error handling:

```ruby
begin
  result = client.classify_document('document.pdf')
rescue Truedocs::AuthenticationError => e
  puts "Invalid API key: #{e.message}"
rescue Truedocs::ValidationError => e
  puts "Validation error: #{e.message}"
rescue Truedocs::RateLimitError => e
  puts "Rate limit exceeded: #{e.message}"
rescue Truedocs::TimeoutError => e
  puts "Request timeout: #{e.message}"
rescue Truedocs::Error => e
  puts "API error: #{e.message}"
  puts "Status code: #{e.status_code}"
end
```

### Error Types

- `Truedocs::ConfigurationError` - Invalid configuration
- `Truedocs::AuthenticationError` - Invalid API key (401)
- `Truedocs::AuthorizationError` - Access forbidden (403)
- `Truedocs::ValidationError` - Request validation failed (422)
- `Truedocs::RateLimitError` - Rate limit exceeded (429)
- `Truedocs::TimeoutError` - Request timeout
- `Truedocs::NetworkError` - Network connectivity issues
- `Truedocs::ServerError` - Server errors (5xx)
- `Truedocs::UnsupportedFileTypeError` - Unsupported file type
- `Truedocs::FileTooLargeError` - File exceeds size limit

## Response Objects

All API methods return response objects with convenient methods:

```ruby
result = client.classify_document('document.pdf')

# Common methods available on all responses
puts result.success?        # true if successful
puts result.error?          # true if error
puts result.error_message   # Error message if any
puts result.to_h           # Raw response hash
puts result.to_json        # JSON representation

# Specific response methods (varies by endpoint)
puts result.document_type   # Classification-specific
puts result.confidence      # Available on multiple response types
```

## Constants

The gem provides useful constants:

```ruby
# Document types
Truedocs::Client::DOCUMENT_TYPES
# => { constancia_situacion_fiscal: 'constancia_de_situacion_fiscal', ine_reverso: 'ine_reverso' }

# Validation types  
Truedocs::Client::VALIDATION_TYPES
# => { did_expire: 'DidExpire', is_recent: 'IsRecent' }

# Job statuses
Truedocs::Client::JOB_STATUSES
# => ['pending', 'in_progress', 'completed', 'failed']
```

## Development

After checking out the repo, run:

```bash
bin/setup      # Install dependencies
bundle exec rake spec    # Run tests
bundle exec rake build   # Build gem
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/unit/client_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Code Quality

```bash
# Run linting
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- [ ] Tests pass (`bundle exec rspec`)
- [ ] Code follows style guidelines (`bundle exec rubocop`)
- [ ] New features include tests
- [ ] Documentation is updated

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Support

- 📚 [Documentation](https://api.truedocs.mx/docs)
- 🐛 [Issue Tracker](https://github.com/true-docs/truedocs-ruby/issues)
- 📧 [Email Support](mailto:dev@truedocs.mx)
