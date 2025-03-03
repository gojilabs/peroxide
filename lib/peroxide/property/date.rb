# frozen_string_literal: true

require 'date'
require_relative '../property'
require_relative 'has_range'

module Peroxide
  class Property
    class Date < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a valid date or is not an ISO8601 string"

      def initialize(name, required: false, range: nil)
        self.range = range

        super(name, required:)
      end

      private

      def serialized_value
        value.to_date.iso8601
      end

      def random_value
        ::Date.new(
          rand(1900..::Date.today.year + 10),
          rand(1..12),
          rand(1..28)
        )
      end

      def validated_value(param)
        date = ::Date.iso8601(param.to_s) if param.respond_to?(:to_s)

        raise StandardError unless date

        date
      rescue StandardError, ArgumentError
        raise ValidationError
      end

      prepend Peroxide::Property::HasRange
    end
  end
end
