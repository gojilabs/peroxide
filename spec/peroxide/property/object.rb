# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Object do
  let(:name) { :test_object }
  let(:object) { described_class.new(name) }
  let(:child) { double('child_property') }

  describe '#random_value' do
    before do
      allow(child).to receive(:name).and_return(:child_name)
      allow(child).to receive(:random_value).and_return('test_value')
      object.add_child(child)
    end

    it 'generates a hash with child property values' do
      result = object.send(:random_value)
      expect(result).to be_a(Hash)
      expect(result[:child_name]).to eq('test_value')
    end
  end

  describe '#valid?' do
    before do
      allow(object).to receive(:value).and_return(value)
      allow(child).to receive(:name).and_return(:child_name)
      object.add_child(child)
    end

    context 'when value is a hash and all children are valid' do
      let(:value) { { child_name: 'test' } }

      before do
        allow(child).to receive(:validate!).with('test').and_return(true)
      end

      it 'returns true' do
        expect(object.send(:valid?)).to be true
      end
    end

    context 'when value is not a hash' do
      ['not a hash', 42, [], nil].each do |invalid_value|
        let(:value) { invalid_value }

        it "returns false for #{invalid_value.inspect}" do
          expect(object.send(:valid?)).to be false
        end
      end
    end

    context 'when child validation fails' do
      let(:value) { { child_name: 'invalid' } }

      before do
        allow(child).to receive(:validate!).with('invalid')
          .and_raise(Peroxide::Property::ValidationError)
      end

      it 'returns false' do
        expect(object.send(:valid?)).to be false
      end
    end
  end

  describe '#add_child' do
    it 'adds a child property' do
      object.add_child(child)
      expect(object.instance_variable_get(:@children)).to include(child)
    end
  end

  describe 'initialization' do
    context 'when required is true' do
      let(:object) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(object.required?).to be true
      end
    end

    context 'when required is false' do
      let(:object) { described_class.new(name, required: false) }

      it 'sets required to false' do
        expect(object.required?).to be false
      end
    end

    it 'initializes with empty children array' do
      expect(object.instance_variable_get(:@children)).to eq([])
    end
  end
end
