# frozen_string_literal: true

require_relative '../property'
require_relative 'has_range'

module Peroxide
  class Property
    class Date < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a valid date or is not a string in the format 'YYYY-MM-DD'"

      def initialize(name, range: nil, required: false)
        super(name, required:)
        self.range = range
      end

      private

      def random_value
        random_value_from_range || ::Date.new(
          rand(1900..Time.now.year + 10),
          rand(1..12),
          rand(1..28)
        )
      end

      def valid?
        @valid ||= value.respond_to?(:to_date) ? value.to_date : ::Date.parse(value)
      rescue ::Date::Error, TypeError
        false
      end

      prepend Peroxide::Property::HasRange
    end
  end
end
