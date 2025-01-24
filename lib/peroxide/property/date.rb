# frozen_string_literal: true

require_relative '../property'
require_relative '../property/has_range'

module Peroxide
  class Property
    class Date < Peroxide::Property
      include Peroxide::Property::HasRange
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a valid date or is not a string in the format 'YYYY-MM-DD'"

      def initialize(name, range: nil, required: false)
        super(name, required:)
        self.range = range
      end

      private

      def random_value
        random_value_from_range || Date.new(
          rand(1900..Date.today.year + 10),
          rand(1..12),
          rand(1..28)
        )
      end

      def valid?
        @date ||= value.is_a?(Date) ? value : Date.parse(value)
        @date && !@date.empty? && check_bounds
      end
    end
  end
end
