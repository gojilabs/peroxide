# frozen_string_literal: true

module Peroxide
  class Property
    module HasLength
      class InvalidLengthError < ValidationError; end

      def length
        @length
      end

      def length=(length)
        return if length.nil?

        potential_length =
          if length.is_a?(Range)
            length
          else
            (length..length)
          end

        raise InvalidLengthError if potential_length.min.negative?

        @length = potential_length
      rescue StandardError
        raise InvalidLengthError
      end

      def length?
        !!defined?(@length)
      end

      def check_length(param)
        !length? || length.include?(param.length)
      end

      def random_value
        raw_value = super

        return raw_value unless length?

        raw_value[0...length.max]
      end

      def validated_value(param)
        validated_param = super(param)
        return validated_param if check_length(validated_param)

        raise InvalidLengthError
      end
    end
  end
end
