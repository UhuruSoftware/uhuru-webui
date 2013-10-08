function show_modal(modal, profiled)
{
    $('body').addClass('noscroll');
    if(profiled)
    {
        $('.modal-background').css("z-index", "20");
    }
    else
    {
        $('.modal-background').show();
    }
    modal.show();
    modal.animate({
        top: '130px',
        opacity: '1'
    }, 250);
}

function hide_modal(modal, profiled, execute_after)
{
    modal.animate({ top: '0px', opacity:'0' }, 250,
        function(){
            modal.hide();
            if(profiled)
            {
                $('.modal-background').css("z-index", "10");
            }
            else
            {
                $('.modal-background').hide();
            }

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
    if ($('#modal_signup').length)
    {
        show_modal($('#modal_signup'));
    }
});

$('#logout_key').click(function(){
    show_modal($('.modal.logout'));
});

/* cancel buttons on all modals hide the modal */
$('.cancel_button').click(function(){
    hide_modal($('.modal'));
});




/*********************************************************************************************************/
/*                                            DELETE MODALS                                              */
/*********************************************************************************************************/


var delete_selected_element = function(){
    $('.selected_guid').val($(this).attr("id"));
    $('.selected_name').text($(this).attr("title"));

    show_modal($('.delete_confirmation'));
}
function deleteUserModal(this_, role)
{
    $('.selected_guid').val($(this_).attr("id"));
    $('.selected_name').text($(this_).attr("title"));
    $('#aditional_data').val(role);

    show_modal($('.delete_confirmation.user'));
}
$('.tile.org .tile.top :button').click(delete_selected_element);
$('.tile.space .tile.top :button').click(delete_selected_element);
$('.tile.app .tile.top :button').click(delete_selected_element);
$('.tile.service .tile.top :button').click(delete_selected_element);
$('.square_tile .square_tile.domain :button').click(delete_selected_element);
$('.square_tile .square_tile.route :button').click(delete_selected_element);



/*********************************************************************************************************/
/*                                            APP DETAILS                                                */
/*********************************************************************************************************/


var bind_service = function(){
    $.ajax({
        url: "/bindServices",
        type: 'POST',
        cache: false,
        data: { appName: $('#app_name').val() , serviceName: $('#service_name').val(), current_organization: $('#current_organization').val(), current_space: $('#current_space').val(), current_tab: $('#current_tab').val() }
    })
        .done(function( msg ) {
            location.reload();
        });
}

var bind_uri = function(){
    $.ajax({
        url: "/bindUri",
        type: 'POST',
        cache: false,
        data: { appName: $('#app_name').val() , domain: $('#uri_domain_name').val(), host: $('#uri_host').val(), current_organization: $('#current_organization').val(), current_space: $('#current_space').val(), current_tab: $('#current_tab').val() }
    })
        .done(function( msg ) {
            location.reload();
        }   );
}

var unbind_service = function(){
    show_modal($('.unbind_service'), true);

    var name = $(this).attr("id");
    $('#unbind_serviceName').val(name);
}
var unbind_uri = function(){
    show_modal($('.unbind_uri'), true);

    var name = $(this).attr("id");
    $('#unbind_uriName').val(name);
}

/* cancel buttons on all modals inside the app details */
$('.cancel_button_app_details').click(function(){
    hide_modal($(".unbind_service"), true);
    hide_modal($(".unbind_uri"), true);
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
    show_modal($('#saving_modal'), false);
    $('.stopApp_btn').css("display", "none");
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


$('.selected_service').change(function(){
    $.ajax({
        url: "/get_service_data",
        type: 'POST',
        cache: false,
        data: { service_name: $(this).children(":selected").val(), current_organization: $('#current_organization').val(), current_space: $('#current_space').val(), current_tab: $('#current_tab').val() }
    })

        .done(function( data ) {
            var values = jQuery.parseJSON( data );
            $('#refresh_service_type').html(values.type);
            $('#refresh_service_plan').html(values.plan);
        }   );
});

$('.update_button').hover(function(){
    var memory = $('#app_memory_setup').val();
    var instances = $('.instances_count').val();
    $('.send_app_memory').val(memory);
    $('.send_app_instances').val(instances);
});


/*********************************************************************************************************/
/*                                            CLOUD FEEDBACK                                             */
/*********************************************************************************************************/

if (cloudFeedbackTimerId === undefined)
{
    var cloudFeedbackTimerId = -1;

    function getCloudFeedback(){

        var request = $.ajax(
            {
                url: "/feedback/" + $(".cloud_feedback").attr('id'),
                type: 'GET',
                cache: false,
                error: function(data)
                {
                    $(".cloud_feedback").html("there was an error");
                    $(".feedback_loading").hide();
                    clearInterval(cloudFeedbackTimerId);
                },
                success: function(response)
                {
                    var instructions = request.getResponseHeader('X-Webui-Feedback-Instructions');
                    var newText = response;
                    if (instructions == 'continue')
                    {
                        if (newText !== '')
                        {
                            $(".cloud_feedback").html(newText);
                        }
                    }
                    else
                    {
                        if (newText !== '')
                        {
                            $(".cloud_feedback").html(newText);
                        }
                        $(".feedback_loading").hide();
                        window.clearInterval(cloudFeedbackTimerId);
                    }

                    var currentHeight = logDiv.scrollHeight;
                    if (lastHeight != currentHeight && scrollToEnd) {
                        logDiv.scrollTop = currentHeight;
                        lastHeight = logDiv.scrollTop;
                    }
                }
            });
    }

    if (($('.cloud_feedback').length > 0))
    {
        $(".feedback_loading").show();
        cloudFeedbackTimerId = window.setInterval(getCloudFeedback,  1000);

        var logDiv = document.getElementById($('.cloud_feedback').attr('id'));
        var scrollToEnd = true;
        var lastHeight = -1;

        $('.cloud_feedback').onscroll = function () {
            if (scrollToEnd && !(logDiv.scrollTop >= 0.95 * (logDiv.scrollHeight - logDiv.clientHeight))) {
                scrollToEnd = false;
            }
            else {
                if (logDiv.scrollTop >= 0.95 * (logDiv.scrollHeight - logDiv.clientHeight)) {
                    scrollToEnd = true;
                }
            }
        }
    }
}