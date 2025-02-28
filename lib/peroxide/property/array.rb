# frozen_string_literal: true

require_relative '../property'
require_relative 'has_length'

module Peroxide
  class Property
    class Array < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not an array or one of its items is not valid"
      DEFAULT_MAX_LENGTH = 10_000

      attr_accessor :item_property

      def initialize(name, required: false, length: nil, array_root: false, item_property: nil)
        self.length = length
        self.item_property = item_property
        super(name, required:, array_root:)
      end

      private

      def random_value
        ::Array.new(rand(DEFAULT_MAX_LENGTH)) { item_property.placeholder }
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
