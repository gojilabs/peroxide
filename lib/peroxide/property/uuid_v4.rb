# frozen_string_literal: true

require_relative '../property'
require 'securerandom'

module Peroxide
  class Property
    class UuidV4 < Peroxide::Property
      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a uuid v4"
      UUID_REGEX = /^[0-9A-Fa-f]{8}-?[0-9A-Fa-f]{4}-?4[0-9A-Fa-f]{3}-?[89ABab][0-9A-Fa-f]{3}-?[0-9A-Fa-f]{12}$/

      def initialize(name, required: false)
        super(name, required:)
      end

      private

      def serialized_value
        value
      end

      def validated_value(param)
        return param if param&.to_s&.match?(UUID_REGEX)

        raise ValidationError
      end

      def random_value
        SecureRandom.uuid_v4
      end
    end
  end
end
