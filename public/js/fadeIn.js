/*
    Here are all the modals that will fade in
*/

$('#organizations_page').fadeIn(400);
$('#organization_page').fadeIn(400);
$('#space_page').fadeIn(400);

$(function(){

var delete_space_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_space_modal').fadeIn(600);
    $('.close').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.cancel').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_organization_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_organization_modal').fadeIn(600);
    $('.close').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.cancel').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
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

var delete_user = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_user_modal').fadeIn(600);
    $('.cancel').click(function(){$("#delete_user_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.close').click(function(){$("#delete_user_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}


$('.delete-organization-button').click(delete_organization_modal);
$('.delete-space-button').click(delete_space_modal);
$('.delete-app-button').click(delete_app);
$('.delete-service-button').click(delete_service);
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

$('.create_app_header_tab_right').click(function(){
    $('#create_app_templates_list').fadeIn(600);
    $('#create_app_templates').fadeIn(600);
});
