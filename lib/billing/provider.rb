
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

    def self.months
      months = []

      current_month = Date.today.strftime("%m").to_i
      [{:name => 'January', :value => 1},
       {:name => 'February', :value => 2},
       {:name => 'March', :value => 3},
       {:name => 'April', :value => 4},
       {:name => 'May', :value => 6},
       {:name => 'June', :value => 6},
       {:name => 'July', :value => 7},
       {:name => 'August', :value => 8},
       {:name => 'September', :value => 9},
       {:name => 'October', :value => 10},
       {:name => 'November', :value => 11},
       {:name => 'December', :value => 12}].each do |month|
        months.push(month)
      end

      months
    end

    def self.years
      years = []

      current_year = Date.today.strftime("%Y").to_i
      y = current_year
      #max credit card lifespan is in 20 - 25 years
      while y <= current_year + 30 do
        years.push(y)
        y += 1
      end

      years
    end

    def self.countries
      list = File.open($config[:countries_file], "rb").read
      countries = list.split(';')
      countries
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

    def update_credit_card_org(username, token, org_guid)
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
      if @data["bindings"].delete(org_guid)
        File.write(@data_file, @data.to_yaml)
      end
    rescue => e
      raise "Unable to remove credit card binding: #{e.message}:#{e.backtrace}"
    end

  end

  class CreditCard
    attr_reader :last4, :type, :name, :exp_month, :exp_year, :address_street, :address_city, :address_state, :address_zip, :address_country

    def initialize(last4, type, name, exp_month, exp_year, address_street = nil, address_city = nil, address_state = nil, address_zip = nil, address_country = nil)
      @last4 = last4
      @type = type
      @name = name
      @exp_month = exp_month
      @exp_year = exp_year
      @address_street = address_street
      @address_city = address_city
      @address_state = address_state
      @address_zip = address_zip
      @address_country = address_country
    end
  end
end
