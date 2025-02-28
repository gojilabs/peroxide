# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Float do
  let(:name) { :test_float }
  let(:float) { described_class.new(name) }

  describe '#serialized_value' do
    let(:value) { 42.5 }

    before do
      allow(float).to receive(:value).and_return(value)
    end

    it 'converts value to float' do
      expect(float.send(:serialized_value)).to eq(42.5)
    end
  end

  describe '#random_value' do
    context 'when range is not specified' do
      it 'generates a random float within DEFAULT_RANDOM_RANGE' do
        result = float.send(:random_value)
        expect(result).to be_a(Float)
        expect(result).to be_between(::Float::MIN, ::Float::MAX)
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

  describe '#validated_value' do
    context 'with valid float values' do
      [42.5, -10.3, 0.0, 13.13E6].each do |valid_value|
        it "validates #{valid_value.inspect}" do
          expect(float.send(:validated_value, valid_value)).to eq(valid_value)
        end
      end
    end

    context 'with invalid float values' do
      ['invalid', nil, [], {}, Date.today, '34', 'abc'].each do |invalid_value|
        it "raises ValidationError for #{invalid_value.inspect}" do
          expect { float.send(:validated_value, invalid_value) }.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end

    context 'with range constraint' do
      let(:float) { described_class.new(name, range: 1.0..100.0) }

      it 'validates floats within range' do
        expect(float.send(:validated_value, 50.5)).to eq(50.5)
      end

      it 'raises ValidationError for floats outside range' do
        expect { float.send(:validated_value, 100.5) }.to raise_error(Peroxide::Property::ValidationError)
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
