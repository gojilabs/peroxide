# frozen_string_literal: true

require 'active_support/core_ext/string'

module Peroxide
  class Error < StandardError; end
  # Your code goes here...
end

require_relative 'peroxide/property'
require_relative 'peroxide/sanitizer'
require_relative 'peroxide/version'
