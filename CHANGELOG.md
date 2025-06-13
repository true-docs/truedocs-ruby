# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-06-13

### Added
- Initial release of the Truedocs Ruby gem
- Document classification with confidence scoring
- Data extraction from documents with field-specific extraction
- Document verification (synchronous and asynchronous)
- String search within documents with similarity matching (updated from document comparison)
- AI-powered natural language document querying
- Document validation with custom validation types
- Comprehensive job management for async operations:
  - Job status checking
  - Job polling with customizable intervals
  - Wait for job completion
- Feedback system for continuous improvement
- File handling for multiple input types:
  - File paths (strings)
  - File objects
  - Pre-prepared multipart data
- Comprehensive error handling with specific error types:
  - ConfigurationError
  - AuthenticationError
  - AuthorizationError
  - ValidationError
  - RateLimitError
  - TimeoutError
  - NetworkError
  - ServerError
  - UnsupportedFileTypeError
  - FileTooLargeError
- Response objects with convenient accessor methods
- Global and per-client configuration options
- Environment variable support
- File validation and MIME type detection
- Support for images (JPEG, PNG, TIFF) and PDF documents
- Built with Faraday for robust HTTP handling
- Comprehensive test suite with RSpec
- WebMock and VCR integration for testing
- Code coverage reporting with SimpleCov
- RuboCop integration for code quality
- Complete API documentation
- Usage examples and getting started guide

### Technical Details
- Ruby 3.0+ support
- Faraday HTTP client with retry logic
- Marcel for MIME type detection
- Comprehensive resource-based architecture
- Response object pattern for clean API
- Job polling with timeout and interval controls
- File size limits (10MB) and type validation
- Rate limiting and retry handling
- Structured logging support
