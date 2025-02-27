# frozen_string_literal: true

module Peroxide
  class Property
    module HasRange
      class InvalidRangeError < Error; end

      attr_reader :range

      def range=(range_val)
        return if range_val.nil?

        @range =
          if range_val.is_a?(Range)
            range_val
          else
            val = validated_value(range_val)
            (val..val)
          end
      rescue StandardError
        raise InvalidRangeError
      end

      def range_min
        @range_min ||= range&.min
      end

      def range_max
        @range_max ||= range&.max
      end

      def random_value
        if range_min.nil? && range_max.nil?
          super
        elsif range_min.nil?
          rand(range_max)
        else
          rand(range)
        end
      end

      def validated_value(param)
        validated_param = super(param)
        within_range = (range_min.nil? || range_min < validated_param) && (range_max.nil? || range_max > validated_param)

        raise ValidationError unless within_range

        validated_param
      end
    end
  end
end
