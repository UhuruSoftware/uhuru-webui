require 'sinatra'
require 'stripe'
require 'yaml'
require 'billing/provider'

module Uhuru::Webui::Billing

  class None < Provider

    def read_credit_card_org(org_guid)
    end

    def create_customer(email, token)
    end

    def add_billing_binding(customer_id, org_guid)
    end

    def update_credit_card(org_guid, token)
    end

    def delete_credit_card_org(org_guid)
    end

  end
end