require "test_helper"
require 'webmock/minitest'

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
    # puts "TINDIE_USERNAME: #{ENV['TINDIE_USERNAME']}"
    # puts "TINDIE_API_KEY: #{ENV['TINDIE_API_KEY']}"
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
  
    assert_raises(JSON::ParserError) do
      @api.get_orders_json
    end
  end
  
  
  # def test_get_orders_json_returns_nil
  #   stub_request = stub_request(:get, "https://www.tindie.com/api/v1/order/?format=json&api_key=#{@api_key}&username=#{@username}")
  #   stub_request.to_return(body: '')
  
  #   assert_nil(@api.get_orders_json)
  # end

end
