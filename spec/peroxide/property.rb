# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property do
  let(:name) { :test_property }
  let(:property) { described_class.new(name) }

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

  describe '#required?' do
    context 'when required is true' do
      let(:property) { described_class.new(name, required: true) }

      it 'returns true' do
        expect(property.required?).to be true
      end
    end

    context 'when required is false' do
      let(:property) { described_class.new(name, required: false) }

      it 'returns false' do
        expect(property.required?).to be false
      end
    end
  end

  describe '#placeholder' do
    before do
      allow(property).to receive(:random_value).and_return('random')
    end

    context 'when placeholder_required? is true' do
      before do
        allow(property).to receive(:placeholder_required?).and_return(true)
      end

      it 'returns random value' do
        expect(property.placeholder).to eq('random')
      end
    end

    context 'when placeholder_required? is false' do
      before do
        allow(property).to receive(:placeholder_required?).and_return(false)
      end

      it 'returns nil' do
        expect(property.placeholder).to be_nil
      end
    end
  end

  describe '#serialize' do
    context 'when @serialize is defined' do
      before do
        property.instance_variable_set(:@serialize, 'cached')
      end

      it 'returns cached value' do
        expect(property.serialize).to eq('cached')
      end
    end

    context 'when @value is not defined' do
      it 'returns nil' do
        expect(property.serialize).to be_nil
      end
    end

    context 'when @value is defined' do
      before do
        property.instance_variable_set(:@value, 'test')
        allow(property).to receive(:serialized_value).and_return('serialized')
      end

      it 'returns serialized value' do
        expect(property.serialize).to eq('serialized')
      end
    end
  end

  describe '#validate!' do
    context 'when required is true' do
      let(:property) { described_class.new(name, required: true) }

      it 'raises ValidationError if param is nil' do
        expect { property.validate!(nil) }.to raise_error(
          Peroxide::Property::ValidationError,
          "Property 'test_property' is required but was not provided"
        )
      end

      it 'sets and returns validated value if param is present' do
        allow(property).to receive(:validated_value).with('test').and_return('validated')
        expect(property.validate!('test')).to eq('validated')
        expect(property.value).to eq('validated')
      end
    end

    context 'when required is false' do
      it 'sets and returns validated value' do
        allow(property).to receive(:validated_value).with('test').and_return('validated')
        expect(property.validate!('test')).to eq('validated')
        expect(property.value).to eq('validated')
      end
    end
  end

  describe '#placeholder_required?' do
    context 'when required is true' do
      let(:property) { described_class.new(name, required: true) }

      it 'returns true' do
        expect(property.send(:placeholder_required?)).to be true
      end
    end

    context 'when required is false' do
      let(:property) { described_class.new(name, required: false) }

      context 'when fifty_fifty? is true' do
        before do
          allow(property).to receive(:fifty_fifty?).and_return(true)
        end

        it 'returns true' do
          expect(property.send(:placeholder_required?)).to be true
        end
      end

      context 'when fifty_fifty? is false' do
        before do
          allow(property).to receive(:fifty_fifty?).and_return(false)
        end

        it 'returns false' do
          expect(property.send(:placeholder_required?)).to be false
        end
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

  describe '#validated_value' do
    it 'raises NotImplementedError' do
      expect { property.send(:validated_value, 'test') }.to raise_error(
        NotImplementedError,
        'validated_value must be implemented by every child class of Peroxide::Property'
      )
    end
  end

  describe '#serialized_value' do
    it 'raises NotImplementedError' do
      expect { property.send(:serialized_value) }.to raise_error(
        NotImplementedError,
        'serialized_value must be implemented by every child class of Peroxide::Property'
      )
    end
  end

  describe '#error_message' do
    before do
      property.instance_variable_set(:@value, 'test')
    end

    it 'formats error message with name and value' do
      expect(property.send(:error_message)).to eq("Property 'test_property' is required but was not provided")
    end
  end
end
