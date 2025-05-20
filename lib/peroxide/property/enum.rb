# frozen_string_literal: true

require_relative '../property'

module Peroxide
  class Property
    class Enum < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not in the enum values list '%<values>s'"

      def initialize(name, values, required: false)
        super(name, required:)

        raise ConfigurationError, "'values' argument must have a #to_a method" unless values.respond_to?(:to_a)

        @values = values.to_a
      end

      private

      def serialized_value
        value.to_s
      end

      def random_value
        @values.sample
      end

      def validated_value(param)
        return param if @values.include?(param) && param.respond_to?(:to_s)

        raise ValidationError, format(ERROR_MESSAGE, name:, value:, values: @values)
      end

      def error_message
        format(ERROR_MESSAGE, name:, value:, values: @values)
      end
    end
  end
end
