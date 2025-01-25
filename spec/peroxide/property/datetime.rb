# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Datetime do
  let(:name) { :test_datetime }
  let(:datetime_property) { described_class.new(name) }

  describe '#valid?' do
    context 'with valid Time object' do
      let(:time) { Time.now }

      it 'validates Time object' do
        allow(datetime_property).to receive(:value).and_return(time)
        expect(datetime_property.send(:valid?)).to be true
      end
    end

    context 'with valid datetime string' do
      let(:valid_values) do
        [
          '2023-01-01 12:00:00+0000',
          '2024-12-31 23:59:59+0000',
          '1900-01-01 00:00:00+0000'
        ]
      end

      it 'validates properly formatted strings' do
        valid_values.each do |valid_value|
          allow(datetime_property).to receive(:value).and_return(valid_value)
          expect(datetime_property.send(:valid?)).to be true
        end
      end
    end

    context 'with valid Unix timestamp' do
      let(:timestamp) { Time.now.to_i }

      it 'validates integer timestamp' do
        allow(datetime_property).to receive(:value).and_return(timestamp)
        expect(datetime_property.send(:valid?)).to be true
      end
    end

    context 'with invalid datetime values' do
      let(:invalid_values) do
        [
          'invalid',
          '2023/01/01 12:00:00',
          '2023-13-01 25:00:00+0000',
          '2023-01-32 12:00:00+0000',
          'not_a_timestamp',
          nil,
          [],
          {}
        ]
      end

      it 'raises ValidationError for invalid values' do
        invalid_values.each do |invalid_value|
          allow(datetime_property).to receive(:value).and_return(invalid_value)
          expect { datetime_property.send(:valid?) }.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end

    context 'with datetime range' do
      let(:start_time) { Time.new(2023, 1, 1) }
      let(:end_time) { Time.new(2023, 12, 31) }
      let(:datetime_property) { described_class.new(name, range: start_time..end_time) }

      it 'validates datetime within range' do
        allow(datetime_property).to receive(:value).and_return('2023-06-15 12:00:00+0000')
        expect(datetime_property.send(:valid?)).to be true
      end

      it 'invalidates datetime before range' do
        allow(datetime_property).to receive(:value).and_return('2022-12-31 23:59:59+0000')
        expect(datetime_property.send(:valid?)).to be false
      end

      it 'invalidates datetime after range' do
        allow(datetime_property).to receive(:value).and_return('2024-01-01 00:00:00+0000')
        expect(datetime_property.send(:valid?)).to be false
      end
    end
  end

  describe '#random_value' do
    it 'generates a random Time object' do
      result = datetime_property.send(:random_value)
      expect(result).to be_a(Time)
    end

    context 'with range specified' do
      let(:start_time) { Time.new(2023, 1, 1) }
      let(:end_time) { Time.new(2023, 12, 31) }
      let(:datetime_property) { described_class.new(name, range: start_time..end_time) }

      it 'generates a random Time within the range' do
        result = datetime_property.send(:random_value)
        expect(result).to be_between(start_time, end_time)
      end
    end
  end

  describe 'initialization' do
    context 'when required is true' do
      let(:datetime_property) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(datetime_property.required?).to be true
      end
    end

    context 'when required is false' do
      it 'sets required to false by default' do
        expect(datetime_property.required?).to be false
      end
    end

    context 'with range specified' do
      let(:range) { Time.new(2023, 1, 1)..Time.new(2023, 12, 31) }
      let(:datetime_property) { described_class.new(name, range:) }

      it 'sets the range' do
        expect(datetime_property.instance_variable_get(:@range)).to eq(range)
      end
    end
  end
end
