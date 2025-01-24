# frozen_string_literal: true

require_relative 'has_length'
require_relative 'has_range'
require_relative '../property'

module Peroxide
  class Property
    class Integer < Peroxide::Property
      include Peroxide::Property::HasLength
      include Peroxide::Property::HasRange

      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not an integer"

      def initialize(name, required: false, range: nil, length: nil)
        self.range = range
        self.length = length

        if length? && range?
          raise MaximumValueIsTooShortError if range_max_length < length
          raise MinimumValueIsTooShortError if range_min_length < length
          raise MaximumValueIsTooLongError if range_max_length > length
          raise MinimumValueIsTooLongError if range_min_length > length
        end

        super(name, required:)
      end

      private

      def random_value
        random_value_from_range || rand(1000).to_i
      end

      def valid?
        value_for_length_check.to_i == value && check_range && check_length
      end

      def value_for_length_check
        value.to_i.to_s
      end
    end
  end
end
