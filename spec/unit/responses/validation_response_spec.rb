# frozen_string_literal: true

RSpec.describe Truedocs::Responses::ValidationResponse do
  describe "successful validation response" do
    let(:validation_data) do
      {
        success: true,
        validation: {
          type: "DidExpire",
          match: "Document has not expired",
          confidence: 95,
          isValid: true
        }
      }
    end

    subject { described_class.new(validation_data) }

    it "returns validation object" do
      validation = subject.validation
      expect(validation[:type]).to eq("DidExpire")
      expect(validation[:match]).to eq("Document has not expired")
      expect(validation[:confidence]).to eq(95)
      expect(validation[:isValid]).to be true
    end

    it "returns validation type" do
      expect(subject.validation_type).to eq("DidExpire")
    end

    it "returns match" do
      expect(subject.match).to eq("Document has not expired")
    end

    it "returns confidence" do
      expect(subject.confidence).to eq(95)
    end

    it "returns is_valid" do
      expect(subject.is_valid).to be true
    end

    it "returns valid status" do
      expect(subject.valid?).to be true
    end

    it "handles snake_case keys" do
      snake_case_data = {
        success: true,
        validation: {
          type: "test",
          isValid: true
        }
      }

      response = described_class.new(snake_case_data)
      expect(response.validation_type).to eq("test")
      expect(response.is_valid).to be true
    end
  end

  describe "failed validation response" do
    let(:failed_data) do
      {
        success: true,
        validation: {
          type: "DidExpire",
          match: "Document has expired",
          confidence: 98,
          isValid: false
        }
      }
    end

    subject { described_class.new(failed_data) }

    it "returns failed validation result" do
      expect(subject.is_valid).to be false
      expect(subject.valid?).to be false
    end

    it "returns validation details" do
      expect(subject.validation_type).to eq("DidExpire")
      expect(subject.match).to eq("Document has expired")
      expect(subject.confidence).to eq(98)
    end
  end

  describe "validation with boolean result" do
    let(:boolean_data) do
      {
        success: true,
        validation: {
          type: "Custom",
          isValid: true
        }
      }
    end

    subject { described_class.new(boolean_data) }

    it "handles boolean validation result" do
      expect(subject.valid?).to be true
      expect(subject.is_valid).to be true
    end
  end

  describe "missing fields" do
    let(:minimal_data) { { success: true } }
    subject { described_class.new(minimal_data) }

    it "provides default values for missing fields" do
      expect(subject.validation).to eq({})
      expect(subject.validation_type).to be_nil
      expect(subject.match).to be_nil
      expect(subject.confidence).to be_nil
      expect(subject.is_valid).to be_nil
      expect(subject.valid?).to be false
    end
  end

  describe "shared examples" do
    let(:data) { { success: true, validation: { isValid: true } } }
    subject { described_class.new(data) }

    include_examples "a successful response" do
      let(:response) { subject }
    end

    include_examples "a response with data" do
      let(:response) { subject }
    end
  end
end
