# frozen_string_literal: true

require_relative '../property'

module Peroxide
  class Property
    class Object < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a hash"

      def initialize(name, required: false)
        super(name, required:)
        @children = []
      end

      def add_child(child)
        @children << child
      end

      private

      def random_value
        {}.tap do |hash|
          @children.each do |child|
            hash[child.name] = child.random_value
          end
        end
      end

      def valid?
        value.is_a?(Hash) && @children.all? do |child|
          child.validate!(value[child.name])
        end
      end
    end
  end
end
