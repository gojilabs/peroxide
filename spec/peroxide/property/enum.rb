# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Enum do
  let(:values) { %w[red green blue] }
  let(:name) { :test_enum }
  let(:enum) { described_class.new(name, values) }

  describe '#serialized_value' do
    it 'converts value to string' do
      allow(enum).to receive(:value).and_return(:red)
      expect(enum.send(:serialized_value)).to eq('red')
    end
  end

  describe '#random_value' do
    it 'returns a random value from the enum values list' do
      result = enum.send(:random_value)
      expect(values).to include(result)
    end
  end

  describe '#validated_value' do
    context 'with valid enum value' do
      %w[red green blue].each do |valid_value|
        it "validates #{valid_value.inspect}" do
          expect(enum.send(:validated_value, valid_value)).to eq(valid_value)
        end
      end
    end

    context 'with invalid enum value' do
      ['invalid', 'yellow', nil, 42, [], {}].each do |invalid_value|
        it "raises ValidationError for #{invalid_value.inspect}" do
          expect { enum.send(:validated_value, invalid_value) }.to raise_error(Peroxide::Property::ValidationError)
        end
      end
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
