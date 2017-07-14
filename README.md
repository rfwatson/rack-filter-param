# rack-filter-param

Refactoring something behind an API? Plagued by extraneous HTTP params? `rack-filter-param` might be for you.

## What is it?

[Rack](https://github.com/rack/rack) middleware to remove specific params from HTTP requests.

## What does it do?

Given a set of params and optional constraints, `rack-filter-param` will remove those params, then pass the request downstream.

Removes params from:

* GET querystring
* POST params (x-www-form-urlencoded)
* JSON or other params hitherto processed by [`ActionDispatch::ParamsParser`](http://api.rubyonrails.org/classes/ActionDispatch/ParamsParser.html)

## Installation

```ruby

gem 'rack-filter-param', require: 'rack/filter_param'
```

## Usage

In rackup file or `application.rb`, initialize `rack-filter-param` with a list of HTTP params you want filtered from requests.

Strip a parameter named `client_id`:

```ruby
use Rack::FilterParam, :client_id
```

Strip a parameter named `client_id` from a specific path only:

```ruby
use Rack::FilterParam, { param: :client_id, path: '/oauth/tokens' }
```

Strip a parameter named `client_id` from a fuzzy path:

```ruby
use Rack::FilterParam, { param: :client_id, path: /\A\/oauth/ }
```

Strip a parameter named `client_id` based on arbitrary logic:

```ruby
use Rack::FilterParam, { param: :client_id, if: -> (value) { ... } }
```

To filter multiple parameters, an array of parameters or options hashes can also be passed.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rfwatson/rack-filter-param


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

