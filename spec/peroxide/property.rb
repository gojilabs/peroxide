# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property do
  let(:name) { :test_property }
  let(:property) { described_class.new(name) }

  describe '.sanitize!' do
    let(:properties) { [property] }
    let(:params) { { test_property: 'value' } }

    before do
      allow(property).to receive(:name).and_return(:test_property)
      allow(property).to receive(:validate!).with('value')
    end

    it 'returns a hash of sanitized parameters' do
      result = described_class.sanitize!(properties, params)
      expect(result).to be_a(Hash)
      expect(result[:test_property]).to eq('value')
    end

    it 'validates each property' do
      expect(property).to receive(:validate!).with('value')
      described_class.sanitize!(properties, params)
    end
  end

  describe '#initialize' do
    context 'with valid name' do
      it 'sets the name' do
        expect(property.name).to eq(name)
      end

      it 'sets required to false by default' do
        expect(property.required?).to be false
      end

      context 'when required is true' do
        let(:property) { described_class.new(name, required: true) }

        it 'sets required to true' do
          expect(property.required?).to be true
        end
      end
    end

    context 'with invalid name' do
      it 'raises ConfigurationError for nil name' do
        expect { described_class.new(nil) }.to raise_error(
          Peroxide::Property::ConfigurationError,
          'Property name is required'
        )
      end

      it 'raises ConfigurationError for empty name' do
        expect { described_class.new('') }.to raise_error(
          Peroxide::Property::ConfigurationError,
          'Property name is required'
        )
      end
    end
  end

  describe '#placeholder' do
    before do
      allow(property).to receive(:random_value).and_return('random')
    end

    context 'when required is true' do
      let(:property) { described_class.new(name, required: true) }

      it 'returns random value' do
        expect(property.placeholder).to eq('random')
      end
    end

    context 'when required is false' do
      it 'may return nil or random value' do
        result = property.placeholder
        expect([nil, 'random']).to include(result)
      end
    end
  end

  describe '#validate!' do
    context 'when value is valid' do
      before do
        allow(property).to receive(:valid?).and_return(true)
      end

      it 'returns the value' do
        expect(property.validate!('test')).to eq('test')
      end

      it 'sets the value' do
        property.validate!('test')
        expect(property.value).to eq('test')
      end
    end

    context 'when value is invalid' do
      before do
        allow(property).to receive(:valid?).and_return(false)
        allow(property).to receive(:error_message).and_return('error')
      end

      it 'raises ValidationError' do
        expect { property.validate!('invalid') }.to raise_error(
          Peroxide::Property::ValidationError,
          'error'
        )
      end
    end

    context 'when required is false' do
      it 'allows nil value' do
        expect { property.validate!(nil) }.not_to raise_error
      end

      it 'allows empty value' do
        expect { property.validate!('') }.not_to raise_error
      end
    end
  end

  describe '#random_value' do
    it 'raises NotImplementedError' do
      expect { property.send(:random_value) }.to raise_error(
        NotImplementedError,
        'random_value must be implemented by every child class of Peroxide::Property'
      )
    end
  end

  describe '#valid?' do
    it 'raises NotImplementedError' do
      expect { property.send(:valid?) }.to raise_error(
        NotImplementedError,
        'valid? must be implemented by every child class of Peroxide::Property'
      )
    end
  end

  describe '#value_for_length_check' do
    before do
      property.instance_variable_set(:@value, 'test')
    end

    it 'returns the value' do
      expect(property.send(:value_for_length_check)).to eq('test')
    end
  end
end
