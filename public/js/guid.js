
//JAVASCRIPT CAN'T SHOW GUID'S

//these functions pass the parameters needed to the "Are you sure?" modals, so they can be posted


function prepareToDeleteOrganization(obj)
{
    document.getElementById('this_organization_name').innerHTML = obj.id;
    document.getElementById('pass_guid').value = obj.title;
}

function prepareToDeleteSpace(obj)
{
    document.getElementById('this_space_name').innerHTML = obj.id;
    document.getElementById('pass_guid').value = obj.title;
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

//add a USER EMAIL
function prepareToAddNewUser(userType)
{
    document.getElementById('new_user_type').value = userType;
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
