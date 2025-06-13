# frozen_string_literal: true

RSpec.describe Truedocs::Client do
  let(:api_key) { "test_api_key" }
  subject { described_class.new(api_key: api_key) }

  describe "#initialize" do
    context "with valid api_key" do
      it "creates a client instance" do
        expect(subject).to be_a(described_class)
      end
    end

    context "without api_key" do
      before do
        # Ensure global configuration has no API key
        Truedocs.configure { |config| config.api_key = nil }
      end

      it "raises ConfigurationError" do
        expect { described_class.new }.to raise_error(Truedocs::ConfigurationError)
      end
    end

    context "with custom options" do
      let(:client) { described_class.new(api_key: api_key, timeout: 120) }

      it "applies custom options" do
        expect(client.send(:config).timeout).to eq(120)
      end
    end
  end

  describe "resource modules" do
    it "includes Document methods" do
      expect(subject).to respond_to(:classify_document)
      expect(subject).to respond_to(:extract_data)
      expect(subject).to respond_to(:verify_document)
    end

    it "includes Job methods" do
      expect(subject).to respond_to(:get_job_status)
      expect(subject).to respond_to(:poll_job)
    end

    it "includes Validation methods" do
      expect(subject).to respond_to(:validate_document)
      expect(subject).to respond_to(:feedback)
    end
  end

  describe "constants" do
    it "defines document types" do
      expect(described_class::DOCUMENT_TYPES).to be_a(Hash)
      expect(described_class::DOCUMENT_TYPES).to include(:constancia_situacion_fiscal)
    end

    it "defines validation types" do
      expect(described_class::VALIDATION_TYPES).to be_a(Hash)
      expect(described_class::VALIDATION_TYPES).to include(:did_expire)
    end

    it "defines job statuses" do
      expect(described_class::JOB_STATUSES).to be_an(Array)
      expect(described_class::JOB_STATUSES).to include("pending", "completed")
    end
  end
end
