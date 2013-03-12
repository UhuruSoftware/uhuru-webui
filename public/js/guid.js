/*
    This is a set of functions that pass guids from tiles to froms (when you click delete a guid is passed to the delete modal, and after that the user will be asked if he is sure)
*/

function deleteSpace(obj)
{
    document.getElementById('space_guid').value = obj.title;
}

function deleteDomain(obj)
{
    document.getElementById('domain_guid').value = obj.title;
}

function deleteOrganization(obj)
{
    document.getElementById('org_guid').value = obj.id;
}



function prepareToDeleteOwner(obj)
{
    document.getElementById('this_user_name').innerHTML = obj.title;
    document.getElementById('pass_user_guid').value = obj.id;
    document.getElementById('pass_user_role').value = "owner";
}

function prepareToDeleteBillingManager(obj)
{
    document.getElementById('this_user_name').innerHTML = obj.title;
    document.getElementById('pass_user_guid').value = obj.id;
    document.getElementById('pass_user_role').value = "billing";
}

function prepareToDeleteDeveloper(obj)
{
    document.getElementById('this_user_name').innerHTML = obj.title;
    document.getElementById('pass_user_guid').value = obj.id;
    document.getElementById('pass_user_role').value = "developer";
}

function prepareToDeleteAuditor(obj)
{
    document.getElementById('this_user_name').innerHTML = obj.title;
    document.getElementById('pass_user_guid').value = obj.id;
    document.getElementById('pass_user_role').value = "auditor";
}


function prepareToDeleteApp(obj)
{
    document.getElementById('pass_app').value = obj.title;
    document.getElementById('this_app_name').innerHTML = obj.title;
}

function prepareToDeleteService(obj)
{
    document.getElementById('pass_service').value = obj.title;
    document.getElementById('this_service_name').innerHTML = obj.id;
}


function selectUserType(userType)
{
    document.getElementById('new_user_type').value = userType.id;
}
function prepareToAddNewUserEmail()
{
    document.getElementById('new_user_email').value = document.getElementById('user_email').value;
}

function newServiceName()
{
    document.getElementById('new_service_name').value = document.getElementById('service_name').value;
}
