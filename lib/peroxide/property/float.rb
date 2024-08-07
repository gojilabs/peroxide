# frozen_string_literal: true

module Peroxide
  class Property
    class Float < Property
      include Peroxide::Property::HasRange

      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s is not a float"

      def initialize(name, range: nil, required: false)
        super
        self.range = range
      end

      private

      def valid?
        value.to_f.to_s == value.to_s && check_range
      end
    end
  end
end
