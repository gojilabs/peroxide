# frozen_string_literal: true

require 'peroxide/property/has_length'

module Peroxide
  class Property
    class Array < Property
      include Peroxide::Property::HasLength

      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not an array"

      attr_writer :child

      def initialize(name, length: nil, required: false)
        super
        self.length = length
      end

      private

      def supports_single_child?
        true
      end

      def valid?
        value.is_a?(Array) && check_length && value.all? do |item|
          @child.validate!(item)
        end
      end
    end
  end
end
