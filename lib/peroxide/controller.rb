# frozen_string_literal: true

module Peroxide
  module Controller
    extend ActiveSupport::Concern

    included do
      initialize_peroxide

      def sanitized_params
        @sanitized_params ||= @sanitizer_class.sanitize!(params)
      rescue Peroxide::SanitizationFailed => e
        render json: { message: e.message }, status: :bad_request
      end

      def sanitized_response(status, body)
        validated_body = @sanitizer_class.sanitize!(body, status)
        return head status if !validated_body || validated_body.empty?

        render json: validated_body, status:
      end
    end

    class_methods do
      def initialize_peroxide
        name = "#{self.name[0..self.name.rindex("Controller")]}Peroxide"
        @sanitizer_class = name.constantize
      end
    end
  end
end
