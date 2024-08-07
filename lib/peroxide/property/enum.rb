# frozen_string_literal: true

module Peroxide
  class Property
    class Enum < Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not in the enum values list '%<values>s'"

      def initialize(name, values, required: false)
        super
      end

      private

      def valid?
        values.include?(value)
      end

      def error_message
        format(ERROR_MESSAGE, name: name, value: value, values: values)
      end
    end
  end
end
