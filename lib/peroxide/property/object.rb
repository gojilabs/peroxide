# frozen_string_literal: true

require_relative '../property'

module Peroxide
  class Property
    class Object < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a hash"

      def initialize(name, required: false)
        super(name, required:)
        @children = {}
      end

      def add_child(child)
        @children[child.name] = child
      end

      private

      def handle_missing_field(key, child, param)
        return false if field_present?(key, param)
        
        raise "Property '#{key}' is missing" if child.required?
        true
      end

      def field_present?(key, param)
        param.key?(key.to_sym) || param.key?(key)
      end

      def transform_child_data(child_data, key)
        child_data.is_a?(Hash) && child_data.size == 1 && child_data[key] ? child_data[key] : child_data
      end

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
        _, first_property = @children.first
        return { name => first_property.validate!(param) } if @children.size == 1 && first_property.is_a?(Peroxide::Property::Array)

        param = param.permit!.to_h if param.respond_to?(:permit!)
        param = param.deep_symbolize_keys
        result = {}

        validated_data = {}
        @children.each do |key, child|
          next if handle_missing_field(key, child, param)
          
          child_data = child.validate!(param)
          validated_data[key] = transform_child_data(child_data, key)
        end

        return validated_data if name.nil?

        result[name] = validated_data
        result
      rescue StandardError, TypeError => e
        raise ValidationError, e.message
      end
    end
  end
end