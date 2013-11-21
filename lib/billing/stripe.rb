require 'stripe'

module Uhuru::Webui::Billing

  # Implementation for Stripe as a billing provider
  class Stripe < Provider

    # Initializes and adds stripe api key to environment
    def initialize
      super()

      ::Stripe.api_key = $config[:billing][:options][:stripe][:secret_key]
    end

    # Reads credit card info from Stripe based on organization guid
    # returns an CreditCard object containing all info
    # the association is 1->1 (organization -> credit card)
    #
    def read_credit_card_org(org_guid)
      credit_card = nil
      customer_id = @data['bindings'][org_guid]

      if customer_id
        begin
          customer = ::Stripe::Customer.retrieve(customer_id)
          card = customer.cards.retrieve(customer.default_card)
          credit_card = CreditCard.new(card.last4, card.type, card.name, card.exp_month, card.exp_year, card.address_line1, card.address_city, card.address_state, card.address_zip, card.address_country)
        rescue => ex
          $logger.error("Error while trying to receive credit card information: #{ex.message}:#{ex.backtrace}")
        end
      end

      credit_card
    end

    # Creates a customer on stripe based on the token received from UI
    # email = customer email
    # token = the token from billing provider used to create customer
    #
    def create_customer(email, token)
      ::Stripe::Customer.create(
          :email => email,
          :card  => token
      ).id
    end

    # Adds a billing binding between Stripe customer id and organization
    # customer_id = billing provider customer id
    # org_guid = organization guid
    #
    def add_billing_binding(customer_id, org_guid)
      save_billing_binding(customer_id, org_guid)
    end

    # Updates credit card info on Stripe;
    # first adds a new credit card and after deletes the old one
    #
    def update_credit_card(org_guid, token)
      customer_id = @data['bindings'][org_guid]
      if customer_id
        customer = ::Stripe::Customer.retrieve(customer_id)
        customer.cards.create(:card => token)
        old_card = customer.cards.retrieve(customer.default_card)
        old_card.delete()
      else
        raise ArgumentError, "Broken billing binding. Credit Card could not be updated.", caller
      end

    end

    # Deletes credit card and the customer on Stripe
    #
    def delete_credit_card_org(org_guid)
      customer_id = @data['bindings'][org_guid]
      if customer_id
        customer = ::Stripe::Customer.retrieve(customer_id)
        card = customer.cards.retrieve(customer.default_card)
        card.delete()
        customer.delete()

        delete_billing_binding(org_guid)
      else
        raise ArgumentError, "Broken billing binding. Credit Card could not be deleted.", caller
      end

    end
  end
end