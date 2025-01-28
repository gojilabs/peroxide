# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Boolean do
  let(:name) { :test_boolean }
  let(:boolean) { described_class.new(name) }

  describe '#random_value' do
    it 'returns either true or false' do
      expect(described_class::RANDOM_VALUE_OPTIONS).to include(boolean.send(:random_value))
    end
  end

  describe '#serialized_value' do
    context 'with true values' do
      described_class::TRUE_VALUES.each do |value|
        it "serializes #{value.inspect} as true" do
          allow(boolean).to receive(:value).and_return(value)
          expect(boolean.send(:serialized_value)).to be true
        end
      end
    end

    context 'with false values' do
      described_class::FALSE_VALUES.each do |value|
        it "serializes #{value.inspect} as false" do
          allow(boolean).to receive(:value).and_return(value)
          expect(boolean.send(:serialized_value)).to be false
        end
      end
    end
  end

  describe '#validated_value' do
    context 'with true values' do
      described_class::TRUE_VALUES.each do |value|
        it "validates #{value.inspect}" do
          expect(boolean.send(:validated_value, value)).to eq(value)
        end
      end
    end

    context 'with false values' do
      described_class::FALSE_VALUES.each do |value|
        it "validates #{value.inspect}" do
          expect(boolean.send(:validated_value, value)).to eq(value)
        end
      end
    end

    context 'with invalid values' do
      ['invalid', nil, 42, 3.14, [], {}].each do |value|
        it "raises ValidationError for #{value.inspect}" do
          expect { boolean.send(:validated_value, value) }.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end
  end

  describe '#initialize' do
    context 'when required is true' do
      let(:boolean) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(boolean.required?).to be true
      end
    end

    context 'when required is false' do
      let(:boolean) { described_class.new(name, required: false) }

      it 'sets required to false' do
        expect(boolean.required?).to be false
      end
    end
  end
end
