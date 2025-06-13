# frozen_string_literal: true

require_relative "../utils/file_handler"
require_relative "../responses/classification_response"
require_relative "../responses/extraction_response"
require_relative "../responses/verification_response"
require_relative "../responses/match_response"
require_relative "../responses/query_response"
require_relative "../responses/ask_response"
require_relative "../responses/job_response"

module Truedocs
  module Resources
    module Document
      def classify_document(file, **options)
        file_data = prepare_file(file)
        response = perform_request(:post, "/classify", payload: { document: file_data }, **options)
        Responses::ClassificationResponse.new(response)
      end

      def extract_data(file, fields: nil, **options)
        file_data = prepare_file(file)
        payload = { document: file_data }
        payload[:fields] = fields.to_json if fields

        response = perform_request(:post, "/extract", payload: payload, **options)
        Responses::ExtractionResponse.new(response)
      end

      def verify_document(file, document_type, async: false, callback_url: nil, **options)
        validate_document_type!(document_type)
        file_data = prepare_file(file)

        payload = {
          documentType: document_type,
          document: file_data
        }

        if async
          payload[:async] = true
          payload[:callbackUrl] = callback_url if callback_url
        end

        response = perform_request(:post, "/verify", payload: payload, **options)

        if async
          Responses::JobResponse.new(response.merge(job_id: response["jobId"]))
        else
          Responses::VerificationResponse.new(response)
        end
      end

      def match_document(file, identifier, threshold: nil, top_k: nil, **options)
        file_data = prepare_file(file)

        payload = {
          document: file_data,
          identifier: identifier
        }

        payload[:threshold] = threshold if threshold
        payload[:top_k] = top_k if top_k

        response = perform_request(:post, "/match", payload: payload, **options)
        Responses::MatchResponse.new(response)
      end

      def query_document(file, query, **options)
        payload = {
          document: prepare_file(file),
          query: query
        }

        response = perform_request(:post, "/query", payload: payload, **options)
        Responses::QueryResponse.new(response)
      end

      def ask_document(file, question, **options)
        payload = {
          document: prepare_file(file),
          question: question
        }

        response = perform_request(:post, "/ask", payload: payload, **options)
        Responses::AskResponse.new(response)
      end

      private

      def prepare_file(file)
        Utils::FileHandler.new(file).prepare
      end

      def validate_document_type!(document_type)
        return if DOCUMENT_TYPES.values.include?(document_type)

        raise ValidationError, "Invalid document type. Must be one of: #{DOCUMENT_TYPES.values.join(", ")}"
      end
    end
  end
end
