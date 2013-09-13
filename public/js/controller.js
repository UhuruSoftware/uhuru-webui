

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



