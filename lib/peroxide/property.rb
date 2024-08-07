module Peroxide
  class Property
    class Error < StandardError; end
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
      raise ConfigurationError, 'Property name is required' if name.blank?

      @name = name
      @required = required
    end

    def supports_multiple_children?
      false
    end

    def supports_single_child?
      false
    end

    def required?
      @required
    end

    def validate!(param)
      @value = param
      raise ValidationError, error_message unless (!required? && value.blank?) || valid?

      @value
    end

    private

    def error_message
      format(ERROR_MESSAGE, name:, value:)
    end
  end
end
