# frozen_string_literal: true

module Peroxide
  module Controller
    extend ActiveSupport::Concern

    def sanitize_request!
      @sanitize_request ||= @sanitizer_class.sanitize_request!(params)
    end

    def sanitized_response(body, status)
      validated_body = @sanitizer_class.sanitize_response!(body, status)
      return head status if !validated_body || validated_body.empty?

      render json: validated_body, status:
    end

    def sanitized_params
      @sanitize_request
    end

    def self.included(base)
      base.class_eval do
        before_action :sanitize_request!

        def sanitizer_class
          return @sanitizer_class if defined?(@sanitizer_class)

          name = "#{self.name[0..self.name.rindex("Controller")]}Peroxide"
          @sanitizer_class = name.constantize
        end
      end
    end
  end
end
