# frozen_string_literal: true

module Peroxide
  class Property
    module HasRange
      class InvalidRangeError < Error; end

      def range
        @range
      end

      def range=(range)
        return if range.nil?

        @range =
          if range.is_a?(Range)
            range
          else
            val = validated_value(range)
            (val..val)
          end
      rescue StandardError
        raise InvalidRangeError
      end

      def range?
        !!defined?(@range)
      end

      def check_range(param)
        !range? || range.include?(param)
      end

      def range_min
        range.min
      rescue StandardError
        nil
      end

      def range_max
        range.max
      rescue StandardError
        nil
      end

      def random_value
        return rand(range) if range_min && range_max

        val = super until check_range(val)

        val
      end

      def validated_value(param)
        validated_param = super(param)
        return validated_param if check_range(validated_param)

        raise ValidationError
      end
    end
  end
end
