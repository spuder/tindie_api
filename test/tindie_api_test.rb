require "test_helper"
require 'webmock/minitest'
require 'json'
require_relative '../lib/tindie_api'

class TindieApiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TindieApi::VERSION
  end

  def setup
    @username = ENV['TINDIE_USERNAME']
    @api_key = ENV['TINDIE_API_KEY']
    @api = TindieApi::TindieOrdersAPI.new(@username, @api_key)
  end

  def test_initialize
    assert_equal @username, @api.instance_variable_get(:@usr)
    assert_equal @api_key, @api.instance_variable_get(:@api)
    assert_equal({ false => nil, true => nil, nil => nil }, @api.instance_variable_get(:@cache))
  end

  def test_get_orders_json
    stub_request = stub_request(:get, "https://www.tindie.com/api/v1/order/?format=json&api_key=#{@api_key}&username=#{@username}")
    stub_request.to_return(body: '{"orders": []}')
    response = @api.get_orders_json
    assert_equal({"orders" => []}, response)
  end

  def test_get_orders_json_with_shipped
    stub_request = stub_request(:get, "https://www.tindie.com/api/v1/order/?format=json&api_key=#{@api_key}&username=#{@username}&shipped=true")
    stub_request.to_return(body: '{"orders": []}')
    response = @api.get_orders_json(true)
    assert_equal({"orders"=>[]}, response)
  end

  def test_get_orders_json_with_pagination
    stub_request = stub_request(:get, "https://www.tindie.com/api/v1/order/?format=json&api_key=#{@api_key}&username=#{@username}&limit=50&offset=0")
    stub_request.to_return(body: '{"orders": [], "meta": {"next": null}}')
    response = @api.get_orders_json(nil, 50, 0)
    assert_equal({"orders" => [], "meta" => {"next" => nil}}, response)
  end

  def test_get_orders_json_with_error
    stub_request = stub_request(:get, "https://www.tindie.com/api/v1/order/?format=json&api_key=#{@api_key}&username=#{@username}")
    stub_request.to_return(status: 500, body: 'Error')
    assert_raises(JSON::ParserError) { @api.get_orders_json }
  end

  def test_get_orders_json_returns_empty_hash
    stub_request = stub_request(:get, "https://www.tindie.com/api/v1/order/?format=json&api_key=#{@api_key}&username=#{@username}")
    stub_request.to_return(body: '{}')
    response = @api.get_orders_json
    assert_equal({}, response)
  end

  def test_get_orders_json_returns_non_valid_json
    stub_request = stub_request(:get, "https://www.tindie.com/api/v1/order/?format=json&api_key=#{@api_key}&username=#{@username}")
    stub_request.to_return(body: 'Invalid JSON')
    assert_raises(JSON::ParserError) { @api.get_orders_json }
  end

  def test_get_orders_json_returns_empty_array
    stub_request = stub_request(:get, "https://www.tindie.com/api/v1/order/?format=json&api_key=#{@api_key}&username=#{@username}")
    stub_request.to_return(body: '[]')
    response = @api.get_orders_json
    assert_equal([], response)
  end

  def test_get_orders_json_with_empty_response
    stub_request = stub_request(:get, "https://www.tindie.com/api/v1/order/?format=json&api_key=#{@api_key}&username=#{@username}")
    stub_request.to_return(body: '')
    assert_raises(JSON::ParserError) { @api.get_orders_json }
  end

  def test_tindie_order_initialization
    mock_order_data = {
      'date' => '2025-01-01T15:59:18Z',
      'date_shipped' => nil,
      'shipped' => false,
      'items' => [],
      'number' => '12345',
      'email' => 'test@example.com',
      'shipping_name' => 'Test Name',
      'shipping_street' => '123 Test St',
      'shipping_city' => 'Test City',
      'shipping_state' => 'TS',
      'shipping_country' => 'Test Country',
      'shipping_postcode' => '12345',
      'total_seller' => '100.00',
      'total_shipping' => '10.00',
      'total_subtotal' => '90.00',
      'total_tindiefee' => '5.00',
      'total_ccfee' => '2.00'
    }
  
    order = TindieApi::TindieOrder.new(mock_order_data)
  
    assert_equal false, order.shipped
    assert_nil order.date_shipped
    assert_equal '12345', order.order_number
    assert_equal 'test@example.com', order.recipient_email
  end
end