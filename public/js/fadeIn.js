/*
    Here are all the modals that will fade in
*/

$('#organizations_page').fadeIn(400);
$('#organization_page').fadeIn(400);
$('#space_page').fadeIn(400);

$(function(){

var delete_organization_modal = function(){
    $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
    $('body').css({"overflow":"hidden"});
    $('#delete_organization_modal').fadeIn(600);
    $('.close').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.cancel').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_space_modal = function(){
    $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
    $('body').css({"overflow":"hidden"});
    $('#delete_space_modal').fadeIn(600);
    $('.close').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.cancel').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_domain_modal = function(){
    $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
    $('body').css({"overflow":"hidden"});
    $('#delete_domain_modal').fadeIn(600);
    $('.close').click(function(){$("#delete_domain_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.cancel').click(function(){$("#delete_domain_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_app = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_app').fadeIn(600);
    $('.close').click(function(){$("#delete_app").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.cancel').click(function(){$("#delete_app").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_service = function(){
    $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
    $('body').css({"overflow":"hidden"});
    $('#delete_service').fadeIn(600);
    $('.close').click(function(){$("#delete_service").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.cancel').click(function(){$("#delete_service").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_route = function(){
    $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
    $('body').css({"overflow":"hidden"});
    $('#delete_route').fadeIn(600);
    $('.close').click(function(){$("#delete_route").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.cancel').click(function(){$("#delete_route").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_user = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_user_modal').fadeIn(600);
    $('.cancel').click(function(){$("#delete_user_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.close').click(function(){$("#delete_user_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}


$('.delete-organization-button').click(delete_organization_modal);
$('.delete-space-button').click(delete_space_modal);
$('.delete-domain-button').click(delete_domain_modal);
$('.delete-app-button').click(delete_app);
$('.delete-service-button').click(delete_service);
$('.delete-route-button').click(delete_route);
$('.delete-user-button').click(delete_user);
$('.delete_this_organization').click(delete_organization_modal);
$('.delete_this_space').click(delete_space_modal);



var bind_service = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#bind_service_modal').fadeIn(600);
    $('.close').click(function(){$("#bind_service_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.cancel').click(function(){$("#bind_service_modal").css("display", "none");$('#screen').css("display", "none")});
}

var unbind_service = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#unbind_service_modal').fadeIn(600);
    $('.close').click(function(){$("#unbind_service_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.cancel').click(function(){$("#unbind_service_modal").css("display", "none");$('#screen').css("display", "none")});
}

var bind_uri = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#bind_uri_modal').fadeIn(600);
    $('.close').click(function(){$("#bind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.cancel').click(function(){$("#bind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
}

var unbind_uri = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#unbind_uri_modal').fadeIn(600);
    $('.close').click(function(){$("#unbind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.cancel').click(function(){$("#unbind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
}

$('.button_bound_services').click(bind_service);
$('.button_unbound_services').click(unbind_service);
$('.button_bound_uri').click(bind_uri);
$('.button_unbound_uri').click(unbind_uri);




//
//
//                  FADE IN ALL THE SPANS FOR WAITING POST ACTIONS
//
//



var create_organization_message = function()
{
    $('#cancel_b_c_organization').fadeOut(200);
    $('#b_c_organization').fadeOut(200);
    $('#p_c_organization').fadeIn(200);
}

var create_space_message = function()
{
    $('#cancel_b_c_space').fadeOut(200);
    $('#b_c_space').fadeOut(200);
    $('#p_c_space').fadeIn(200);
}

var create_user_message = function()
{
    $('.btn_add_user').fadeOut(200);
    $('#span_add_user').fadeIn(200);
}


$('#b_c_organization').click(create_organization_message);
$('#b_c_space').click(create_space_message);
$('.btn_add_user').click(create_user_message);



var saving_modal_start = function()
{
    $('#screen').css({	display: "block", opacity: 0.9, width: "10000px", height: "10000px"});
    $('body').css({"overflow":"hidden"});
    $('#saving_modal').fadeIn(200);
    $('.stopApp_btn').css("display", "block");
    $('.startApp_btn').css("display", "none");
}

var saving_modal_stop = function()
{
    $('#screen').css({	display: "block", opacity: 0.9, width: "10000px", height: "10000px"});
    $('body').css({"overflow":"hidden"});
    $('#saving_modal').fadeIn(200);
    $('.startApp_btn').css("display", "block");
    $('.stopApp_btn').css("display", "none");
}

var delete_organization_message = function()
{
    $('#cancel_btn_delete_organization').fadeOut(200);
    $('#btn_delete_organization').fadeOut(200);
    $('#span_delete_organization').fadeIn(200);
}

var delete_space_message = function()
{
    $('#cancel_btn_delete_space').fadeOut(200);
    $('#btn_delete_space').fadeOut(200);
    $('#span_delete_space').fadeIn(200);
}

var delete_domain_message = function()
{
    $('#cancel_btn_delete_domain').fadeOut(200);
    $('#btn_delete_domain').fadeOut(200);
    $('#span_delete_domain').fadeIn(200);
}

var delete_app_message = function()
{
    $('#btn_cancel_app').fadeOut(200);
    $('#btn_delete_app').fadeOut(200);
    $('#span_delete_app').fadeIn(200);
}

var delete_service_message = function()
{
    $('#btn_cancel_service').fadeOut(200);
    $('#btn_delete_service').fadeOut(200);
    $('#span_delete_service').fadeIn(200);
}

var delete_user_message = function()
{
    $('.btn_delete_user').fadeOut(200);
    $('.btn_cancel_user').fadeOut(200);
    $('#span_delete_user').fadeIn(200);
}



$('.startApp_btn').click(saving_modal_start);
$('.stopApp_btn').click(saving_modal_stop);

$('#btn_delete_organization').click(delete_organization_message);
$('#btn_delete_space').click(delete_space_message);
$('#btn_delete_domain').click(delete_domain_message);
$('#btn_delete_app').click(delete_app_message);
$('#btn_delete_service').click(delete_service_message);
$('.btn_delete_user').click(delete_user_message);


$('#logout_key').click(function(){
    $('#logout_small_modal').slideToggle(200, function(){
        //
    });
});
    $('.toggle_logout_up').click(function(){
        $('#logout_small_modal').slideToggle(200, function(){
            //
        });
    });

});




var cancel_error_modal = function()
{
    $('.dark_background_error').hide(200);
    $('#errors_modal').hide(200);
}


$('.button_error_cancel').click(cancel_error_modal);





