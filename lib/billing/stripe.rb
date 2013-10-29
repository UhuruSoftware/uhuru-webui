require 'stripe'

module Uhuru::Webui::Billing

  class Stripe < Provider

    def initialize
      super()

      ::Stripe.api_key = $config[:billing][:options][:stripe][:secret_key]
    end

    # this is how you read credit card for org
    # card = Uhuru::Webui::Billing::Provider.provider.read_credit_card_org("8826c38c-e191-477a-9829-77ae9c242dec")
    def read_credit_card_org(org_guid)
      credit_card = nil
      customer_id = @data['bindings'][org_guid]

      if customer_id
        customer = ::Stripe::Customer.retrieve(customer_id)
        card = customer.cards.retrieve(customer.default_card)
        credit_card = CreditCard.new(card.last4, card.type, card.name, card.exp_month, card.exp_year, card.address_line1, card.address_city, card.address_state, card.address_zip, card.address_country)
      end

      credit_card
    end

    def create_customer(email, token)
      ::Stripe::Customer.create(
          :email => email,
          :card  => token
      ).id
    end

    def add_billing_binding(customer_id, org_guid)
      save_billing_binding(customer_id, org_guid)
    end

    def update_credit_card(org_guid, token)
      customer_id = @data['bindings'][org_guid]
      if customer_id
        customer = ::Stripe::Customer.retrieve(customer_id)
        customer.cards.create(:card => token)
        old_card = customer.cards.retrieve(customer.default_card)
        old_card.delete()
      else
        raise ArgumentError, "Broken billing binding. Credit Card could not de added.", caller
      end

    end

    def delete_credit_card_org(org_guid)
      customer_id = @data['bindings'][org_guid]
      if customer_id
        customer = ::Stripe::Customer.retrieve(customer_id)
        card = customer.cards.retrieve(customer.default_card)
        card.delete()
        customer.delete()

        delete_billing_binding(org_guid)
      else
        raise ArgumentError, "Broken billing binding. Credit Card could not de deleted.", caller
      end

    end
  end
end