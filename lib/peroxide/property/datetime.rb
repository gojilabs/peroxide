# frozen_string_literal: true

module Peroxide
  class Property
    class Datetime < Property
      include Peroxide::Property::HasRange
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a valid datetime or is not a string in the format 'YYYY-MM-DD HH:MM:SSZ'"

      def initialize(name, range: nil, required: false)
        super
        self.range = range
      end

      private

      def valid?
        @datetime ||= value.is_a?(Time) ? value : Time.parse(value)
        @datetime.present? && check_bounds
      end
    end
  end
end
