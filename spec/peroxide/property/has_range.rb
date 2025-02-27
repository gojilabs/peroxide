# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::HasRange do
  let(:test_class) do
    Class.new do
      def initialize(name)
        @name = name
      end

      def random_value
        42
      end

      def validated_value(param)
        param
      end

      prepend Peroxide::Property::HasRange
    end
  end

  let(:name) { :test_property }
  let(:instance) { test_class.new(name) }

  describe '#range=' do
    context 'with valid range' do
      it 'sets integer range as range' do
        instance.range = 5
        expect(instance.range).to eq(5..5)
      end

      it 'sets range directly' do
        instance.range = 5..10
        expect(instance.range).to eq(5..10)
      end
    end
  end

  describe '#random_value' do
    context 'when range is not set' do
      it 'calls super' do
        expect(instance.random_value).to eq(42)
      end
    end

    context 'when range is set' do
      before { instance.range = 1..10 }

      it 'returns a random value from the range' do
        result = instance.random_value
        expect(result).to be_between(1, 10)
      end
    end
  end

  describe '#validated_value' do
    context 'when range is not set' do
      it 'returns validated param' do
        expect(instance.validated_value(5)).to eq(5)
      end
    end

    context 'when range is set' do
      before { instance.range = 1..10 }

      it 'returns validated param if within range' do
        expect(instance.validated_value(5)).to eq(5)
      end

      it 'raises ValidationError if outside range' do
        expect { instance.validated_value(11) }.to raise_error(Peroxide::Property::ValidationError)
      end
    end
  end
end
