# Real API Testing with VCR

This document explains how to test the Truedocs Ruby gem against the real API and record VCR cassettes for use in automated tests.

## Prerequisites

1. **API Key**: Make sure you have a valid Truedocs API key
2. **Environment Setup**: Create a `.env` file in the project root with your API key:
   ```
   TRUEDOCS_API_KEY=your_actual_api_key_here
   ```

## Running Real API Tests

### Option 1: Record New VCR Cassettes

To test against the real API and record new VCR cassettes:

```bash
bundle exec rake api:record
```

This will:
- Load your API key from the `.env` file
- Run tests against the real Truedocs API
- Record all HTTP interactions as VCR cassettes
- Store cassettes in `spec/fixtures/vcr_cassettes/real_api/`

### Option 2: Test Against Real API (No Recording)

To run integration tests against the real API without recording:

```bash
bundle exec rake api:test
```

### Option 3: Manual Test Execution

You can also run the tests manually:

```bash
# Record new cassettes
VCR_RECORD_MODE=new_episodes bundle exec rspec spec/integration/real_api_recording_spec.rb

# Run existing integration tests
bundle exec rspec spec/integration/v2_api_compatibility_spec.rb
```

## Test Document

The tests use `spec/fixtures/ine-frente.jpeg` as the test document. This is an INE (Mexican ID) front image that works well with the Truedocs API for testing various document processing features.

## What Gets Tested

The real API tests cover:

- ✅ **Document Classification**: Classify the document type
- ✅ **Document Extraction**: Extract fields and data from the document
- ✅ **Document Match**: Search for specific text within the document
- ✅ **Document Validation**: Validate document properties (e.g., expiration)
- ✅ **Document Query**: Ask questions about the document content
- ✅ **Document Ask**: Get AI-powered responses about the document
- ⏭️ **Document Verification**: Skipped for now
- ⏭️ **Job Management**: Skipped for now (depends on verification)

## VCR Cassette Management

### View Recorded Cassettes

```bash
bundle exec rake api:cassettes
```

### Clean Cassettes

```bash
bundle exec rake api:clean
```

### Cassette Structure

Cassettes are stored in:
```
spec/fixtures/vcr_cassettes/real_api/
├── classify_document.yml
├── extract_document.yml
├── match_document.yml
├── validate_document.yml
├── query_document.yml
└── ask_document.yml
```

## Security

- API keys are automatically filtered out of VCR cassettes
- Sensitive data is replaced with `<API_KEY>` placeholder
- Never commit real API keys to version control

## Using Recorded Cassettes in Tests

Once you've recorded cassettes, your regular test suite will use them automatically:

```bash
bundle exec rake spec
```

The recorded cassettes ensure:
- Tests run fast (no real HTTP calls)
- Tests are deterministic
- Tests work offline
- No API rate limits during testing

## Troubleshooting

### API Key Issues
- Ensure your `.env` file exists and contains `TRUEDOCS_API_KEY`
- Verify the API key is valid and has proper permissions
- Check that `dotenv` gem is installed: `bundle install`

### Network Issues
- Ensure you have internet connectivity
- Check if the Truedocs API is accessible from your network
- Verify the base URL is correct (defaults to `https://api.truedocs.mx`)

### File Issues
- Ensure `spec/fixtures/ine-frente.jpeg` exists
- Check file permissions and readability
- Verify the image file is not corrupted 