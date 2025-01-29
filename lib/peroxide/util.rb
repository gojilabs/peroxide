module Peroxide
  module Util
    class InvalidAction < Error; end
    class InvalidStatusCode < Error; end

    def self.action_name(params)
      action = params['action']
      return action.to_sym if action.respond_to?(:to_sym) && action.respond_to?(:empty?) && !action.empty?

      raise InvalidAction, "Action '#{action}' is invalid"
    end

    def self.http_code(code)
      code = code.to_i
      raise InvalidStatusCode, "Invalid status code: #{code}" if code < 100 || code > 599

      code
    end

    def self.response_properties_for(actions, params, code)
      actions[Util.action_name(params)][:response][Util.http_code(code)]
    end

    def self.request_properties_for(actions, params)
      actions[Util.action_name(params)][:request]
    end
  end
end
