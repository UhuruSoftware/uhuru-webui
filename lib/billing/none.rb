require 'sinatra'
require 'stripe'
require 'yaml'
require 'billing/provider'

module Uhuru::Webui::Billing

  # A dummy billing provider, when no real billing provider is used
  class None < Provider

    # Dummy method for reading billing binding from file
    def read_credit_card_org(org_guid)
    end

    # Dummy method to create a customer for billing provider
    def create_customer(email, token)
    end

    # Dummy method to add a billing binding to file
    def add_billing_binding(customer_id, org_guid)
    end

    # Dummy method to update a credit card info
    def update_credit_card(org_guid, token)
    end

    # Dummy method to delete a credit card from billing provider and file
    def delete_credit_card_org(org_guid)
    end

  end
end