# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class QueryResponse < BaseResponse
      def answers
        raw_data[:answers] || {}
      end

      def answer_for(question)
        answers[question] || answers[question.to_s] || answers[question.to_sym]
      end

      def first_answer
        answers.values.first
      end

      def results_for(question)
        answer_data = answer_for(question)
        answer_data ? answer_data[:results] || [] : []
      end
    end
  end
end
