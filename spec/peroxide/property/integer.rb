# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Integer do
  let(:name) { :test_integer }
  let(:integer) { described_class.new(name) }

  describe '#random_value' do
    context 'when range is not specified' do
      it 'generates a random integer' do
        result = integer.send(:random_value)
        expect(result).to be_a(Integer)
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

  describe '#valid?' do
    context 'with valid integer values' do
      [42, '42', -10, '-10'].each do |valid_value|
        it "validates #{valid_value.inspect}" do
          allow(integer).to receive(:value).and_return(valid_value)
          expect(integer.send(:valid?)).to be true
        end
      end
    end

    context 'with invalid integer values' do
      ['invalid', '42.5', nil, [], {}, 3.14].each do |invalid_value|
        it "invalidates #{invalid_value.inspect}" do
          allow(integer).to receive(:value).and_return(invalid_value)
          expect(integer.send(:valid?)).to be false
        end
      end
    end

    context 'with range constraint' do
      let(:integer) { described_class.new(name, range: 1..100) }

      it 'validates integers within range' do
        allow(integer).to receive(:value).and_return(50)
        expect(integer.send(:valid?)).to be true
      end

      it 'invalidates integers outside range' do
        allow(integer).to receive(:value).and_return(101)
        expect(integer.send(:valid?)).to be false
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
