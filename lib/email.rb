require 'rest-client'

module Email
  def self.send_email(email, body)

    RestClient.post "" + $config[:email][:mailgun_api_url] + "",
                    :from => "" + $config[:email][:from_title] + "<" + $config[:email][:from] + ">",
                    :to => email,
                    :subject => $config[:email][:subject],
                    :html => body
  end
end