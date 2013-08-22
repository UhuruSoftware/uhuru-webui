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
      puts e
      puts 'read route error'
      return 'error'
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
          puts e
          puts 'create route error'
          return 'error'
        end

      end

      app.add_route(route)
      return route
    rescue Exception => e
      puts e
      puts 'bind uri method error'
      return 'error'
    end

    # delete is used: - to unmap a route (url) from an app
    #                 - to unmap a route and delete it
    # the second parameter will decide if it's an unmap or a delete
    # if route_guid is not passed, will unmap/delete all the routes
    def delete(app_name, delete = false, route_guid = nil)
      app = @client.apps.find { |a| a.name == app_name }

      if (route_guid != nil)
        route = @client.route(route_guid)
        app.remove_route(route)
        route.delete! if delete
      else
        app.routes.each do |r|
          app.remove_route(r)
          r.delete! if delete
        end
      end
    rescue Exception => e
      puts e
      puts 'unbind url error'
      return 'error'
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