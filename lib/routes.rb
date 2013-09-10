require 'cfoundry'
require 'config'

module Library
  class Routes

    def initialize(token, target)
      @client = CFoundry::V2::Client.new(target, token)
    end

    def initialize_with_client(client)
      @client = client
    end

    def self.initialize_client_for_template_apps(client)
      @client = client
    end

    # will read all routes in space, if domain_guid is specified will filter for the domain given
    def read_routes(space_guid, domain_guid = nil)
      routes = []

      @client.routes.each do |r|
        if (r.space.guid == space_guid)
          if (domain_guid != nil)
            routes << Route.new(r.name, r.guid) if r.domain.guid == domain_guid
          else
            routes << Route.new(r.name, r.guid)
          end
        end
      end

      return routes

    rescue Exception => e
      return e
    end

    # create is used: - to create a route (url) and map it to an app
    #                 - just to map a route (url) to an app if the route exists
    def create(app_name, space_guid, domain_guid, host = nil)
      app = @client.apps.find { |a| a.name == app_name }

      space = @client.space(space_guid)
      domain = @client.domain(domain_guid)

      route = @client.routes.find { |r|
        r.host == host && r.domain == domain && r.space == space
      }
      unless route
        begin
          route = @client.route

          route.host = host if host != nil #app_name if app_name != nil
          route.domain = domain
          route.space = space
          route.create!

        rescue Exception => e
          return e
        end
      end

      app.add_route(route)
      return route
    rescue Exception => e
      return e
    end

    def delete(route_guid)
      route = @client.route(route_guid)
      route.delete!

    rescue Exception => e
      return e
    end

    class Route
      attr_reader :name, :guid

      def initialize(name, guid)
        @name = name
        @guid = guid
      end

    end
  end
end