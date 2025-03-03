# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Object do
  let(:name) { :test_object }
  let(:object) { described_class.new(name) }
  let(:child) { double('child_property') }

  describe '#serialized_value' do
    before do
      allow(child).to receive(:name).and_return(:child_name)
      allow(child).to receive(:serialized_value).and_return('test_value')
      allow(object).to receive(:value).and_return({ child_name: 'original_value' })
      object.add_child(child)
    end

    it 'returns hash with serialized child values' do
      result = object.send(:serialized_value)
      expect(result).to be_a(Hash)
      expect(result[:child_name]).to eq('test_value')
    end
  end

  describe '#random_value' do
    before do
      allow(child).to receive(:name).and_return(:child_name)
      allow(child).to receive(:placeholder).and_return('test_value')
      object.add_child(child)
    end

    it 'generates a hash with child property values' do
      result = object.send(:random_value)
      expect(result).to be_a(Hash)
      expect(result[:child_name]).to eq('test_value')
    end
  end

  describe '#validated_value' do
    before do
      allow(child).to receive(:name).and_return(:child_name)
      allow(child).to receive(:validate!).with('test').and_return('validated_test')
      object.add_child(child)
    end

    context 'with valid hash input' do
      let(:param) { { child_name: 'test' } }

      it 'returns hash with validated child values' do
        result = object.send(:validated_value, param)
        expect(result).to be_a(Hash)
        expect(result[:child_name]).to eq('validated_test')
      end
    end

    context 'with non-hash input' do
      ['not a hash', 42, [], nil].each do |invalid_param|
        it "raises ValidationError for #{invalid_param.inspect}" do
          expect { object.send(:validated_value, invalid_param) }
            .to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end
  end

  describe '#add_child' do
    before do
      allow(child).to receive(:name).and_return(:child_name)
    end

    it 'adds child property to children hash' do
      object.add_child(child)
      expect(object.instance_variable_get(:@children)).to eq({ child_name: child })
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

    it 'initializes with empty children hash' do
      expect(object.instance_variable_get(:@children)).to eq({})
    end

    context 'when inside an array' do
      let(:object) { described_class.new(nil) }

      it 'must not have a name' do
        expect(object.name).to be_nil
      end

      it 'must not raise an error when there is no name' do
        expect { object }.not_to raise_error
      end
    end
  end
end
