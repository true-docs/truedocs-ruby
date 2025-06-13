# frozen_string_literal: true

require_relative "../utils/file_handler"
require_relative "../responses/validation_response"

module Truedocs
  module Resources
    module Validation
      def validate_document(file, validation_type, **options)
        validate_validation_type!(validation_type)
        file_data = prepare_file(file)

        payload = {
          document: file_data,
          validationType: validation_type
        }

        response = perform_request(:post, "/validate", payload: payload, **options)
        Responses::ValidationResponse.new(response)
      end

      def feedback(is_positive:, endpoint:, description: nil, job_id: nil, document_id: nil, **options)
        payload = {
          isPositive: is_positive,
          endpoint: endpoint
        }

        payload[:description] = description if description
        payload[:jobId] = job_id if job_id
        payload[:documentId] = document_id if document_id

        perform_request(
          :post,
          "/feedback",
          payload: payload.to_json,
          **options.merge(content_type: "application/json")
        )

        # Feedback typically returns a simple success response
      end

      private

      def validate_validation_type!(validation_type)
        return if VALIDATION_TYPES.values.include?(validation_type)

        raise ValidationError, "Invalid validation type. Must be one of: #{VALIDATION_TYPES.values.join(", ")}"
      end
    end
  end
end
