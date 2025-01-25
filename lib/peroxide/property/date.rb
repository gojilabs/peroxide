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
        random_value_from_range || ::Date.new(
          rand(1900..Time.now.year + 10),
          rand(1..12),
          rand(1..28)
        )
      end

      def valid?
        @date ||= value.is_a?(Date) ? value : ::Date.parse(value)
        @valid ||= @date && check_range
      rescue ::Date::Error, TypeError
        raise ValidationError, error_message
      end
    end
  end
end
