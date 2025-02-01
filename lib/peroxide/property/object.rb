# frozen_string_literal: true

require_relative '../property'

module Peroxide
  class Property
    class Object < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a hash"

      def initialize(name, required: false, array_root: false)
        super(name, required:, array_root:)
        @children = {}
      end

      def add_child(child)
        @children[child.name] = child
      end

      private

      def serialized_value
        value.tap do |hash|
          @children.each do |key, child|
            hash[key] = child.serialized_value
          end
        end
      end

      def random_value
        {}.tap do |hash|
          @children.each do |key, child|
            hash[key] = child.placeholder
          end
        end
      end

      def validated_value(param)
        raise StandardError unless param.respond_to?(:[])

        {}.tap do |validated_param|
          @children.each do |key, child|
            validated_param[key] = child.validate!(param[key])
          end
        end
      rescue StandardError, TypeError
        raise ValidationError
      end
    end
  end
end
