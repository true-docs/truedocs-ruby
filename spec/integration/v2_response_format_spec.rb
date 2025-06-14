# frozen_string_literal: true

require "spec_helper"

RSpec.describe "V2 Response Format Integration Test" do
  describe "Response parsing for V2 API format" do
    it "correctly parses V2 classification response" do
      v2_response_data = {
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
      }

      response = Truedocs::Responses::ClassificationResponse.new(v2_response_data[:data])

      expect(response.document_type).to eq("passport")
      expect(response.confidence).to eq(95)
      expect(response.country).to eq("Mexico")
      expect(response.entity).to eq("Secretaría de Relaciones Exteriores")
      expect(response.entity_short_name).to eq("SRE")

      # Verify legacy methods are removed
      expect { response.classification_result }.to raise_error(NoMethodError)
    end

    it "correctly parses V2 extraction response" do
      v2_response_data = {
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
      }

      response = Truedocs::Responses::ExtractionResponse.new(v2_response_data[:data])

      expect(response.lines).to include("INSTITUTO NACIONAL ELECTORAL")
      expect(response.fields[:nombre]).to eq("JUAN PEREZ GARCIA")

      # Verify legacy methods are removed
      expect { response.extracted_fields }.to raise_error(NoMethodError)
      expect { response.text_blocks }.to raise_error(NoMethodError)
    end

    it "correctly parses V2 match response" do
      v2_response_data = {
        status: "success",
        data: {
          confidence: 90,
          matches: [
            { line: "VIAJERO", similarity: 90 },
            { line: "FRONTERA", similarity: 85 }
          ]
        }
      }

      response = Truedocs::Responses::MatchResponse.new(v2_response_data[:data])

      expect(response.confidence).to eq(90)
      expect(response.matches.first[:line]).to eq("VIAJERO")
      expect(response.matches.first[:similarity]).to eq(90)

      # Verify legacy methods are removed
      expect { response.match_score }.to raise_error(NoMethodError)
    end

    it "correctly parses V2 validation response" do
      v2_response_data = {
        status: "success",
        data: {
          validation: {
            type: "DidExpire",
            match: "Document has not expired",
            confidence: 95,
            isValid: true
          }
        }
      }

      response = Truedocs::Responses::ValidationResponse.new(v2_response_data[:data])

      expect(response.validation_type).to eq("DidExpire")
      expect(response.is_valid).to be true
      expect(response.valid?).to be true

      # Verify legacy methods are removed
      expect { response.validation_result }.to raise_error(NoMethodError)
      expect { response.warnings }.to raise_error(NoMethodError)
    end

    it "correctly parses V2 verification response" do
      v2_response_data = {
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
      }

      response = Truedocs::Responses::VerificationResponse.new(v2_response_data[:data])

      expect(response.found[:issuer]).to eq("SAT")
      expect(response.verified?).to be true
      expect(response.messages).to include("Document successfully verified")

      # Verify legacy methods are removed
      expect { response.verification_result }.to raise_error(NoMethodError)
      expect { response.status }.to raise_error(NoMethodError)
    end

    it "correctly parses V2 query response" do
      v2_response_data = {
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
      }

      response = Truedocs::Responses::QueryResponse.new(v2_response_data[:data])

      expect(response.answers).to have_key(:"What type of document is this?")
      results = response.results_for("What type of document is this?")
      expect(results.first[:text]).to eq("This is a passport document")

      # Verify legacy methods are removed
      expect { response.answer }.to raise_error(NoMethodError)
      expect { response.sources }.to raise_error(NoMethodError)
    end

    it "correctly parses V2 ask response" do
      v2_response_data = {
        status: "success",
        data: {
          response: "Yes, this document appears to be valid and has not expired."
        }
      }

      response = Truedocs::Responses::AskResponse.new(v2_response_data[:data])

      expect(response.response).to eq("Yes, this document appears to be valid and has not expired.")

      # Verify legacy methods are removed
      expect { response.answer }.to raise_error(NoMethodError)
      expect { response.context }.to raise_error(NoMethodError)
    end

    it "correctly parses V2 job response with uppercase status" do
      v2_response_data = {
        status: "success",
        data: {
          jobId: "job_123456789",
          status: "PENDING",
          progress: 0,
          createdAt: "2024-01-15T10:30:00Z"
        }
      }

      response = Truedocs::Responses::JobResponse.new(v2_response_data[:data])

      expect(response.job_id).to eq("job_123456789")
      expect(response.status).to eq("PENDING")
      expect(response.pending?).to be true
      expect(response.completed?).to be false
    end

    it "handles V2 error response format" do
      v2_error_data = {
        status: "error",
        error: {
          code: "INVALID_FILE",
          message: "The uploaded file is not a valid document"
        }
      }

      # Test that our base response can handle error status
      response = Truedocs::Responses::BaseResponse.new(v2_error_data)
      expect(response.raw_data[:status]).to eq("error")
      expect(response.success?).to be false
      expect(response.error?).to be true
    end
  end

  describe "Client V2 response parsing" do
    let(:client) do
      Truedocs::Client.new(api_key: "test_key")
    end

    it "extracts data from V2 response format" do
      # Mock the connection to return V2 format
      mock_response = double(
        status: 200,
        body: {
          "status" => "success",
          "data" => {
            "prediction" => {
              "documentType" => "passport",
              "confidence" => 95
            }
          }
        }
      )

      allow(client.instance_variable_get(:@connection)).to receive(:post).and_return(mock_response)

      # Test that the client correctly extracts the data portion
      response_data = client.send(:handle_response, mock_response)
      expect(response_data["prediction"]["documentType"]).to eq("passport")
    end

    it "uses API version 2 in headers" do
      connection = client.instance_variable_get(:@connection)
      expect(connection.headers["X-API-Version"]).to eq("2")
    end
  end
end
