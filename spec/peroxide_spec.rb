# frozen_string_literal: true

require 'spec_helper'

require_relative 'peroxide/property'
require_relative 'peroxide/sanitizer'
require_relative 'peroxide/util'
require_relative 'peroxide/property/array'
require_relative 'peroxide/property/boolean'
require_relative 'peroxide/property/date'
require_relative 'peroxide/property/datetime'
require_relative 'peroxide/property/enum'
require_relative 'peroxide/property/float'
require_relative 'peroxide/property/has_length'
require_relative 'peroxide/property/has_range'
require_relative 'peroxide/property/id'
require_relative 'peroxide/property/integer'
require_relative 'peroxide/property/no_content'
require_relative 'peroxide/property/object'
require_relative 'peroxide/property/string'
require_relative 'peroxide/property/uuid_v4'

RSpec.describe Peroxide do
  it 'has a version number' do
    expect(Peroxide::VERSION).not_to be nil
  end
end
