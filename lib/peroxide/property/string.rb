# frozen_string_literal: true

require_relative '../property'
require_relative 'has_length'

module Peroxide
  class Property
    class String < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a string"
      DEFAULT_MAX_LENGTH = 20

      def initialize(name, required: false, length: nil)
        self.length = length

        super(name, required:)
      end

      private

      def serialized_value
        value.to_s
      end

      def validated_value(param)
        return param if param.to_s == param

        raise ValidationError
      end

      def random_value
        SecureRandom.hex(rand(DEFAULT_MAX_LENGTH).to_i)
      end

      prepend Peroxide::Property::HasLength
    end
  end
end
