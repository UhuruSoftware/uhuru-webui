require 'yaml'

class TemplateApps

  def read_collections
    begin
      collections = YAML.load_file("../template_apps/collections_list.yml")
      return collections
    rescue Exception => ex
      puts ex
      return nil
    end
  end

  def read_collection(folder)
    begin
      collection = YAML.load_file("../template_apps/" + folder + "/template_collection_manifest.yml")
      return collection
    rescue Exception => ex
      puts ex
      return nil
    end
  end

  def read_apps(folder1, folder2)
    begin
      app = YAML.load_file("../template_apps/" + folder1 + "/" + folder2 + "/template_manifest.yml")
      return app
    rescue Exception => ex
      puts ex
      return nil
    end
  end

end



#def read_apps
#
#  @apps = Array.new
#  @i = 0
#
#  app_file = File.join(File.dirname(__FILE__), "../apps.yaml")
#
#  file = YAML.load_file app_file
#  file.each_key { |key|
#    @apps[@i] = file[key]
#    @i = @i + 1
#  }
#  @apps
#end




<<-Doc
    def read_apps
      @apps = Array.new
      @i = 0

      file = YAML.load_file "apps.yaml"
      file.each_key { |key|
        @apps[@i] = file[key]['name']
        @i = @i + 1
      }
      @apps
    end

    def read_runtimes
      @runtimes = Array.new
      @i = 0

      file = YAML.load_file "apps.yaml"
      file.each_key { |key|
        @runtimes[@i] = file[key]['runtime']
        @i = @i + 1
      }
      @runtimes
    end

    def read_frameworks
      @frameworks = Array.new
      @i = 0

      file = YAML.load_file "apps.yaml"
      file.each_key { |key|
        @frameworks[@i] = file[key]['framework']['name']
        @i = @i + 1
      }
      @frameworks
    end

    def read_memory
      @memory = Array.new
      @i = 0

      file = YAML.load_file "apps.yaml"
      file.each_key { |key|
        @memory[@i] = file[key]['mem']
        @i = @i + 1
      }
      @memory
    end

    def read_locations
      @locations = Array.new
      @i = 0

      file = YAML.load_file "apps.yaml"
      file.each_key { |key|
        @locations[@i] = file[key]['download-location']
        @i = @i + 1
      }
      @locations
    end
Doc