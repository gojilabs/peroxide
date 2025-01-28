# frozen_string_literal: true

require 'time'
require 'date'
require_relative '../property'
require_relative 'has_range'

module Peroxide
  class Property
    class Datetime < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' must be either a valid Time object or an ISO8601 string"

      def initialize(name, required: false, range: nil)
        self.range = range

        super(name, required:)
      end

      private

      def serialized_value
        value.to_time.utc.iso8601(3)
      end

      def random_value
        Time.new(
          rand(1900..Date.today.year + 10),
          rand(1..12),
          rand(1..28),
          rand(0..23),
          rand(0..59),
          rand(0..59),
          rand(0..999)
        ).utc
      end

      def validated_value(param)
        return param if param.respond_to?(:to_time)
        return Time.iso8601(param.to_s) if param.respond_to?(:to_s)

        raise ValidationError
      rescue StandardError
        raise ValidationError
      end

      prepend Peroxide::Property::HasRange
    end
  end
end
