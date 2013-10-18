require 'cfoundry'
require 'config'

module Library
  class Routes

    def initialize(token, target)
      @client = CFoundry::V2::Client.new(target, token)
    end

    # will read all routes in space, if domain_guid is specified will filter for the domain given
    def read_routes(space_guid, domain_guid = nil)
      routes = []

      @client.routes.each do |r|
        if r.space.guid == space_guid
          if domain_guid != nil
            routes << Route.new(r.name, r.guid) if r.domain.guid == domain_guid
          else
            routes << Route.new(r.name, r.guid)
          end
        end
      end

      routes
    end

    # create is used: - to create a route (url) and map it to an app
    #                 - just to map a route (url) to an app if the route exists
    def create(app_guid, space_guid, domain_guid, host = nil)
      app = @client.app(app_guid)
      space = @client.space(space_guid)
      domain = @client.domain(domain_guid)

      route = @client.routes.find { |r|
        r.host == host && r.domain == domain && r.space == space
      }

      unless route
        route = @client.route

        route.host = host if host != nil #app_name if app_name != nil
        route.domain = domain
        route.space = space
        route.create!
      end

      if app
        app.add_route(route)
      end
      route
    end

    def delete(route_guid)
      route = @client.route(route_guid)
      route.delete!
    end

    class Route
      attr_reader :name, :guid, :app

      def initialize(name, guid, app = nil)
        @name = name
        @guid = guid
        @app = app
      end

    end
  end
end