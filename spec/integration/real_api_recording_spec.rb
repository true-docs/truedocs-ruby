# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Real API Recording with VCR", :vcr do
  let(:client) do
    api_key = ENV["TRUEDOCS_API_KEY"]
    skip "TRUEDOCS_API_KEY environment variable not set" unless api_key

    Truedocs::Client.new(
      api_key: api_key,
      base_url: ENV["TRUEDOCS_BASE_URL"] || "https://api.truedocs.mx",
      timeout: 30
    )
  end

  let(:test_document_path) do
    # Use the INE front image for testing
    File.join(__dir__, "..", "fixtures", "ine-frente.jpeg")
  end

  describe "Document Classification", vcr: { cassette_name: "real_api/classify_document" } do
    it "records real API response for document classification" do
      response = client.classify_document(test_document_path)

      expect(response).to be_a(Truedocs::Responses::ClassificationResponse)
      expect(response.success?).to be true

      # Log the response for verification
      puts "Classification Response:"
      puts "  Document Type: #{response.document_type}"
      puts "  Confidence: #{response.confidence}"
      puts "  Prediction: #{response.prediction}"
    end
  end

  describe "Document Extraction", vcr: { cassette_name: "real_api/extract_document" } do
    it "records real API response for document extraction" do
      response = client.extract_data(test_document_path)

      expect(response).to be_a(Truedocs::Responses::ExtractionResponse)
      expect(response.success?).to be true

      # Log the response for verification
      puts "Extraction Response:"
      puts "  Lines count: #{response.lines.length}"
      puts "  Fields: #{response.fields.keys.join(", ")}"
    end
  end

  describe "Document Match", vcr: { cassette_name: "real_api/match_document" } do
    it "records real API response for document matching" do
      response = client.match_document(
        test_document_path,
        "GÓMEZ",
        threshold: 70,
        top_k: 3
      )

      expect(response).to be_a(Truedocs::Responses::MatchResponse)
      expect(response.success?).to be true

      # Log the response for verification
      puts "Match Response:"
      puts "  Confidence: #{response.confidence}"
      puts "  Matches count: #{response.matches.length}"
      puts "  Lines count: #{response.lines.length}"
    end
  end

  describe "Document Validation", vcr: { cassette_name: "real_api/validate_document" } do
    it "records real API response for document validation" do
      response = client.validate_document(test_document_path, "DidExpire")

      expect(response).to be_a(Truedocs::Responses::ValidationResponse)
      expect(response.success?).to be true

      # Log the response for verification
      puts "Validation Response:"
      puts "  Validation Type: #{response.validation_type}"
      puts "  Is Valid: #{response.is_valid}"
      puts "  Validation: #{response.validation}"
    end
  end

  describe "Document Verification", vcr: { cassette_name: "real_api/verify_document" } do
    it "records real API response for document verification" do
      skip "Verification feature testing skipped for now"

      response = client.verify_document(test_document_path)

      expect(response).to be_a(Truedocs::Responses::VerificationResponse)
      expect(response.success?).to be true

      # Log the response for verification
      puts "Verification Response:"
      puts "  Verified: #{response.verified?}"
      puts "  Found: #{response.found.keys.join(", ")}"
      puts "  Not Found: #{response.not_found.join(", ")}"
      puts "  Messages count: #{response.messages.length}"
    end
  end

  describe "Document Query", vcr: { cassette_name: "real_api/query_document" } do
    it "records real API response for document query" do
      response = client.query_document(test_document_path, "What type of document is this?")

      expect(response).to be_a(Truedocs::Responses::QueryResponse)
      expect(response.success?).to be true

      # Log the response for verification
      puts "Query Response:"
      puts "  Answers count: #{response.answers.length}"
      puts "  First Answer: #{response.first_answer}" if response.answers.any?
    end
  end

  describe "Document Ask", vcr: { cassette_name: "real_api/ask_document" } do
    it "records real API response for document ask" do
      response = client.ask_document(test_document_path, "Is this document valid?")

      expect(response).to be_a(Truedocs::Responses::AskResponse)
      expect(response.success?).to be true

      # Log the response for verification
      puts "Ask Response:"
      puts "  Response: #{response.response[0..100]}..." # First 100 chars
    rescue Truedocs::ServerError => e
      puts "Ask Response:"
      puts "  Server Error: #{e.message}"
      puts "  This endpoint may be temporarily unavailable"
      # Skip the test if server error occurs
      skip "Ask endpoint returned server error: #{e.message}"
    end
  end

  describe "Job Management", vcr: { cassette_name: "real_api/job_management" } do
    it "records real API response for async job management" do
      skip "Job management testing skipped (uses verify_document_async which is part of verification feature)"

      # Start an async verification job
      job_response = client.verify_document_async(test_document_path)

      expect(job_response).to be_a(Truedocs::Responses::JobResponse)
      expect(job_response.success?).to be true

      puts "Job Response:"
      puts "  Job ID: #{job_response.job_id}"
      puts "  Status: #{job_response.status}"

      # Check job status
      status_response = client.job_status(job_response.job_id)
      expect(status_response).to be_a(Truedocs::Responses::JobResponse)

      puts "Job Status Response:"
      puts "  Status: #{status_response.status}"
      puts "  Pending: #{status_response.pending?}"
      puts "  In Progress: #{status_response.in_progress?}"
      puts "  Completed: #{status_response.completed?}"
      puts "  Failed: #{status_response.failed?}"
    end
  end
end
