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
        card = ::Stripe::Customer.retrieve(customer_id).cards.data[0]
        credit_card = CreditCard.new(card.last4, card.type, card.name, card.exp_month, card.exp_year)
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

    def update_credit_card_org(username, org_guid)
      customer = create_customer(username, org_guid)
      delete_credit_card_org(org_guid)
      add_billing_binding(customer, org_guid)
    end

    def delete_credit_card_org(org_guid)
      customer_id = @data['bindings'][org_guid]
      if customer_id
        customer = ::Stripe::Customer.retrieve(customer_id)

        if customer
          card = customer.cards.data[0]
          if card
            card.delete()
          end

          customer.delete()
        end
      end

      delete_billing_binding(org_guid)
    end
  end
end