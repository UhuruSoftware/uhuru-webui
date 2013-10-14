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
    $('#additional_data').val(role);

    show_modal($('.delete_confirmation.user'));
}
$('.tile.org .tile.top :button').click(delete_selected_element);
$('.tile.space .tile.top :button').click(delete_selected_element);
$('.tile.app .tile.top :button').click(delete_selected_element);
$('.tile.service .tile.top :button').click(delete_selected_element);
$('.square_tile .square_tile.domain :button').click(delete_selected_element);
$('.square_tile .square_tile.route :button').click(delete_selected_element);





/*********************************************************************************************************/
/***********                                 APP DETAILS                                     *************/
/*********************************************************************************************************/

//****************************  getting app state memory and instances  ******************************//
function getStateValue()
{
    if($('#app_state').is(":checked") == false)
    {
        $('#app_state').removeAttr('checked');
        return false
    }
    else
    {
        $('#app_state').attr('checked', 'checked');
        return true
    }
}

var app_instances_val = $('.app_instances').val();
var app_memory_val = $('.app_memory').val();
var app_state_val = getStateValue();

$('.add_instance').click(function(){
    var new_value = parseInt($('.instances_count').val()) + 1;
    if(new_value <= 10)
    {
        $('.instances_count').val(new_value.toString());
        $('.send_app_instances').val(new_value.toString());
        app_instances_val = new_value;
    }
});
$('.subtract_instance').click(function(){
    var new_value = parseInt($('.instances_count').val()) - 1;
    if(new_value > 0)
    {
        $('.instances_count').val(new_value.toString());
        $('.send_app_instances').val(new_value.toString());
        app_instances_val = new_value;
    }
});
$('.add_memory').click(function(){
    var new_value = parseInt($('#app_memory_setup').val()) + 32;
    if(new_value <= 1024)
    {
        $('#app_memory_setup').val(new_value.toString());
        $('.send_app_memory').val(new_value.toString());
        app_memory_val = new_value;
    }
});
$('.subtract_memory').click(function(){
    var new_value = parseInt($('#app_memory_setup').val()) - 32;
    if(new_value > 0)
    {
        $('#app_memory_setup').val(new_value.toString());
        $('.send_app_memory').val(new_value.toString());
        app_memory_val = new_value;
    }
});

$('.app_instances').blur(function(){
    app_instances_val = $(this).val();
});
$('.app_memory').blur(function(){
    app_memory_val = $(this).val();
});

$('#app_state').click(function(){
    app_state_val = getStateValue();
});


//*******************************  getting required variables  *********************************//
var selected_service_name = $('.selected_service').children(":selected").val();
var selected_service_type = $('.get_service_type').html();
var selected_service_plan = $('.get_service_plan').html();
var selected_url_host;
var selected_url_domain = $('.get_url_domain').children(":selected").html();
var selected_url_domain_guid = $('.get_url_domain').children(":selected").val();
$('.get_url_host').blur(function(){
    selected_url_host = $(this).val();
});
$('.get_url_domain').change(function(){
    selected_url_domain = $(this).children(":selected").html();
    selected_url_domain_guid = $(this).children(":selected").val();
});

var services = new Array();
var urls = new Array();

services = readServices();
urls = readUrls();

//***********************  getting list of services and urls from table  **********************//
function readServices()
{
    var table = document.getElementById('services_list');
    var r;
    var row;
    var data = new Array();

    if(table != undefined)
    {
        for(r = 1, row; row = table.rows[r], r < table.rows.length - 1; r++)
        {
            data.push({ name: row.cells[0].innerHTML, type: row.cells[1].innerHTML, plan: row.cells[2].innerHTML });
        }
    }
    return data;
}

function readUrls()
{
    var table = document.getElementById('urls_list');
    var r;
    var row;
    var data = new Array();

    if(table != undefined)
    {
        for(r = 1, row; row = table.rows[r], r < table.rows.length - 1; r++)
        {
            data.push({ host: row.cells[0].innerHTML, domain: row.cells[1].innerHTML, domain_guid: row.cells[2].innerHTML });
        }
    }
    return data;
}

