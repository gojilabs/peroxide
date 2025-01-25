# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Peroxide::Sanitizer do
  describe '.action' do
    before do
      described_class.instance_variable_set(:@actions, nil)
    end

    it 'creates a new action with request and response containers' do
      described_class.action(:test) do
        # Empty block
      end

      actions = described_class.instance_variable_get(:@actions)
      expect(actions[:test]).to eq({
        request: [],
        response: {}
      })
    end
  end

  describe '.request' do
    before do
      described_class.instance_variable_set(:@actions, nil)
      described_class.action(:test)
    end

    it 'stores properties for request validation' do
      described_class.request do
        described_class.string(:name)
      end

      actions = described_class.instance_variable_get(:@actions)
      expect(actions[:test][:request].length).to eq(1)
      expect(actions[:test][:request].first).to be_a(Peroxide::Property::String)
    end
  end

  describe '.response' do
    before do
      described_class.instance_variable_set(:@actions, nil)
      described_class.action(:test)
    end

    context 'with numeric status code' do
      it 'stores properties for response validation' do
        described_class.response(200) do
          described_class.string(:message)
        end

        actions = described_class.instance_variable_get(:@actions)
        expect(actions[:test][:response][200].length).to eq(1)
      end
    end

    context 'with symbolic status code' do
      it 'stores properties for response validation' do
        described_class.response(:ok) do
          described_class.string(:message)
        end

        actions = described_class.instance_variable_get(:@actions)
        expect(actions[:test][:response][200].length).to eq(1)
      end
    end
  end

  describe '.sanitize_request!' do
    before do
      described_class.instance_variable_set(:@actions, nil)
      described_class.action(:test) do
        described_class.request do
          described_class.string(:name, required: true)
        end
      end
    end

    context 'when properties exist for action' do
      it 'validates request parameters' do
        result = described_class.sanitize_request!({ 'action' => 'test', 'name' => 'value' })
        expect(result[:name]).to eq('value')
      end
    end

    context 'when properties do not exist for action' do
      it 'raises Failed error' do
        expect do
          described_class.sanitize_request!({ 'action' => 'missing' })
        end.to raise_error(Peroxide::Sanitizer::Failed, "Properties for 'missing' request are missing")
      end
    end
  end

  describe '.sanitize_response!' do
    before do
      described_class.instance_variable_set(:@actions, nil)
      described_class.action(:test) do
        described_class.response(200) do
          described_class.string(:message, required: true)
        end
      end
    end

    context 'when properties exist for action and status' do
      it 'validates response parameters' do
        result = described_class.sanitize_response!({ 'action' => 'test', 'message' => 'success' }, 200)
        expect(result[:message]).to eq('success')
      end
    end

    context 'when properties do not exist for action and status' do
      it 'raises Failed error' do
        expect do
          described_class.sanitize_response!({ 'action' => 'test' }, 404)
        end.to raise_error(Peroxide::Sanitizer::Failed, "Properties for 'test' response 404 are missing")
      end
    end
  end

  describe '.placeholder_response!' do
    before do
      described_class.instance_variable_set(:@actions, nil)
      described_class.action(:test) do
        described_class.response(200) do
          described_class.string(:message)
        end
        described_class.response(204) do
          described_class.no_content
        end
      end
    end

    context 'when response has properties' do
      it 'generates placeholder values' do
        result = described_class.placeholder_response!(:test, 200)
        expect(result).to be_a(Hash)
        expect(result).to have_key(:message)
      end
    end

    context 'when response is no_content' do
      it 'returns nil' do
        result = described_class.placeholder_response!(:test, 204)
        expect(result).to be_nil
      end
    end
  end

  describe 'property registration methods' do
    before do
      described_class.instance_variable_set(:@actions, nil)
      described_class.action(:test)
      described_class.request {}
    end

    describe '.array' do
      it 'registers array property' do
        described_class.array(:items) do
          described_class.string(:name)
        end
        properties = described_class.instance_variable_get(:@properties)
        expect(properties.first).to be_a(Peroxide::Property::Array)
      end
    end

    describe '.boolean' do
      it 'registers boolean property' do
        described_class.boolean(:flag)
        properties = described_class.instance_variable_get(:@properties)
        expect(properties.first).to be_a(Peroxide::Property::Boolean)
      end
    end

    describe '.date' do
      it 'registers date property' do
        described_class.date(:created_at)
        properties = described_class.instance_variable_get(:@properties)
        expect(properties.first).to be_a(Peroxide::Property::Date)
      end
    end

    describe '.datetime' do
      it 'registers datetime property' do
        described_class.datetime(:updated_at)
        properties = described_class.instance_variable_get(:@properties)
        expect(properties.first).to be_a(Peroxide::Property::Datetime)
      end
    end

    describe '.enum' do
      it 'registers enum property' do
        described_class.enum(:status, values: %w[active inactive])
        properties = described_class.instance_variable_get(:@properties)
        expect(properties.first).to be_a(Peroxide::Property::Enum)
      end
    end

    describe '.float' do
      it 'registers float property' do
        described_class.float(:price)
        properties = described_class.instance_variable_get(:@properties)
        expect(properties.first).to be_a(Peroxide::Property::Float)
      end
    end

    describe '.integer' do
      it 'registers integer property' do
        described_class.integer(:count)
        properties = described_class.instance_variable_get(:@properties)
        expect(properties.first).to be_a(Peroxide::Property::Integer)
      end
    end

    describe '.no_content' do
      it 'registers no_content property' do
        described_class.no_content
        properties = described_class.instance_variable_get(:@properties)
        expect(properties.first).to be_a(Peroxide::Property::NoContent)
      end
    end

    describe '.object' do
      it 'registers object property' do
        described_class.object(:user) do
          described_class.string(:name)
        end
        properties = described_class.instance_variable_get(:@properties)
        expect(properties.first).to be_a(Peroxide::Property::Object)
      end
    end

    describe '.string' do
      it 'registers string property' do
        described_class.string(:name)
        properties = described_class.instance_variable_get(:@properties)
        expect(properties.first).to be_a(Peroxide::Property::String)
      end
    end
  end
end
