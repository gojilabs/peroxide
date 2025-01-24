# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::Datetime do
  let(:name) { :test_datetime }
  let(:datetime_property) { described_class.new(name) }

  describe '#valid?' do
    context 'with valid datetime string' do
      ['2023-01-01 12:00:00Z', '2023-12-31 23:59:59Z'].each do |valid_value|
        it "validates #{valid_value.inspect}" do
          allow(datetime_property).to receive(:value).and_return(valid_value)
          expect(datetime_property.send(:valid?)).to be true
        end
      end
    end

    context 'with Time object' do
      let(:time) { Time.new(2023, 1, 1, 12, 0, 0) }

      it 'validates Time object' do
        allow(datetime_property).to receive(:value).and_return(time)
        expect(datetime_property.send(:valid?)).to be true
      end
    end

    context 'with invalid datetime string' do
      ['invalid', '2023/01/01 12:00:00', '2023-13-01 25:00:00Z', nil, 42, [], {}].each do |invalid_value|
        it "invalidates #{invalid_value.inspect}" do
          allow(datetime_property).to receive(:value).and_return(invalid_value)
          expect(datetime_property.send(:valid?)).to be false
        end
      end
    end

    context 'with datetime range' do
      let(:start_time) { Time.new(2023, 1, 1, 0, 0, 0) }
      let(:end_time) { Time.new(2023, 12, 31, 23, 59, 59) }
      let(:datetime_property) { described_class.new(name, range: start_time..end_time) }

      it 'validates datetime within range' do
        allow(datetime_property).to receive(:value).and_return('2023-06-15 12:00:00Z')
        expect(datetime_property.send(:valid?)).to be true
      end

      it 'invalidates datetime before range' do
        allow(datetime_property).to receive(:value).and_return('2022-12-31 23:59:59Z')
        expect(datetime_property.send(:valid?)).to be false
      end

      it 'invalidates datetime after range' do
        allow(datetime_property).to receive(:value).and_return('2024-01-01 00:00:00Z')
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
      let(:datetime_property) { described_class.new(name, required: false) }

      it 'sets required to false' do
        expect(datetime_property.required?).to be false
      end
    end
  end
end
