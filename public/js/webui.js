
function show_modal(modal)
{
    $('body').addClass('noscroll');
    $('.modal-background').show();
    modal.show();
    modal.animate({
        top: '130px',
        opacity: '1'
    }, 250);
}

function hide_modal(modal, execute_after)
{
    modal.animate({ top: '0px', opacity:'0' }, 250,
        function(){
            modal.hide();
            $('.modal-background').hide();
            $('body').removeClass('noscroll');

            if (typeof execute_after !== 'undefined')
            {
                execute_after();
            }
        });
}


$(document).ready(function(){
    if ($('#modal_login').length)
    {
        show_modal($('#modal_login'));
    }
});

$('#logout_key').click(function(){
    show_modal($('.modal.logout'));
});

/* cancel buttons on all modals hide the modal */
$('.cancel_button').click(function(){
    hide_modal($('.modal'));
});

function showSpacesInput()
{
    $('#space_input').css({ "display": "block" });
    $('#space_input').val($('#space_name').attr('innerHTML'));
    $('#space_input').focus();
    $('#space_name').css({ "display": "none" });
}

function showOrganizationsInput()
{
    $('#organization_input').css({ "display": "block" });
    $('#organization_input').val($('#space_name').attr('innerHTML'));
    $('#organization_input').focus();
    $('#organization_name').css({ "display": "none" });
}

function deleteCurrentOrganization()
{
    show_modal($('#delete_current_organization_modal'));
}

function deleteCurrentSpace()
{
    show_modal($('#delete_current_space_modal'));
}

var delete_selected_element = function(){
    $('#selected_guid').val($(this).attr("id"));
    $('#selected_name').text($(this).attr("title"));

    show_modal($('.delete_confirmation'));
}

function deleteUserModal(this_, role)
{
    $('#selected_guid').val($(this_).attr("id"));
    $('#selected_name').text($(this_).attr("title"));
    $('#aditional_data').val(role);

    show_modal($('.delete_confirmation.user'));
}

/* ALL THE DELETE MODALS ARE CALLED FROM HERE, EXCEPT THE DELETE USERS
 DELETE USERS HAVE AN ADDITIONAL PARAMETER AND THE THIS POINTER */
$('.tile.org .tile.top :button').click(delete_selected_element);
$('.tile.space .tile.top :button').click(delete_selected_element);
$('.tile.app .tile.top :button').click(delete_selected_element);
$('.tile.service .tile.top :button').click(delete_selected_element);
$('.square_tile .square_tile.domain :button').click(delete_selected_element);
$('.square_tile .square_tile.route :button').click(delete_selected_element);

/* the binding for focus and blur for the update input boxes */
$('.tiped').bind({
    focus: function() {
        $('.tooltips').show(200);
    },
    blur: function() {
        $('.tooltips').hide(300);
    }
});






var bind_service = function(){
    $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
    $('body').css({"overflow":"hidden"});
    $('#bind_service_modal').fadeIn(600);
    $('.close').click(function(){$("#bind_service_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.cancel').click(function(){$("#bind_service_modal").css("display", "none");$('#screen').css("display", "none")});
}

var bind_uri = function(){
    $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
    $('body').css({"overflow":"hidden"});
    $('#bind_uri_modal').fadeIn(600);
    $('.close').click(function(){$("#bind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.cancel').click(function(){$("#bind_uri_modal").css("display", "none");$('#screen').css("display", "none")});
}



/****************************************************/
/*                APP DETAILS                       */
/****************************************************/



//var bind_service = $.ajax({
//        url: "/bindServices",
//        type: 'POST',
//        cache: false,
//        data: { appName: $('#app_name').val() , serviceName: $('#service_name').val(), current_organization: $('#current_organization').val(), current_space: $('#current_space').val(), current_tab: $('#current_tab').val() }
//    });
//
//var bind_uri = $.ajax({
//    url: "/bindUri",
//    type: 'POST',
//    cache: false,
//    data: { appName: $('#uri_app_name').val() , serviceName: $('#uri_domain_name').val() }
//});

var unbind_service = function(){
    $('.unbind_service').fadeIn(600);
    var name = $(this).attr("id");
    $('#unbind_serviceName').val(name);
}
var unbind_uri = function(){
    $('.unbind_uri').fadeIn(600);
    var name = $(this).attr("id");
    $('#unbind_uriName').val(name);
}

/* cancel buttons on all modals inside the app details */
$('.cancel_button_app_details').click(function(){

    $(".unbind_service").css("display", "none");
    $(".unbind_uri").css("display", "none");
});


$('.bind_service_button').click(bind_service);
$('.bind_uri_button').click(bind_uri);
$('.unbind_service_button').click(unbind_service);
$('.unbind_uri_button').click(unbind_uri);



/*
 APP DETAILS UPDATE MEMORY AND INSTANCES
 */

var saving_modal = function()
{
    $('.modal-background').css({	display: "block", opacity: 0.9, width: "10000px", height: "10000px"});
    $('body').css({"overflow":"hidden"});
    $('#saving_modal').fadeIn(400);
    $('.stopApp_btn').css("display", "block");
    $('.startApp_btn').css("display", "none");
}

$('.start_app').click(saving_modal);
$('.stop_app').click(saving_modal);


$('.add_instance').click(function(){
    var new_value = parseInt($('.instances_count').val()) + 1;
    if(new_value <= 10)
    {
        $('.instances_count').val(new_value.toString());
        $('.send_app_instances').val(new_value.toString());
    }
});
$('.subtract_instance').click(function(){
    var new_value = parseInt($('.instances_count').val()) - 1;
    if(new_value > 0)
    {
        $('.instances_count').val(new_value.toString());
        $('.send_app_instances').val(new_value.toString());
    }
});


$('.add_memory').click(function(){
    var new_value = parseInt($('#app_memory_setup').val()) + 32;
    if(new_value <= 1024)
    {
        $('#app_memory_setup').val(new_value.toString());
        $('.send_app_memory').val(new_value.toString());
    }
});
$('.subtract_memory').click(function(){
    var new_value = parseInt($('#app_memory_setup').val()) - 32;
    if(new_value > 0)
    {
        $('#app_memory_setup').val(new_value.toString());
        $('.send_app_memory').val(new_value.toString());
    }
});


$('.update_button').hover(function(){
    var memory = $('#app_memory_setup').val();
    var instances = $('.instances_count').val();
    $('.send_app_memory').val(memory);
    $('.send_app_instances').val(instances);
});