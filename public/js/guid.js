
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
    thisSpaceGuid = obj.title;
}

function getAppGuid()
{
    document.getElementById('pass_app').value =  thisSpaceGuid;
}

function setAppName(obj)
{
    document.getElementById('app_name_big').innerHTML = obj.id;
}



function setServiceGuid(obj)
{
    thisSpaceGuid = obj.title;
}

function getServiceGuid()
{
    document.getElementById('pass_service').value =  thisSpaceGuid;
}
