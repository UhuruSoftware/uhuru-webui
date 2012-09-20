
//JAVASCRIPT CANt SHOW GUID'S

var thisOrgGuid;
var thisSpaceGuid;

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


