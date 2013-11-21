
module Uhuru
  module Webui
    module Billing

    end
  end
end

module Uhuru::Webui::Billing
  #Generic class for billing providers
  class Provider

    # List of existing providers
    def self.providers
      {
          :none => "None",
          :stripe => "Stripe"
      }
    end

    # Includes the classes for all providers
    providers.each do |provider, _|
      require "billing/#{provider.to_s}"
    end

    # Defines the current billing provider used for the deployment
    def self.provider
      billing_provider = $config[:billing][:provider]
      @current_provider = @current_provider || billing_provider

      if (@provider == nil) || (@current_provider != billing_provider)
        @current_provider = billing_provider
        @provider = case @current_provider
                      when 'stripe' then Stripe.new
                      else None.new
                    end
      end
      @provider
    end

    # Provides a list of months for expiration credit card month
    def self.months
      months = []

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

    # Provides a list of years for expiration credit card year, max credit card lifespan is in 20 - 25 years
    def self.years
      years = []

      current_year = Date.today.strftime("%Y").to_i
      year = current_year
      while year <= current_year + 30 do
        years.push(year)
        year += 1
      end

      years
    end

    # Provides a list of countries for owner credit card country
    def self.countries
      list = File.open($config[:countries_file], "rb").read
      countries = list.split(';')
      countries
    end

    # Loads the file that contains binding between billing provider customer id and organization
    def initialize
      @data = {}
      @data_file = $config[:billing_data][:connection]

      @data = YAML.load_file(@data_file) if File.exist?(@data_file)

      @data["bindings"] = {} unless @data.has_key?("bindings")
    end

    # Adds a binding between billing provider customer id and organization
    # customer_id = billing provider customer id
    # org_guid = organization guid
    #
    def add_billing_binding(customer_id, org_guid)
      raise "Not implemented!"
    end

    # Reads the billing binding corresponding to organization guid
    # org_guid = organization guid
    #
    def read_credit_card_org(org_guid)
      raise "Not implemented!"
    end

    # Updates credit card information on billing provider side
    # org_guid = organization guid
    # token = the token from billing provider used for updating credit card info
    #
    def update_credit_card(org_guid, token)
      raise "Not implemented!"
    end

    # Deletes credit card on billing provider side and from the billing bindings file
    # org_guid = organization guid
    #
    def delete_credit_card_org(org_guid)
      raise "Not implemented!"
    end

    # Creates the customer on billing provider side
    # email = customer email
    # token = the token from billing provider used to create customer
    #
    def create_customer(email, token)
      raise "Not implemented!"
    end

    protected

    # Saves binding between billing provider customer id and organization in the billing bindings file
    # customer_id = billing provider customer id
    # org_guid = organization guid
    #
    def save_billing_binding(customer_id, org_guid)
      @data["bindings"][org_guid] = customer_id
      File.write(@data_file, @data.to_yaml)
    rescue => ex
      raise "Unable to add credit card binding: #{ex.message}:#{ex.backtrace}"
    end

    # Removes the billing binding from the billing bindings file based on organization guid
    # org_guid = organization guid
    #
    def delete_billing_binding(org_guid)
      if @data["bindings"].delete(org_guid)
        File.write(@data_file, @data.to_yaml)
      end
    rescue => ex
      raise "Unable to remove credit card binding: #{ex.message}:#{ex.backtrace}"
    end

  end

  # Data holder for the tile displayed in organization/credit cards tab
  #
  # last4 = last 4 numbers from credit card number
  # type = credit card type
  # name = name of the credit card's owner
  # exp_month = expiration month of the credit card
  # exp_year = expiration year of the credit card
  # address_street = street of the credit card's owner
  # address_city = city of the credit card's owner
  # address_state = state of the credit card's owner
  # address_zip = zip code of the credit card's owner
  # address_country = country of the credit card's owner
  #
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
