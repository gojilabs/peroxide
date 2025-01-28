# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Float do
  let(:name) { :test_float }
  let(:float) { described_class.new(name) }

  describe '#random_value' do
    context 'when range is not specified' do
      it 'generates a random float' do
        result = float.send(:random_value)
        expect(result).to be_a(Float)
      end
    end

    context 'when range is specified' do
      let(:float) { described_class.new(name, range: 1.0..10.0) }

      it 'generates a float within the specified range' do
        result = float.send(:random_value)
        expect(result).to be_between(1.0, 10.0)
      end
    end
  end

  describe '#valid?' do
    context 'with valid float values' do
      [42.5, '42.5', -10.3, '-10.3', 0.0, '0.0'].each do |valid_value|
        it "validates #{valid_value.inspect}" do
          allow(float).to receive(:value).and_return(valid_value)
          expect(float.send(:valid?)).to be true
        end
      end
    end

    context 'with invalid float values' do
      ['invalid', nil, [], {}, 'abc'].each do |invalid_value|
        it "invalidates #{invalid_value.inspect}" do
          allow(float).to receive(:value).and_return(invalid_value)
          expect(float.send(:valid?)).to be false
        end
      end
    end

    context 'with range constraint' do
      let(:float) { described_class.new(name, range: 1.0..100.0) }

      it 'validates floats within range' do
        allow(float).to receive(:value).and_return(50.5)
        expect(float.send(:valid?)).to be true
      end

      it 'invalidates floats outside range' do
        allow(float).to receive(:value).and_return(100.5)
        expect(float.send(:valid?)).to be false
      end
    end
  end

  describe 'initialization' do
    context 'when required is true' do
      let(:float) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(float.required?).to be true
      end
    end

    context 'when required is false' do
      let(:float) { described_class.new(name, required: false) }

      it 'sets required to false' do
        expect(float.required?).to be false
      end
    end
  end
end
