# tindie_api

## Description

tindie_api is a Ruby gem that provides a convenient interface for interacting with the Tindie API. This library simplifies the process of managing products, orders, and other Tindie-related operations programmatically.
### Installation
Add this line to your application's Gemfile:
```ruby
gem 'tindie_api'
```
Then execute:
```bash
bundle install
```
Or install it yourself as:
```bash
gem install tindie_api
```
## Usage


Get unshipped orders
```ruby

get "/orders" do
    @username = ENV['TINDIE_USERNAME']
    @api_key = ENV['TINDIE_API_KEY']
    @api = TindieApi::TindieOrdersAPI.new(@username, @api_key)

    # false means unshipped
    orders = @api.get_orders_json(false)

    puts orders.inspect

    erb :orders, locals: { orders: orders }
end
```


## Examples

See this git repo for additional examples

[spuder/packpoint](https://github.com/spuder/packpoint)