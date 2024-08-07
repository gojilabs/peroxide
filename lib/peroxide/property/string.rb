# frozen_string_literal: true

module Peroxide
  class Property
    class String < Property
      include Peroxide::Property::HasLength
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a string"

      def initialize(name, required: false, length: nil)
        super
        self.length = length
      end

      private

      def valid?
        value.to_s == value
      end
    end
  end
end
