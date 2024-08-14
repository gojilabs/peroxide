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

      def initialize(name, required: false)
        super(name, required:)
      end

      def true?
        value.in?(TRUE_VALUES)
      end

      def false?
        value.in?(FALSE_VALUES)
      end

      private

      def valid?
        true? || false?
      end
    end
  end
end
