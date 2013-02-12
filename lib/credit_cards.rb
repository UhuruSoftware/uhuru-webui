require 'config'
require 'http_direct_client'

class CreditCards

  attr_accessor :auth_token, :base_path

  def initialize(token, target)
    @auth_token = token
    @base_path = target + '/v2'
    @http_client = HttpDirectClient.new
  end

  def read_all
    headers = {'Content-Type' => 'text/html;charset=utf-8', 'Authorization' => @auth_token}

    response = @http_client.get("#{@base_path}/credit_cards", :headers => headers)

    credit_card_list = []

    if response.request.last_response.code == '200'
      if CreditCardObj.valid_json?(response.body)
        JSON.parse(response.body).each do |item|
          card = item.to_hash

          #for some reason the response from ccng/chargify sometimes has credit_card key and under all the other keys,
          #and sometimes it doesn't. next lines should work for both cases
          if card.has_key?("credit_card")
            credit_card = JSON.parse(card["credit_card"].to_json)
          else
            credit_card = JSON.parse(card.to_json)
          end

          if card.has_key?("id")
            subscription_id = card["id"]
          else
            raise NotFound + "Credit card with no valid subscription"
          end

          card = CreditCardObj.new(subscription_id, credit_card["first_name"], credit_card["last_name"], credit_card["masked_card_number"],
          credit_card["expiration_month"], credit_card["expiration_year"], credit_card["billing_address"], credit_card["billing_address_2"],
          credit_card["billing_city"], credit_card["billing_state"], credit_card["billing_zip"], credit_card["billing_country"],
          credit_card["card_type"])
          #card = CreditCardObj.from_json!(credit_card, subscription_id)
          credit_card_list << card
        end
      end
    end

    return credit_card_list
  rescue Exception => e
    raise "#{e.inspect}"
  end

  def read_card_by_id(card_id)
    headers = {'Content-Type' => 'text/html;charset=utf-8', 'Authorization' => @auth_token}
    response = HttpDirectClient.get("#{@base_path}/credit_cards/#{card_id}", :headers => headers)

    if response.request.last_response.code == '200'
      if CreditCardObj.valid_json?(response.body)
        credit_card = JSON.parse(response.body)
        card = CreditCardObj.new(card_id, credit_card["first_name"], credit_card["last_name"], credit_card["masked_card_number"],
          credit_card["expiration_month"], credit_card["expiration_year"], credit_card["billing_address"], credit_card["billing_address_2"],
          credit_card["billing_city"], credit_card["billing_state"], credit_card["billing_zip"], credit_card["billing_country"],
          credit_card["card_type"])
        return card
        #return CreditCardObj.from_json!(response.body, nil)
      else
        return response.body
      end
    end

  rescue Exception => e
    raise "#{e.inspect}"
  end

  def create(user_guid, user_email, first_name, last_name, card_number, expiration_year, expiration_month, card_type, cvv, address = nil, address2 = nil, city = nil, state = nil, zip = nil, country = nil)
    headers = {'Content-Type' => 'application/json', 'Authorization' => @auth_token}

    # for testing purpose take only last character, to be removed when working with real credit cards
    card_number = card_number[-1, 1]

    attributes = {:reference => user_guid, :email => user_email, :first_name => first_name, :last_name => last_name, :full_number => card_number, :expiration_year => expiration_year,
                  :expiration_month => expiration_month, :card_type => card_type, :cvv => cvv, :billing_address => address, :billing_address_2 => address2, :billing_city => city,
                  :billing_state => state, :billing_zip => zip, :billing_country => country}

    response = HttpDirectClient.post("#{@base_path}/credit_cards", :headers => headers, :body => attributes.to_json)
    return true if response.request.last_response.code == '200'

  rescue Exception => e
    raise "create credit failed" #"#{e.inspect}"
  end

  def delete_by_id(card_id)
    headers = {'Content-Type' => 'application/json', 'Authorization' => @auth_token}
    response = HttpDirectClient.delete("#{@base_path}/credit_cards/#{card_id}", :headers => headers)
    return true if response.request.last_response.code == '200'

  rescue Exception => e
    raise "delete credit failed" #"#{e.inspect}"
  end

  def get_organization_credit_card(org_guid)
    headers = {'Content-Type' => 'text/html;charset=utf-8', 'Authorization' => @auth_token}

    url_param ={:q=>"organization_guid:#{org_guid}"}
    response = HttpDirectClient.get("#{@base_path}/organization_credit_cards", :headers => headers, :query => url_param)

    if response.request.last_response.code == '200'

      if JSON.parse(response.body)["total_results"] > 0
        credit_card_id = JSON.parse(response.body)["resources"][0]["entity"]["credit_card_token"]
        return read_card_by_id(credit_card_id)
      else
        return nil
      end
    end

  end

  def get_org_credit_card_guid(org_guid)
    headers = {'Content-Type' => 'text/html;charset=utf-8', 'Authorization' => @auth_token}

    url_param ={:q=>"organization_guid:#{org_guid}"}
    response = HttpDirectClient.get("#{@base_path}/organization_credit_cards", :headers => headers, :query => url_param)

    if response.request.last_response.code == '200'
      if JSON.parse(response.body)["total_results"] > 0
        relation_id = JSON.parse(response.body)["resources"][0]["metadata"]["guid"]
        return relation_id
      else
        return nil
      end
    end

  end

  #added param if card already exist make update, else create org credit card
  def add_organization_credit_card(org_guid, new_card_id)
    headers = {'Content-Type' => 'application/json', 'Authorization' => @auth_token}

    relation_id = get_org_credit_card_guid(org_guid)

    if relation_id
      attributes = {:credit_card_token => new_card_id}
      response = HttpDirectClient.put("#{@base_path}/organization_credit_cards/#{relation_id}", :headers => headers, :body => attributes.to_json)
    else
      attributes = {:credit_card_token => new_card_id, :organization_guid => org_guid}
      response = HttpDirectClient.post("#{@base_path}/organization_credit_cards", :headers => headers, :body => attributes.to_json)
    end

    return true if response.request.last_response.code == '201'

  rescue Exception => e
    raise "add credit failed" #"#{e.inspect}"
  end

end

class CreditCardObj

  #class << self
  #
  #  attr_accessor :id, :first_name, :last_name, :masked_card_number, :expiration_month, :expiration_year, :card_type,
  #                :billing_address, :billing_address_2, :billing_city, :billing_state, :billing_zip, :billing_country
  #
  #end

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

  #def self.from_json!(string, subscription_id)
  #  JSON.load(string).each do |var, val|
  #    if(var == "id")
  #      self.instance_variable_get '@'+var
  #      self.instance_variable_set '@'+var, subscription_id
  #    else
  #      self.instance_variable_get '@'+var
  #      self.instance_variable_set '@'+var, val
  #    end
  #  end
  #
  #  return self
  #end

  def self.valid_json? json
    begin
      JSON.parse(json)
      return true
    rescue Exception => e
      return false
    end
  end

end
