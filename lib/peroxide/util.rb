module Peroxide
  module Util
    class InvalidStatusCode < Error; end

    def self.action_name(params)
      action = params[:action] || params['action']
      return action.to_sym if action.respond_to?(:to_sym) && action.respond_to?(:empty?) && !action.empty?

      raise InvalidAction, "Action '#{action}' is invalid"
    end

    def self.http_code(code)
      code = code.to_i
      raise InvalidStatusCode, "Invalid status code: #{code}" if code < 100 || code > 599

      code
    end

    def self.response_properties_for(actions, params, code)
      action_for(actions, params)[:response][Util.http_code(code)]
    end

    def self.body_properties_for(actions, params)
      action_for(actions, params)[:request][:body]
    end

    def self.url_properties_for(actions, params)
      action_for(actions, params)[:request][:url]
    end

    def self.action_for(actions, params)
      action_name = Util.action_name(params)
      actions[action_name.to_sym]
    end
  end
end
