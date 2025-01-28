# frozen_string_literal: true

require_relative '../property'

module Peroxide
  class Property
    class NoContent < Peroxide::Property
      ERROR_MESSAGE = 'Response body must be empty'

      def initialize(required: false)
        super('_no_content', required:)
      end

      private

      def serialized_value
        nil
      end

      def random_value
        nil
      end

      def validated_value(param)
        return param if param.nil?

        raise ValidationError
      end
    end
  end
end
