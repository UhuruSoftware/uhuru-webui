
module Uhuru
  module Webui
    # Class used to generate reports
    class CFReports

      attr_reader :uaa_users

      def reports
        $reports[:reports]
      end

      # Replace the user id from a report column with username
      #
      def init_users
        uaadb_config = $config[:uaadb]
        conn = PG.connect(
            host:     uaadb_config[:host],
            port:     uaadb_config[:port],
            dbname:   uaadb_config[:dbname],
            user:     uaadb_config[:user],
            password: uaadb_config[:password]
        )

        cf_users = run_query('SELECT id, guid FROM USERS')

        uaa_users = conn.exec('SELECT * FROM USERS')
        @uaa_users = {}

        uaa_users.each do |user|
          cf_user = cf_users.find { |cf_user| cf_user['guid'] == user['id'] }

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

      # Connects to the cloud controller db specified in config file
      #
      def get_connection
        ccdb_config = $config[:ccdb]
        conn = PG.connect(
            host:     ccdb_config[:host],
            port:     ccdb_config[:port],
            dbname:   ccdb_config[:dbname],
            user:     ccdb_config[:user],
            password: ccdb_config[:password]
        )

        return conn
      end

      # Initializes the class
      #
      def initialize
        @conn = get_connection
      end

      # Runs a query and returns query result
      #
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

