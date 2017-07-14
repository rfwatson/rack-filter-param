module Rack
  class Filter
    attr_reader :param, :path, :if_proc

    def initialize(options)
      if options.is_a?(Hash)
        @param   = parse_param(options[:param])
        @path    = options[:path]
        @if_proc = options[:if]
      else
        @param   = parse_param(options)
      end
    end

    private

    def parse_param(param)
      param.is_a?(Symbol) ? param.to_s : param
    end
  end
end
