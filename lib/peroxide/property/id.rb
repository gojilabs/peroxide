# frozen_string_literal: true

require_relative '../property'
require_relative '../../ext/integer'
require_relative 'has_range'

module Peroxide
  class Property
    class Id < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a valid id"
      DEFAULT_RANDOM_RANGE = (::Integer::MIN_UINT..::Integer::MAX_UINT)

      def initialize(name, required: false, array_root: false)
        self.range = DEFAULT_RANDOM_RANGE

        super(name, required:, array_root:)
      end

      private

      def serialized_value
        value.to_i
      end

      def random_value
        puts "Generating random value for #{name} as integer"
        rand(DEFAULT_RANDOM_RANGE).to_i
      end

      def validated_value(param)
        return param if param.is_a?(::Integer)
        return param.to_i if param.is_a?(::String) && param.to_i.to_s == param

        raise StandardError
      rescue StandardError
        raise ValidationError
      end

      prepend Peroxide::Property::HasRange
    end
  end
end
