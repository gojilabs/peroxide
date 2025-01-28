# frozen_string_literal: true

require_relative '../property'

module Peroxide
  class Property
    class Boolean < Peroxide::Property
      FALSE_VALUES = [
        false,
        0,
        '0',
        :'0',
        'f',
        :f,
        'F',
        :F,
        'false',
        :false,
        'FALSE',
        :FALSE,
        'off',
        :off,
        'OFF',
        :OFF,
        'no',
        :no,
        'NO',
        :NO,
        'n',
        :n,
        'N',
        :N
      ].freeze

      TRUE_VALUES = [
        true,
        1,
        '1',
        :'1',
        't',
        :t,
        'T',
        :T,
        'true',
        :true,
        'TRUE',
        :TRUE,
        'on',
        :on,
        'ON',
        :ON,
        'yes',
        :yes,
        'YES',
        :YES,
        'y',
        :y,
        'Y',
        :Y
      ].freeze

      ERROR_MESSAGE = "Property '%<name>s' value '%<value>s' is not a valid boolean"
      RANDOM_VALUE_OPTIONS = [true, false].freeze

      private

      def random_value
        RANDOM_VALUE_OPTIONS.sample
      end

      def serialized_value
        true?(value)
      end

      def validated_value(param)
        return param if true?(param) || false?(param)

        raise ValidationError
      end

      def true?(param)
        param.in?(TRUE_VALUES)
      end

      def false?(param)
        param.in?(FALSE_VALUES)
      end
    end
  end
end
