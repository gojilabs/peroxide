# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::HasLength do
  let(:test_class) do
    Class.new do
      def initialize(name)
        @name = name
      end

      def random_value
        'test_string'
      end

      def validated_value(param)
        param
      end

      prepend Peroxide::Property::HasLength
    end
  end

  let(:name) { :test_property }
  let(:instance) { test_class.new(name) }

  describe '#length=' do
    context 'with valid length' do
      it 'sets integer length as range' do
        instance.length = 5
        expect(instance.length).to eq(5..5)
      end

      it 'sets range length directly' do
        instance.length = 0..10
        expect(instance.length).to eq(0..10)
      end
    end

    context 'with invalid length' do
      it 'raises InvalidLengthError for non-numeric input' do
        expect { instance.length = 'invalid' }.to raise_error(Peroxide::Property::HasLength::InvalidLengthError)
      end

      it 'raises InvalidLengthError for negative length' do
        expect { instance.length = -1 }.to raise_error(Peroxide::Property::HasLength::InvalidLengthError)
      end

      it 'raises InvalidLengthError for range with negative minimum' do
        expect { instance.length = -1..5 }.to raise_error(Peroxide::Property::HasLength::InvalidLengthError)
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
        expect(instance.check_length('any string')).to be true
      end
    end

    context 'when length is set' do
      context 'with exact length' do
        before { instance.length = 4 }

        it 'returns true for matching length' do
          expect(instance.check_length('test')).to be true
        end

        it 'returns false for non-matching length' do
          expect(instance.check_length('wrong')).to be false
        end
      end

      context 'with length range' do
        before { instance.length = 2..6 }

        it 'returns true for minimum length' do
          expect(instance.check_length('ab')).to be true
        end

        it 'returns true for maximum length' do
          expect(instance.check_length('abcdef')).to be true
        end

        it 'returns false for too short' do
          expect(instance.check_length('a')).to be false
        end

        it 'returns false for too long' do
          expect(instance.check_length('abcdefg')).to be false
        end
      end
    end
  end

  describe '#random_value' do
    context 'when length is not set' do
      it 'returns super value unchanged' do
        expect(instance.random_value).to eq('test_string')
      end
    end

    context 'when length is set' do
      before { instance.length = 5 }

      it 'truncates value to maximum length' do
        expect(instance.random_value.length).to eq(5)
      end

      it 'preserves original string up to length' do
        expect(instance.random_value).to eq('test_')
      end
    end
  end

  describe '#validated_value' do
    context 'when length is not set' do
      it 'returns the validated param unchanged' do
        expect(instance.validated_value('test')).to eq('test')
      end
    end

    context 'when length is set' do
      before { instance.length = 4 }

      it 'returns param when length matches' do
        expect(instance.validated_value('test')).to eq('test')
      end

      it 'raises InvalidLengthError when length does not match' do
        expect { instance.validated_value('wrong') }.to raise_error(Peroxide::Property::HasLength::InvalidLengthError)
      end
    end
  end
end
