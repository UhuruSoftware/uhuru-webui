
module Uhuru
  module Webui
    module Billing

    end
  end
end

module Uhuru::Webui::Billing
  class Provider

    def self.providers
      {
          :none => "None",
          :stripe => "Stripe"
      }
    end

    providers.each do |provider, _|
      require "billing/#{provider.to_s}"
    end

    def self.provider
      @current_provider = @current_provider || $config[:billing][:provider]

      if (@provider == nil) || (@current_provider != $config[:billing][:provider])
        @current_provider = $config[:billing][:provider]
        @provider = case @current_provider
                      when 'stripe' then Stripe.new
                      else None.new
                    end
      end
      @provider
    end

    def initialize
      @data = {}
      @data_file = $config[:billing_data][:connection]

      @data = YAML.load_file(@data_file) if File.exist?(@data_file)

      @data["bindings"] = {} unless @data.has_key?("bindings")
    end

    def add_billing_binding(customer_id, org_guid)
      raise "Not implemented!"
    end

    def read_credit_card_org(org_guid)
      raise "Not implemented!"
    end

    def update_credit_card_org(username, org_guid)
      raise "Not implemented!"
    end

    def delete_credit_card_org(org_guid)
      raise "Not implemented!"
    end

    def create_customer(email, token)
      raise "Not implemented!"
    end

    protected

    def save_billing_binding(customer_id, org_guid)
      @data["bindings"][org_guid] = customer_id
      File.write(@data_file, @data.to_yaml)
    rescue => e
      raise "Unable to add credit card binding: #{e.message}:#{e.backtrace}"
    end

    def delete_billing_binding(org_guid)
      unless @data["bindings"].delete(org_guid)
        File.write(@data_file, @data.to_yaml)
      end
    rescue => e
      raise "Unable to remove credit card binding: #{e.message}:#{e.backtrace}"
    end

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
