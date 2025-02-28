# frozen_string_literal: true

module Peroxide
  class Property
    module HasLength
      class InvalidLengthError < ValidationError; end
      DEFAULT_MAX_LENGTH = 10_000

      attr_reader :length

      def length=(length_val)
        return if length_val.nil?

        val =
          if length_val.is_a?(Range)
            length_val
          elsif length_val.to_i == length_val
            (length_val..length_val)
          else
            raise InvalidLengthError
          end

        raise InvalidLengthError if val.min.negative? || val.max.negative? || val.min > val.max

        @length = val
      rescue StandardError
        raise InvalidLengthError
      end

      def length_min
        length&.min || ::Integer::MIN_UINT
      end

      def length_max
        length&.max || DEFAULT_MAX_LENGTH
      end

      def random_value
        random_length = rand(length_min..length_max)

        super[0...random_length]
      end

      def validated_value(param)
        validated_param = super(param)
        vp_length = validated_param&.length || 0

        raise InvalidLengthError unless length_min <= vp_length && length_max >= vp_length

        validated_param
      end
    end
  end
end
