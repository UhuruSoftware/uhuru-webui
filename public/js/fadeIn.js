
$(function(){

$('#logout_key').click(function(){
    $('.modal-background').css({ "display": "block" });
    $('body').css({"overflow":"hidden"});
    $('.modal.logout').fadeIn(600);
});

var delete_selected_element = function(){
    $('#selected_guid').val($(this).attr("id"))
    $('#selected_name').text($(this).attr("title"));
    $('.modal-background').css({ "display": "block" });
    $('body').css({"overflow":"hidden"});
    $('.delete_confirmation').fadeIn(600);
}


$('.cancel_button').click(function(){$(".modal").css("display", "none");$('.modal-background').css("display", "none");$('body').css({"overflow":"auto"});});
$('.tile.org .tile.top :button').click(delete_selected_element);
$('.tile.space .tile.top :button').click(delete_selected_element);
$('.tile.app .tile.top :button').click(delete_selected_element);
$('.tile.service .tile.top :button').click(delete_selected_element);

$('.square_tile .square_tile.domain :button').click(delete_selected_element);
$('.square_tile .square_tile.route :button').click(delete_selected_element);



$('.square_tile .square_tile.owner :button').click(delete_selected_element, $('#aditional_data').val('owner'));
$('.square_tile .square_tile.developer :button').click(delete_selected_element);
$('.square_tile .square_tile.billing :button').click(delete_selected_element);
$('.square_tile .square_tile.auditor :button').click(delete_selected_element);












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



});




var cancel_error_modal = function()
{
    $('.dark_background_error').hide(200);
    $('#errors_modal').hide(200);
}


$('.button_error_cancel').click(cancel_error_modal);





