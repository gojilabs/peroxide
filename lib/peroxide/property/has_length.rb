# frozen_string_literal: true

module Peroxide
  class Property
    module HasLength
      class LengthIsTooShortError < Error; end

      def self.included(base)
        base.class_eval do
          attr_reader :length

          def length=(length)
            return if length.nil?
            raise LengthIsTooShortError if length < 1

            @length =
              if length.is_a?(Range)
                length
              elsif length.is_a?(Integer)
                length..length
              else
                raise Invalid, "Invalid length: #{length}"
              end
          end

          def length?
            defined?(@length) && @length.present?
          end

          def check_length
            !length? || @length.include?(value_for_length_check.length)
          end
        end
      end
    end
  end
end
