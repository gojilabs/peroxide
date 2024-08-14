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

      def valid?
        value.is_a?(Hash) && @children.all? do |child|
          child.validate!(value[child.name])
        end
      end
    end
  end
end
