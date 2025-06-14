# frozen_string_literal: true

RSpec.describe Truedocs::Responses::AskResponse do
  describe "successful ask response" do
    let(:ask_data) do
      {
        success: true,
        response: "Yes, this document is still valid. It expires on December 31, 2024."
      }
    end

    subject { described_class.new(ask_data) }

    it "returns response" do
      expect(subject.response).to eq("Yes, this document is still valid. It expires on December 31, 2024.")
    end
  end

  describe "ask with empty response" do
    let(:empty_response_data) do
      {
        success: true,
        response: ""
      }
    end

    subject { described_class.new(empty_response_data) }

    it "handles empty response" do
      expect(subject.response).to eq("")
    end
  end

  describe "missing fields" do
    let(:minimal_data) { { success: true } }
    subject { described_class.new(minimal_data) }

    it "provides default values for missing fields" do
      expect(subject.response).to be_nil
    end
  end

  describe "shared examples" do
    let(:data) { { success: true, response: "Test response" } }
    subject { described_class.new(data) }

    include_examples "a successful response" do
      let(:response) { subject }
    end

    include_examples "a response with data" do
      let(:response) { subject }
    end
  end
end 