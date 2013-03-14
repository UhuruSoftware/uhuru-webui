Uhuru WebUI

Description
The WebUI is a web portal that allows users to manage their CloudFoundry account.


To start the WebUI run the following commands:
 bundle install
 cd bin
 bundle exec ruby webui


The UAA target has to have an oauth2 client with secret for the webui
 with the following confgs:
   webui:
     id: webui
     secret: webuisecret  # Security: assign a random value.
     scope: cloud_controller.read,cloud_controller.write,cloud_controller.admin,openid,password.write,scim.read,scim.write # scopes that can be requested to impersonate a user
     authorities: uaa.admin,uaa.resource,tokens.read,scim.read,scim.write,password.write,cloud_controller.read,cloud_controller.write,cloud_controller.admin # scopes granted to the client
     authorized-grant-types: client_credentials,password