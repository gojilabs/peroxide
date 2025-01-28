# frozen_string_literal: true

require_relative '../property'
require_relative 'has_range'

module Peroxide
  class Property
    class Integer < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not an integer"

      def initialize(name, required: false, range: nil)
        self.range = range

        super(name, required:)
      end

      private

      def random_value
        random_value_from_range || rand(1000).to_i
      end

      def valid?
        value.to_s.to_i == value
      end

      prepend Peroxide::Property::HasRange
    end
  end
end
