# frozen_string_literal: true

RSpec.describe Peroxide::Sanitizer do
  describe '.action' do
    context 'with valid action name' do
      it 'creates action configuration' do
        described_class.action('test') do
          expect(described_class.instance_variable_get(:@current_action)).to eq(:test)
          expect(described_class.instance_variable_get(:@actions)[:test]).to eq(
            request: [],
            response: {}
          )
        end
      end
    end

    context 'with invalid action name' do
      it 'raises InvalidAction when name is nil' do
        expect { described_class.action(nil) }.to raise_error(
          Peroxide::Util::InvalidAction, "Action '' is invalid"
        )
      end

      it 'raises InvalidAction when name is empty' do
        expect { described_class.action('') }.to raise_error(
          Peroxide::Util::InvalidAction, "Action '' is invalid"
        )
      end
    end
  end

  describe '.request' do
    before do
      described_class.action('test')
    end

    it 'configures request properties' do
      properties = []
      described_class.request do
        properties << described_class.string('name')
      end

      expect(described_class.instance_variable_get(:@actions)[:test][:request]).to eq(properties)
    end
  end

  describe '.response' do
    before do
      described_class.action('test')
    end

    it 'configures response properties for status code' do
      properties = []
      described_class.response(200) do
        properties << described_class.string('name')
      end

      expect(described_class.instance_variable_get(:@actions)[:test][:response][200]).to eq(properties)
    end

    it 'raises InvalidStatusCode for invalid code' do
      expect { described_class.response(600) }.to raise_error(
        Peroxide::Util::InvalidStatusCode, 'Invalid status code: 600'
      )
    end
  end

  describe '.sanitize_request!' do
    let(:params) { { 'action' => 'test', 'name' => 'value' } }

    before do
      described_class.action('test') do
        described_class.request do
          described_class.string('name')
        end
      end
    end

    it 'validates and returns request parameters' do
      result = described_class.sanitize_request!(params)
      expect(result).to include('name' => 'value')
    end
  end

  describe '.sanitize_response!' do
    let(:params) { { 'action' => 'test', 'name' => 'value' } }

    before do
      described_class.action('test') do
        described_class.response(200) do
          described_class.string('name')
        end
      end
    end

    it 'validates and returns response parameters' do
      result = described_class.sanitize_response!(params, 200)
      expect(result).to include('name' => 'value')
    end
  end

  describe '.placeholder_response!' do
    let(:params) { { 'action' => 'test' } }

    context 'with regular properties' do
      before do
        described_class.action('test') do
          described_class.response(200) do
            described_class.string('name', required: true)
          end
        end
      end

      it 'returns hash with random values' do
        result = described_class.placeholder_response!(params, 200)
        expect(result).to include('name')
        expect(result['name']).to be_a(String)
      end
    end

    context 'with no_content property' do
      before do
        described_class.action('test') do
          described_class.response(204) do
            described_class.no_content
          end
        end
      end

      it 'returns nil' do
        expect(described_class.placeholder_response!(params, 204)).to be_nil
      end
    end
  end

  describe 'property registration methods' do
    before do
      described_class.action('test')
      described_class.request
    end

    it 'registers array property' do
      property = described_class.array('items') do
        described_class.string
      end
      expect(property).to be_a(Peroxide::Property::Array)
    end

    it 'registers boolean property' do
      property = described_class.boolean('flag')
      expect(property).to be_a(Peroxide::Property::Boolean)
    end

    it 'registers date property' do
      property = described_class.date('created_at')
      expect(property).to be_a(Peroxide::Property::Date)
    end

    it 'registers datetime property' do
      property = described_class.datetime('updated_at')
      expect(property).to be_a(Peroxide::Property::Datetime)
    end

    it 'registers enum property' do
      property = described_class.enum('status', %w[active inactive])
      expect(property).to be_a(Peroxide::Property::Enum)
    end

    it 'registers float property' do
      property = described_class.float('price')
      expect(property).to be_a(Peroxide::Property::Float)
    end

    it 'registers integer property' do
      property = described_class.integer('count')
      expect(property).to be_a(Peroxide::Property::Integer)
    end

    it 'registers no_content property' do
      property = described_class.no_content
      expect(property).to be_a(Peroxide::Property::NoContent)
    end

    it 'registers object property' do
      property = described_class.object('user') do
        described_class.string('name')
      end
      expect(property).to be_a(Peroxide::Property::Object)
    end

    it 'registers string property' do
      property = described_class.string('name')
      expect(property).to be_a(Peroxide::Property::String)
    end
  end
end
