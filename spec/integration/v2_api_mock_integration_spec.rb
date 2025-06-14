# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe "V2 API Mock Integration Test" do
  let(:client) do
    Truedocs::Client.new(
      api_key: "test_api_key",
      base_url: "https://api.truedocs.mx"
    )
  end

  let(:test_file_path) { File.join(__dir__, "..", "fixtures", "test.pdf") }

  before do
    # Create a dummy PDF file with proper PDF header
    FileUtils.mkdir_p(File.dirname(test_file_path))
    unless File.exist?(test_file_path)
      # Create a minimal PDF file
      pdf_content = "%PDF-1.4\n1 0 obj\n<<\n/Type /Catalog\n/Pages 2 0 R\n>>\nendobj\n2 0 obj\n<<\n/Type /Pages\n/Kids [3 0 R]\n/Count 1\n>>\nendobj\n3 0 obj\n<<\n/Type /Page\n/Parent 2 0 R\n/MediaBox [0 0 612 792]\n>>\nendobj\nxref\n0 4\n0000000000 65535 f \n0000000009 00000 n \n0000000058 00000 n \n0000000115 00000 n \ntrailer\n<<\n/Size 4\n/Root 1 0 R\n>>\nstartxref\n174\n%%EOF"
      File.write(test_file_path, pdf_content)
    end
  end

  after do
    # Clean up the test file
    File.delete(test_file_path) if File.exist?(test_file_path)
  end

  describe "V2 API Response Format Compatibility" do
    it "handles V2 classification response format" do
      # Mock V2 API response
      stub_request(:post, "https://api.truedocs.mx/classify")
        .to_return(
          status: 200,
          body: {
            status: "success",
            data: {
              prediction: {
                documentType: "passport",
                confidence: 95,
                country: "Mexico",
                entity: "Secretaría de Relaciones Exteriores",
                entityShortName: "SRE"
              }
            }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.classify_document(test_file_path)

      expect(response).to be_a(Truedocs::Responses::ClassificationResponse)
      expect(response.success?).to be true
      expect(response.document_type).to eq("passport")
      expect(response.confidence).to eq(95)
      expect(response.country).to eq("Mexico")
      expect(response.entity).to eq("Secretaría de Relaciones Exteriores")
      expect(response.entity_short_name).to eq("SRE")

      # Verify legacy methods are removed
      expect { response.classification_result }.to raise_error(NoMethodError)
    end

    it "handles V2 extraction response format" do
      stub_request(:post, "https://api.truedocs.mx/extract")
        .to_return(
          status: 200,
          body: {
            status: "success",
            data: {
              lines: [
                "INSTITUTO NACIONAL ELECTORAL",
                "CREDENCIAL PARA VOTAR",
                "NOMBRE: JUAN PEREZ GARCIA"
              ],
              fields: {
                nombre: "JUAN PEREZ GARCIA",
                fecha_nacimiento: "15/03/1985"
              }
            }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.extract_data(test_file_path)

      expect(response).to be_a(Truedocs::Responses::ExtractionResponse)
      expect(response.success?).to be true
      expect(response.lines).to include("INSTITUTO NACIONAL ELECTORAL")
      expect(response.fields[:nombre]).to eq("JUAN PEREZ GARCIA")

      # Verify legacy methods are removed
      expect { response.extracted_fields }.to raise_error(NoMethodError)
      expect { response.text_blocks }.to raise_error(NoMethodError)
    end

    it "handles V2 match response format" do
      stub_request(:post, "https://api.truedocs.mx/match")
        .to_return(
          status: 200,
          body: {
            status: "success",
            data: {
              confidence: 90,
              matches: [
                { line: "VIAJERO", similarity: 90 },
                { line: "FRONTERA", similarity: 85 }
              ]
            }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.match_document(test_file_path, "VIAJERO", threshold: 80)

      expect(response).to be_a(Truedocs::Responses::MatchResponse)
      expect(response.success?).to be true
      expect(response.confidence).to eq(90)
      expect(response.matches.first[:line]).to eq("VIAJERO")
      expect(response.matches.first[:similarity]).to eq(90)

      # Verify legacy methods are removed
      expect { response.match_score }.to raise_error(NoMethodError)
    end

    it "handles V2 validation response format" do
      stub_request(:post, "https://api.truedocs.mx/validate")
        .to_return(
          status: 200,
          body: {
            status: "success",
            data: {
              validation: {
                type: "DidExpire",
                match: "Document has not expired",
                confidence: 95,
                isValid: true
              }
            }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.validate_document(test_file_path, "DidExpire")

      expect(response).to be_a(Truedocs::Responses::ValidationResponse)
      expect(response.success?).to be true
      expect(response.validation_type).to eq("DidExpire")
      expect(response.is_valid).to be true
      expect(response.valid?).to be true

      # Verify legacy methods are removed
      expect { response.validation_result }.to raise_error(NoMethodError)
      expect { response.warnings }.to raise_error(NoMethodError)
    end

    it "handles V2 verification response format" do
      stub_request(:post, "https://api.truedocs.mx/verify")
        .to_return(
          status: 200,
          body: {
            status: "success",
            data: {
              verifications: {
                found: {
                  issuer: "SAT",
                  documentNumber: "ABC123456789"
                },
                notFound: [],
                messages: ["Document successfully verified"]
              }
            }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.verify_document(test_file_path, "ine_reverso")

      expect(response).to be_a(Truedocs::Responses::VerificationResponse)
      expect(response.success?).to be true
      expect(response.found[:issuer]).to eq("SAT")
      expect(response.verified?).to be true
      expect(response.messages).to include("Document successfully verified")

      # Verify legacy methods are removed
      expect { response.verification_result }.to raise_error(NoMethodError)
      expect { response.status }.to raise_error(NoMethodError)
    end

    it "handles V2 query response format" do
      stub_request(:post, "https://api.truedocs.mx/query")
        .to_return(
          status: 200,
          body: {
            status: "success",
            data: {
              answers: {
                "What type of document is this?" => {
                  results: [
                    {
                      text: "This is a passport document",
                      confidence: 92,
                      page: 1
                    }
                  ]
                }
              }
            }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.query_document(test_file_path, "What type of document is this?")

      expect(response).to be_a(Truedocs::Responses::QueryResponse)
      expect(response.success?).to be true
      expect(response.answers).to have_key(:"What type of document is this?")

      results = response.results_for("What type of document is this?")
      expect(results.first["text"]).to eq("This is a passport document")

      # Verify legacy methods are removed
      expect { response.answer }.to raise_error(NoMethodError)
      expect { response.sources }.to raise_error(NoMethodError)
    end

    it "handles V2 ask response format" do
      stub_request(:post, "https://api.truedocs.mx/ask")
        .to_return(
          status: 200,
          body: {
            status: "success",
            data: {
              response: "Yes, this document appears to be valid and has not expired."
            }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.ask_document(test_file_path, "Is this document valid?")

      expect(response).to be_a(Truedocs::Responses::AskResponse)
      expect(response.success?).to be true
      expect(response.response).to eq("Yes, this document appears to be valid and has not expired.")

      # Verify legacy methods are removed
      expect { response.answer }.to raise_error(NoMethodError)
      expect { response.context }.to raise_error(NoMethodError)
    end

    it "handles V2 job response format with uppercase status" do
      stub_request(:post, "https://api.truedocs.mx/verify")
        .to_return(
          status: 200,
          body: {
            status: "success",
            data: {
              jobId: "job_123456789",
              status: "PENDING",
              progress: 0,
              createdAt: "2024-01-15T10:30:00Z"
            }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      response = client.verify_document(test_file_path, "ine_reverso", async: true)

      expect(response).to be_a(Truedocs::Responses::JobResponse)
      expect(response.success?).to be true
      expect(response.job_id).to eq("job_123456789")
      expect(response.status).to eq("PENDING")
      expect(response.pending?).to be true
      expect(response.completed?).to be false
    end

    it "verifies API version header is sent" do
      stub_request(:post, "https://api.truedocs.mx/classify")
        .with(headers: { "X-API-Version" => "2" })
        .to_return(
          status: 200,
          body: {
            status: "success",
            data: { prediction: { documentType: "test" } }
          }.to_json
        )

      client.classify_document(test_file_path)

      # The stub will only match if the correct header is sent
      expect(WebMock).to have_requested(:post, "https://api.truedocs.mx/classify")
        .with(headers: { "X-API-Version" => "2" })
    end
  end
end
