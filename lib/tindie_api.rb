require "tindie_api/version"
require 'net/http'
require 'json'
require 'date'

module TindieApi
  class Error < StandardError; end

  # Constants
  EXPIRES_TIME = 3600 # 3600s = 1h

  class TindieProduct
    attr_reader :json_parsed, :model, :options, :qty, :sku, :unit_price, :price, :name

    def initialize(data)
      @json_parsed = data
      @model = data['model_number']
      @options = data['options']
      @qty = data['quantity']
      @sku = data['sku']
      @unit_price = data['price_unit']
      @price = data['price_total']
      @name = data['product']
    end
  end

  class TindieOrder
    attr_reader :json_parsed, :date, :date_shipped, :products, :shipped, :refunded, :order_number,
                :recipient_email, :recipient_phone, :address_dict, :address_str, :seller_payout,
                :shipping_cost, :subtotal, :tindie_fee, :cc_fee, :tracking_code, :tracking_url

    def initialize(data)
      @json_parsed = data
      @date = DateTime.parse(data['date'])
      @date_shipped = DateTime.parse(data['date_shipped'])
      @products = data['items'].map { |i| TindieProduct.new(i) }
      @shipped = data['shipped']
      @refunded = data['refunded']
      @order_number = data['number']
      @recipient_email = data['email']
      @recipient_phone = data['phone']
      @address_dict = {
        city: data['shipping_city'],
        country: data['shipping_country'],
        recipient_name: data['shipping_name'],
        instructions: data['shipping_instructions'],
        postcode: data['shipping_postcode'],
        service: data['shipping_service'],
        state: data['shipping_state'],
        street: data['shipping_street']
      }
      @address_str = "#{data['shipping_name']}\n#{data['shipping_street']}\n" \
                     "#{data['shipping_city']} #{data['shipping_state']} #{data['shipping_postcode']}\n" \
                     "#{data['shipping_country']}"
      @seller_payout = data['total_seller']
      @shipping_cost = data['total_shipping']
      @subtotal = data['total_subtotal']
      @tindie_fee = data['total_tindiefee']
      @cc_fee = data['total_ccfee']
      if @shipped
        @tracking_code = data['tracking_code']
        @tracking_url = data['tracking_url']
      end
    end
  end

  class TindieOrdersAPI
    def initialize(username, api_key)
      @usr = username
      @api = api_key
      @cache = { false => nil, true => nil, nil => nil }
    end

    def get_orders_json(shipped = nil)
      url = "https://www.tindie.com/api/v1/order/?format=json&api_key=#{@api}&username=#{@usr}"
      url += "&shipped=#{shipped}" unless shipped.nil?
      uri = URI(url)
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end

    def get_orders(shipped = nil)
      raise ArgumentError, "shipped must be true, false, or nil" if !shipped.nil? && ![true, false].include?(shipped)
      result = get_orders_json(shipped)['orders'].map { |i| TindieOrder.new(i) }
      @cache[shipped] = [Time.now + EXPIRES_TIME, result]
      result
    end

    def _get_cache_(shipped = nil)
      elem = @cache[shipped]
      return get_orders(shipped) if elem.nil? || elem[0] < Time.now
      elem[1]
    end

    def get_last_order
      _get_cache_.first
    end

    def average_order_revenue(limit = 20)
      orders = _get_cache_.take(limit)
      orders.sum(&:seller_payout) / orders.size.to_f
    end

    def average_order_shipping(limit = 20)
      orders = _get_cache_.take(limit)
      orders.sum(&:shipping_cost) / orders.size.to_f
    end

    def average_order_timedelta(limit = 20)
      orders = _get_cache_.take(limit + 1)
      total_time = orders.each_cons(2).sum { |a, b| a.date - b.date }
      total_time / [limit, orders.size - 1].min
    end
  end
end
