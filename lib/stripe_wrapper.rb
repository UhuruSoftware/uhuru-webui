require 'sinatra'
require 'stripe'
require 'yaml'

config_file = File.expand_path("../../config/uhuru-webui.yml", __FILE__)
config = Uhuru::Webui::Config.from_file(config_file)

set :publishable_key, config[:stripe][:publishable_key]
set :secret_key, config[:stripe][:secret_key]

Stripe.api_key = settings.secret_key

class StripeWrapper

  @billing_bindings_file = File.expand_path("../../billing_cache/billing_bindings.yml", __FILE__)
  @billing_bindings = YAML.load_file(@billing_bindings_file)

  def self.add_billing_binding(cc_user_guid, stripe_customer_id, card_id)
    bindings = @billing_bindings["bindings"] || []
    bindings << {"cc_user_guid" => cc_user_guid, "stripe_customer_id" => stripe_customer_id, "stripe_card_id" => card_id, "org_guid" => nil}
    @billing_bindings["bindings"] = bindings
    File.write(@billing_bindings_file, @billing_bindings.to_yaml)
  end

  def self.create_customer(email, token)
    customer = Stripe::Customer.create(
        :email => email,
        :card  => token
    )
    customer
  end

end

