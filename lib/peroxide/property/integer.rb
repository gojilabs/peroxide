# frozen_string_literal: true

require_relative '../property'
require_relative 'has_range'

module Peroxide
  class Property
    class Integer < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not an integer"
      DEFAULT_RANDOM_RANGE = (-1000..1000)

      def initialize(name, required: false, range: nil)
        self.range = range

        super(name, required:)
      end

      private

      def serialized_value
        value.to_i
      end

      def random_value
        rand(DEFAULT_RANDOM_RANGE).to_i
      end

      def validated_value(param)
        return param if param.to_s.to_i == param

        raise ValidationError
      end

      prepend Peroxide::Property::HasRange
    end
  end
end
