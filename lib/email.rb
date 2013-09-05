require 'net/smtp'
require 'openssl'

module Email
  def self.send_email(to_email, subject, body)

    msg = <<END_OF_MESSAGE
From: #{$config[:email][:from_alias]} <#{$config[:email][:from]}>
To: <#{to_email}>
Subject: #{subject}
MIME-Version: 1.0
Content-type: text/html

#{body}
END_OF_MESSAGE

    client = Net::SMTP.new(
        $config[:email][:server],
        $config[:email][:port])


    if $config[:email][:enable_tls]
      context = Net::SMTP.default_ssl_context
      client.enable_starttls(context)
    end


    client.start(
        "localhost",
        $config[:email][:user],
        $config[:email][:secret],
        $config[:email][:auth_method]) do

      client.send_message msg, $config[:email][:from], to_email
    end
  end
end




