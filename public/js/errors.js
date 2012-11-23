
$(window).load(function () {
var login = $('#login_failed').html();
var signup = $('#sign_up_failed').html();

var error_create_credit = $('#create_credit_failed');
var error_delete_credit = $('#delete_credit_failed');
var error_add_credit = $('#add_credit_failed');

var error_create_organization = $('#create_organization_failed').html();
var error_delete_organization = $('#delete_organization_failed').html();
var error_delete_this_organization = $('#delete_this_organization_failed').html();
var error_delete_this_space = $('#delete_this_space_failed').html();

var error_create_space = $('#create_space_failed').html();
var error_delete_space = $('#delete_space_failed').html();


var error_create_user = $('#create_user_failed').html();
var error_delete_user = $('#delete_user_failed').html();


var error_create_app = $('#create_app_failed').html();
var error_update_app = $('#update_app_failed').html();
var error_delete_app = $('#delete_app_failed').html();
var error_create_service = $('#create_service_failed').html();
var error_delete_service = $('#delete_service_failed').html();

var error_start_app = $('#start_app_failed').html();
var error_stop_app = $('#stop_app_failed').html();

var error_bind_service = $('#bind_service_failed').html();
var error_unbind_service = $('#unbind_service_failed').html();
var error_bind_url = $('#bind_url_failed').html();
var error_unbind_url = $('#unbind_url_failed').html();

    if(login == "Wrong email and/or password!")
    {
        $('input[name=username]').trigger('focus');
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#login_modal').fadeIn(60);
        $('.close').click(function(){$("#login_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#login_failed').html('');});
        $('.cancel').click(function(){$("#login_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#login_failed').html('');});
   }

    if(signup == "Email already exists try another one!" || signup == "Server couldn't create the default organization!" || signup == "Server did not respond!")
    {
        $('input[name=email]').trigger('focus');
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#signup_modal').fadeIn(60);
        $('.close').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#sign_up_failed').html('');});
        $('.cancel').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#sign_up_failed').html('');});
   }



    if(error_create_organization == "Create organization failed(try other names)!")
    {
        $('#screen').css({"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#create_organization').fadeIn(600);
        $('.close').click(function(){$("#create_organization").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#create_organization_failed').html('');});
        $('.cancel').click(function(){$("#create_organization").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#create_organization_failed').html('');});
        $('#org_name').focus();
    }

    if(error_create_space == "Create space failed(try other names)!")
    {
        $('#screen').css({"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#create_space').fadeIn(600);
        $('.close').click(function(){$("#create_space").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#create_space_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#create_space").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#create_space_failed').html(''); location.reload();});
        $('#space_name').focus();
    }

    if(error_delete_organization == "You are not authorized to delete this organization!" || error_delete_this_organization == "You are not authorized to delete this organization!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#delete_organization_modal').fadeIn(600);
        $('.btn-danger').hide();
        $('.modal-body').html('');
        $('.modal-body').html('<p>Error!</p>');
        $('.close').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#delete_organization_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#delete_organization_failed').html(''); location.reload();});
    }

    if(error_delete_space == "You are not authorized to delete this space!" || error_delete_this_space == "You are not authorized to delete this space!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#delete_space_modal').fadeIn(600);
        $('.btn-danger').hide();
        $('.modal-body').html('');
        $('.modal-body').html('<p>Error!</p>');
        $('.close').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#delete_space_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#delete_space_failed').html(''); location.reload();});
    }

    if(error_create_user == "Can't add user to space: user doesn't exist!" || error_create_user == "Can't add user to organization: user doesn't exist!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#add_user').fadeIn(600);
        $('.close').click(function(){$("#add_user").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#create_user_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#add_user").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#create_user_failed').html(''); location.reload();});
    }

    if(error_delete_user == "You are not authorized to delete this user!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#delete_user_modal').fadeIn(600);
        $('.btn-danger').hide();
        $('.modal-body').html('');
        $('.modal-body').html('<p>Error!</p>');
        $('.close').click(function(){$("#delete_user_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#delete_user_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#delete_user_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#delete_user_failed').html(''); location.reload();});
    }

    if(error_create_app == "App was not created: server error!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#create_tempcta_modal').fadeIn(600);
        $('.close').click(function(){$("#create_tempcta_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#create_app_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#create_tempcta_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#create_app_failed').html(''); location.reload();});
    }

    if(error_delete_app == "App was not deleted: server error!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#delete_app').fadeIn(600);
        $('.btn-danger').hide();
        $('.modal-body').html('');
        $('.modal-body').html('<p>Error!</p>');
        $('.close').click(function(){$("#delete_app").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#delete_app_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#delete_app").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#delete_app_failed').html(''); location.reload();});
    }

    if(error_create_service == "Service was not created: server error!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#add_ctService_modal').fadeIn(600);
        $('.close').click(function(){$("#add_ctService_modal").css("display", "none");$('#screen').css("display", "none"); $('#unbind_url_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#add_ctService_modal").css("display", "none");$('#screen').css("display", "none"); $('#unbind_url_failed').html(''); location.reload();});
    }

    if(error_delete_service == "Service was not deleted: server error!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#delete_service').fadeIn(600);
        $('.btn-danger').hide();
        $('.modal-body').html('');
        $('.modal-body').html('<p>Error!</p>');
        $('.close').click(function(){$("#delete_service").css("display", "none");$('#screen').css("display", "none"); $('#unbind_url_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#delete_service").css("display", "none");$('#screen').css("display", "none"); $('#unbind_url_failed').html(''); location.reload();});
    }



    if(error_bind_service == "Can't bind this service to app!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#bind_service_modal').fadeIn(600);
        $('.close').click(function(){$("#bind_service_modal").css("display", "none");$('#screen').css("display", "none"); $('#bind_service_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#bind_service_modal").css("display", "none");$('#screen').css("display", "none"); $('#bind_service_failed').html(''); location.reload();});
    }

    if(error_unbind_service == "Can't unbind this service from app!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#unbind_service_modal').fadeIn(600);
        $('.btn-danger').hide();
        $('.modal-body').html('');
        $('.modal-body').html('<p>Error!</p>');
        $('.close').click(function(){$("#unbind_service_modal").css("display", "none");$('#screen').css("display", "none"); $('#unbind_service_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#unbind_service_modal").css("display", "none");$('#screen').css("display", "none"); $('#unbind_service_failed').html(''); location.reload();});
    }

    if(error_bind_url == "Can't bind this url to app!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#bind_uri_modal').fadeIn(600);
        $('.close').click(function(){$("#bind_uri_modal").css("display", "none");$('#screen').css("display", "none"); $('#bind_url_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#bind_uri_modal").css("display", "none");$('#screen').css("display", "none"); $('#bind_url_failed').html(''); location.reload();});
    }

    if(error_unbind_url == "Can't unbind this url from app!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#unbind_uri_modal').fadeIn(600);
        $('.btn-danger').hide();
        $('.modal-body').html('');
        $('.modal-body').html('<p>Error!</p>');
        $('.close').click(function(){$("#unbind_uri_modal").css("display", "none");$('#screen').css("display", "none"); $('#unbind_url_failed').html(''); location.reload();});
        $('.cancel').click(function(){$("#unbind_uri_modal").css("display", "none");$('#screen').css("display", "none"); $('#unbind_url_failed').html(''); location.reload();});
    }


    if(error_create_credit == "Create credit card failed, try again!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#create_credit_card_modal').fadeIn(600);
        $('.close').click(function(){$("#create_credit_card_modal").css("display", "none");$('#screen').css("display", "none");$('#show_modal_errors').hide();$('body').css({"overflow":"auto"});});
        $('.cancel').click(function(){$("#create_credit_card_modal").css("display", "none");$('#screen').css("display", "none");$('#show_modal_errors').hide();$('body').css({"overflow":"auto"});});
    }

    if(error_add_credit == "Add credit card failed, try again!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#add_credit_card_to_organization_modal').fadeIn(600);
        $('.close').click(function(){$("#add_credit_card_to_organization_modal").css("display", "none");$('#screen').css("display", "none");$('#show_modal_errors').hide();$('body').css({"overflow":"auto"}); location.reload();});
        $('.cancel').click(function(){$("#add_credit_card_to_organization_modal").css("display", "none");$('#screen').css("display", "none");$('#show_modal_errors').hide();$('body').css({"overflow":"auto"}); location.reload();});
    }

    if(error_delete_credit == "Delete credit card failed, try again!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#delete_credit_card_modal').fadeIn(600);
        $('.btn-danger').hide();
        $('.modal-body').html('');
        $('.modal-body').html('<p>Error!</p>');
        $('.close').click(function(){$("#delete_credit_card_modal").css("display", "none");$('#screen').css("display", "none");$('#show_modal_errors').hide();$('body').css({"overflow":"auto"}); location.reload();});
        $('.cancel').click(function(){$("#delete_credit_card_modal").css("display", "none");$('#screen').css("display", "none");$('#show_modal_errors').hide();$('body').css({"overflow":"auto"}); location.reload();});
    }

    if(error_update_app == "App was not updated: server error!")
    {
        //
    }

    if(error_start_app == "Can't start app!")
    {

            //$('#opac_screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
            //$('body').css({"overflow":"hidden"});
            //element.fadeIn(800);
            $('.close_app_details').click(function(){$('.app_details_modal').css("display", "none");$('#opac_screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#start_app_failed').html(''); $('#stop_app_failed').html('');});
            $('.close').click(function(){$('.app_details_modal').css("display", "none");$('#opac_screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#start_app_failed').html(''); $('#stop_app_failed').html('');});
    }
    if(error_stop_app == "Can't stop app!")
    {
        //
    }

});