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

      def valid?
        @date ||= value.is_a?(Date) ? value : Date.parse(value)
        @date && !@date.empty? && check_bounds
      end
    end
  end
end
