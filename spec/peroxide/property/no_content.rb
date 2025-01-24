# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Property::NoContent do
  let(:no_content) { described_class.new }

  describe '#random_value' do
    it 'returns nil' do
      expect(no_content.send(:random_value)).to be_nil
    end
  end

  describe '#valid?' do
    context 'when value is nil' do
      before do
        allow(no_content).to receive(:value).and_return(nil)
      end

      it 'returns true' do
        expect(no_content.send(:valid?)).to be true
      end
    end

    context 'when value is not nil' do
      ['content', 42, true, [], {}].each do |invalid_value|
        it "returns false for #{invalid_value.inspect}" do
          allow(no_content).to receive(:value).and_return(invalid_value)
          expect(no_content.send(:valid?)).to be false
        end
      end
    end
  end

  describe 'initialization' do
    it 'sets name to _no_content' do
      expect(no_content.name).to eq('_no_content')
    end

    it 'sets required to false' do
      expect(no_content.required?).to be false
    end
  end
end
