



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




var cancel_error_modal = function()
{
    $('.dark_background_error').hide(200);
    $('#errors_modal').hide(200);
}


$('.button_error_cancel').click(cancel_error_modal);





