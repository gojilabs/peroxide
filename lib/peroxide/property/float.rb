# frozen_string_literal: true

require_relative '../property'
require_relative 'has_range'

module Peroxide
  class Property
    class Float < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s is not a float"
      DEFAULT_RANDOM_RANGE = (::Float::MIN..::Float::MAX)

      def initialize(name, required: false, range: nil, array_root: false)
        self.range = range

        super(name, required:, array_root:)
      end

      private

      def serialized_value
        value.to_f
      end

      def random_value
        rand(DEFAULT_RANDOM_RANGE).to_f
      end

      def validated_value(param)
        return param if param.is_a?(::Float) || param.is_a?(::Integer)
        return param.to_f if param.is_a?(::String) && param.to_f.to_s == param

        raise StandardError
      rescue StandardError
        raise ValidationError
      end

      prepend Peroxide::Property::HasRange
    end
  end
end
