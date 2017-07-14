require 'rack/filter_param/version'
require 'rack/filter_param/middleware'
require 'rack/filter_param/filter'
require 'rack/filter_param/apply_filter'

module Rack
  module FilterParam
    ACTION_DISPATCH_KEY = 'action_dispatch.request.request_parameters'.freeze
    FILTERED_PARAMS_KEY = 'rack.filtered_params'.freeze

    extend SingleForwardable
    def_delegators :'Rack::FilterParam::Middleware', :new
  end
end
