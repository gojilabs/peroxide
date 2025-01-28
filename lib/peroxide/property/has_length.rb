# frozen_string_literal: true

module Peroxide
  class Property
    module HasLength
      class LengthIsTooShortError < Error; end

      def length
        @length
      end

      def length=(length)
        return if length.nil?

        @length =
          if length.is_a?(Range)
            length
          else
            (length.to_i..length.to_i)
          end

        raise LengthIsTooShortError if @length.min < 1
      end

      def length?
        defined?(@length)
      end

      def check_length
        !length? || @length.include?(value.length)
      end

      def valid?
        super && check_length
      end
    end
  end
end
