# frozen_string_literal: true

require_relative '../property'

module Peroxide
  class Property
    class Float < Peroxide::Property
      include Peroxide::Property::HasRange

      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s is not a float"

      def initialize(name, range: nil, required: false)
        super(name, required:)
        self.range = range
      end

      private

      def valid?
        value.to_f.to_s == value.to_s && check_range
      end
    end
  end
end
