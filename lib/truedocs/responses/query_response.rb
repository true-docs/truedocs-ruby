# frozen_string_literal: true

require_relative "base_response"

module Truedocs
  module Responses
    class QueryResponse < BaseResponse
      def answers
        answers_data = raw_data[:answers] || {}
        # Ensure we can access both string and symbol keys
        answers_data.is_a?(Hash) ? answers_data.transform_keys(&:to_sym) : answers_data
      end

      def answer_for(question)
        question_key = question.to_sym
        answers[question_key] || answers[question.to_s]
      end

      def first_answer
        answers.values.first
      end

      def results_for(question)
        question_key = question.to_sym
        question_data = answers[question_key] || answers[question.to_s] || {}
        # Handle both string and symbol keys in the question data
        question_data = question_data.transform_keys(&:to_sym) if question_data.is_a?(Hash)
        question_data[:results] || []
      end
    end
  end
end
