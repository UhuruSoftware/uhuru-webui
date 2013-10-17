
module Uhuru
  module Webui
    class CFReports

      attr_reader :uaa_users

      def reports
        $reports[:reports]
      end

      def init_users
        conn = PG.connect(
            host:     $config[:uaadb][:host],
            port:     $config[:uaadb][:port],
            dbname:   $config[:uaadb][:dbname],
            user:     $config[:uaadb][:user],
            password: $config[:uaadb][:password]
        )

        cf_users = run_query('SELECT id, guid FROM USERS')

        uaa_users = conn.exec('SELECT * FROM USERS')
        @uaa_users = {}

        uaa_users.each do |user|

          cf_user = cf_users.find { |u| u['guid'] == user['id'] }

          if cf_user
            @uaa_users[cf_user['id']] = {
                :username => user['username'],
                :email => user['email'],
                :first_name => user['givenname'],
                :last_name => user['familyname'],
                :phone => user['phonenumber']
            }
          end
        end


        @uaa_users.define_singleton_method(:get_user_label) do |user_id|
          if self.has_key?(user_id)
            self[user_id][:username]
          else
            "Unknown (#{user_id})"
          end
        end
      end


      def get_connection
        conn = PG.connect(
            host:     $config[:ccdb][:host],
            port:     $config[:ccdb][:port],
            dbname:   $config[:ccdb][:dbname],
            user:     $config[:ccdb][:user],
            password: $config[:ccdb][:password]
        )

        return conn
      end

      def initialize
        @conn = get_connection
      end

      def run_query(query)
        if query.is_a?(String)
          @conn.exec(query)
        else
          @conn.exec(reports[query][:query])
        end
      end
    end
  end
end

