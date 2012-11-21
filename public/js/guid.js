function prepareToDeleteOrganization(obj)
{
    document.getElementById('this_organization_name').innerHTML = obj.title;
    document.getElementById('pass_guid').value = obj.id;
}

function prepareToDeleteSpace(obj)
{
    document.getElementById('this_space_name').innerHTML = obj.id;
    document.getElementById('pass_guid').value = obj.title;
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

function prepareToDeleteCreditCard(obj)
{
    document.getElementById('pass_credit_card_id').value = obj.id;
}

function prepareToAddCreditCard(obj)
{
    document.getElementById('pass_credit_card_add_id').value = obj.id;
}

function selectUserType(userType)
{
    document.getElementById('new_user_type').value = userType.id;
}
function prepareToAddNewUserEmail()
{
    document.getElementById('new_user_email').value = document.getElementById('user_email').value;
}

function newServiceType() //this is the combo box
{
    document.getElementById('new_user_type').value = userType;
}

function newServiceName()
{
    document.getElementById('new_service_name').value = document.getElementById('service_name').value;
}
