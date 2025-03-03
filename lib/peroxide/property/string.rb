# frozen_string_literal: true

require_relative '../property'
require_relative 'has_length'

module Peroxide
  class Property
    class String < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a string"
      DEFAULT_MAX_LENGTH = 140
      ALPHABET = [*('a'..'z'), *('A'..'Z')].shuffle

      def initialize(name, required: false, length: nil)
        self.length = length

        super(name, required:)
      end

      private

      def serialized_value
        value.to_s
      end

      def validated_value(param)
        return param if param.to_s == param

        raise ValidationError
      end

      def random_value
        ::Array.new(rand(DEFAULT_MAX_LENGTH)) { ALPHABET.sample }.join
      end

      prepend Peroxide::Property::HasLength
    end
  end
end
