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
    orders = @api.get_all_orders(false)

    puts orders.inspect

    erb :orders, locals: { orders: orders }
end
```

Note that the Tindie api uses pagination with 20 items (default) and 50 items (max). 

There are 3 ways to get orders depending on the level of abstraction you desire

- `get_orders` (Returns TindieAPI Objects)  
- `get_orders_json` (Returns Json)  
- `get_all_orders` (Returns TindieAPI Objects)  

## Examples

See this git repo for additional examples

[spuder/packpoint](https://github.com/spuder/packpoint)