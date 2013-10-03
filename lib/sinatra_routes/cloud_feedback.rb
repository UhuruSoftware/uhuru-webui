require 'sinatra/base'

module Uhuru::Webui
  module SinatraRoutes
    module CloudFeedback
      def self.registered(app)

        app.get FEEDBACK do
          if session[:login_] == false || session[:login_] == nil
            halt 401, 'unauthorized'
          end

          feedback_id = params[:id]

          feedback = ClassWithFeedback.content(feedback_id)

          if feedback == [ :STOP ]
            headers 'X-Webui-Feedback-Instructions' => 'stop'
          else
            headers 'X-Webui-Feedback-Instructions' => 'continue'
            feedback
          end
        end
      end
    end
  end
end