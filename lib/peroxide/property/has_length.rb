# frozen_string_literal: true

module Peroxide
  module Property
    module HasLength
      def self.included(base)
        base.class_eval do
          def length=(value)
            if value.is_a?(Range)
              @min_length = value.min
              @max_length = value.max
            elsif value.is_a?(Integer)
              @min_length = value
              @max_length = value
            else
              raise Peroxide::InvalidPropertyError, "Invalid length: #{value}"
            end
          end

          def check_length
            (!defined?(@min_length) && !defined?(@max_length)) ||
              (@min_length <= value && value <= @max_length)
          end
        end
      end
    end
  end
end
