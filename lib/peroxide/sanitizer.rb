# frozen_string_literal: true

require 'rack'

module Peroxide
  class Sanitizer
    def self.index
      @index = {}
      @action = :index
      yield if block_given?
    end

    def self.show
      @show = {}
      @action = :show
      yield if block_given?
    end

    def self.create
      @create = {}
      @action = :create
      yield if block_given?
    end

    def self.update
      @update = {}
      @action = :update
      yield if block_given?
    end

    def self.destroy
      @destroy = {}
      @action = :destroy
      yield if block_given?
    end

    def self.request
      @properties = []
      yield if block_given?

      ivar = instance_variable_get("@#{@action}")
      ivar['request'] = @properties
      instance_variable_set("@#{@action}", ivar)
    end

    def self.for_status(status)
      @properties = []
      yield if block_given?

      code = status.to_i
      if status.to_s == code.to_s # integer code
        # message = Rack::Utils::HTTP_STATUS_CODES[code]
        symbol = Rack::Utils::SYMBOL_TO_STATUS_CODE_MAP.detect { |k, v| v == code }.first
      else # assuming symbol code
        symbol = status.to_sym
        code = Rack::Utils::SYMBOL_TO_STATUS_CODE_MAP[symbol]
        # message = Rack::Utils::HTTP_STATUS_CODES[code]
      end

      ivar = instance_variable_get("@#{@action}")
      ivar[code.to_s] = @properties
      ivar[symbol.to_s] = @properties
      instance_variable_set("@#{@action}", ivar)
    end

    def self.register_property(property)
      if @parent.blank?
        @properties << property
      elsif @parent.supports_multiple_children?
        @parent.children << property
      elsif @parent.supports_single_child?
        @parent.child = property
      end

      property
    end

    def self.sanitize!(params, behavior = 'request')
      action = params['action']
      action_behaviors = instance_variable_get("@#{action}")
      raise Peroxide::SanitizationFailed, "Action '#{action}' is not supported" if action_behaviors.blank?

      properties = action_behaviors[behavior]
      if properties.blank?
        raise Peroxide::SanitizationFailed,
              "Properties for '#{behavior}' in '#{action}' are missing"
      end

      Peroxide::Property.sanitize_request!(params, properties)
    end

    def self.array(name, length: nil, required: false)
      old_parent = @parent
      @parent = register_property(Peroxide::Property::Array.new(name, length:, required:))

      yield if block_given?
      @parent = old_parent
    end

    def self.boolean(name, optional: false)
      register_property(Peroxide::Property::Boolean.new(name, optional:))
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

    def self.object(name, required: false)
      old_parent = @parent
      @parent = register_property(Peroxide::Property::Object.new(name, required:))

      yield if block_given?
      @parent = old_parent
    end

    def self.string(name, length: nil, required: false)
      register_property(Peroxide::Property::String.new(name, length:, required:))
    end
  end
end
