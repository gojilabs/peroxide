# frozen_string_literal: true

require 'active_support/concern'

module Peroxide
  module Controller
    extend ActiveSupport::Concern

    def sanitize_request!
      @sanitize_request ||= sanitizer_class.sanitize_request!(params)
    end

    def sanitized_response(body, status)
      validated_body = @sanitizer_class.sanitize_response!(body, status)
      return head status if !validated_body || validated_body.empty?

      render json: validated_body, status:
    end

    def placeholder_response(status)
      sanitizer_class.placeholder_response(status)
    end

    def sanitized_params
      @sanitize_request
    end

    def self.included(base)
      base.class_eval do
        before_action :sanitize_request!

        def sanitizer_class
          return @sanitizer_class if defined?(@sanitizer_class)

          class_name = self.class.name

          name = "#{class_name[0...class_name.rindex("Controller")]}Sanitizer"
          @sanitizer_class = name.constantize
        end
      end
    end
  end
end
