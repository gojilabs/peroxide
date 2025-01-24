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

  describe '#valid?' do
    context 'with true values' do
      described_class::TRUE_VALUES.each do |value|
        it "validates #{value.inspect} as true" do
          allow(boolean).to receive(:value).and_return(value)
          expect(boolean.send(:valid?)).to be true
          expect(boolean.true?).to be true
          expect(boolean.false?).to be false
        end
      end
    end

    context 'with false values' do
      described_class::FALSE_VALUES.each do |value|
        it "validates #{value.inspect} as false" do
          allow(boolean).to receive(:value).and_return(value)
          expect(boolean.send(:valid?)).to be true
          expect(boolean.true?).to be false
          expect(boolean.false?).to be true
        end
      end
    end

    context 'with invalid values' do
      ['invalid', nil, 42, 3.14, [], {}].each do |value|
        it "invalidates #{value.inspect}" do
          allow(boolean).to receive(:value).and_return(value)
          expect(boolean.send(:valid?)).to be false
          expect(boolean.true?).to be false
          expect(boolean.false?).to be false
        end
      end
    end
  end

  describe 'initialization' do
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
