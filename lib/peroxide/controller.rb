# frozen_string_literal: true

require 'active_support/concern'

module Peroxide
  module Controller
    extend ActiveSupport::Concern

    included do
      before_action :sanitize_body!
      before_action :sanitize_url!

      attr_reader :sanitized_params

      def sanitizer_class
        return @sanitizer_class if defined?(@sanitizer_class)

        class_name = self.class.name

        name = "#{class_name[0...class_name.rindex("Controller")]}Sanitizer"
        @sanitizer_class = name.constantize
      end

      def sanitize_body!
        body = sanitizer_class.sanitize_body!(params)
        @sanitized_params ||= {}
        @sanitized_params[:body] = body
      rescue Peroxide::Property::ValidationError
        render json: { error: { msg: "Invalid params in request body: #{e.message}", code: 400 } }, status: :bad_request
      end

      def sanitize_url!
        url = sanitizer_class.sanitize_url!(params)
        @sanitized_params ||= {}
        @sanitized_params[:url] = url
      rescue Peroxide::Property::ValidationError
        render json: { error: { msg: "Invalid params in request url: #{e.message}", code: 400 } }, status: :bad_request
      end

      def render_sanitized_response(body, action, status)
        sanitized_response_body = @sanitizer_class.sanitize_response!(body, action, status)
        head_only_response = !sanitized_response_body ||
                             (sanitized_response_body.respond_to?(:empty?) && sanitized_response_body.empty?)

        return head status if head_only_response

        render json: sanitized_response_body, status:
      end

      def render_placeholder_response(status)
        render json: sanitizer_class.placeholder_response!(params, status), status:
      end
    end
  end
end
