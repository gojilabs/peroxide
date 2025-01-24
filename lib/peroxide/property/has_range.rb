# frozen_string_literal: true

module Peroxide
  class Property
    module HasRange
      class MaximumValueIsTooLongError < Error; end
      class MaximumValueIsTooShortError < Error; end
      class MinimumValueIsTooLongError < Error; end
      class MinimumValueIsTooShortError < Error; end

      def self.included(base)
        base.class_eval do
          attr_reader :range

          def range=(range)
            raise Invalid, "Invalid range: #{range}" unless range.is_a?(Range)

            @range = range
          end

          def range?
            defined?(@range) && @range.present?
          end

          def range_max_length
            range? ? @range.max.to_s.length : 0
          end

          def range_min_length
            range? ? @range.min.to_s.length : 0
          end

          def check_range
            !range? || @range.include?(value_for_range_check)
          end

          def random_value_from_range
            return nil unless range?

            @range.to_a.sample
          end
        end
      end
    end
  end
end
