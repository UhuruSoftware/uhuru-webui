
module Uhuru
  module Webui
  end
end

# The class that manages admin-settings.yml file
class Uhuru::Webui::AdminSettings < VCAP::Config
  define_schema do
    {
        :contact => {
            :company                          => String,
            :address                          => String,
            :phone                            => String,
            :email                            => String
        },

        :recaptcha => {
            :recaptcha_private_key            => String,
            :recaptcha_public_key             => String
        },

        :webui =>{
            :page_title                       => String,
            :site_tab                         => String,
            :welcome_message                  => String,
            :copyright_message                => String,
            #:color_theme                     => String,

            :domain                           => String,
            :activation_link_secret           => String,
            :more_videos_link                 => String,
            :guest_feedback_link              => String,
            :twitter_link                     => String,
            :facebook_link                    => String,
            :terms_of_services_link           => String,
            :privacy_policy_link              => String,
            :visual_studio_plugin_link        => String,
            :app_cloud_admin_link             => String,
            :command_line_link                => String,
            :eclipse_url                      => String,
            :company_link                     => String,
            :support_link                     => String,
            :start_page_text                  => String,
            :start_page_splash_text           => String
        },

        :email => {
            :from                             => String,
            :from_alias                       => String,
            :server                           => String,
            :port                             => Integer,
            :user                             => String,
            :secret                           => String,
            :auth_method                      => Symbol,
            :enable_tls                       => Object,
            :registration_email               => String,
            :welcome_email                    => String,
            :password_recovery_email          => String
        },

        :billing => {
            :provider                       => String
        }
    }
  end

  # Copies the administration settings from the default file, to the one that will be used by the webui.
  # If destination file doesn't exist will create one.
  # destination_file = file to be used by webui containing admin settings
  #
  def self.bootstrap(destination_file)
    original_file = File.expand_path('../../config/admin-settings.yml', __FILE__)

    unless File.exist?(destination_file)
      FileUtils.cp original_file, destination_file
    else
      settings = YAML.load_file(destination_file)
      if(settings)
        settings = VCAP.symbolize_keys(settings)
        new_settings = from_file(original_file)

        Uhuru::Webui::AdminSettings.import_settings!(settings, new_settings)
        Uhuru::Webui::AdminSettings.schema.validate(new_settings)

        settings = stringify_keys(new_settings.dup)

        write_to_file(destination_file, settings)

      else
        FileUtils.cp original_file, destination_file
      end
    end
  end

  # Loads settings from a file to a Hash validating the file schema
  # *args = filename, symbolize_keys=true
  #
  def self.from_file(*args)
    config = super(*args)
    config
  end

  # Save values to the admin configuration file, then merge them into webui configuration file too
  #
  def self.save_changed_value
    write_to_file($config[:admin_config_file], stringify_keys($admin.dup))

    merge_config($config, $admin)
  end

  # Keep main config file and admin settings file updated, when admin file is modified the modification will
  # be merged into config file right away
  # config = hash containing main config settings
  # admin_settings = hash containing admin settings
  #
  def self.merge_config(config, admin_settings)
    admin_settings.each do |key|
      first_key = key[0]
      if config.include?first_key
        config[first_key] = admin_settings[first_key]
      else
        config = config.merge({first_key => key[1]})
      end
    end

    config
  end

  # Recursive method that copies key-values pairs from a yml file to another
  # source = source hash
  # dest = destination hash
  #
  def self.import_settings!(source, dest)
    dest.each do |key, _|
      if source.has_key?(key)
        dest_key = dest[key]
        source_key = source[key]
        if (dest_key.is_a?(Hash) && source_key.is_a?(Hash))
          import_settings!(source_key, dest_key)
        else
          dest[key] = source_key
        end
      end
    end
  end

  private

  # Transforms keys of a hash from string to symbol
  # hash = the hash containing the keys
  #
  def self.stringify_keys(hash)
    if hash.is_a? Hash
      new_hash = {}
      hash.each {|key, value| new_hash[key.to_s] = stringify_keys(value) }
      new_hash
    else
      hash
    end
  end

  # Writes a hash to a file
  # file_path = file path where to write
  # settings = the hash containing the settings
  #
  def self.write_to_file(file_path, settings)
    File.open(file_path, "w+") do |file|
      file.sync = true
      file.write(settings.to_yaml)
      file.flush()
    end
  end

end
