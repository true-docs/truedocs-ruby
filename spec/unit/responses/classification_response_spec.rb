# frozen_string_literal: true

RSpec.describe Truedocs::Responses::ClassificationResponse do
  describe "successful classification response" do
    let(:classification_data) do
      {
        success: true,
        prediction: {
          documentType: "instituto_nacional_electoral",
          confidence: 0.95,
          country: "Mexico",
          entity: "Instituto Nacional Electoral",
          entityShortName: "INE"
        }
      }
    end

    subject { described_class.new(classification_data) }

    it "returns prediction object" do
      prediction = subject.prediction
      expect(prediction[:documentType]).to eq("instituto_nacional_electoral")
      expect(prediction[:confidence]).to eq(0.95)
    end

    it "returns correct document type" do
      expect(subject.document_type).to eq("instituto_nacional_electoral")
    end

    it "returns correct confidence" do
      expect(subject.confidence).to eq(0.95)
    end

    it "returns country" do
      expect(subject.country).to eq("Mexico")
    end

    it "returns entity" do
      expect(subject.entity).to eq("Instituto Nacional Electoral")
    end

    it "returns entity short name" do
      expect(subject.entity_short_name).to eq("INE")
    end

    it "indicates known document" do
      expect(subject.unknown?).to be false
    end

    it "handles snake_case keys" do
      snake_case_data = {
        success: true,
        prediction: {
          document_type: "ine_reverso",
          confidence: 0.88,
          entity_short_name: "INE"
        }
      }
      
      response = described_class.new(snake_case_data)
      expect(response.document_type).to eq("ine_reverso")
      expect(response.entity_short_name).to eq("INE")
    end
  end

  describe "unknown document response" do
    let(:unknown_data) do
      {
        success: true,
        prediction: {
          documentType: "unknown"
        }
      }
    end

    subject { described_class.new(unknown_data) }

    it "handles unknown document" do
      expect(subject.document_type).to eq("unknown")
      expect(subject.unknown?).to be true
      expect(subject.confidence).to be_nil
    end
  end

  describe "missing prediction" do
    let(:minimal_data) { { success: true } }
    subject { described_class.new(minimal_data) }

    it "provides default values for missing prediction" do
      expect(subject.prediction).to eq({})
      expect(subject.document_type).to eq("unknown")
      expect(subject.confidence).to be_nil
    end
  end

  describe "shared examples" do
    let(:data) { { success: true, prediction: { documentType: "test" } } }
    subject { described_class.new(data) }

    include_examples "a successful response" do
      let(:response) { subject }
    end

    include_examples "a response with data" do
      let(:response) { subject }
    end
  end
end 