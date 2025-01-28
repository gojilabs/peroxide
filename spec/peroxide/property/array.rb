# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Array do
  let(:name) { :test_array }
  let(:array) { described_class.new(name) }
  let(:item_property) { double('item_property') }

  before do
    array.item_property = item_property
  end

  describe '#random_value' do
    before do
      allow(item_property).to receive(:random_value).and_return('test')
    end

    context 'when length is not specified' do
      it 'generates an array of random values up to DEFAULT_MAX_LENGTH' do
        result = array.send(:random_value)
        expect(result).to be_an(Array)
        expect(result.length).to be <= described_class::DEFAULT_MAX_LENGTH
        expect(result.all? { |item| item == 'test' }).to be true
      end
    end

    context 'when length is specified' do
      let(:array) { described_class.new(name, length: 3) }

      it 'generates an array with length within the specified range' do
        result = array.send(:random_value)
        expect(result).to be_an(Array)
        expect(result.length).to be <= 3
        expect(result.all? { |item| item == 'test' }).to be true
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
      expect(array.send(:serialized_value)).to eq(['1', '2', '3'])
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
