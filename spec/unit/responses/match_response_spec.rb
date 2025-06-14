# frozen_string_literal: true

RSpec.describe Truedocs::Responses::MatchResponse do
  describe "string search format" do
    let(:string_search_data) do
      {
        success: true,
        confidence: 90,
        matches: [
          {
            line: "VIAJERO",
            similarity: 90
          },
          {
            line: "FRONTERA",
            similarity: 85
          },
          {
            line: "JORGE",
            similarity: 88
          }
        ]
      }
    end

    subject { described_class.new(string_search_data) }

    it "returns correct confidence" do
      expect(subject.confidence).to eq(90)
    end

    it "returns correct matches" do
      matches = subject.matches
      expect(matches.length).to eq(3)

      first_match = matches.first
      expect(first_match[:line]).to eq("VIAJERO")
      expect(first_match[:similarity]).to eq(90)
    end

    it "returns lines array" do
      expect(subject.lines).to eq(%w[VIAJERO FRONTERA JORGE])
    end

    it "returns similarities array" do
      expect(subject.similarities).to eq([90, 85, 88])
    end

    it "returns top match" do
      top_match = subject.top_match
      expect(top_match[:line]).to eq("VIAJERO")
      expect(top_match[:similarity]).to eq(90)
    end

    it "indicates has matches" do
      expect(subject.has_matches?).to be true
      expect(subject.matches?).to be true
    end

    it "calculates average similarity" do
      expect(subject.average_similarity).to eq((90 + 85 + 88) / 3.0)
    end

    context "with different key formats" do
      let(:snake_case_data) do
        {
          success: true,
          confidence: 90,
          matches: [
            {
              line: "John Doe",
              similarity: 95
            }
          ]
        }
      end

      subject { described_class.new(snake_case_data) }

      it "handles different key formats" do
        match = subject.matches.first
        expect(match[:line]).to eq("John Doe")
        expect(match[:similarity]).to eq(95)
      end
    end
  end

  describe "empty results" do
    let(:empty_data) { { success: true, confidence: 0, matches: [] } }
    subject { described_class.new(empty_data) }

    it "handles empty results" do
      expect(subject.has_matches?).to be false
      expect(subject.matches?).to be false
      expect(subject.matches).to be_empty
      expect(subject.top_match).to be_nil
      expect(subject.average_similarity).to eq(0.0)
      expect(subject.confidence).to eq(0)
    end
  end

  describe "shared examples" do
    let(:data) { { success: true, confidence: 90, matches: [] } }
    subject { described_class.new(data) }

    include_examples "a successful response" do
      let(:response) { subject }
    end

    include_examples "a response with data" do
      let(:response) { subject }
    end
  end
end
