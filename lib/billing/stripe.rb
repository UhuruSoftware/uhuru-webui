require 'stripe'

module Uhuru::Webui::Billing

  class Stripe < Provider

    def initialize
      super()

      ::Stripe.api_key = $config[:billing][:options][:secret_key]
    end

    # this is how you read credit card for org
    # card = Uhuru::Webui::Billing::Provider.provider.read_credit_card_org("8826c38c-e191-477a-9829-77ae9c242dec")
    def read_credit_card_org(org_guid)
      customer_id = @data['bindings'][org_guid]
      credit_card = nil

      if customer_id
        card = ::Stripe::Customer.retrieve(customer_id).cards.data[0]
        credit_card = CreditCard.new(card.last4, card.type, card.name, card.exp_month, card.exp_year)
      end

      credit_card
    end

    def create_customer(email, token)
      ::Stripe::Customer.create(
          :email => email,
          :card  => token
      )
    end

    def add_billing_binding(customer_id, org_guid)
      save_billing_binding(customer_id, org_guid)
    end
  end
end