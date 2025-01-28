# frozen_string_literal: true

require_relative '../property'
require_relative 'has_range'

module Peroxide
  class Property
    class Float < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s is not a float"

      def initialize(name, range: nil, required: false)
        self.range = range

        super(name, required:)
      end

      private

      def random_value
        random_value_from_range || rand(1000)
      end

      def valid?
        value == value.to_s.to_f
      end

      prepend Peroxide::Property::HasRange
    end
  end
end
