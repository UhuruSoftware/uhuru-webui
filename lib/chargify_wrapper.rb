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

end