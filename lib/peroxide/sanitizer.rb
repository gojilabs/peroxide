# frozen_string_literal: true

require_relative 'util'
require_relative 'property'
require_relative 'property/array'
require_relative 'property/boolean'
require_relative 'property/date'
require_relative 'property/datetime'
require_relative 'property/enum'
require_relative 'property/float'
require_relative 'property/id'
require_relative 'property/integer'
require_relative 'property/no_content'
require_relative 'property/object'
require_relative 'property/string'
require_relative 'property/uuid_v4'

module Peroxide
  class Sanitizer
    class Failed < Error; end
    class InvalidAction < Error; end
    class InvalidBodyProperties < Error; end
    class InvalidPropertyContainer < Error; end
    class InvalidResponseProperties < Error; end
    class InvalidStatusCode < Error; end
    class InvalidUrlProperties < Error; end

    def self.action(name)
      return nil unless name.respond_to?(:to_sym) && !name.empty?

      @actions ||= {}

      @current_action = name.to_sym
      @actions[@current_action] = {
        request: [],
        response: {}
      }

      yield if block_given?
    end

    def self.request
      @request = {}

      yield if block_given?

      @actions[@current_action][:request] = @request
    end

    def self.body
      @properties = nil
      yield if block_given?
      @request[:body] = @properties
    end

    def self.url
      @properties = nil
      yield if block_given?
      @request[:url] = @properties
    end

    def self.response(code)
      @properties = nil
      yield if block_given?

      http_code = Util.http_code(code)
      raise InvalidStatusCode, "Invalid status code: #{code}" unless http_code

      @actions[@current_action][:response][http_code] = @properties
    end

    def self.register_property(property)
      if @properties.nil?
        if property.name # implicit object container at root, this property is its first child
          @properties = Peroxide::Property::Object.new(nil, required: true)
          @properties.add_child(property)
        else
          @properties = property # root-level singleton property
        end
      elsif @properties.respond_to?(:add_child)
        @properties.add_child(property)
      elsif @properties.respond_to?(:item_property=)
        @properties.item_property = property
      else
        raise InvalidPropertyContainer,
              "Invalid container, property #{@properties.inspect} cannot contain property #{property.inspect}"
      end

      property
    end

    def self.sanitize_body!(params)
      properties = Util.body_properties_for(@actions, params)
      raise InvalidBodyProperties, "No body properties found for action #{@current_action}" unless properties

      properties.validate!(params)
    end

    def self.sanitize_url!(params)
      properties = Util.url_properties_for(@actions, params)
      return if properties.nil?

      properties.validate!(params)
    end

    def self.sanitize_response!(params, action, code)
      properties = Util.response_properties_for(@actions, (params || {}).merge(action:), code)
      unless properties
        raise InvalidResponseProperties,
              "No response properties found for action #{@current_action} and status code #{code}"
      end

      properties.validate!(params)
    end

    def self.placeholder_response!(params, code)
      Util.response_properties_for(@actions, params, code)&.placeholder
    end

    def self.array(name = nil, length: nil, required: false)
      old_properties = @properties
      property = register_property(Peroxide::Property::Array.new(name, length:, required:))
      @properties = property

      yield if block_given?
      @properties = property.name == old_properties&.name ? property : old_properties

      property
    end

    def self.boolean(name = nil, required: false)
      register_property(Peroxide::Property::Boolean.new(name, required:))
    end

    def self.date(name = nil, range: nil, required: false)
      register_property(Peroxide::Property::Date.new(name, required:, range:))
    end

    def self.datetime(name = nil, range: nil, required: false)
      register_property(Peroxide::Property::Datetime.new(name, required:, range:))
    end

    def self.enum(name = nil, values, required: false)
      register_property(Peroxide::Property::Enum.new(name, values, required:))
    end

    def self.float(name = nil, range: nil, required: false)
      register_property(Peroxide::Property::Float.new(name, range:, required:))
    end

    def self.integer(name = nil, range: nil, required: false)
      register_property(Peroxide::Property::Integer.new(name, range:, required:))
    end

    def self.id(name = nil, required: false)
      register_property(Peroxide::Property::Id.new(name, required:))
    end

    def self.uuid(name = nil, required: false)
      register_property(Peroxide::Property::UuidV4.new(name, required:))
    end

    def self.no_content
      register_property(Peroxide::Property::NoContent.new)
    end

    def self.object(name = nil, required: false)
      property = register_property(Peroxide::Property::Object.new(name, required:))
      @properties = property

      yield if block_given?
      @properties = property

      property
    end

    def self.string(name = nil, length: nil, required: false)
      register_property(Peroxide::Property::String.new(name, length:, required:))
    end
  end
end
