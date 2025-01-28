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
            (range.to_i..range.to_i)
          end
      rescue StandardError
        raise InvalidRangeError
      end

      def range?
        defined?(@range) && range
      end

      def check_range(param)
        return true unless range?

        range.include?(param)
      end

      def random_value
        return range.to_a.sample if range?

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
