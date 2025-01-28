# frozen_string_literal: true

require_relative '../property'
require_relative 'has_length'

module Peroxide
  class Property
    class Array < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not an array"

      attr_accessor :item_property

      def initialize(name, length: nil, required: false)
        super(name, required:)
        self.length = length
      end

      private

      def random_value
        len = length? ? length.to_a.sample : rand(20).to_i
        len.times.map do
          item_property.random_value
        end
      end

      def valid?
        value.is_a?(Array) && value.all? do |item|
          item_property.validate!(item)
        end
      end

      prepend Peroxide::Property::HasLength
    end
  end
end
