require "rack/filter_param/version"

module Rack
  class FilterParam
    ACTION_DISPATCH_KEY = 'action_dispatch.request.request_parameters'.freeze
    FILTERED_PARAMS_KEY = 'rack.filtered_params'.freeze

    def initialize(app, *params)
      @app = app
      @params = params.flatten
    end

    def call(env)
      @request = Rack::Request.new(env)
      @params.each { |param| process_param(param) }

      @app.call(env)
    end

    private

    attr_reader :request

    def process_param(param)
      return unless path_matches?(param)
      return unless param_exists?(param)
      return unless affirmative_conditional?(param)

      param = param[:param] if param.is_a?(Hash)

      if delete_from_action_dispatch(param) || delete_from_request(param)
        filtered_params << [ param.to_s, nil ]
      end
    end

    def path_matches?(param)
      return true unless param.is_a?(Hash)

      path = param[:path]
      return true unless path = param[:path]

      return request.env['PATH_INFO'] == path if path.is_a?(String)
      return request.env['PATH_INFO'] =~ path if path.is_a?(Regexp)

      false
    end

    def param_exists?(param)
      param = param.is_a?(Hash) ? param[:param] : param
      params.has_key?(param.to_s)
    end

    def params
      action_dispatch_parsed? ? action_dispatch_params : request.params
    end

    def affirmative_conditional?(param)
      return true unless param.is_a?(Hash)

      callable, param = param[:if], param[:param]
      return true if callable.nil?

      callable.call(params[param.to_s])
    end

    def delete_from_action_dispatch(param)
      action_dispatch_parsed? && !!action_dispatch_params.delete(param.to_s)
    end

    def delete_from_request(param)
      !!request.delete_param(param.to_s)
    end

    def action_dispatch_params
      request.env[ACTION_DISPATCH_KEY]
    end

    def action_dispatch_parsed?
      !action_dispatch_params.nil?
    end

    def filtered_params
      request.env[FILTERED_PARAMS_KEY] ||= []
    end
  end
end
