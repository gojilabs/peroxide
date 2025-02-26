# frozen_string_literal: true

require_relative '../property'
require_relative 'has_length'

module Peroxide
  class Property
    class Array < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not an array or one of its items is not valid"
      DEFAULT_MAX_LENGTH = 20

      attr_accessor :item_property

      def initialize(name, required: false, length: nil, array_root: false)
        self.length = length

        super(name, required:, array_root:)
      end

      private

      def random_value
        rand(DEFAULT_MAX_LENGTH).to_i.times.map do
          item_property.placeholder
        end
      end

      def serialized_value
        value.map { |item| item_property.serialize(item) }
      end

      def validated_value(param)
        return param.map { |item| item_property.validate!(item) } if param.respond_to?(:map)

        raise ValidationError
      end

      prepend Peroxide::Property::HasLength
    end
  end
end
