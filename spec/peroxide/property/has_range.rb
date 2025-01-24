# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::HasRange do
  let(:test_class) do
    Class.new do
      include Peroxide::Property::HasRange

      def value_for_range_check
        42
      end
    end
  end

  let(:instance) { test_class.new }

  describe '#range=' do
    context 'with valid range' do
      let(:valid_range) { 1..100 }

      it 'sets the range' do
        instance.range = valid_range
        expect(instance.range).to eq(valid_range)
      end
    end

    context 'with invalid range' do
      it 'raises Invalid error' do
        expect { instance.range = 'invalid' }.to raise_error(Peroxide::Property::Invalid)
      end
    end
  end

  describe '#range?' do
    context 'when range is set' do
      before { instance.range = 1..10 }

      it 'returns true' do
        expect(instance.range?).to be true
      end
    end

    context 'when range is not set' do
      it 'returns false' do
        expect(instance.range?).to be false
      end
    end
  end

  describe '#range_max_length' do
    context 'when range is set' do
      before { instance.range = 1..1000 }

      it 'returns length of maximum value as string' do
        expect(instance.range_max_length).to eq(4)
      end
    end

    context 'when range is not set' do
      it 'returns 0' do
        expect(instance.range_max_length).to eq(0)
      end
    end
  end

  describe '#range_min_length' do
    context 'when range is set' do
      before { instance.range = 100..1000 }

      it 'returns length of minimum value as string' do
        expect(instance.range_min_length).to eq(3)
      end
    end

    context 'when range is not set' do
      it 'returns 0' do
        expect(instance.range_min_length).to eq(0)
      end
    end
  end

  describe '#check_range' do
    context 'when range is not set' do
      it 'returns true' do
        expect(instance.check_range).to be true
      end
    end

    context 'when range is set' do
      context 'when value is within range' do
        before { instance.range = 1..100 }

        it 'returns true' do
          expect(instance.check_range).to be true
        end
      end

      context 'when value is outside range' do
        before { instance.range = 1..10 }

        it 'returns false' do
          expect(instance.check_range).to be false
        end
      end
    end
  end

  describe '#random_value_from_range' do
    context 'when range is not set' do
      it 'returns nil' do
        expect(instance.random_value_from_range).to be_nil
      end
    end

    context 'when range is set' do
      before { instance.range = 1..10 }

      it 'returns a random value from the range' do
        result = instance.random_value_from_range
        expect(result).to be_between(1, 10)
      end
    end
  end
end
