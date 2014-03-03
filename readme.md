## Uhuru WebUI

This is the repository for the Uhuru WebUI. The Uhuru WebUI is an end-user web console for using Cloud Foundry.

The key features of the WebUI are:
-	Register e-mail addresses as Cloud Foundry accounts.
-	Deploy applications from a Cloud Foundry template library.
-	Manage applications that were deployed to a Cloud Foundry environment.

To start the WebUI run the following commands:

	 bundle install
	 cd bin
	 bundle exec ruby webui

To test the WebUI do the following:

	add your test user's password as an environment variable (ex: export WEBUI_USER_PASSWORD=mypassword)
	run bundle install
	cd ../path/to/webui_folder/spec
	run the tests
    
The Cloud Foundry UAA target has to have an oauth2 client for the webui with the following configs:

	   webui:
	     id: webui
	     secret: webuisecret  # Security: assign a random value.
	     scope: cloud_controller.read,cloud_controller.write,cloud_controller.admin,openid,password.write,scim.read,scim.write # scopes that can be requested to impersonate a user
	     authorities: uaa.admin,uaa.resource,tokens.read,scim.read,scim.write,password.write,cloud_controller.read,cloud_controller.write,cloud_controller.admin # scopes granted to the client
	     authorized-grant-types: client_credentials,password

## Notice of Export Control Law

This software distribution includes cryptographic software that is subject to the U.S. Export Administration Regulations (the "EAR") and other U.S. and foreign laws and may not be exported, re-exported or transferred (a) to any country listed in Country Group E:1 in Supplement No. 1 to part 740 of the EAR (currently, Cuba, Iran, North Korea, Sudan & Syria); (b) to any prohibited destination or to any end user who has been prohibited from participating in U.S. export transactions by any federal agency of the U.S. government; or (c) for use in connection with the design, development or production of nuclear, chemical or biological weapons, or rocket systems, space launch vehicles, or sounding rockets, or unmanned air vehicle systems.You may not download this software or technical information if you are located in one of these countries or otherwise subject to these restrictions. You may not provide this software or technical information to individuals or entities located in one of these countries or otherwise subject to these restrictions. You are also responsible for compliance with foreign law requirements applicable to the import, export and use of this software and technical information.

