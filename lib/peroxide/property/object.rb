# frozen_string_literal: true

module Peroxide
  class Property
    class Object < Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a hash"

      def initialize(name, required: false)
        super
        @children = []
      end

      private

      def supports_multiple_children?
        true
      end

      def valid?
        value.is_a?(Hash) && @children.all? do |child|
          child.validate!(value[child.name])
        end
      end
    end
  end
end
