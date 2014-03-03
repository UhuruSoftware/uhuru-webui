require 'net/smtp'
require 'openssl'

module Email
  # Method to send an email
  # to_email = email address where email is sent
  # subject =  email title
  # body = email content
  #
  def self.send_email(to_email, subject, body)
    email_config = $config[:email]
    email_from = email_config[:from]

    msg = <<END_OF_MESSAGE
From: #{email_config[:from_alias]} <#{email_from}>
To: <#{to_email}>
Subject: #{subject}
MIME-Version: 1.0
Content-type: text/html

#{body}
END_OF_MESSAGE

    client = Net::SMTP.new(
        email_config[:server],
        email_config[:port])


    if email_config[:enable_tls].to_s == 'true'
      context = Net::SMTP.default_ssl_context
      client.enable_starttls(context)
    end


    client.start(
        "localhost",
        email_config[:user],
        email_config[:secret],
        email_config[:auth_method]) do

      client.send_message msg, email_from, to_email
    end
  end
end




