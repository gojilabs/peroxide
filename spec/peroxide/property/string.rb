# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::String do
  let(:name) { :test_string }
  let(:string) { described_class.new(name) }

  describe '#valid?' do
    before do
      allow(string).to receive(:value).and_return(value)
      allow(string).to receive(:check_length).and_return(true)
    end

    context 'with string value' do
      let(:value) { 'test' }

      it 'returns true' do
        expect(string.send(:valid?)).to be true
      end
    end

    context 'with non-string values' do
      [42, 3.14, true, [], {}, nil].each do |invalid_value|
        let(:value) { invalid_value }

        it "returns false for #{invalid_value.inspect}" do
          expect(string.send(:valid?)).to be false
        end
      end
    end

    context 'when length check fails' do
      let(:value) { 'test' }

      before do
        allow(string).to receive(:check_length).and_return(false)
      end

      it 'returns false' do
        expect(string.send(:valid?)).to be false
      end
    end
  end

  describe '#value_for_length_check' do
    let(:test_value) { 'test' }

    before do
      allow(string).to receive(:value).and_return(test_value)
    end

    it 'returns the value' do
      expect(string.send(:value_for_length_check)).to eq(test_value)
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
      let(:length) { 5 }
      let(:string) { described_class.new(name, length: length) }

      it 'sets the length' do
        expect(string.length).to eq(length)
      end
    end
  end
end
