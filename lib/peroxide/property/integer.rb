# frozen_string_literal: true

module Peroxide
  class Property
    class Integer < Property
      include Peroxide::Property::HasRange
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not an integer"

      def initialize(name, required: false, range: nil)
        super
        self.range = range
      end

      private

      def valid?
        value.to_i.to_s == value.to_s && check_range
      end
    end
  end
end
