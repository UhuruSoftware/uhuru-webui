$('#organizations_page').fadeIn(200);
$('#organization_page').fadeIn(200);
$('#space_page').fadeIn(200);

$(function(){

var create_organization = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_organization').fadeIn(1200);
    $('.close').click(function(){$("#create_organization").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#create_organization").css("display", "none");$('#screen').css("display", "none")});
    $('#org_name').focus();
}

var create_space = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_space').fadeIn(1200);
    $('.close').click(function(){$("#create_space").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#create_space").css("display", "none");$('#screen').css("display", "none")});
    $('#org_name').focus();
}

var create_tempcta_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_tempcta_modal').fadeIn(1200);
    $('.close').click(function(){$("#create_tempcta_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#create_tempcta_modal").css("display", "none");$('#screen').css("display", "none")});
}


var add_ctService_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#add_ctService_modal').fadeIn(1200);
    $('.close').click(function(){$("#add_ctService_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#add_ctService_modal").css("display", "none");$('#screen').css("display", "none")});
}

var add_user = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#add_user').fadeIn(1200);
    $('.close').click(function(){$("#add_user").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#add_user").css("display", "none");$('#screen').css("display", "none")});
}





var delete_space_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_space_modal').slideDown(200);
    $('.close').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none")});
}

var delete_organization_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_organization_modal').slideDown(200);
    $('.close').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none")});
}

var delete_app = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_app').slideDown(200);
    $('.close').click(function(){$("#delete_app").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#delete_app").css("display", "none");$('#screen').css("display", "none")});
}

var delete_service = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_service').slideDown(200);
    $('.close').click(function(){$("#delete_service").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#delete_service").css("display", "none");$('#screen').css("display", "none")});
}



$('#create_organization_btn').click(create_organization);
$('#create_space_btn').click(create_space);
$('#create_app').click(create_tempcta_modal);
$('#create_service').click(add_ctService_modal);
$('#add_user_btn_owner').click(add_user);
$('#add_user_btn_developer').click(add_user);
$('#add_user_btn_manager').click(add_user);


$('.delete-organization-button').click(delete_organization_modal);
$('.delete-space-button').click(delete_space_modal);
$('.delete-app-button').click(delete_app);
$('.delete-service-button').click(delete_service);






var bind_service = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#bind_service_modal').slideDown(200);
    $('.close').click(function(){$("#bind_service_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#bind_service_modal").css("display", "none");$('#screen').css("display", "none")});
}

var unbind_service = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#unbind_service_modal').slideDown(200);
    $('.close').click(function(){$("#unbind_service_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#unbind_service_modal").css("display", "none");$('#screen').css("display", "none")});
}


var bind_uri = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#bind_uri_modal').slideDown(200);
    $('.close').click(function(){$("#bind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#bind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
}

var unbind_uri = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#unbind_uri_modal').slideDown(200);
    $('.close').click(function(){$("#unbind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#unbind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
}





$('.button_bound_services').click(bind_service);
$('.button_unbound_services').click(unbind_service);

$('.button_bound_uri').click(bind_uri);
$('.button_unbound_uri').click(unbind_uri);



var add_subscription = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('.this_sub').fadeIn(200);
    $('.close').click(function(){$(".this_sub").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$(".this_sub").css("display", "none");$('#screen').css("display", "none")});
    $('#quantity_slider').css("display", "none");
}

$('.button_add_subscription').click(add_subscription);


});


