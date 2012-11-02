$:.unshift(File.join(File.dirname(__FILE__)))

require 'uhuru_config'
require 'httparty'

class CreditCards
  include HTTParty

  attr_accessor :auth_token, :base_path

  def initialize(token)
    UhuruConfig.load
    @auth_token = token
    @base_path = UhuruConfig.cloud_controller_api + '/v2/credit_cards'
  end

  def read_all
    headers = {'Content-Type' => 'text/html;charset=utf-8', 'Authorization' => @auth_token}

    response = get("#{@base_path}", :headers => headers)
    credit_card_list = []

    if response.request.last_response.code == '200'
      JSON.parse(response).each do |item|
        credit_card = CreditCard.from_json! item.to_json
        credit_card_list << credit_card
      end
    end

    return credit_card_list
  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  def read_card_by_id(card_id)
    headers = {'Content-Type' => 'text/html;charset=utf-8', 'Authorization' => @auth_token}
    response = get("#{@base_path}/#{card_id}", :headers => headers)

    if response.request.last_response.code == '200'
      return CreditCard.from_json! response.body
    end

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  def create(user_guid, user_email, first_name, last_name, card_number, expiration_year, expiration_month, card_type, cvv, address = nil, address2 = nil, city = nil, state = nil, zip = nil, country = nil)
    headers = {'Content-Type' => 'application/json', 'Authorization' => @auth_token}

    attributes = {:reference => user_guid, :email => user_email, :first_name => first_name, :last_name => last_name, :full_number => card_number, :expiration_year => expiration_year,
                  :expiration_month => expiration_month, :card_type => card_type, :cvv => cvv, :billing_address => address, :billing_address_2 => address2, :billing_city => city,
                  :billing_state => state, :billing_zip => zip, :billing_country => country}

    response = post("#{@base_path}", :headers => headers, :body => attributes)
    return true if response.request.last_response.code == '200'

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  def delete_by_id(card_id)
    headers = {'Content-Type' => 'application/json', 'Authorization' => @auth_token}
    response = delete("#{@base_path}/v2/credit_cards/#{card_id}", :headers => headers)
    return true if response.request.last_response.code == '200'

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  private

  def post(path, options={})
    jsonify_body!(options)
    self.class.post(path, options)
  end

  def delete(path, options={})
    jsonify_body!(options)
    self.class.delete(path, options)
  end

  def get(path, options={})
    jsonify_body!(options)
    self.class.get(path, options)
  end

  def jsonify_body!(options)
    options[:body] = options[:body].to_json if options[:body]
  end

end

class CreditCard

  class << self

  attr_accessor :id, :first_name, :last_name, :masked_card_number, :expiration_month, :expiration_year, :card_type,
              :billing_address, :billing_address_2, :billing_city, :billing_state, :billing_zip, :billing_country

  end

  attr_accessor :id, :first_name, :last_name, :masked_card_number, :expiration_month, :expiration_year, :card_type,
              :billing_address, :billing_address_2, :billing_city, :billing_state, :billing_zip, :billing_country

  def initialize(id, first_name, last_name, masked_card_number, expiration_month, expiration_year, card_type,
      billing_address = nil, billing_address_2 = nil, billing_city = nil, billing_state = nil, billing_zip = nil,
      billing_country = nil)

    @id = id
    @first_name = first_name
    @last_name = last_name
    @masked_card_number = masked_card_number
    @expiration_month = expiration_month
    @expiration_year = expiration_year
    @billing_address = billing_address
    @billing_address_2 = billing_address_2
    @billing_city = billing_city
    @billing_state = billing_state
    @billing_zip = billing_zip
    @billing_country = billing_country
    @card_type = card_type
  end

  def self.from_json! string
    JSON.load(string).each do |var, val|
      self.instance_variable_get '@'+var
      self.instance_variable_set '@'+var, val
    end

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end
end
