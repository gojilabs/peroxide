# frozen_string_literal: true

require_relative '../property'
require_relative 'has_length'

module Peroxide
  class Property
    class Array < Peroxide::Property
      include Peroxide::Property::HasLength

      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not an array"

      attr_writer :child

      def initialize(name, length: nil, required: false)
        super(name, required:)
        self.length = length
      end

      private

      def valid?
        value.is_a?(Array) && check_length && value.all? do |item|
          @child.validate!(item)
        end
      end
    end
  end
end
