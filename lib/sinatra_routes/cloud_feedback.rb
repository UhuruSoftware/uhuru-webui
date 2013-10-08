require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module CloudFeedback
      def self.registered(app)

        app.get FEEDBACK do
          require_login
          feedback_id = params[:id]

          action, feedback = ClassWithFeedback.content(feedback_id)

          if action == :continue
            headers 'X-Webui-Feedback-Instructions' => 'continue'
            feedback
          else
            headers 'X-Webui-Feedback-Instructions' => 'stop'
            if action == :done
              feedback
            else
              "Can't find log messages..."
            end
          end
        end
      end
    end
  end
end