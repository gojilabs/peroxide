# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::HasLength do
  let(:test_class) do
    Class.new do
      include Peroxide::Property::HasLength

      def value_for_length_check
        'test'
      end
    end
  end

  let(:instance) { test_class.new }

  describe '#length=' do
    context 'when length is nil' do
      it 'does not set length' do
        instance.length = nil
        expect(instance.length).to be_nil
      end
    end

    context 'when length is less than 1' do
      it 'raises LengthIsTooShortError' do
        expect { instance.length = 0 }.to raise_error(described_class::LengthIsTooShortError)
      end
    end

    context 'when length is a Range' do
      let(:length_range) { 1..5 }

      it 'sets length to the range' do
        instance.length = length_range
        expect(instance.length).to eq(length_range)
      end
    end

    context 'when length is an Integer' do
      it 'sets length to a range with same start and end' do
        instance.length = 3
        expect(instance.length).to eq(3..3)
      end
    end

    context 'when length is invalid' do
      it 'raises Invalid error' do
        expect { instance.length = 'invalid' }.to raise_error(Peroxide::Property::Invalid)
      end
    end
  end

  describe '#length?' do
    context 'when length is set' do
      before { instance.length = 3 }

      it 'returns true' do
        expect(instance.length?).to be true
      end
    end

    context 'when length is not set' do
      it 'returns false' do
        expect(instance.length?).to be false
      end
    end
  end

  describe '#check_length' do
    context 'when length is not set' do
      it 'returns true' do
        expect(instance.check_length).to be true
      end
    end

    context 'when length is set' do
      before { instance.length = 4 }

      it 'returns true when value length matches' do
        allow(instance).to receive(:value_for_length_check).and_return('test')
        expect(instance.check_length).to be true
      end

      it 'returns false when value length does not match' do
        allow(instance).to receive(:value_for_length_check).and_return('testing')
        expect(instance.check_length).to be false
      end
    end

    context 'when length is a range' do
      before { instance.length = 2..4 }

      it 'returns true when value length is within range' do
        allow(instance).to receive(:value_for_length_check).and_return('abc')
        expect(instance.check_length).to be true
      end

      it 'returns false when value length is outside range' do
        allow(instance).to receive(:value_for_length_check).and_return('abcde')
        expect(instance.check_length).to be false
      end
    end
  end
end
