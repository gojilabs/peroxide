# frozen_string_literal: true

require_relative '../property'
require_relative '../property/has_length'

module Peroxide
  class Property
    class String < Peroxide::Property
      include Peroxide::Property::HasLength
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a string"

      def initialize(name, required: false, length: nil)
        super(name, required:)
        self.length = length
      end

      private

      def valid?
        value.to_s == value_for_length_check && check_length
      end

      def value_for_length_check
        value
      end

      def random_value
        len = length? ? length.to_a.sample : rand(40).to_i
        SecureRandom.hex(len)
      end
    end
  end
end
