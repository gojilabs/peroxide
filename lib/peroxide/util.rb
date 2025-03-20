module Peroxide
  module Util
    class InvalidStatusCode < Error; end

    def self.action_name(params)
      action = params[:action] || params['action']
      return nil unless action.respond_to?(:to_sym) && action.respond_to?(:empty?) && !action.empty?

      action.to_sym
    end

    def self.http_code(code)
      code = code.to_i
      return nil if code < 100 || code > 599

      code
    end

    def self.response_properties_for(actions, params, code)
      action = action_for(actions, params)
      return nil unless action

      action[:response][Util.http_code(code)]
    end

    def self.body_properties_for(actions, params)
      action = action_for(actions, params)
      return nil unless action

      action[:request][:body]
    end

    def self.url_properties_for(actions, params)
      action = action_for(actions, params)
      return nil unless action

      action[:request][:url]
    end

    def self.action_for(actions, params)
      actions[Util.action_name(params)]
    end
  end
end
