# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2025-06-13

### Fixed
- **V2 API Compatibility**: Fixed success detection for V2 API responses
  - V2 API does not return a `success` key, now checks `status` field instead
  - Updated `BaseResponse#success?` to check for `status == "success"` or absence of error
  - Added custom success logic for `JobResponse` (success means job created with valid job_id and not failed)
- **Response Key Handling**: Fixed nested hash key transformation in response classes
  - V2 API returns nested hashes with string keys, now properly transformed to symbols
  - Affects `prediction`, `fields`, `validation`, `verifications`, and `answers` objects
  - Ensures consistent access patterns across all response classes
- **Constant References**: Fixed NameError in resource modules
  - Updated to use fully qualified constant names for `DOCUMENT_TYPES` and `VALIDATION_TYPES`
  - Prevents scope-related errors when constants are not directly accessible
- **Test Compatibility**: Updated tests to match V2 API format and current defaults
  - Fixed configuration tests for API version "2" and timeout 60 seconds
  - Updated response tests to use symbol keys for transformed data structures

### Added
- **Comprehensive V2 API Tests**: Added extensive integration test coverage
  - V2 response format parsing tests for all endpoints
  - Mock integration tests with WebMock stubs for offline testing
  - Live API compatibility tests (require API key)
  - Verification of V2 format handling and legacy method removal

### Technical Details
- All 139 tests now passing with 86.28% code coverage
- Maintains backward compatibility while fixing V2 API issues
- Improved error handling and response parsing reliability

## [0.2.0] - 2025-06-13

### Changed
- **BREAKING**: Updated all response classes to use V2 API format
- **BREAKING**: Removed all backward compatibility code and legacy methods
- Updated client to default API version to "2"
- Updated response parsing to extract data from V2 format: `{"status": "success", "data": {...}}`

### Updated Response Classes
- **ClassificationResponse**: Now uses `prediction` object with `documentType`, `confidence`, `country`, `entity`, `entityShortName`
- **ExtractionResponse**: Now uses `lines` array and `fields` object
- **ValidationResponse**: Now uses `validation` object with `type`, `match`, `confidence`, `isValid`
- **VerificationResponse**: Now uses `verifications` object with `found`, `notFound`, `messages`
- **QueryResponse**: Now uses `answers` object with question-result mapping
- **AskResponse**: Now uses simple `response` field
- **JobResponse**: Status values now uppercase ("PENDING", "IN_PROGRESS", "COMPLETED", "FAILED")

### Removed
- All legacy/backward compatibility methods from response classes
- Deprecated `match_documents` method (replaced with `match_document`)
- Legacy response methods like `extracted_fields`, `confidence_scores`, `text_blocks`
- Legacy validation methods like `validation_result`, `validation_details`, `warnings`
- Legacy verification methods like `verification_result`, `verification_details`, `status`
- Legacy query methods like `answer`, `confidence`, `sources`
- Legacy ask methods like `answer`, `confidence`, `context`

### Technical Details
- All tests updated to use V2 API format
- Removed deprecation warnings and legacy test cases
- Improved response class consistency and clarity
- Better alignment with actual Truedocs API V2 specification

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
