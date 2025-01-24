# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Date do
  let(:name) { :test_date }
  let(:date_property) { described_class.new(name) }

  describe '#random_value' do
    context 'when range is not specified' do
      it 'generates a random date' do
        result = date_property.send(:random_value)
        expect(result).to be_a(Date)
      end
    end

    context 'when range is specified' do
      let(:start_date) { Date.new(2023, 1, 1) }
      let(:end_date) { Date.new(2023, 12, 31) }
      let(:date_property) { described_class.new(name, range: start_date..end_date) }

      it 'generates a date within the specified range' do
        result = date_property.send(:random_value)
        expect(result).to be_a(Date)
        expect(result).to be >= start_date
        expect(result).to be <= end_date
      end
    end
  end

  describe '#valid?' do
    context 'with valid date string' do
      it 'validates correct date format' do
        allow(date_property).to receive(:value).and_return('2023-01-01')
        expect(date_property.send(:valid?)).to be true
      end
    end

    context 'with Date object' do
      it 'validates Date instance' do
        allow(date_property).to receive(:value).and_return(Date.today)
        expect(date_property.send(:valid?)).to be true
      end
    end

    context 'with invalid date string' do
      ['invalid', '2023/01/01', '01-01-2023', nil, 42, [], {}].each do |invalid_value|
        it "invalidates #{invalid_value.inspect}" do
          allow(date_property).to receive(:value).and_return(invalid_value)
          expect(date_property.send(:valid?)).to be false
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

  describe 'initialization' do
    context 'when required is true' do
      let(:date_property) { described_class.new(name, required: true) }

      it 'sets required to true' do
        expect(date_property.required?).to be true
      end
    end

    context 'when required is false' do
      let(:date_property) { described_class.new(name, required: false) }

      it 'sets required to false' do
        expect(date_property.required?).to be false
      end
    end
  end
end
