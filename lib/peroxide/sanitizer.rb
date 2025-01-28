# frozen_string_literal: true

require 'rack/utils'
require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'

require_relative 'property/array'
require_relative 'property/boolean'
require_relative 'property/date'
require_relative 'property/datetime'
require_relative 'property/enum'
require_relative 'property/float'
require_relative 'property/integer'
require_relative 'property/no_content'
require_relative 'property/object'
require_relative 'property/string'

module Peroxide
  class Sanitizer
    class Failed < Error; end
    class InvalidStatusCode < Error; end

    def self.action(name)
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

      @actions[@current_action][:response][http_code(code)] = @properties
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
      action = params['action'].to_sym
      properties = @actions[action][:request]
      return Peroxide::Property.sanitize!(params, properties) if properties.present?

      raise Failed, "Properties for '#{action}' request are missing"
    end

    def self.sanitize_response!(params, code)
      action = params['action'].to_sym
      properties = @actions[action][:response][http_code(code)]
      return Peroxide::Property.sanitize!(params, properties) if properties.present?

      raise Failed, "Properties for '#{action}' response #{code} are missing"
    end

    def self.placeholder_response!(action, code)
      properties = @actions[action.to_sym][:response][http_code(code)]
      return nil if properties.length == 1 && properties.first.is_a?(Peroxide::Property::NoContent)

      {}.tap do |values|
        properties.each do |property|
          values[property.name] = property.send(:random_value)
        end
      end
    end

    def self.array(name, length: nil, required: false)
      old_parent = @parent
      @parent = register_property(Peroxide::Property::Array.new(name, length:, required:))

      yield if block_given?
      @parent = old_parent
    end

    def self.boolean(name, required: false)
      register_property(Peroxide::Property::Boolean.new(name, required:))
    end

    def self.date(name, range: nil, required: false)
      register_property(Peroxide::Property::Date.new(name, required:, range:))
    end

    def self.datetime(name, range: nil, required: false)
      register_property(Peroxide::Property::Datetime.new(name, required:, range:))
    end

    def self.enum(name, required: false, values: [])
      register_property(Peroxide::Property::Enum.new(name, values, required:))
    end

    def self.float(name, range: nil, required: false)
      register_property(Peroxide::Property::Float.new(name, range:, required:))
    end

    def self.integer(name, range: nil, required: false)
      register_property(Peroxide::Property::Integer.new(name, range:, required:))
    end

    def self.no_content
      register_property(Peroxide::Property::NoContent.new)
    end

    def self.object(name, required: false)
      old_parent = @parent
      @parent = register_property(Peroxide::Property::Object.new(name, required:))

      yield if block_given?
      @parent = old_parent
    end

    def self.string(name, length: nil, required: false)
      register_property(Peroxide::Property::String.new(name, length:, required:))
    end

    def self.http_code(code)
      code = code.to_i
      raise InvalidStatusCode, "Invalid status code: #{code}" if code < 100 || code > 599

      code
    end
  end
end
