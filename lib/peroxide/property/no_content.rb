# frozen_string_literal: true

require_relative '../property'

module Peroxide
  class Property
    class NoContent < Peroxide::Property
      ERROR_MESSAGE = 'Response body must be empty'

      def initialize
        super('_no_content', required: false)
      end

      private

      def random_value
        nil
      end

      def valid?
        value.nil?
      end
    end
  end
end