//**************************  getting services from cloud controller  *************************//
$('.selected_service').change(function(){
    selected_service_name = $(this).children(":selected").val();
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
            selected_service_type = values.type;
            selected_service_plan = values.plan;
        }   );
});

//***********************  add services/urls in lists and render them in html  ********************//
var add_service = function(){
    var exists = false;
    if (services.length > 0)
    {
        var i;
        for(i = 0; i < services.length; i++)
        {
            if( services[i]['name'] != undefined && services[i]['name'] == selected_service_name )
            {
                exists = true;
            }
        }
    }

    if (exists == false)
    {
        services.push({ name: selected_service_name, type: selected_service_type, plan: selected_service_plan });

        var table = document.getElementById('services_list');
        var row = table.insertRow(1);
        var name = row.insertCell(0);
        name.className = name.className + 'name';
        var type = row.insertCell(1);
        var plan = row.insertCell(2);
        var action = row.insertCell(3);

        name.innerHTML = selected_service_name;
        type.innerHTML = selected_service_type;
        plan.innerHTML = selected_service_plan;
        action.innerHTML = "<button type='button' id=\'" + selected_service_name + "\' class='image s24px trash remove_service' title='Remove " + selected_service_name + "' onclick='removeService(this)'></button>";
        action.className = action.className + 'action';
    }
}

var add_url = function(){
    var exists = false;
    if (urls.length > 0)
    {
        var i;
        for(i = 0; i < urls.length; i++)
        {
            if(urls[i]['host'] != undefined || urls[i]['domain'] != undefined)
            {
                if(urls[i]['host'] == selected_url_host && urls[i]['domain'] == selected_url_domain)
                {
                    exists = true;
                }
            }
        }
    }

    if (exists == false)
    {
        urls.push({ host: selected_url_host, domain: selected_url_domain, domain_guid: selected_url_domain_guid });

        var table = document.getElementById('urls_list');
        var row = table.insertRow(1);
        var host = row.insertCell(0);
        host.className = host.className + 'name';
        var url = row.insertCell(1);
        url.className = url.className + 'url';
        var action = row.insertCell(2);

        host.innerHTML = selected_url_host;
        url.innerHTML = selected_url_domain;
        action.innerHTML = "<button type='button' id=\'" + selected_url_host + "\' class='image s24px trash remove_url' title='Remove " + selected_url_host + "' onclick='removeUrl(this)'></button>";
        action.className = action.className + 'action';
    }
}

function removeService(element){
    id = element.id;
    var table = document.getElementById('services_list');
    var r;
    var row;

    for(r = 1, row; row = table.rows[r], r < table.rows.length - 1; r++)
    {
        if(row.cells[0].innerHTML == id)
        {
            table.deleteRow(r);
            var s;

            for(s = 0; s <= services.length - 1; s++)
            {
                if(services[s]['name'] == id)
                {
                    services.splice(s, 1);
                }
            }
        }
    }
}

function removeUrl(element){
    id = element.id;
    var table = document.getElementById('urls_list');
    var r;
    var row;

    for(r = 1, row; row = table.rows[r], r < table.rows.length - 1; r++)
    {
        if(row.cells[0].innerHTML == id)
        {
            table.deleteRow(r);
            var s;

            for(s = 0; s <= urls.length - 1; s++)
            {
                if(urls[s]['host'] == id)
                {
                    urls.splice(s, 1);
                }
            }
        }
    }

}

$('#add_service').click(add_service);
$('#add_url').click(add_url);

//*******************************   update app button  *********************************************//
$('#update_app').hover(function(){
    $('#pass_app_state').val(app_state_val);
    $('#app_services').val(JSON.stringify(services));
    $('#app_urls').val(JSON.stringify(urls));
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


/*********************************************************************************************************/
/*                                            SERVICE CREATION - SERVICE PLANS                           */
/*********************************************************************************************************/


function fillSelect(services)
{
    var serviceId = $("#service_type").val();

    $("#service_plan").empty();

    $.each(services[serviceId]['plans'], function(key, value) {
        $('#service_plan')
            .append($("<option></option>")
            .attr("value",key)
            .text(value));
    });
}

if (($('#service_type').length > 0))
{
    $( document ).ready(function() {
        fillSelect(window.all_services);
    });
}
