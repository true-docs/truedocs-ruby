# frozen_string_literal: true

RSpec.describe "Document Match Resource" do
  let(:client) { Truedocs::Client.new(api_key: "test_key") }
  let(:file_path) { "spec/fixtures/sample.pdf" }

  before do
    allow(File).to receive(:exist?).with(file_path).and_return(true)
    allow(File).to receive(:size).with(file_path).and_return(1024)
    allow_any_instance_of(Truedocs::Utils::FileHandler).to receive(:prepare).and_return("prepared_file_data")
  end

  describe "#match_document" do
    let(:identifier) { "VIAJERO" }
    let(:successful_response) do
      {
        "success" => true,
        "confidence" => 90,
        "matches" => [
          {
            "line" => "VIAJERO",
            "similarity" => 90
          },
          {
            "line" => "FRONTERA",
            "similarity" => 90
          },
          {
            "line" => "JORGE",
            "similarity" => 90
          }
        ]
      }
    end

    context "with basic parameters" do
      before do
        stub_request(:post, "https://api.truedocs.mx/match")
          .with(
            body: hash_including({
                                   document: "prepared_file_data",
                                   identifier: identifier
                                 })
          )
          .to_return(
            status: 200,
            body: successful_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "sends correct payload" do
        result = client.match_document(file_path, identifier)

        expect(result).to be_a(Truedocs::Responses::MatchResponse)
        expect(result.has_matches?).to be true
        expect(result.matches.length).to eq(3)
      end

      it "returns correct match data" do
        result = client.match_document(file_path, identifier)

        expect(result.confidence).to eq(90)

        top_match = result.top_match
        expect(top_match[:line]).to eq("VIAJERO")
        expect(top_match[:similarity]).to eq(90)

        expect(result.lines).to eq(%w[VIAJERO FRONTERA JORGE])
        expect(result.similarities).to eq([90, 90, 90])
        expect(result.average_similarity).to eq(90.0)
      end
    end

    context "with threshold and top_k parameters" do
      before do
        stub_request(:post, "https://api.truedocs.mx/match")
          .with(
            body: hash_including({
                                   document: "prepared_file_data",
                                   identifier: identifier,
                                   threshold: 80,
                                   top_k: 5
                                 })
          )
          .to_return(
            status: 200,
            body: successful_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "sends threshold and top_k in payload" do
        result = client.match_document(file_path, identifier, threshold: 80, top_k: 5)

        expect(result).to be_a(Truedocs::Responses::MatchResponse)
        expect(result.has_matches?).to be true
      end
    end

    context "when no matches found" do
      let(:empty_response) do
        {
          "success" => true,
          "confidence" => 0,
          "matches" => []
        }
      end

      before do
        stub_request(:post, "https://api.truedocs.mx/match")
          .with(
            body: hash_including({
                                   document: "prepared_file_data",
                                   identifier: identifier
                                 })
          )
          .to_return(
            status: 200,
            body: empty_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns empty results" do
        result = client.match_document(file_path, identifier)

        expect(result.has_matches?).to be false
        expect(result.matches).to be_empty
        expect(result.top_match).to be_nil
        expect(result.average_similarity).to eq(0.0)
        expect(result.confidence).to eq(0)
      end
    end
  end
end
