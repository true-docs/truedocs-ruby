# frozen_string_literal: true

RSpec.describe Truedocs::Responses::VerificationResponse do
  describe "successful verification response" do
    let(:verification_data) do
      {
        success: true,
        verifications: {
          found: {
            issuer: "SAT",
            validFrom: "2023-01-01",
            validUntil: "2024-12-31",
            documentNumber: "ABC123456789"
          },
          notFound: [],
          messages: ["Document successfully verified"]
        }
      }
    end

    subject { described_class.new(verification_data) }

    it "returns verifications object" do
      verifications = subject.verifications
      expect(verifications[:found]).to be_truthy
      expect(verifications[:notFound]).to be_an(Array)
      expect(verifications[:messages]).to be_an(Array)
    end

    it "returns found data" do
      found = subject.found
      expect(found[:issuer]).to eq("SAT")
      expect(found[:validFrom]).to eq("2023-01-01")
      expect(found[:validUntil]).to eq("2024-12-31")
      expect(found[:documentNumber]).to eq("ABC123456789")
    end

    it "returns not_found array" do
      not_found = subject.not_found
      expect(not_found).to be_an(Array)
      expect(not_found).to be_empty
    end

    it "returns messages" do
      messages = subject.messages
      expect(messages).to be_an(Array)
      expect(messages.first).to eq("Document successfully verified")
    end

    it "returns verified status" do
      expect(subject.verified?).to be true
    end

    it "handles snake_case keys" do
      snake_case_data = {
        success: true,
        verifications: { 
          found: { issuer: "Test Issuer" },
          not_found: [],
          messages: []
        }
      }
      
      response = described_class.new(snake_case_data)
      expect(response.found[:issuer]).to eq("Test Issuer")
    end
  end

  describe "failed verification response" do
    let(:failed_data) do
      {
        success: true,
        verifications: {
          found: {},
          notFound: ["documentNumber", "issuer"],
          messages: ["Document could not be verified", "Missing required fields"]
        }
      }
    end

    subject { described_class.new(failed_data) }

    it "returns failed verification result" do
      expect(subject.verified?).to be false
    end

    it "returns failure details" do
      not_found = subject.not_found
      expect(not_found).to include("documentNumber")
      expect(not_found).to include("issuer")
      
      messages = subject.messages
      expect(messages).to include("Document could not be verified")
    end
  end

  describe "verification with empty found" do
    let(:empty_data) do
      {
        success: true,
        verifications: {
          found: {},
          notFound: [],
          messages: []
        }
      }
    end

    subject { described_class.new(empty_data) }

    it "handles empty found object" do
      expect(subject.verified?).to be false
      expect(subject.found).to be_empty
    end
  end

  describe "missing fields" do
    let(:minimal_data) { { success: true } }
    subject { described_class.new(minimal_data) }

    it "provides default values for missing fields" do
      expect(subject.verifications).to eq({})
      expect(subject.found).to eq({})
      expect(subject.not_found).to eq([])
      expect(subject.messages).to eq([])
      expect(subject.verified?).to be false
    end
  end

  describe "shared examples" do
    let(:data) { { success: true, verifications: { found: { test: "data" } } } }
    subject { described_class.new(data) }

    include_examples "a successful response" do
      let(:response) { subject }
    end

    include_examples "a response with data" do
      let(:response) { subject }
    end
  end
end 