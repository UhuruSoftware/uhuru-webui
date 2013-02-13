require 'config'
require 'chargify_api_ares'

class ChargifyWrapper

  attr_accessor :config

  def self.configure(config)
    @config = config

    Chargify.configure do |conf|
      conf.subdomain = @config[:quota_settings][:billing_provider_domain]
      conf.api_key = @config[:quota_settings][:auth_token]
    end
  end

  def self.get_product_by_handle(handle = "paid")
    product = Chargify::Product.find_by_handle(handle)
    return product.id if product != nil
  end

  def self.subscription_exists?(reference)
    subscription = Chargify::Subscription.find_by_customer_reference(reference)

    return subscription != nil
  end

  def self.get_subscription_card_type_and_number(org_guid, billing_manager_guid)
    reference = "#{billing_manager_guid} #{org_guid}"
    subscription = Chargify::Subscription.find_by_customer_reference(reference)

    return subscription.credit_card.card_type, subscription.credit_card.masked_card_number if subscription != nil
  end

  #returns an array of hashes containing component name and corresponding price
  def self.get_components_with_price
    product = Chargify::Product.find_by_handle("paid")
    product_family_id = product.product_family.id
    components = Chargify::Component.find(:all, :params => { :product_family_id => product_family_id})

    components_price = []
    components.each do |comp|
      components_price << {:name => comp.name, :price => comp.unit_price}
    end

    return components_price

  end

end