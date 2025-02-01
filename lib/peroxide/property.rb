# frozen_string_literal: true

module Peroxide
  class Property
    class Error < Peroxide::Error; end
    class ConfigurationError < Error; end
    class ValidationError < Error; end

    ERROR_MESSAGE = "Property '%<name>s' is required but was not provided"

    attr_reader :name, :value

    def initialize(name, required: false, array_root: false)
      raise ConfigurationError, 'Property name is required' unless array_root || name.to_s&.length&.positive?

      @name = name
      @required = required
    end

    def required?
      @required
    end

    def placeholder
      return nil unless placeholder_required?

      random_value
    end

    def serialize
      return @serialize if defined?(@serialize)
      return nil unless defined?(@value)

      @serialize = serialized_value
    end

    def validate!(param)
      raise ValidationError, error_message if required? && param.nil?

      @value = validated_value(param)
    end

    private

    def placeholder_required?
      required? || Property::Boolean::RANDOM_VALUE_OPTIONS.sample
    end

    def random_value
      raise NotImplementedError, 'random_value must be implemented by every child class of Peroxide::Property'
    end

    def validated_value(_)
      raise NotImplementedError, 'validated_value must be implemented by every child class of Peroxide::Property'
    end

    def serialized_value
      raise NotImplementedError, 'serialized_value must be implemented by every child class of Peroxide::Property'
    end

    def error_message
      format(self.class::ERROR_MESSAGE, name:, value:)
    end
  end
end
