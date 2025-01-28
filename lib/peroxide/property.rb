# frozen_string_literal: true

module Peroxide
  class Property
    class Error < Peroxide::Error; end
    class ConfigurationError < Error; end
    class ValidationError < Error; end

    def self.sanitize!(properties, params)
      {}.tap do |sanitized_params|
        properties.each do |property|
          param = params[property.name]
          property.validate!(param)
          sanitized_params[property.name] = param
        end
      end
    end

    attr_reader :name, :value, :required

    def initialize(name, required: false)
      raise ConfigurationError, 'Property name is required' unless name.to_s&.length&.positive?

      @name = name
      @required = required

      puts "Property '#{name}' initialized, required: #{required}"
    end

    def required?
      @required
    end

    def placeholder
      return nil unless required? || Property::Boolean::RANDOM_VALUE_OPTIONS.sample

      random_value
    end

    def validate!(param)
      @value = param
      return @value if !required && !value || valid?

      raise ValidationError, error_message
    end

    private

    def random_value
      raise NotImplementedError, 'random_value must be implemented by every child class of Peroxide::Property'
    end

    def valid?
      raise NotImplementedError, 'valid? must be implemented by every child class of Peroxide::Property'
    end

    def value_for_length_check
      @value
    end

    def error_message
      format(self.class::ERROR_MESSAGE, name:, value:)
    end
  end
end
