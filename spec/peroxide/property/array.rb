# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Array do
  let(:name) { :test_array }
  let(:array) { described_class.new(name) }
  let(:child) { double('child_property') }

  before do
    array.child = child
  end

  describe '#random_value' do
    context 'when length is not specified' do
      before do
        allow(child).to receive(:random_value).and_return('test')
      end

      it 'generates an array of random length with child values' do
        result = array.send(:random_value)
        expect(result).to be_an(Array)
        expect(result.all? { |item| item == 'test' }).to be true
      end
    end

    context 'when length is specified' do
      let(:array) { described_class.new(name, length: 3) }

      before do
        allow(child).to receive(:random_value).and_return('test')
      end

      it 'generates an array of specified length with child values' do
        result = array.send(:random_value)
        expect(result).to be_an(Array)
        expect(result.length).to eq(3)
        expect(result.all? { |item| item == 'test' }).to be true
      end
    end
  end

  describe '#valid?' do
    before do
      allow(array).to receive(:value).and_return(value)
      allow(array).to receive(:check_length).and_return(true)
    end

    context 'when value is an array and all items are valid' do
      let(:value) { [1, 2, 3] }

      before do
        allow(child).to receive(:validate!).and_return(true)
      end

      it 'returns true' do
        expect(array.send(:valid?)).to be true
      end
    end

    context 'when value is not an array' do
      let(:value) { 'not an array' }

      it 'returns false' do
        expect(array.send(:valid?)).to be false
      end
    end

    context 'when length check fails' do
      let(:value) { [1, 2, 3] }

      before do
        allow(array).to receive(:check_length).and_return(false)
      end

      it 'returns false' do
        expect(array.send(:valid?)).to be false
      end
    end

    context 'when child validation fails' do
      let(:value) { [1, 2, 3] }

      before do
        allow(child).to receive(:validate!).and_return(false)
      end

      it 'returns false' do
        expect(array.send(:valid?)).to be false
      end
    end
  end

  describe '#value_for_length_check' do
    let(:test_value) { [1, 2, 3] }

    before do
      allow(array).to receive(:value).and_return(test_value)
    end

    it 'returns the value' do
      expect(array.send(:value_for_length_check)).to eq(test_value)
    end
  end
end
