
//JAVASCRIPT CANt SHOW GUID'S

var thisOrgGuid;
var thisSpaceGuid;

var thisApp;
var thisService;

function setOrganizationGuid(obj)
{
    thisOrgGuid = obj.title;
}

function getOrganizationGuid()
{
    document.getElementById('pass_guid').value =  thisOrgGuid;
}



function setSpaceGuid(obj)
{
    thisSpaceGuid = obj.title;
}

function getSpaceGuid()
{
    document.getElementById('pass_guid').value =  thisSpaceGuid;
}



function setAppGuid(obj)
{
    thisApp = obj.title;
}

function getAppGuid()
{
    document.getElementById('pass_app').value =  thisApp;
}

//this sets the name on the app details

function setAppName(obj)
{
    document.getElementById('app_name_big').innerHTML = obj.id;
    document.getElementById('details_app_name_start').value = obj.id;
    document.getElementById('details_app_name_stop').value = obj.id;
}




function setServiceGuid(obj)
{
    thisService = obj.title;
}

function getServiceGuid()
{
    document.getElementById('pass_service').value =  thisService;
}
