# frozen_string_literal: true

require "spec_helper"

RSpec.describe "V2 API Compatibility Integration", :integration do
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

  describe "Document Classification" do
    it "returns V2 format classification response" do
      response = client.classify_document(test_document_path)
      
      expect(response).to be_a(Truedocs::Responses::ClassificationResponse)
      expect(response.success?).to be true
      
      # V2 format checks
      expect(response.prediction).to be_a(Hash)
      expect(response.document_type).to be_a(String)
      expect(response.confidence).to be_a(Numeric)
      
      # Should not have legacy methods
      expect { response.classification_result }.to raise_error(NoMethodError)
      expect { response.document_class }.to raise_error(NoMethodError)
    end
  end

  describe "Document Extraction" do
    it "returns V2 format extraction response" do
      response = client.extract_from_document(test_document_path)
      
      expect(response).to be_a(Truedocs::Responses::ExtractionResponse)
      expect(response.success?).to be true
      
      # V2 format checks
      expect(response.lines).to be_an(Array)
      expect(response.fields).to be_a(Hash)
      
      # Should not have legacy methods
      expect { response.extracted_fields }.to raise_error(NoMethodError)
      expect { response.confidence_scores }.to raise_error(NoMethodError)
      expect { response.text_blocks }.to raise_error(NoMethodError)
    end
  end

  describe "Document Match" do
    it "returns V2 format match response" do
      response = client.match_document(
        test_document_path,
        "test search string",
        threshold: 80,
        top_k: 5
      )
      
      expect(response).to be_a(Truedocs::Responses::MatchResponse)
      expect(response.success?).to be true
      
      # V2 format checks
      expect(response.confidence).to be_a(Numeric)
      expect(response.matches).to be_an(Array)
      expect(response.lines).to be_an(Array)
      expect(response.similarities).to be_an(Array)
      
      # Should not have legacy methods
      expect { response.match_score }.to raise_error(NoMethodError)
      expect { response.matched_fields }.to raise_error(NoMethodError)
    end
  end

  describe "Document Validation" do
    it "returns V2 format validation response" do
      response = client.validate_document(test_document_path, "DidExpire")
      
      expect(response).to be_a(Truedocs::Responses::ValidationResponse)
      expect(response.success?).to be true
      
      # V2 format checks
      expect(response.validation).to be_a(Hash)
      expect(response.validation_type).to be_a(String)
      expect([true, false, nil]).to include(response.is_valid)
      expect([true, false]).to include(response.valid?)
      
      # Should not have legacy methods
      expect { response.validation_result }.to raise_error(NoMethodError)
      expect { response.validation_details }.to raise_error(NoMethodError)
      expect { response.warnings }.to raise_error(NoMethodError)
    end
  end

  describe "Document Verification" do
    it "returns V2 format verification response" do
      response = client.verify_document(test_document_path)
      
      expect(response).to be_a(Truedocs::Responses::VerificationResponse)
      expect(response.success?).to be true
      
      # V2 format checks
      expect(response.verifications).to be_a(Hash)
      expect(response.found).to be_a(Hash)
      expect(response.not_found).to be_an(Array)
      expect(response.messages).to be_an(Array)
      expect([true, false]).to include(response.verified?)
      
      # Should not have legacy methods
      expect { response.verification_result }.to raise_error(NoMethodError)
      expect { response.verification_details }.to raise_error(NoMethodError)
      expect { response.status }.to raise_error(NoMethodError)
    end
  end

  describe "Document Query" do
    it "returns V2 format query response" do
      response = client.query_document(test_document_path, "What type of document is this?")
      
      expect(response).to be_a(Truedocs::Responses::QueryResponse)
      expect(response.success?).to be true
      
      # V2 format checks
      expect(response.answers).to be_a(Hash)
      expect(response.first_answer).to be_a(Hash) if response.answers.any?
      
      # Should not have legacy methods
      expect { response.answer }.to raise_error(NoMethodError)
      expect { response.confidence }.to raise_error(NoMethodError)
      expect { response.sources }.to raise_error(NoMethodError)
    end
  end

  describe "Document Ask" do
    it "returns V2 format ask response" do
      response = client.ask_document(test_document_path, "Is this document valid?")
      
      expect(response).to be_a(Truedocs::Responses::AskResponse)
      expect(response.success?).to be true
      
      # V2 format checks
      expect(response.response).to be_a(String)
      
      # Should not have legacy methods
      expect { response.answer }.to raise_error(NoMethodError)
      expect { response.confidence }.to raise_error(NoMethodError)
      expect { response.context }.to raise_error(NoMethodError)
    end
  end

  describe "Job Management" do
    it "returns V2 format job response with uppercase status" do
      # Start an async verification job
      job_response = client.verify_document_async(test_document_path)
      
      expect(job_response).to be_a(Truedocs::Responses::JobResponse)
      expect(job_response.success?).to be true
      expect(job_response.job_id).to be_a(String)
      
      # V2 format status checks (uppercase)
      expect(["PENDING", "IN_PROGRESS", "COMPLETED", "FAILED"]).to include(job_response.status)
      expect([true, false]).to include(job_response.pending?)
      expect([true, false]).to include(job_response.in_progress?)
      expect([true, false]).to include(job_response.completed?)
      expect([true, false]).to include(job_response.failed?)
      
      # Check job status
      status_response = client.job_status(job_response.job_id)
      expect(status_response).to be_a(Truedocs::Responses::JobResponse)
      expect(["PENDING", "IN_PROGRESS", "COMPLETED", "FAILED"]).to include(status_response.status)
    end
  end

  describe "API Version Header" do
    it "sends API version 2 in requests" do
      # This test verifies that the client is sending the correct API version header
      allow(client.instance_variable_get(:@connection)).to receive(:post).and_call_original
      
      client.classify_document(test_document_path)
      
      # Verify that the connection was called with the correct headers
      expect(client.instance_variable_get(:@connection)).to have_received(:post) do |path, body, headers|
        expect(headers["X-API-Version"]).to eq("2")
      end
    end
  end

  describe "Error Handling" do
    it "handles V2 format errors correctly" do
      # Test with invalid file to trigger an error
      expect {
        client.classify_document("/nonexistent/file.pdf")
      }.to raise_error(Truedocs::Error)
    end
  end
end
