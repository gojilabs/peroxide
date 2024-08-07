# frozen_string_literal: true

require_relative 'peroxide/version'

module Peroxide
  class Error < StandardError; end
  class SanitizationFailed < Error; end
  class ValidationFailed < Error; end
  class InvalidPropertyValue < Error; end
  # Your code goes here...
end
