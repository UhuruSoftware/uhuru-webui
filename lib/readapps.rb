$:.unshift(File.join(File.dirname(__FILE__)))
require 'rubygems'
require 'sinatra'
require 'yaml'
require 'uhuru_config'
require 'dev_utils'

class TemplateApps
  def read_apps

    @apps = Array.new
    @i = 0

    file = YAML.load_file "apps.yaml"
    file.each_key { |key|
      @apps[@i] = file[key]
      @i = @i + 1
    }
    @apps
    end
end


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