require 'yaml'

class TemplateApps

  def read_collections
    result = {}
    search_collections =  File.expand_path("../../template_apps/*/manifest.yml", __FILE__)
    all_collections = Dir.glob(search_collections)

    all_collections.each do |collection|

      collection_manifest = YAML.load_file collection


      apps_search = File.expand_path("../*/template_manifest.yml", collection)
      all_apps = Dir.glob(apps_search)

      all_apps.each do |app|
        service_types = []
        app_manifest = YAML.load_file app

        app_manifest['collection'] = collection_manifest
        app_manifest['collection_src'] = collection
        app_manifest['app_src'] = app
        app_manifest['logo'] = File.expand_path("../logo.png", app)
        app_manifest['vmc_manifest_file'] = File.expand_path("../vmc_manifest.yml", app)
        app_manifest['vmc_manifest'] = YAML.load_file app_manifest['vmc_manifest_file']
        service_manifest = YAML.load_file app_manifest['vmc_manifest_file']
        services = service_manifest['applications']['.']['services']

        services.each do |_, value|
          value.each do |_, service_type|
            service_types << service_type
          end
        end

        app_manifest['service_type'] = service_types

        result[app_manifest['id']] = app_manifest
      end
    end

    result
  end
end