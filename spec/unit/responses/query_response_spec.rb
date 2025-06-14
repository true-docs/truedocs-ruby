# frozen_string_literal: true

RSpec.describe Truedocs::Responses::QueryResponse do
  describe "successful query response" do
    let(:query_data) do
      {
        success: true,
        answers: {
          "When does this document expire?" => {
            results: [
              {
                text: "The document expires on December 31, 2024.",
                confidence: 0.92,
                page: 1,
                bbox: [150, 300, 250, 320]
              }
            ]
          }
        }
      }
    end

    subject { described_class.new(query_data) }

    it "returns answers object" do
      answers = subject.answers
      expect(answers).to be_a(Hash)
      expect(answers[:"When does this document expire?"]).to be_truthy
    end

    it "returns answer for specific question" do
      answer = subject.answer_for("When does this document expire?")
      expect(answer[:results]).to be_an(Array)
      expect(answer[:results].first[:text]).to eq("The document expires on December 31, 2024.")
    end

    it "returns results for specific question" do
      results = subject.results_for("When does this document expire?")
      expect(results).to be_an(Array)
      expect(results.first[:text]).to eq("The document expires on December 31, 2024.")
      expect(results.first[:confidence]).to eq(0.92)
    end

    it "returns first answer" do
      first_answer = subject.first_answer
      expect(first_answer[:results]).to be_an(Array)
      expect(first_answer[:results].first[:text]).to eq("The document expires on December 31, 2024.")
    end
  end

  describe "query with no results" do
    let(:no_results_data) do
      {
        success: true,
        answers: {
          "What is the color?" => {
            results: []
          }
        }
      }
    end

    subject { described_class.new(no_results_data) }

    it "handles empty results" do
      results = subject.results_for("What is the color?")
      expect(results).to be_empty
    end
  end

  describe "missing fields" do
    let(:minimal_data) { { success: true } }
    subject { described_class.new(minimal_data) }

    it "provides default values for missing fields" do
      expect(subject.answers).to eq({})
      expect(subject.first_answer).to be_nil
      expect(subject.results_for("any question")).to eq([])
    end
  end

  describe "shared examples" do
    let(:data) { { success: true, answers: {} } }
    subject { described_class.new(data) }

    include_examples "a successful response" do
      let(:response) { subject }
    end

    include_examples "a response with data" do
      let(:response) { subject }
    end
  end
end 