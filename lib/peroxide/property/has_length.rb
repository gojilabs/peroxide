# frozen_string_literal: true

module Peroxide
  class Property
    module HasLength
      class InvalidLengthError < ValidationError; end

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
        @length_min ||= length&.min
      end

      def length_max
        @length_max ||= length&.max
      end

      def random_value
        random_length = random_value_length
        return super if random_length.nil?

        super[0..random_length]
      end

      def random_value_length
        if length_min.nil? && length_max.nil?
          nil
        elsif length_max.nil?
          length_min + rand(100)
        else
          rand(length)
        end
      end

      def validated_value(param)
        validated_param = super(param)
        vp_length = validated_param&.length || 0

        valid = (length_min.nil? || length_min <= vp_length) && (length_max.nil? || length_max >= vp_length)

        raise InvalidLengthError unless valid

        validated_param
      end
    end
  end
end
