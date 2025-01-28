# frozen_string_literal: true

require_relative '../property'
require_relative 'has_range'

module Peroxide
  class Property
    class Float < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s is not a float"
      DEFAULT_RANDOM_RANGE = (-1000.0..1000.0)

      def initialize(name, required: false, range: nil)
        self.range = range

        super(name, required:)
      end

      private

      def serialized_value
        value.to_f
      end

      def random_value
        rand(DEFAULT_RANDOM_RANGE).to_f
      end

      def validated_value(param)
        return param if param == param.to_s.to_f

        raise ValidationError
      end

      prepend Peroxide::Property::HasRange
    end
  end
end
