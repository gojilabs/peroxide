# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Datetime do
  let(:name) { :test_datetime }
  let(:datetime_property) { described_class.new(name) }

  describe '#serialized_value' do
    let(:time) { Time.new(2023, 1, 1, 12, 0, 0, 0) }

    before do
      allow(datetime_property).to receive(:value).and_return(time)
    end

    it 'returns the ISO8601 formatted datetime string with milliseconds' do
      expect(datetime_property.send(:serialized_value)).to eq('2023-01-01T12:00:00.000Z')
    end
  end

  describe '#random_value' do
    it 'generates a random Time object' do
      result = datetime_property.send(:random_value)
      expect(result).to be_a(Time)
      expect(result.year).to be_between(1900, Date.today.year + 10)
      expect(result.month).to be_between(1, 12)
      expect(result.day).to be_between(1, 28)
      expect(result.hour).to be_between(0, 23)
      expect(result.min).to be_between(0, 59)
      expect(result.sec).to be_between(0, 59)
      expect(result.utc?).to be true
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

  describe '#validated_value' do
    context 'with objects that respond to to_time' do
      let(:time) { Time.new(2023, 1, 1, 12, 0, 0) }

      it 'returns the original param' do
        expect(datetime_property.send(:validated_value, time)).to eq(time)
      end
    end

    context 'with valid ISO8601 string' do
      it 'returns a Time object' do
        result = datetime_property.send(:validated_value, '2023-01-01T12:00:00Z')
        expect(result).to be_a(Time)
        expect(result).to eq(Time.new(2023, 1, 1, 12, 0, 0, 0))
      end
    end

    context 'with invalid values' do
      ['invalid', '2023/01/01 12:00:00', nil, [], {}].each do |invalid_value|
        it "raises ValidationError for #{invalid_value.inspect}" do
          expect do
            datetime_property.send(:validated_value, invalid_value)
          end.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end

    context 'with range specified' do
      let(:start_time) { Time.new(2023, 1, 1) }
      let(:end_time) { Time.new(2023, 12, 31) }
      let(:datetime_property) { described_class.new(name, range: start_time..end_time) }

      it 'validates datetime within range' do
        expect(datetime_property.send(:validated_value, '2023-06-15T12:00:00Z')).to be_a(Time)
      end

      it 'raises ValidationError for datetime before range' do
        expect do
          datetime_property.send(:validated_value, '2022-12-31T23:59:59Z')
        end.to raise_error(Peroxide::Property::ValidationError)
      end

      it 'raises ValidationError for datetime after range' do
        expect do
          datetime_property.send(:validated_value, '2024-01-01T00:00:00Z')
        end.to raise_error(Peroxide::Property::ValidationError)
      end
    end
  end

  describe '#initialize' do
    context 'when required is true' do
      let(:datetime_property) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(datetime_property.required?).to be true
      end
    end

    context 'when required is false' do
      let(:datetime_property) { described_class.new(name, required: false) }

      it 'sets required to false' do
        expect(datetime_property.required?).to be false
      end
    end
  end
end
