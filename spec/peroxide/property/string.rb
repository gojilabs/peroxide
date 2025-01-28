# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::String do
  let(:name) { :test_string }
  let(:string) { described_class.new(name) }

  describe '#serialized_value' do
    let(:value) { 'test' }

    before do
      allow(string).to receive(:value).and_return(value)
    end

    it 'converts value to string' do
      expect(string.send(:serialized_value)).to eq('test')
    end
  end

  describe '#random_value' do
    it 'generates a random hex string' do
      result = string.send(:random_value)
      expect(result).to be_a(String)
      expect(result.length).to be <= Peroxide::Property::String::DEFAULT_MAX_LENGTH * 2
    end
  end

  describe '#validated_value' do
    context 'with valid string values' do
      ['test', '', '123'].each do |valid_value|
        it "validates #{valid_value.inspect}" do
          expect(string.send(:validated_value, valid_value)).to eq(valid_value)
        end
      end
    end

    context 'with invalid string values' do
      [42, 3.14, true, [], {}, nil].each do |invalid_value|
        it "raises ValidationError for #{invalid_value.inspect}" do
          expect { string.send(:validated_value, invalid_value) }
            .to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end

    context 'with length constraint' do
      let(:string) { described_class.new(name, length: 1..5) }

      it 'validates strings within length range' do
        expect(string.send(:validated_value, 'test')).to eq('test')
      end

      it 'raises InvalidLengthError for strings outside length range' do
        expect { string.send(:validated_value, 'too long') }
          .to raise_error(Peroxide::Property::HasLength::InvalidLengthError)
      end
    end
  end

  describe 'initialization' do
    context 'when required is true' do
      let(:string) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(string.required?).to be true
      end
    end

    context 'when required is false' do
      let(:string) { described_class.new(name, required: false) }

      it 'sets required to false' do
        expect(string.required?).to be false
      end
    end

    context 'with length specified' do
      let(:string) { described_class.new(name, length: 5) }

      it 'sets the length' do
        expect(string.length).to eq(5..5)
      end
    end
  end
end
