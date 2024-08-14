# frozen_string_literal: true

module Peroxide
  class Property
    module HasRange
      def self.included(base)
        base.class_eval do
          def range=(range)
            raise Invalid, "Invalid range: #{range}" unless range.is_a?(Range)

            @range = range
          end

          def check_range
            !defined?(@range) || @range.include?(value)
          end
        end
      end
    end
  end
end
