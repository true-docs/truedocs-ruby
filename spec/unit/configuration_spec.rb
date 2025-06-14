# frozen_string_literal: true

RSpec.describe Truedocs::Configuration do
  subject { described_class.new }

  describe "#initialize" do
    it "sets default values" do
      # Stub environment variables to ensure clean test
      allow(ENV).to receive(:fetch).with("TRUEDOCS_API_KEY", nil).and_return(nil)
      allow(ENV).to receive(:fetch).with("TRUEDOCS_URL", "https://api.truedocs.mx").and_return("https://api.truedocs.mx")

      config = described_class.new
      expect(config.api_key).to be_nil
      expect(config.base_url).to eq("https://api.truedocs.mx")
      expect(config.api_version).to eq("2")
      expect(config.timeout).to eq(60)
      expect(config.retries).to eq(3)
      expect(config.logger).to be_a(Logger)
    end

    context "when environment variables are set" do
      before do
        allow(ENV).to receive(:fetch).with("TRUEDOCS_API_KEY", nil).and_return("env_key")
        allow(ENV).to receive(:fetch).with("TRUEDOCS_URL", "https://api.truedocs.mx").and_return("https://custom.api.com")
      end

      it "uses environment variables" do
        config = described_class.new
        expect(config.api_key).to eq("env_key")
        expect(config.base_url).to eq("https://custom.api.com")
      end
    end
  end

  describe "#valid?" do
    context "when api_key is set" do
      before { subject.api_key = "test_key" }

      it "returns true" do
        expect(subject).to be_valid
      end
    end

    context "when api_key is nil" do
      before { subject.api_key = nil }

      it "returns false" do
        expect(subject).not_to be_valid
      end
    end

    context "when api_key is empty string" do
      before { subject.api_key = "" }

      it "returns false" do
        expect(subject).not_to be_valid
      end
    end
  end
end
