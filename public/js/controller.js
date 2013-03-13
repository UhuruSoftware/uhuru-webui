var delete_organization = function()
{
    $('#org_guid').val($(this).attr("id"))
    $('#this_organization_name').text($(this).attr("title"));
}
var delete_space = function()
{
    $('#space_guid').val($(this).attr("title"));
    $('#this_space_name').text($(this).attr("id"));
}
var delete_domain = function()
{
    $('#domain_guid').val($(this).attr("title"));
    $('#this_domain_name').text($(this).attr("id"));
}
var delete_app = function()
{
    $('#pass_app').val($(this).attr("id"));
    $('#this_app_name').text($(this).attr("id"));
}
var delete_service = function()
{
    $('#pass_service').val($(this).attr("title"));
    $('#this_service_name').text($(this).attr("id"));
}
var delete_route = function()
{
    $('#pass_route').val($(this).attr("id"));
    $('#this_route_name').text($(this).attr("title"));
}


$('.delete-organization-button').click(delete_organization);
$('.delete-space-button').click(delete_space);
$('.delete-domain-button').click(delete_domain);
$('.delete-app-button').click(delete_app);
$('.delete-service-button').click(delete_service);
$('.delete-route-button').click(delete_route);


var delete_owner = function()
{
    $('#this_user_name').text($(this).attr("title"));
    $('#pass_user_guid').val($(this).attr("id"));
    $('#pass_user_role').val("owner");
}
var delete_developer = function()
{
    $('#this_user_name').text($(this).attr("title"));
    $('#pass_user_guid').val($(this).attr("id"));
    $('#pass_user_role').val("developer");
}
var delete_auditor = function()
{
    $('#this_user_name').text($(this).attr("title"));
    $('#pass_user_guid').val($(this).attr("id"));
    $('#pass_user_role').val("auditor");
}

$('.btn_delete_owner').click(delete_owner);
$('.btn_delete_developer').click(delete_developer);
$('.btn_delete_auditor').click(delete_auditor);
