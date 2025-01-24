# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Enum do
  values = %w[red green blue]
  let(:name) { :test_enum }
  let(:enum) { described_class.new(name, values) }

  describe '#valid?' do
    context 'with valid enum value' do
      values.each do |valid_value|
        it "validates #{valid_value.inspect}" do
          allow(enum).to receive(:value).and_return(valid_value)
          expect(enum.send(:valid?)).to be true
        end
      end
    end

    context 'with invalid enum value' do
      ['invalid', 'yellow', nil, 42, [], {}].each do |invalid_value|
        it "invalidates #{invalid_value.inspect}" do
          allow(enum).to receive(:value).and_return(invalid_value)
          expect(enum.send(:valid?)).to be false
        end
      end
    end
  end

  describe '#random_value' do
    it 'returns a random value from the enum values list' do
      result = enum.send(:random_value)
      expect(values).to include(result)
    end
  end

  describe '#error_message' do
    it 'formats error message with name, value and values list' do
      invalid_value = 'invalid'
      allow(enum).to receive(:value).and_return(invalid_value)
      allow(enum).to receive(:name).and_return(name)

      expected_message = "Property 'test_enum' value 'invalid' is not in the enum values list '[\"red\", \"green\", \"blue\"]'"
      expect(enum.send(:error_message)).to eq(expected_message)
    end
  end

  describe 'initialization' do
    context 'when required is true' do
      let(:enum) { described_class.new(name, values, required: true) }

      it 'sets required to true' do
        expect(enum.required?).to be true
      end
    end

    context 'when required is false' do
      let(:enum) { described_class.new(name, values, required: false) }

      it 'sets required to false' do
        expect(enum.required?).to be false
      end
    end
  end
end
