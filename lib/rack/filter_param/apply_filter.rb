module Rack
  class ApplyFilter
    extend Forwardable

    def initialize(filter, request)
      @filter  = filter
      @request = request
    end

    def call
      return unless param_exists?
      return unless path_matches?
      return unless if_proc_affirmative?

      if delete_from_action_dispatch || delete_from_request
        filtered_params << [ param, nil ]
      end
    end

    private
    attr_reader :filter, :request

    def_delegators :@filter, :param, :path, :if_proc
    def_delegators :@request, :env

    def params
      action_dispatch_parsed? ? action_dispatch_params : request.params
    end

    def param_exists?
      params.has_key?(param)
    end

    def param_value
      params[param]
    end

    def action_dispatch_params
      env[FilterParam::ACTION_DISPATCH_KEY]
    end

    def action_dispatch_parsed?
      !action_dispatch_params.nil?
    end

    def path_matches?
      return true if path.nil?

      return env['PATH_INFO'] == path if path.is_a?(String)
      return env['PATH_INFO'] =~ path if path.is_a?(Regexp)

      false
    end

    def if_proc_affirmative?
      return true if if_proc.nil?

      if_proc.call(param_value)
    end

    def delete_from_action_dispatch
      action_dispatch_parsed? && !!action_dispatch_params.delete(param)
    end

    def delete_from_request
      !!request.delete_param(param)
    end

    def filtered_params
      env[FilterParam::FILTERED_PARAMS_KEY] ||= []
    end
  end
end
