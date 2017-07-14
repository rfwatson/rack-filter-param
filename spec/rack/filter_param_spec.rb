require "spec_helper"
require 'json'

RSpec.describe Rack::FilterParam do
  let(:path)            { '/' }
  let(:params)          { {} }
  let(:headers)         { {} }
  let(:rack_env)        { {} }
  let(:params_to_test)  {
    last_request.env[Rack::FilterParam::ACTION_DISPATCH_KEY] || last_request.params
  }

  before {
    headers.each { |k, v| header(k.to_s, v) }
    public_send(method, path, params, rack_env)
  }

  shared_context 'middleware with basic filters' do
    let(:app) {
      Rack::Builder.new do
        use Rack::FilterParam, :x, :y
        run -> (env) { [200, {}, ['OK']] }
      end.to_app
    }
  end

  shared_context 'middleware with filtered paths' do
    let(:app) {
      Rack::Builder.new do
        use Rack::FilterParam, [
          { param: :x, path: '/' },
          { param: :y, path: /\A\/something/ }
        ]
        run -> (env) { [200, {}, ['OK']] }
      end.to_app
    }
  end

  shared_context 'middleware with conditional filter' do
    let(:app) {
      Rack::Builder.new do
        use Rack::FilterParam, {
          param: :x,
          if: ->(value) { value == 'yes' }
        }
        run -> (env) { [200, {}, ['OK']] }
      end.to_app
    }
  end

  shared_examples 'core functionality' do
    context 'sending a param that is not expected to be filtered' do
      let(:params) { { 'a' => '1' } }

      it 'does not filter the param' do
        expect(params_to_test).to eq('a' => '1')
      end

      it 'does not include the param in `rack.filtered_params`' do
        expect(last_request.env['rack.filtered_params'])
          .to be nil
      end
    end

    context 'sending a param that is expected to be filtered' do
      let(:params) { { 'x' => '1' } }

      it 'filters the param' do
        expect(params_to_test.keys).to eq []
      end

      it 'includes the param in `rack.filtered_params`' do
        expect(last_request.env['rack.filtered_params'])
          .to eq [['x', nil]]
      end
    end

    context 'sending two params, filtering one' do
      let(:params) { { 'x' => '1', 'a' => '1' } }

      it 'filters the param' do
        expect(params_to_test.keys).to eq ['a']
      end

      it 'includes one param in `rack.filtered_params`' do
        expect(last_request.env['rack.filtered_params'])
          .to eq [['x', nil]]
      end
    end

    context 'sending three params, filtering two' do
      let(:params) { { 'x' => '1', 'y' => '1', 'a' => '1' } }

      it 'filters the params' do
        expect(params_to_test.keys).to eq ['a']
      end

      it 'includes two params in `rack.filtered_params`' do
        expect(last_request.env['rack.filtered_params'])
          .to eq [['x', nil], ['y', nil]]
      end
    end
  end

  shared_examples 'path filtering' do
    let(:params) { { 'x' => '1', 'y' => '1' } }

    context 'when the path is equal to a string' do
      let(:path) { '/' }

      it 'filters the param' do
        expect(params_to_test.keys).to eq ['y']
      end

      it 'includes the param in `rack.filtered_params`' do
        expect(last_request.env['rack.filtered_params'])
          .to eq [['x', nil]]
      end
    end

    context 'when the path matches a regexp' do
      let(:path) { '/something/good' }

      it 'filters the param' do
        expect(params_to_test.keys).to eq ['x']
      end

      it 'includes the param in `rack.filtered_params`' do
        expect(last_request.env['rack.filtered_params'])
          .to eq [['y', nil]]
      end
    end

    context 'when the path does not match' do
      let(:path) { '/wrong' }

      it 'does not filter the param' do
        expect(params_to_test)
          .to eq('x' => '1', 'y' => '1')
      end

      it 'does not include the param in `rack.filtered_params`' do
        expect(last_request.env['rack.filtered_params'])
          .to be nil
      end
    end
  end

  shared_examples 'conditional filtering' do
    context 'when the value should be filtered' do
      let(:params) { { 'x' => 'yes', 'y' => 'no' } }

      it 'filters the param' do
        expect(params_to_test.keys).to eq ['y']
      end

      it 'includes the param in `rack.filtered_params`' do
        expect(last_request.env['rack.filtered_params'])
          .to eq [['x', nil]]
      end
    end

    context 'when the value should not be filtered' do
      let(:params) { { 'x' => 'no', 'y' => 'no' } }

      it 'does not filter the param' do
        expect(params_to_test)
          .to eq('x' => 'no', 'y' => 'no')
      end

      it 'does not include the param in `rack.filtered_params`' do
        expect(last_request.env['rack.filtered_params'])
          .to be nil
      end
    end
  end

  context 'GET request' do
    let(:method) { :get }

    describe 'basic functionality' do
      include_context 'middleware with basic filters'
      include_examples 'core functionality'
    end

    describe 'path filtering' do
      include_context 'middleware with filtered paths'
      include_examples 'path filtering'
    end

    describe 'conditional filtering' do
      include_context 'middleware with conditional filter'
      include_examples 'conditional filtering'
    end
  end

  context 'POST request' do
    let(:method) { :post }

    let(:headers) {
      super().merge(
        'Content-Type' => 'application/x-www-form-urlencoded'
      )
    }

    describe 'basic functionality' do
      include_context 'middleware with basic filters'
      include_examples 'core functionality'
    end

    describe 'path filtering' do
      include_context 'middleware with filtered paths'
      include_examples 'path filtering'
    end

    describe 'conditional filtering' do
      include_context 'middleware with conditional filter'
      include_examples 'conditional filtering'
    end
  end

  context 'Request previously parsed by ActionDispatch::ParamsParser' do
    let(:method) { :post }
    let(:headers) { super().merge('Content-Type' => 'application/json') }
    let(:params) { super().to_json }

    let(:rack_env) {
      { Rack::FilterParam::ACTION_DISPATCH_KEY => params }
    }

    describe 'basic functionality' do
      include_context 'middleware with basic filters'
      include_examples 'core functionality'
    end

    describe 'path filtering' do
      include_context 'middleware with filtered paths'
      include_examples 'path filtering'
    end

    describe 'conditional filtering' do
      include_context 'middleware with conditional filter'
      include_examples 'conditional filtering'
    end
  end
end
