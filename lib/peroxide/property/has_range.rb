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

      def random_value
        return rand(range) if range?

        super
      end

      def validated_value(param)
        validated_param = super(param)
        return validated_param if check_range(validated_param)

        raise ValidationError
      end
    end
  end
end
