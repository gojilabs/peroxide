# frozen_string_literal: true

require_relative '../property'

module Peroxide
  class Property
    class Enum < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not in the enum values list '%<values>s'"

      def initialize(name, values, required: false)
        super(name, required:)
        @values = values
      end

      private

      def random_value
        @values.sample
      end

      def valid?
        @values.include?(value)
      end

      def error_message
        format(ERROR_MESSAGE, name:, value:, values:)
      end
    end
  end
end
