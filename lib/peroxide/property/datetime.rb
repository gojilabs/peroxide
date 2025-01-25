# frozen_string_literal: true

require 'active_support/core_ext/time'
require_relative '../property'
require_relative '../property/has_range'

module Peroxide
  class Property
    class Datetime < Peroxide::Property
      include Peroxide::Property::HasRange
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' must be either a valid Time object, an integer representing a Unix timestamp, or a string in the format 'YYYY-MM-DD HH:MM:SSZ'"

      def initialize(name, range: nil, required: false)
        super(name, required:)
        self.range = range
      end

      private

      def random_value
        random_value_from_range || Time.new(
          rand(1900..Time.now.year + 10),
          rand(1..12),
          rand(1..28),
          rand(0..23),
          rand(0..59),
          rand(0..59)
        )
      end

      def valid?
        @datetime ||=
          case value
          when Time
            value
          when String
            Time.strptime(value, '%Y-%m-%d %H:%M:%S%z')
          else
            numeric_value = value.to_i
            raise ValidationError, error_message unless numeric_value.to_s.to_i == numeric_value

            Time.at(numeric_value)
          end

        @valid ||= @datetime && check_range
      end
    end
  end
end
