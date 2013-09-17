
$('#logout_key').click(function(){
    $('.modal-background').css({ "display": "block" });
    $('body').css({"overflow":"hidden"});
    $('.modal.logout').fadeIn(600);
});

/* cancel buttons on all modals hide the modal */
$('.cancel_button').click(function(){
        $(".modal").css("display", "none");
        $('.modal-background').css("display", "none");
        $('body').css({"overflow":"auto"});}
);

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
    $('.modal-background').css({ "display": "block" });
    $('body').css({"overflow":"hidden"});
    $('#delete_current_organization_modal').fadeIn(600);
}

function deleteCurrentSpace()
{
    $('.modal-background').css({ "display": "block" });
    $('body').css({"overflow":"hidden"});
    $('#delete_current_space_modal').fadeIn(600);
}

var delete_selected_element = function(){
    $('#selected_guid').val($(this).attr("id"));
    $('#selected_name').text($(this).attr("title"));
    $('.modal-background').css({ "display": "block" });
    $('body').css({"overflow":"hidden"});
    $('.delete_confirmation').fadeIn(600);
}

function deleteUserModal(this_, role)
{
    $('#selected_guid').val($(this_).attr("id"));
    $('#selected_name').text($(this_).attr("title"));
    $('#aditional_data').val(role);
    $('.modal-background').css({ "display": "block" });
    $('body').css({"overflow":"hidden"});
    $('.delete_confirmation.user').fadeIn(600);
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

var bind_service = function(){
    $('.bind_service').fadeIn(600);
}
var bind_uri = function(){
    $('.bind_uri').fadeIn(600);
}
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

        $(".bind_service").css("display", "none");
        $(".unbind_service").css("display", "none");
        $(".bind_uri").css("display", "none");
        $(".unbind_uri").css("display", "none");
});

$('.bind_service_button').click(bind_service);
$('.bind_uri_button').click(bind_uri);

$('.rectangle_tile .rectangle_tile.service :button').click(unbind_service);
$('.rectangle_tile .rectangle_tile.uri :button').click(unbind_uri);



/*
 APP DETAILS UPDATE MEMORY AND INSTANCES
 */

$(function(){
    var instance = 1;
    var firstInstance = $('.send_app_instances').val();
    instance = parseInt(instance);
    var insMemory = $(this).contents().find("span:nth-child(4)").attr("id");

    var plus_instance = function(){
        instance+=1;
        instance = instance + "";
        $('.instances_count').val(instance);
        $('.send_app_instances').val(instance);
        instance = parseInt(instance);
        if(firstInstance != instance)
        {
            $('.update_button').fadeIn('slow');
        }
        else
        {
            $('.update_button').fadeOut('slow');
        }
    }

    var minus_instance = function(){
        instance-=1;
        instance = instance + "";
        $('.instances_count').val(instance);
        $('.send_app_instances').val(instance);
        instance = parseInt(instance);
        if(firstInstance != instance)
        {
            $('.update_button').fadeIn('slow');
        }
        else
        {
            $('.update_button').fadeOut('slow');
        }
    }

    $('.add_instance').click(plus_instance);
    $('.subtract_instance').click(minus_instance);
    $('.update_button').hover(function(){
        var memory = $('#app_memory_setup').val();
        $('.send_app_memory').val(memory);
    });



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

});


/* this code needs to be redone in another way */

//$(":submit").click(function(){
//    $(this).hide();
//    $(":button").hide();
//    $('.image').show();
//    $('.hidden_message').fadeIn(300);
//});
//$(document).ready(function(){
//    $(":submit").show();
//    $(":button").show();
//});
