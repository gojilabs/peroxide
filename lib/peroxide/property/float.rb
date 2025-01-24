# frozen_string_literal: true

require_relative 'has_length'
require_relative 'has_range'
require_relative '../property'

module Peroxide
  class Property
    class Float < Peroxide::Property
      include Peroxide::Property::HasLength
      include Peroxide::Property::HasRange

      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s is not a float"

      def initialize(name, range: nil, required: false, length: nil)
        self.length = length
        self.range = range

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
        random_value_from_range || rand(1000)
      end

      def value_for_length_check
        value.to_f.to_s
      end

      def valid?
        value == value_for_length_check.to_f && check_range && check_length
      end
    end
  end
end
