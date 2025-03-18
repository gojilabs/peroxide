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

      it 'raises InvalidAction when name does not respond to to_sym' do
        expect { described_class.action(Object.new) }.to raise_error(
          Peroxide::Util::InvalidAction
        )
      end
    end
  end

  describe '.request' do
    before do
      described_class.action('test')
    end

    it 'initializes request hash' do
      described_class.request do
        expect(described_class.instance_variable_get(:@request)).to eq({})
      end
    end

    it 'assigns request to current action' do
      described_class.request do
        # Set properties
      end
      expect(described_class.instance_variable_get(:@actions)[:test][:request]).to be_a(Hash)
    end
  end

  describe '.body' do
    before do
      described_class.action('test')
      described_class.request
    end

    it 'initializes properties to nil' do
      described_class.body do
        expect(described_class.instance_variable_get(:@properties)).to be_nil
      end
    end

    it 'assigns properties to request body' do
      described_class.body do
        described_class.string('name')
      end
      expect(described_class.instance_variable_get(:@request)[:body]).to be_a(Peroxide::Property::Object)
    end
  end

  describe '.url' do
    before do
      described_class.action('test')
      described_class.request
    end

    it 'initializes properties to nil' do
      described_class.url do
        expect(described_class.instance_variable_get(:@properties)).to be_nil
      end
    end

    it 'assigns properties to request url' do
      described_class.url do
        described_class.string('id')
      end
      expect(described_class.instance_variable_get(:@request)[:url]).to be_a(Peroxide::Property::Object)
    end
  end

  describe '.response' do
    before do
      described_class.action('test')
    end

    it 'initializes response array' do
      described_class.response(200) do
        expect(described_class.instance_variable_get(:@response)).to eq([])
      end
    end

    it 'configures response properties for status code' do
      described_class.response(200) do
        described_class.string('name')
      end
      expect(described_class.instance_variable_get(:@actions)[:test][:response][200]).to be_a(Peroxide::Property::Object)
    end

    it 'raises InvalidStatusCode for invalid code' do
      expect { described_class.response(600) }.to raise_error(
        Peroxide::Util::InvalidStatusCode, 'Invalid status code: 600'
      )
    end
  end

  describe '.register_property' do
    before do
      described_class.action('test')
      described_class.request
      described_class.body
    end

    context 'when @properties is nil' do
      it 'creates implicit object container for named property' do
        property = Peroxide::Property::String.new('name')
        described_class.register_property(property)
        expect(described_class.instance_variable_get(:@properties)).to be_a(Peroxide::Property::Object)
      end

      it 'assigns property directly for unnamed property' do
        property = Peroxide::Property::NoContent.new
        described_class.register_property(property)
        expect(described_class.instance_variable_get(:@properties)).to eq(property)
      end
    end

    context 'when @properties responds to add_child' do
      before do
        described_class.object
      end

      it 'adds property as child' do
        property = Peroxide::Property::String.new('name')
        expect_any_instance_of(Peroxide::Property::Object).to receive(:add_child).with(property)
        described_class.register_property(property)
      end
    end

    context 'when @properties responds to item_property=' do
      before do
        described_class.array
      end

      it 'sets property as item_property' do
        property = Peroxide::Property::String.new(nil)
        expect_any_instance_of(Peroxide::Property::Array).to receive(:item_property=).with(property)
        described_class.register_property(property)
      end
    end

    context 'when @properties is invalid container' do
      before do
        described_class.instance_variable_set(:@properties, Peroxide::Property::String.new('test'))
      end

      it 'raises InvalidPropertyContainer' do
        property = Peroxide::Property::String.new('name')
        expect { described_class.register_property(property) }.to raise_error(
          Peroxide::Sanitizer::InvalidPropertyContainer
        )
      end
    end
  end

  describe '.sanitize_body!' do
    let(:params) { { 'action' => 'test', 'name' => 'value' } }

    before do
      described_class.action('test') do
        described_class.request do
          described_class.body do
            described_class.string('name')
          end
        end
      end
    end

    it 'delegates to Util.body_properties_for and validates params' do
      expect(Peroxide::Util).to receive(:body_properties_for).with(
        described_class.instance_variable_get(:@actions), params
      ).and_call_original

      result = described_class.sanitize_body!(params)
      expect(result).to include('name' => 'value')
    end
  end

  describe '.sanitize_url!' do
    let(:params) { { 'action' => 'test', 'id' => '123' } }

    before do
      described_class.action('test') do
        described_class.request do
          described_class.url do
            described_class.string('id')
          end
        end
      end
    end

    it 'delegates to Util.url_properties_for and validates params' do
      expect(Peroxide::Util).to receive(:url_properties_for).with(
        described_class.instance_variable_get(:@actions), params
      ).and_call_original

      result = described_class.sanitize_url!(params)
      expect(result).to include('id' => '123')
    end
  end

  describe '.sanitize_response!' do
    let(:params) { { 'action' => 'test', 'name' => 'value' } }

    before do
      described_class.action('test') do
        described_class.response(200) do
          described_class.object do
            described_class.string('name')
          end
        end
      end
    end

    it 'delegates to Util.response_properties_for and validates params' do
      expect(Peroxide::Util).to receive(:response_properties_for).with(
        described_class.instance_variable_get(:@actions), params, 200
      ).and_call_original

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
            described_class.object(required: true) do
              described_class.string('name', required: true)
            end
          end
        end
      end

      it 'delegates to Util.response_properties_for and returns placeholder' do
        expect(Peroxide::Util).to receive(:response_properties_for).with(
          described_class.instance_variable_get(:@actions), params, 200
        ).and_call_original

        result = described_class.placeholder_response!(params, 200)
        expect(result).to be_a(Hash)
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
      described_class.body
    end

    it 'registers array property' do
      property = described_class.array('items', length: 2, required: true) do
        described_class.string
      end
      expect(property).to be_a(Peroxide::Property::Array)
      expect(property.name).to eq('items')
      expect(property).to be_required
    end

    it 'registers boolean property' do
      property = described_class.boolean('flag', required: true)
      expect(property).to be_a(Peroxide::Property::Boolean)
      expect(property.name).to eq('flag')
      expect(property).to be_required
    end

    it 'registers date property' do
      range = (Date.today..Date.today + 30)
      property = described_class.date('created_at', range: range, required: true)
      expect(property).to be_a(Peroxide::Property::Date)
      expect(property.name).to eq('created_at')
      expect(property).to be_required
    end

    it 'registers datetime property' do
      range = (DateTime.now..DateTime.now + 30)
      property = described_class.datetime('updated_at', range: range, required: true)
      expect(property).to be_a(Peroxide::Property::Datetime)
      expect(property.name).to eq('updated_at')
      expect(property).to be_required
    end

    it 'registers enum property' do
      property = described_class.enum('status', %w[active inactive], required: true)
      expect(property).to be_a(Peroxide::Property::Enum)
      expect(property.name).to eq('status')
      expect(property).to be_required
    end

    it 'registers float property' do
      property = described_class.float('price', range: (0.0..100.0), required: true)
      expect(property).to be_a(Peroxide::Property::Float)
      expect(property.name).to eq('price')
      expect(property).to be_required
    end

    it 'registers integer property' do
      property = described_class.integer('count', range: (0..10), required: true)
      expect(property).to be_a(Peroxide::Property::Integer)
      expect(property.name).to eq('count')
      expect(property).to be_required
    end

    it 'registers id property' do
      property = described_class.id('user_id', required: true)
      expect(property).to be_a(Peroxide::Property::Id)
      expect(property.name).to eq('user_id')
      expect(property).to be_required
    end

    it 'registers uuid property' do
      property = described_class.uuid('uuid', required: true)
      expect(property).to be_a(Peroxide::Property::UuidV4)
      expect(property.name).to eq('uuid')
      expect(property).to be_required
    end

    it 'registers no_content property' do
      property = described_class.no_content
      expect(property).to be_a(Peroxide::Property::NoContent)
    end

    it 'registers object property' do
      property = described_class.object('user', required: true) do
        described_class.string('name')
      end
      expect(property).to be_a(Peroxide::Property::Object)
      expect(property.name).to eq('user')
      expect(property).to be_required
    end

    it 'registers string property' do
      property = described_class.string('name', length: 10, required: true)
      expect(property).to be_a(Peroxide::Property::String)
      expect(property.name).to eq('name')
      expect(property).to be_required
    end
  end
end
