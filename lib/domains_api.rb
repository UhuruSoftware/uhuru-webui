require 'cfoundry'
require 'config'

module Library
  class DomainsApi
    def initialize(token, target)
      @client = CFoundry::V2::Client.new(target, token)
    end

    #if no org_guid or space_guid is provided will display all available domains
    #if one of the params is provided will filter the domains according to the params
    def read_domains(org_guid = nil, space_guid = nil)
      domains = []
      domains_api = []

      if (org_guid == nil && space_guid == nil)
        domains_api = @client.domains
      elsif org_guid != nil
        org = @client.organization(org_guid)
        domains_api = org.domains
      elsif space_guid != nil
        space = @client.space(space_guid)
        domains_api = space.domains
      end

      domains_api.each do |d|
        owning_org_name = d.owning_organization == nil ? "Shared" : d.owning_organization.name
        domains << Domain.new(d.name, d.wildcard, owning_org_name, d.guid)
      end

      return domains

    rescue Exception => e
      puts "#{e.inspect}, #{e.backtrace}"
      puts 'read domains error'
      return 'error'
    end

    # create is used: - to create an domain and map it to an organization or space
    #                 - just to map an domain to an organization or space if the domain exists
    def create(name, org_guid, space_guid = nil)
      domain_exist = @client.domains.find { |d|
          d.name == name }

      org = @client.organization(org_guid)

      # if domain doesn't exist will create it and put the organization as owning org
      if (domain_exist == nil)
        domain = @client.domain
        domain.owning_organization = org
        domain.name = name
        domain.create!
      else
        domain = domain_exist
        existing_domains = org.domains

        # if domain exist will check that the  org and domain exists, if not will add it
        if (!existing_domains.include?(domain))
          existing_domains << domain
          org.domains = existing_domains

          org.update!
        end
      end

      # if a space guid is provided will add a connection between domain and space
      if space_guid != nil
        space = @client.space(space_guid)
        existing_domains = space.domains
        if (!existing_domains.include?(domain))
          existing_domains << domain
          space.domains = existing_domains

          space.update!
        end
      end

    rescue Exception => e
      puts e
      puts 'create domain method error'
      return 'error'
    end

    # unmaps a domain from an organization or space
    def unmap_domain(domain_guid, org_guid = nil, space_guid = nil)
      domain = @client.domain(domain_guid)

      if (org_guid == nil && space_guid == nil)
        raise
          "nothing to unmap"
      else
        if (org_guid != nil)
          org = @client.organization(org_guid)
          existing_domains = org.domains
          existing_domains.delete(domain)
          org.domains = existing_domains

          org.update!
        end

        if (space_guid != nil)
          space = @client.space(space_guid)
          existing_domains = space.domains
          existing_domains.delete(domain)
          space.domains = existing_domains

          space.update!
        end

      end

    rescue Exception => e
      puts e
      puts 'unmap domain method error'
      return 'error'
    end

    # deletes the domain and unmap all existing connections
    def delete(domain_guid)
      domain = @client.domain(domain_guid)
      domain.delete!

    rescue Exception => e
      puts e
      puts 'delete domain method error'
      return 'error'
    end

    class Domain
      attr_reader :name, :wildcard, :owning_org_name, :guid

      def initialize(name, wildcard, owning_org_name, guid)
        @name = name
        @wildcard = wildcard
        @owning_org = owning_org_name
        @guid = guid
      end
    end

  end

end
