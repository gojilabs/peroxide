# frozen_string_literal: true

require_relative '../property'
require_relative '../property/has_range'

module Peroxide
  class Property
    class Datetime < Peroxide::Property
      include Peroxide::Property::HasRange
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a valid datetime or is not a string in the format 'YYYY-MM-DD HH:MM:SSZ'"

      def initialize(name, range: nil, required: false)
        super(name, required:)
        self.range = range
      end

      private

      def random_value
        random_value_from_range || Time.new(
          rand(1900..Date.today.year + 10),
          rand(1..12),
          rand(1..28),
          rand(0..23),
          rand(0..59),
          rand(0..59)
        )
      end

      def valid?
        @datetime ||= value.is_a?(Time) ? value : Time.parse(value)
        @datetime && !@datetime.empty? && check_bounds
      end
    end
  end
end
