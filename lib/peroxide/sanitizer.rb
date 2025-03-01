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

    def self.action(name)
      raise Util::InvalidAction, "Action '#{name}' is invalid" if !name || name.empty? || !name.respond_to?(:to_sym)

      @actions ||= {}

      @current_action = name.to_sym
      @actions[@current_action] = {
        request: [],
        response: {}
      }

      yield if block_given?
    end

    def self.request
      @properties = []
      yield if block_given?

      @actions[@current_action][:request] = @properties
    end

    def self.response(code)
      @properties = []
      yield if block_given?

      @actions[@current_action][:response][Util.http_code(code)] = @properties
    end

    def self.register_property(property)
      if !@parent
        @properties << property
      elsif @parent.respond_to?(:add_child)
        @parent.add_child(property)
      elsif @parent.respond_to?(:item_property=)
        @parent.item_property = property
      end

      property
    end

    def self.sanitize_request!(params)
      properties = Util.request_properties_for(@actions, params)
      {}.tap do |values|
        properties.each do |property|
          values[property.name] = property.validate!(params[property.name])
        end
      end
    end

    def self.sanitize_response!(params, code)
      {}.tap do |values|
        Util.response_properties_for(@actions, params, code).each do |property|
          values[property.name] = property.validate!(params[property.name])
        end
      end
    end

    def self.placeholder_response!(params, code)
      properties = Util.response_properties_for(@actions, params, code)
      return nil if properties.length == 1 && properties.first.is_a?(Peroxide::Property::NoContent)

      {}.tap do |values|
        properties.each do |property|
          values[property.name] = property.placeholder
        end
      end
    end

    def self.array(name = nil, length: nil, required: false)
      old_parent = @parent
      @parent = register_property(Peroxide::Property::Array.new(name, length:, required:))
      property = @parent
      @array_root = true

      yield if block_given?
      @array_root = false
      @parent = old_parent

      property
    end

    def self.boolean(name = nil, required: false)
      register_property(Peroxide::Property::Boolean.new(name, required:, array_root: @array_root))
    end

    def self.date(name = nil, range: nil, required: false)
      register_property(Peroxide::Property::Date.new(name, required:, range:, array_root: @array_root))
    end

    def self.datetime(name = nil, range: nil, required: false)
      register_property(Peroxide::Property::Datetime.new(name, required:, range:, array_root: @array_root))
    end

    def self.enum(name = nil, values, required: false)
      register_property(Peroxide::Property::Enum.new(name, values, required:, array_root: @array_root))
    end

    def self.float(name = nil, range: nil, required: false)
      register_property(Peroxide::Property::Float.new(name, range:, required:, array_root: @array_root))
    end

    def self.integer(name = nil, range: nil, required: false)
      register_property(Peroxide::Property::Integer.new(name, range:, required:, array_root: @array_root))
    end

    def self.id(name = nil, required: false)
      register_property(Peroxide::Property::Id.new(name, required:, array_root: @array_root))
    end

    def self.uuid(name = nil, required: false)
      register_property(Peroxide::Property::UuidV4.new(name, required:, array_root: @array_root))
    end

    def self.no_content
      register_property(Peroxide::Property::NoContent.new)
    end

    def self.object(name = nil, required: false)
      old_parent = @parent
      @parent = register_property(Peroxide::Property::Object.new(name, required:, array_root: @array_root))
      property = @parent
      yield if block_given?
      @parent = old_parent
      property
    end

    def self.string(name = nil, length: nil, required: false)
      register_property(Peroxide::Property::String.new(name, length:, required:, array_root: @array_root))
    end
  end
end
