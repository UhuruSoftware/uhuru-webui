function showSpacesInput()
{
    $('#space_input').css({ "display": "block" });
    $('#space_input').val($('#space_name').attr('innerHTML'))
    $('#space_input').focus();
    $('#space_name').css({ "display": "none" });
}

function showOrganizationsInput()
{
    $('#organization_input').css({ "display": "block" });
    $('#organization_input').val($('#space_name').attr('innerHTML'))
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

$('.tiped').bind({
    focus: function() {
        $('.tooltips').show(200);
    },
    blur: function() {
        $('.tooltips').hide(300);
    }
});













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



