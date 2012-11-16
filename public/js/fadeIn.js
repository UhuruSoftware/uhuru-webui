$('#organizations_page').fadeIn(400);
$('#organization_page').fadeIn(400);
$('#space_page').fadeIn(400);

$(function(){

var create_organization = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_organization').fadeIn(600);
    $('.close').click(function(){$("#create_organization").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('#org_name').focus();
}

var create_space = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_space').fadeIn(600);
    $('.close').click(function(){$("#create_space").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('#space_name').focus();
}

var create_tempcta_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_tempcta_modal').fadeIn(600);
    $('.close').click(function(){$("#create_tempcta_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}


var add_ctService_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#add_ctService_modal').fadeIn(600);
    $('.close').click(function(){$("#add_ctService_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.btn').click(function(){$("#add_ctService_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var add_user = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#add_user').fadeIn(600);
    $('.close').click(function(){$("#add_user").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}





var delete_space_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_space_modal').fadeIn(600);
    $('.close').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_organization_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_organization_modal').fadeIn(600);
    $('.close').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_app = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_app').fadeIn(600);
    $('.close').click(function(){$("#delete_app").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_service = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_service').fadeIn(600);
    $('.close').click(function(){$("#delete_service").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.btn').click(function(){$("#delete_service").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_user = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_user_modal').fadeIn(600);
    $('.close').click(function(){$("#delete_user_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}





var delete_this_space_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_this_space_modal').fadeIn(600);
    $('.close').click(function(){$("#delete_this_space_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.btn').click(function(){$("#delete_this_space_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
}

var delete_this_organization_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_this_organization_modal').fadeIn(600);
    $('.close').click(function(){$("#delete_this_organization_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
    $('.btn').click(function(){$("#delete_this_organization_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"});});
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
$('.delete-user-button').click(delete_user);


$('.delete_this_organization').click(delete_this_organization_modal);
$('.delete_this_space').click(delete_this_space_modal);





var bind_service = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#bind_service_modal').fadeIn(600);
    $('.close').click(function(){$("#bind_service_modal").css("display", "none");$('#screen').css("display", "none")});
}

var unbind_service = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#unbind_service_modal').fadeIn(600);
    $('.close').click(function(){$("#unbind_service_modal").css("display", "none");$('#screen').css("display", "none")});
}


var bind_uri = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#bind_uri_modal').fadeIn(600);
    $('.close').click(function(){$("#bind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
}

var unbind_uri = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#unbind_uri_modal').fadeIn(600);
    $('.close').click(function(){$("#unbind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
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


//create template app fade in and out


$('.create_app_header_tab_left').click(function(){
    $('#create_app_templates').hide();
    $('#create_app_templates_list').hide();

    $(this).css('border-bottom', '1px solid #ffffff');
    $('.create_app_header_tab_right').css('border-bottom', '0 solid #ffffff');

    $('#create_app_samples_list').fadeIn(600);
    $('#create_app_samples').fadeIn(600);
});

$('.create_app_header_tab_right').click(function(){
    $('#create_app_samples').hide();
    $('#create_app_samples_list').hide();

    $(this).css('border-bottom', '1px solid #ffffff');
    $('.create_app_header_tab_left').css('border-bottom', '0 solid #ffffff');

    $('#create_app_templates_list').fadeIn(600);
    $('#create_app_templates').fadeIn(600);
});



$('.create_app_side_list_templates_li').click(function(){
    var th = $(this).html();

    $('.create_app_side_list_templates_li').css('border-bottom', '0px solid #ffffff');
    $('.create_app_side_list_templates_li').css('font-weight', '200');
    $(this).css('border-bottom', '1px solid #ffffff');
    $(this).css('font-weight', '800');

    $('.create_app_side_container').hide();
    $('#' + th + '').fadeIn(600);
});

$('.create_app_side_list_samples_li').click(function(){
    $('#create_app_sample_1').fadeIn(600);
});




