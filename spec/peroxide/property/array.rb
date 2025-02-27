# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Array do
  let(:name) { :test_array }
  let(:array) { described_class.new(name) }
  let(:item_property) { Peroxide::Property::String.new(:test) }

  before do
    array.item_property = item_property
  end

  describe '#random_value' do
    context 'when length is not specified' do
      it 'generates an array of random values up to DEFAULT_MAX_LENGTH' do
        result = array.send(:random_value)
        expect(result).to be_an(Array)
        expect(result.length).to be <= described_class::DEFAULT_MAX_LENGTH
      end
    end

    context 'when length is a range' do
      let(:array) { described_class.new(name, length: 2..4) }

      it 'generates an array with length within the specified range' do
        result = array.send(:random_value)
        expect(result).to be_an(Array)
        expect(result.length).to be >= array.length.min
        expect(result.length).to be <= array.length.max
      end
    end

    context 'when length is static' do
      let(:array) { described_class.new(name, length: 3) }

      it 'generates an array with length of that value' do
        result = array.send(:random_value)
        expect(result).to be_an(Array)
        expect(result.length).to eq array.length.min
        expect(result.length).to eq array.length.max
      end
    end
  end

  describe '#serialized_value' do
    let(:value) { [1, 2, 3] }

    before do
      allow(array).to receive(:value).and_return(value)
      allow(item_property).to receive(:serialize).with(1).and_return('1')
      allow(item_property).to receive(:serialize).with(2).and_return('2')
      allow(item_property).to receive(:serialize).with(3).and_return('3')
    end

    it 'serializes each item in the array' do
      expect(array.send(:serialized_value)).to eq(%w[1 2 3])
    end
  end

  describe '#validated_value' do
    context 'when param responds to map' do
      let(:param) { [1, 2, 3] }

      before do
        allow(item_property).to receive(:validate!).with(1).and_return(1)
        allow(item_property).to receive(:validate!).with(2).and_return(2)
        allow(item_property).to receive(:validate!).with(3).and_return(3)
      end

      it 'validates each item in the array' do
        expect(array.send(:validated_value, param)).to eq([1, 2, 3])
      end

      context 'when an item is invalid' do
        before do
          allow(item_property).to receive(:validate!).with(2).and_raise(Peroxide::Property::ValidationError)
        end

        it 'raises ValidationError' do
          expect { array.send(:validated_value, param) }.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end

    context 'when param does not respond to map' do
      let(:param) { 'not an array' }

      it 'raises ValidationError' do
        expect { array.send(:validated_value, param) }.to raise_error(Peroxide::Property::ValidationError)
      end
    end
  end
end
