# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Date do
  let(:name) { :test_date }
  let(:date_property) { described_class.new(name) }

  describe '#serialized_value' do
    let(:date) { Date.new(2023, 1, 1) }

    before do
      allow(date_property).to receive(:value).and_return(date)
    end

    it 'returns the ISO8601 formatted date string' do
      expect(date_property.send(:serialized_value)).to eq('2023-01-01')
    end
  end

  describe '#random_value' do
    it 'generates a random Date object' do
      result = date_property.send(:random_value)
      expect(result).to be_a(Date)
      expect(result.year).to be_between(1900, Date.today.year + 10)
      expect(result.month).to be_between(1, 12)
      expect(result.day).to be_between(1, 28)
    end

    context 'with range specified' do
      let(:start_date) { Date.new(2023, 1, 1) }
      let(:end_date) { Date.new(2023, 12, 31) }
      let(:date_property) { described_class.new(name, range: start_date..end_date) }

      it 'generates a random Date within the range' do
        result = date_property.send(:random_value)
        expect(result).to be_between(start_date, end_date)
      end
    end
  end

  describe '#validated_value' do
    context 'with objects that respond to to_date' do
      let(:date) { Date.new(2023, 1, 1) }

      it 'returns the original param' do
        expect(date_property.send(:validated_value, date)).to eq(date)
      end
    end

    context 'with valid ISO8601 string' do
      it 'returns a Date object' do
        result = date_property.send(:validated_value, '2023-01-01')
        expect(result).to be_a(Date)
        expect(result).to eq(Date.new(2023, 1, 1))
      end
    end

    context 'with invalid values' do
      ['invalid', '2023/01/01', '2023-13-01', '2023-01-32', nil, [], {}].each do |invalid_value|
        it "raises ValidationError for #{invalid_value.inspect}" do
          expect do
            date_property.send(:validated_value, invalid_value)
          end.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end

    context 'with range specified' do
      let(:start_date) { Date.new(2023, 1, 1) }
      let(:end_date) { Date.new(2023, 12, 31) }
      let(:date_property) { described_class.new(name, range: start_date..end_date) }

      it 'validates date within range' do
        expect(date_property.send(:validated_value, '2023-06-15')).to be_a(Date)
      end

      it 'raises ValidationError for date before range' do
        expect do
          date_property.send(:validated_value, '2022-12-31')
        end.to raise_error(Peroxide::Property::ValidationError)
      end

      it 'raises ValidationError for date after range' do
        expect do
          date_property.send(:validated_value, '2024-01-01')
        end.to raise_error(Peroxide::Property::ValidationError)
      end
    end
  end

  describe '#initialize' do
    context 'when required is true' do
      let(:date_property) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(date_property.required?).to be true
      end
    end

    context 'when required is false' do
      it 'sets required to false by default' do
        expect(date_property.required?).to be false
      end
    end

    context 'with range specified' do
      let(:range) { Date.new(2023, 1, 1)..Date.new(2023, 12, 31) }
      let(:date_property) { described_class.new(name, range:) }

      it 'sets the range' do
        expect(date_property.range).to eq(range)
      end
    end
  end
end
