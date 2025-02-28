# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::UuidV4 do
  let(:name) { :test_uuid }
  let(:uuid) { described_class.new(name) }

  describe '#serialized_value' do
    let(:value) { '123e4567-e89b-4123-8456-426614174000' }

    before do
      allow(uuid).to receive(:value).and_return(value)
    end

    it 'returns the value unchanged' do
      expect(uuid.send(:serialized_value)).to eq(value)
    end
  end

  describe '#random_value' do
    it 'generates a valid UUID v4' do
      result = uuid.send(:random_value)
      expect(result).to match(described_class::UUID_REGEX)
    end
  end

  describe '#validated_value' do
    context 'with valid UUID v4 values' do
      %w[
        123e4567-e89b-4123-8456-426614174000
        123e4567e89b412384564266141740aa
        123E4567-E89B-4123-8456-426614174000
      ].each do |valid_uuid|
        it "validates #{valid_uuid}" do
          expect(uuid.send(:validated_value, valid_uuid)).to eq(valid_uuid)
        end
      end
    end

    context 'with invalid UUID v4 values' do
      [
        'invalid',
        '123e4567-e89b-3123-8456-426614174000', # wrong version
        '123e4567-e89b-4123-7456-426614174000', # wrong variant
        '123e4567-e89b-4123-8456', # too short
        nil,
        123,
        []
      ].each do |invalid_uuid|
        it "raises ValidationError for #{invalid_uuid.inspect}" do
          expect { uuid.send(:validated_value, invalid_uuid) }.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end
  end

  describe 'initialization' do
    context 'when required is true' do
      let(:uuid) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(uuid.required?).to be true
      end
    end

    context 'when required is false' do
      let(:uuid) { described_class.new(name, required: false) }

      it 'sets required to false' do
        expect(uuid.required?).to be false
      end
    end
  end
end
