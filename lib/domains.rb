require 'cfoundry'
require 'config'

module Library
  # Data layer containing methods to handle cc API Domain object
  class Domains
    def initialize(token, target)
      @client = CFoundry::V2::Client.new(target, token)
    end

    # Read the domain list according to parameters
    # org_guid = organization guid to filter domains
    # space_guid = space guid to filter domains
    # if no org_guid or space_guid is provided will display all available domains
    # if one of the params is provided will filter the domains according to the params
    #
    def read_domains(org_guid = nil, space_guid = nil)
      domains = []

      type = space_guid == nil ? (org_guid == nil ? :none : :org) : :space

      cc_domains = @client.domains
      domains_api = case type
                      when :org then @client.organization(org_guid).domains + cc_domains.select { |cc_domain| cc_domain.owning_organization == nil }
                      when :space then @client.space(space_guid).domains
                      else cc_domains
                    end

      domains_api.each do |domain_api|
        owning_org = domain_api.owning_organization
        owning_org_name = owning_org == nil ? "Shared" : owning_org.name
        domains << Domain.new(domain_api.name, domain_api.wildcard, owning_org_name, domain_api.spaces, domain_api.guid)
      end

      domains.uniq {|domain| domain.name }
    end

    # Create is used: - to create an domain and map it to an organization or space
    #                 - just to map an domain to an organization or space if the domain exists
    # name = domain name
    # org_guid = organization guid where domain will be added
    # domain_wildcard = a bool parameter that tells if the domain is a wildcard or not
    # space_guid = if provided, will add the domain to ths space having this guid
    #
    def create(name, org_guid, domain_wildcard, space_guid = nil)
        domain_exist = @client.domains.find { |domain|
            domain.name == name }

        org = @client.organization(org_guid)

        # if domain doesn't exist will create it and put the organization as owning org
        if (domain_exist == nil)
          domain = @client.domain
          domain.owning_organization = org
          domain.name = name
          domain.wildcard = domain_wildcard
          domain.create!
        else
          domain = domain_exist
          existing_org_domains = org.domains

          # if domain exist will check that the  org and domain exists, if not will add it
          if (!existing_org_domains.include?(domain))
            existing_org_domains << domain
            org.domains = existing_org_domains

            org.update!
          end
        end

        # if a space guid is provided will add a connection between domain and space
        if space_guid != nil
          space = @client.space(space_guid)
          existing_space_domains = space.domains
          if (!existing_space_domains.include?(domain))
            existing_space_domains << domain
            space.domains = existing_space_domains

            space.update!
          end
        end
    end

    # Unmap a domain from an organization or space
    # domain_guid = domain to be unmapped
    # org_guid = organization guid, from which the domain will be unmapped
    # space_guid = space guid, from which the domain will be unmapped
    #
    def unmap_domain(domain_guid, org_guid = nil, space_guid = nil)
      domain = @client.domain(domain_guid)

      if (org_guid == nil && space_guid == nil)
        raise
          "nothing to unmap"
      else
        if (org_guid != nil)
          org = @client.organization(org_guid)
          existing_org_domains = org.domains
          existing_org_domains.delete(domain)
          org.domains = existing_org_domains

          org.update!
        end

        if (space_guid != nil)
          space = @client.space(space_guid)
          existing_space_domains = space.domains
          existing_space_domains.delete(domain)
          space.domains = existing_space_domains

          space.update!
        end

      end
    end

    # Deletes the domain and unmap all existing connections
    # domain_guid = the domains guid to be deleted
    #
    def delete(domain_guid)
      domain = @client.domain(domain_guid)
      domain.delete(:recursive => true)
    end

    # Data holder for the tile displayed in organization/space domains tab
    # name = full name of the domain
    # wildcard = if it's a wildcard or not
    # owning_org_name = owning organization name
    # owning_spaces = list of owning spaces
    # guid = domains guid
    #
    class Domain
      attr_reader :name, :wildcard, :owning_org_name, :owning_spaces, :guid

      def initialize(name, wildcard, owning_org_name, owning_spaces, guid)
        @name = name
        @wildcard = wildcard
        @owning_org_name = owning_org_name
        @owning_spaces = owning_spaces
        @guid = guid
      end
    end
  end

end
