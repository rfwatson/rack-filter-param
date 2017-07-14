module Rack
  module FilterParam
    class Middleware
      def initialize(app, *filters)
        @app = app
        @filters = filters.flatten.map(&Filter.public_method(:new))
      end

      def call(env)
        request = Request.new(env)

        @filters.each { |filter| ApplyFilter.new(filter, request).call }
        @app.call(env)
      end
    end
  end
end
