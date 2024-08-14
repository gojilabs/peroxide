# frozen_string_literal: true

module Peroxide
  class Property
    module HasLength
      def self.included(base)
        base.class_eval do
          def length=(length)
            if length.is_a?(Range)
              @length = length
            elsif length.is_a?(Integer)
              @length = length..length
            else
              raise Invalid, "Invalid length: #{length}"
            end
          end

          def check_length
            !defined?(@length) || @length.include?(value.length)
          end
        end
      end
    end
  end
end
