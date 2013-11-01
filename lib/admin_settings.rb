
module Uhuru
  module Webui
  end
end

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


  def self.bootstrap(destination_file)
    original_file = File.expand_path('../../config/admin-settings.yml', __FILE__)

    unless File.exist?(destination_file)
      FileUtils.cp original_file, destination_file
    else
      settings = YAML.load_file(destination_file)
      if(settings)
        settings = VCAP.symbolize_keys(settings)
        new_settings = from_file(original_file)

        begin
          Uhuru::Webui::AdminSettings.import_settings!(settings, new_settings)
          Uhuru::Webui::AdminSettings.schema.validate(new_settings)

          settings = stringify_keys(new_settings.dup)

          File.open(destination_file, "w+") do |f|
            f.sync = true
            f.write(settings.to_yaml)
            f.flush()
          end
        end
      else
        FileUtils.cp original_file, destination_file
      end
    end
  end


  def self.from_file(*args)
    config = super(*args)
    config
  end

  def self.save_changed_value
    path = $config[:admin_config_file]

    settings = stringify_keys($admin.dup)

    File.open(path, "w+") do |f|
      f.sync = true
      f.write(settings.to_yaml)
      f.flush()
    end

    merge_config($config, $admin)
  end

  def self.merge_config(config, admin_settings)
    admin_settings.each do |key|
      if config.include?key[0]
        config[key[0]] = admin_settings[key[0]]
      else
        config = config.merge({key[0] => key[1]})
      end
    end

    config
  end

  def self.import_settings!(source, dest)
    dest.each do |key|
      if source.has_key?(key)
        if (dest[key].is_a?(Hash) && source[key].is_a?(Hash))
          import_settings!(source[key], dest[key])
        else
          dest[key] = source[key]
        end
      end
    end
  end

  private

  def self.stringify_keys(hash)
    if hash.is_a? Hash
      new_hash = {}
      hash.each {|k, v| new_hash[k.to_s] = stringify_keys(v) }
      new_hash
    else
      hash
    end
  end

end