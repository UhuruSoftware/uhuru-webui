/*

    These functions control the big app modal and all its functionality

*/

var element = "";

$('.tile_app_name').hover(function(){

    var id = $(this).contents().find("span:nth-child(1)").attr("id");
    element = $('body').find('#details_' + id);

    var displayAppDetails = function(){
            $('#opac_screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
            $('body').css({"overflow":"hidden"});
            element.fadeIn(800);
            $('.close_app_details').click(function(){$('.app_details_modal').css("display", "none");$('#opac_screen').css("display", "none");$('body').css({"overflow":"auto"});});
            $('.close').click(function(){$('.app_details_modal').css("display", "none");$('#opac_screen').css("display", "none");$('body').css({"overflow":"auto"});});
        }
    $('.show_this_app_details').click(displayAppDetails);
});

$(function(){

$('.bind_uri_footer').hover(function(){
    var name = $('#newUri').val();
    $('#uriName').val(name);
});

$('.get_uri_name').hover(function(){
    var name = $(this).attr("id");
    var app = $(this).attr("title");

    $('#unbind_uriName').val(name);

    $('#bind_uri_app_name').val(app);
    $('#unbind_uri_app_name').val(app);
});
$('.get_service_name').hover(function(){
    var name = $(this).attr("id");
    var app = $(this).attr("title");

    $('#unbind_serviceName').val(name);

    $('#bind_service_app_name').val(app);
    $('#unbind_service_app_name').val(app);
});

});




$(function(){
    var memory = $('.app_memory_count').text();
    var instance = 1;


    var firstInstance = $('.send_app_instances').val();

    instance = parseInt(instance);
    memory = parseInt(memory);


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





$('.tile_app_name').click(function(){

var appName = $(this).contents().find("span:nth-child(1)").attr("id");
var sliderId = $('body').find('#slider_' + appName);
var insMemory = $(this).contents().find("span:nth-child(4)").attr("id");

$(function() {


            var slider = sliderId.slider({
                min: 0,
                max: 1024,
                step: 32,
            value: insMemory,
                range: "min",
                change: function(event, ui) {
                            var sliderValue = sliderId.slider( "option", "value" );
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
    var sliderCurrentValue = sliderId.slider( "option", "value" );
      slider.slider( "value", sliderCurrentValue + 32 );
    });

    $('.app_minus_memory').click(function() {
    var sliderCurrentValue = sliderId.slider( "option", "value" );
      slider.slider( "value", sliderCurrentValue - 32 );
    });

});

});








$('.app_plus_instance').click(plus_instance);
$('.app_minus_instance').click(minus_instance);


        function showButton()
        {
            $('.hidden_app_details_submit_button').show();
        }

});



