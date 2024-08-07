# frozen_string_literal: true

module Peroxide
  class Property
    class Date < Property
      include Peroxide::Property::HasRange
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a valid date or is not a string in the format 'YYYY-MM-DD'"

      def initialize(name, range: nil, required: false)
        super
        self.range = range
      end

      private

      def valid?
        @date ||= value.is_a?(Date) ? value : Date.parse(value)
        @date.present? && check_bounds
      end
    end
  end
end
