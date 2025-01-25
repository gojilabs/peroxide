# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Date do
  let(:name) { :test_date }
  let(:date_property) { described_class.new(name) }

  describe '#valid?' do
    context 'with valid date string' do
      %w[2023-01-01 2024-12-31 1900-01-01].each do |valid_value|
        it "validates #{valid_value.inspect}" do
          allow(date_property).to receive(:value).and_return(valid_value)
          expect(date_property.send(:valid?)).to be true
        end
      end
    end

    context 'with Date object' do
      let(:date) { Date.new(2023, 1, 1) }

      it 'validates Date object' do
        allow(date_property).to receive(:value).and_return(date)
        expect(date_property.send(:valid?)).to be true
      end
    end

    context 'with invalid date values' do
      ['invalid', '2023/01/01', '2023-13-01', '2023-01-32', nil, [], {}].each do |invalid_value|
        it "raises ValidationError for #{invalid_value.inspect}" do
          allow(date_property).to receive(:value).and_return(invalid_value)
          expect { date_property.send(:valid?) }.to raise_error(Peroxide::Property::ValidationError)
        end
      end
    end

    context 'with date range' do
      let(:start_date) { Date.new(2023, 1, 1) }
      let(:end_date) { Date.new(2023, 12, 31) }
      let(:date_property) { described_class.new(name, range: start_date..end_date) }

      it 'validates date within range' do
        allow(date_property).to receive(:value).and_return('2023-06-15')
        expect(date_property.send(:valid?)).to be true
      end

      it 'invalidates date before range' do
        allow(date_property).to receive(:value).and_return('2022-12-31')
        expect(date_property.send(:valid?)).to be false
      end

      it 'invalidates date after range' do
        allow(date_property).to receive(:value).and_return('2024-01-01')
        expect(date_property.send(:valid?)).to be false
      end
    end
  end

  describe '#random_value' do
    it 'generates a random Date object' do
      result = date_property.send(:random_value)
      expect(result).to be_a(Date)
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

  describe 'initialization' do
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
        expect(date_property.instance_variable_get(:@range)).to eq(range)
      end
    end
  end
end
