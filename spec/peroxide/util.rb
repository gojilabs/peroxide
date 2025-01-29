# frozen_string_literal: true

RSpec.describe Peroxide::Util do
  describe '.action_name' do
    context 'with valid action' do
      it 'returns symbolized action name' do
        params = { 'action' => 'test_action' }
        expect(described_class.action_name(params)).to eq(:test_action)
      end
    end

    context 'with invalid action' do
      it 'raises InvalidAction when action is nil' do
        params = { 'action' => nil }
        expect { described_class.action_name(params) }.to raise_error(
          Peroxide::Util::InvalidAction, "Action '' is invalid"
        )
      end

      it 'raises InvalidAction when action is empty' do
        params = { 'action' => '' }
        expect { described_class.action_name(params) }.to raise_error(
          Peroxide::Util::InvalidAction, "Action '' is invalid"
        )
      end
    end
  end

  describe '.http_code' do
    context 'with valid code' do
      it 'returns integer code' do
        expect(described_class.http_code('200')).to eq(200)
        expect(described_class.http_code(404)).to eq(404)
      end
    end

    context 'with invalid code' do
      it 'raises InvalidStatusCode when code is too low' do
        expect { described_class.http_code(99) }.to raise_error(
          Peroxide::Util::InvalidStatusCode, 'Invalid status code: 99'
        )
      end

      it 'raises InvalidStatusCode when code is too high' do
        expect { described_class.http_code(600) }.to raise_error(
          Peroxide::Util::InvalidStatusCode, 'Invalid status code: 600'
        )
      end
    end
  end

  describe '.response_properties_for' do
    it 'returns response properties for action and code' do
      actions = {
        test: {
          response: {
            200 => %i[property1 property2]
          }
        }
      }
      params = { 'action' => 'test' }

      expect(described_class.response_properties_for(actions, params, 200)).to eq(%i[property1 property2])
    end
  end

  describe '.request_properties_for' do
    it 'returns request properties for action' do
      actions = {
        test: {
          request: %i[property1 property2]
        }
      }
      params = { 'action' => 'test' }

      expect(described_class.request_properties_for(actions, params)).to eq(%i[property1 property2])
    end
  end
end
