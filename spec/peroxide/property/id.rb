# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Id do
  let(:name) { :test_id }
  let(:id) { described_class.new(name) }

  describe '#serialized_value' do
    let(:value) { 123 }

    before do
      allow(id).to receive(:value).and_return(value)
    end

    it 'returns the value as integer' do
      expect(id.send(:serialized_value)).to eq(123)
    end
  end

  describe '#random_value' do
    it 'generates a random integer within DEFAULT_RANDOM_RANGE' do
      result = id.send(:random_value)
      expect(result).to be_an(Integer)
      expect(result).to be >= described_class::DEFAULT_RANDOM_RANGE.min
      expect(result).to be <= described_class::DEFAULT_RANDOM_RANGE.max
    end
  end

  describe '#validated_value' do
    context 'with valid id values' do
      it 'accepts integers' do
        expect(id.send(:validated_value, 123)).to eq(123)
      end

      it 'accepts numeric strings' do
        expect(id.send(:validated_value, '123')).to eq(123)
      end
    end

    context 'with invalid id values' do
      [
        'invalid',
        '123abc',
        '12.34',
        nil,
        [],
        {}
      ].each do |invalid_id|
        it "raises ValidationError for #{invalid_id.inspect}" do
          expect { id.send(:validated_value, invalid_id) }.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end
  end

  describe 'initialization' do
    context 'when required is true' do
      let(:id) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(id.required?).to be true
      end
    end

    context 'when required is false' do
      let(:id) { described_class.new(name, required: false) }

      it 'sets required to false' do
        expect(id.required?).to be false
      end
    end

    it 'sets the default range' do
      expect(id.range).to eq(described_class::DEFAULT_RANDOM_RANGE)
    end
  end
end
