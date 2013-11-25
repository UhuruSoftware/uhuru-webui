require 'cfoundry'
require 'config'

#this class contains all the functionality that deals with the routes inside of a specific space
module Library
  class Routes

    def initialize(token, target)
      @client = CFoundry::V2::Client.new(target, token)
    end

    # will read all routes in space, if domain_guid is specified will filter for the domain given
    def read_routes(space_guid, domain_guid = nil)
      routes = []

      @client.routes.each do |route|
        if route.space && route.space.guid == space_guid
          if domain_guid != nil
            routes << Route.new(route.name, route.guid) if route.domain.guid == domain_guid
          else
            routes << Route.new(route.name, route.guid)
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

      route = @client.routes.find { |rt|
        rt.host == host && rt.domain == domain && rt.space == space
      }

      unless route
        route = @client.route

        route.host = host if host != nil #app_name if app_name != nil
        route.domain = domain
        route.space = space
        route.create!
      end

      #@client.app(app_guid) will get an empty instance of Application, so we check that guid exists
      if app.guid
        app.add_route(route)
      end
      route
    end

    # deletes the route from the space
    def delete(route_guid)
      route = @client.route(route_guid)
      route.delete!
    end

    # Data holder for the route tile that will be displayed inside a space (visible in the routes tab)
    # name = the route name (or host name)
    # app = the app owning the route
    # guid = the id or guid of the route
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