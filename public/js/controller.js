

//
//          CONTROLLER FOR THE LANDING PAGE PLACEHOLDERS
//

$('[placeholder]').focus(function() {
    var input = $(this);
    input.css("font-style", "normal");
    input.css("color", "#ffffff");
    if (input.val() == input.attr('placeholder')) {
        input.val('');
        input.removeClass('placeholder');
    }
}).blur(function() {
        var input = $(this);
        input.css("font-style", "italic");
        input.css("color", "gray");
        if (input.val() == '' || input.val() == input.attr('placeholder')) {
            input.addClass('placeholder');
            input.val(input.attr('placeholder'));
        }
    }).blur();

$('[placeholder]').parents('form').submit(function() {
    $(this).find('[placeholder]').each(function() {
        var input = $(this);
        if (input.val() == input.attr('placeholder')) {
            input.val('');
        }
    })
});






//
//          CONTROLLING THE UPDATE ORG AND SPACE INPUT BOX AND TEXT (NAME UPDATES)
//

function showSpacesInput()
{
    document.getElementById('space_input').style.display = 'block';
    document.getElementById('space_input').value = document.getElementById('space_name').innerHTML;
    document.getElementById('space_input').focus();
    document.getElementById('space_input').style.border = '1px solid #2eccfa';
    document.getElementById('space_name').style.display = 'none';
}

function showOrganizationsInput()
{
    document.getElementById('organization_input').style.display = 'block';
    document.getElementById('organization_input').value = document.getElementById('organization_name').innerHTML;
    document.getElementById('organization_input').focus();
    document.getElementById('organization_input').style.border = '1px solid #2eccfa';
    document.getElementById('organization_name').style.display = 'none';
}

$('.tiped').bind({
    focus: function() {
        $('.tooltips').show(200);
    },
    blur: function() {
        $('.tooltips').hide(300);
    }
});




//
//          PASSING DATA TO DELETE MODALS
//


var delete_organization = function()
{
    $('#org_guid').val($(this).attr("id"))
    $('#this_organization_name').text($(this).attr("title"));
}
var delete_space = function()
{
    $('#space_guid').val($(this).attr("title"));
    $('#this_space_name').text($(this).attr("id"));
}
var delete_domain = function()
{
    $('#domain_guid').val($(this).attr("title"));
    $('#this_domain_name').text($(this).attr("id"));
}
var delete_app = function()
{
    $('#pass_app').val($(this).attr("id"));
    $('#this_app_name').text($(this).attr("id"));
}
var delete_service = function()
{
    $('#pass_service').val($(this).attr("title"));
    $('#this_service_name').text($(this).attr("id"));
}
var delete_route = function()
{
    $('#pass_route_guid').val($(this).attr("id"));
}


$('.delete-organization-button').click(delete_organization);
$('.delete-space-button').click(delete_space);
$('.delete-domain-button').click(delete_domain);
$('.delete-app-button').click(delete_app);
$('.delete-service-button').click(delete_service);
$('.delete-route-button').click(delete_route);


var delete_owner = function()
{
    $('#this_user_name').text($(this).attr("title"));
    $('#pass_user_guid').val($(this).attr("id"));
    $('#pass_user_role').val("owner");
}
var delete_developer = function()
{
    $('#this_user_name').text($(this).attr("title"));
    $('#pass_user_guid').val($(this).attr("id"));
    $('#pass_user_role').val("developer");
}
var delete_auditor = function()
{
    $('#this_user_name').text($(this).attr("title"));
    $('#pass_user_guid').val($(this).attr("id"));
    $('#pass_user_role').val("auditor");
}

$('.btn_delete_owner').click(delete_owner);
$('.btn_delete_developer').click(delete_developer);
$('.btn_delete_auditor').click(delete_auditor);


//bindings and unbindings

$('.get_uri_name').hover(function(){
    var name = $(this).attr("id");
    $('#unbind_uriName').val(name);
});
$('.get_service_name').hover(function(){
    var name = $(this).attr("id");
    $('#unbind_serviceName').val(name);
});



/*
                        APP DETAILS UPDATE
 */


$(function(){
    var instance = 1;
    var firstInstance = $('.send_app_instances').val();
    instance = parseInt(instance);
    var insMemory = $(this).contents().find("span:nth-child(4)").attr("id");

    var plus_instance = function(){
        instance+=1;
        instance = instance + "";
        $('.app_instances_count').text(instance);
        $('.send_app_instances').val(instance);
        instance = parseInt(instance);
        if(firstInstance != instance)
        {
            $('.hidden_app_details_submit_button').fadeIn('slow');
        }
        else
        {
            $('.hidden_app_details_submit_button').fadeOut('slow');
        }
    }

    var minus_instance = function(){
        instance-=1;
        instance = instance + "";
        $('.app_instances_count').text(instance);
        $('.send_app_instances').val(instance);
        instance = parseInt(instance);
        if(firstInstance != instance)
        {
            $('.hidden_app_details_submit_button').fadeIn('slow');
        }
        else
        {
            $('.hidden_app_details_submit_button').fadeOut('slow');
        }
    }



    $('.app_plus_instance').click(plus_instance);
    $('.app_minus_instance').click(minus_instance);


    $(function() {
        var slider = $('#slider_app_memory').slider({
            min: 0,
            max: 1024,
            step: 32,
            value: insMemory,
            range: "min",
            change: function(event, ui) {
                var sliderValue = $('#slider_app_memory').slider( "option", "value" );
                $('.app_memory_count').html(sliderValue);
                $('.send_app_memory').val(sliderValue);
                if(insMemory != sliderValue)
                {
                    $('.hidden_app_details_submit_button').fadeIn('slow');
                }
                else
                {
                    $('.hidden_app_details_submit_button').fadeOut('slow');
                }
            }

        });


        $('.app_plus_memory').click(function() {
            var sliderCurrentValue = $('#slider_app_memory').slider( "option", "value" );
            slider.slider( "value", sliderCurrentValue + 32 );
        });

        $('.app_minus_memory').click(function() {
            var sliderCurrentValue = $('#slider_app_memory').slider( "option", "value" );
            slider.slider( "value", sliderCurrentValue - 32 );
        });

    });
});



