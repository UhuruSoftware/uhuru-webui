require 'sinatra'
require 'stripe'
require 'yaml'

class StripeWrapper

  @billing_bindings_file = File.expand_path("../../billing_cache/billing_bindings.yml", __FILE__)
  @billing_bindings = YAML.load_file(@billing_bindings_file)

  def self.add_billing_binding(stripe_customer_id, org_guid)
    bindings = @billing_bindings["bindings"] || []
    bindings << {"stripe_customer_id" => stripe_customer_id, "org_guid" => org_guid}
    @billing_bindings["bindings"] = bindings
    File.write(@billing_bindings_file, @billing_bindings.to_yaml)
  rescue => e
    "Unable to add credit card binging: #{e.message}:#{e.backtrace}"
  end

  #this is how you read credit card for org
  #card = StripeWrapper.read_credit_card_org("8826c38c-e191-477a-9829-77ae9c242dec")
  def self.read_credit_card_org(org_guid)
    bindings = @billing_bindings["bindings"] || []
    binding = bindings.select do |b|
      b["org_guid"]== org_guid
    end

    if binding.count() == 1
      card = Stripe::Customer.retrieve(binding[0]["stripe_customer_id"]).cards.data[0]
      credit_card = CreditCard.new(card.last4, card.type, card.name, card.exp_month, card.exp_year)
    end

    credit_card

  rescue => e
    "Unable to read credit card: #{e.message}:#{e.backtrace}"
  end

  def self.create_customer(email, token)
    customer = Stripe::Customer.create(
        :email => email,
        :card  => token
    )
    customer
  rescue => e
    "Unable to create customer and credit card on billing provider side: #{e.message}:#{e.backtrace}"
  end

  class CreditCard
    attr_reader :last4, :type, :name, :exp_month, :exp_year

    def initialize(last4, type, name, exp_month, exp_year)
      @last4 = last4
      @type = type
      @name = name
      @exp_month = exp_month
      @exp_year = exp_year
    end
  end

end

