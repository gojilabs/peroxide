# frozen_string_literal: true

module Peroxide
  module Property
    module HasRange
      def self.included(base)
        base.class_eval do
          def range=(range)
            raise Peroxide::InvalidPropertyError, "Invalid range: #{range}" unless range.is_a?(Range)

            @min = range.min
            @max = range.max
          end

          def check_range
            (!defined?(@min) && !defined?(@max)) ||
              (@min <= value && value <= @max)
          end
        end
      end
    end
  end
end
