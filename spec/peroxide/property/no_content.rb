# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::NoContent do
  let(:no_content) { described_class.new }

  describe '#serialized_value' do
    it 'returns nil' do
      expect(no_content.send(:serialized_value)).to be_nil
    end
  end

  describe '#random_value' do
    it 'returns nil' do
      expect(no_content.send(:random_value)).to be_nil
    end
  end

  describe '#validated_value' do
    context 'with nil value' do
      it 'returns nil' do
        expect(no_content.send(:validated_value, nil)).to be_nil
      end
    end

    context 'with non-nil values' do
      ['content', 42, true, [], {}].each do |invalid_value|
        it "raises ValidationError for #{invalid_value.inspect}" do
          expect do
            no_content.send(:validated_value, invalid_value)
          end.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end
  end

  describe 'initialization' do
    it 'does not set name' do
      expect(no_content.name).to be_nil
    end

    context 'when required is true' do
      let(:no_content) { described_class.new(required: true) }

      it 'sets required to true' do
        expect(no_content.required?).to be true
      end
    end

    context 'when required is false' do
      let(:no_content) { described_class.new(required: false) }

      it 'sets required to false' do
        expect(no_content.required?).to be false
      end
    end
  end
end
