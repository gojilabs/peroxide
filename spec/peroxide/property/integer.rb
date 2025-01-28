# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Integer do
  let(:name) { :test_integer }
  let(:integer) { described_class.new(name) }

  describe '#serialized_value' do
    let(:value) { 42 }

    before do
      allow(integer).to receive(:value).and_return(value)
    end

    it 'converts value to integer' do
      expect(integer.send(:serialized_value)).to eq(42)
    end
  end

  describe '#random_value' do
    context 'when range is not specified' do
      it 'generates a random integer within DEFAULT_RANDOM_RANGE' do
        result = integer.send(:random_value)
        expect(result).to be_a(Integer)
        expect(result).to be_between(-1000, 1000)
      end
    end

    context 'when range is specified' do
      let(:integer) { described_class.new(name, range: 1..10) }

      it 'generates an integer within the specified range' do
        result = integer.send(:random_value)
        expect(result).to be_between(1, 10)
      end
    end
  end

  describe '#validated_value' do
    context 'with valid integer values' do
      [42, '42', -10, '-10', 0, '0'].each do |valid_value|
        it "validates #{valid_value.inspect}" do
          expect(integer.send(:validated_value, valid_value)).to eq(valid_value)
        end
      end
    end

    context 'with invalid integer values' do
      ['invalid', '42.5', nil, [], {}, 3.14].each do |invalid_value|
        it "raises ValidationError for #{invalid_value.inspect}" do
          expect { integer.send(:validated_value, invalid_value) }.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end

    context 'with range constraint' do
      let(:integer) { described_class.new(name, range: 1..100) }

      it 'validates integers within range' do
        expect(integer.send(:validated_value, 50)).to eq(50)
      end

      it 'raises ValidationError for integers outside range' do
        expect { integer.send(:validated_value, 101) }.to raise_error(Peroxide::Property::ValidationError)
      end
    end
  end

  describe 'initialization' do
    context 'when required is true' do
      let(:integer) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(integer.required?).to be true
      end
    end

    context 'when required is false' do
      let(:integer) { described_class.new(name, required: false) }

      it 'sets required to false' do
        expect(integer.required?).to be false
      end
    end
  end
end
