require 'vcap/config'

module Uhuru
  module Webui
  end
end

class Uhuru::Webui::AdminSettings < VCAP::Config
  #DEFAULT_CONFIG_PATH = File.expand_path('../../admin-settings.yml', __FILE__)

  define_schema do
    {
        :contact => {
            :company                          => String,
            :address                          => String,
            :phone                            => String,
            :email                            => String
        },

        :recaptcha => {
            :use_recaptcha                    => TrueClass,
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
            :enable_tls                       => String,
            :registration_email               => String,
            :welcome_email                    => String
        },

        :stripe => {
            :publishable_key                => String,
            :secret_key                     => String
        }
    }
  end

  def self.from_file(*args)
    config = super(*args)
    config
  end

  def self.save_changed_value
    path = File.expand_path("#{$config[:admin_config_file]}", __FILE__)
    File.open(path, "w+") do |f|
      f.sync = true
      f.write($admin.to_yaml)
      f.flush()
    end
  end

  def self.copy_admin_to_config(config, admin_settings, config_file)

    admin_settings.each do |key|
      if config.include?key[0]
        config[key[0]] = admin_settings[key[0]]
      else
        config = config.merge({key[0] => key[1]})
      end
    end

    File.write(config_file, config.to_yaml)
  end

end