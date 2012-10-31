$:.unshift(File.join(File.dirname(__FILE__)))

require 'uhuru_config'

class CreditCards

  def initialize(token)
    @client = CFoundry::Client.new(UhuruConfig.cloud_controller_api, token)
  end

  def read_all(org_id)
    credit_card_list = []

    credit_cards = @client.credit_cards(org_id)
    credit_cards.each do |cc|
      credit_card_list << CreditCard.new(cc.first_name, cc.last_name, cc.card_number, cc.card_type)
    end

    credit_card_list
  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  def read_card_by_id(card_id)
    cc_billing = @client.credit_card(card_id)

    credit_card = CreditCard.new(cc_billing.first_name, cc_billing.last_name, cc_billing.card_number, cc_billing.card_type)
    credit_card

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  def create(org_guid, first_name, last_name, card_number, expiration_year, expiration_month, cvv, address, address2, city, state, zip, country, card_type)
    org = @client.organization(org_guid)

    credit_card = @client.credit_card
    credit_card.organization = org
    credit_card.first_name = first_name
    credit_card.last_name = last_name
    credit_card.card_number = card_number
    credit_card.expiration_year = expiration_year
    credit_card.expiration_month = expiration_month
    credit_card.cvv = cvv
    credit_card.billing_address = address
    credit_card.billing_address_2 = address2
    credit_card.billing_city = city
    credit_card.billing_state = state
    credit_card.billing_zip = zip
    credit_card.billing_country = country
    credit_card.card_type = card_type

    credit_card.create!

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  def delete(card_id)

    credit_card = @client.credit_card

    credit_card.delete!

  rescue Exception => e
    raise "#{e.inspect}"
    #puts "#{e.inspect}, #{e.backtrace}"
  end

  class CreditCard
    attr_reader :first_name, :last_name, :card_number, :card_type

    def initialize(first_name, last_name, card_number, card_type)
      @first_name = first_name
      @last_name = last_name
      @card_number = card_number
      @card_type = credit_card_type
    end
  end

end