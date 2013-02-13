require 'config'

class BillingHelper
  # To change this template use File | Settings | File Templates.

  def self.initialize(config)
    @component_prices = ChargifyWrapper.get_components_with_price
    @division_factor = config[:quota_settings][:division_factor]
  end

  def self.compute_space_estimated_cost(space)
    apps = space.apps
    service_instances = space.service_instances
    space_cost = 0

    apps.each do |app|
      usage = app.total_instances * app.memory * 720
      price_app_component = (@component_prices.select { |x| x[:name] == "free"}).map { |x| x[:price]}

      space_cost += (((usage / @division_factor).to_i) * price_app_component[0]).to_i
    end

    service_instances.each do |service|
      price_service = (@component_prices.select { |x| x[:name] == service.service_plan.service.label}).map { |x| x[:price]}
      space_cost += (1 * 720 * price_service[0]).to_i
    end

    return space_cost
  end

  def self.compute_org_estimated_cost(org)
    spaces = org.spaces
    org_cost = 0

    spaces.each do |space|
      org_cost += compute_space_estimated_cost(space)
    end

    return org_cost
  end

end