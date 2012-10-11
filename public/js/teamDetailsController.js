
//THIS FUNCTION SETS THE VARIABLES TO THE APP DETAILS ON THE CURRENT HOWERED APP TILE



$('.read_app_details').hover(function(){

    var id = $(this).contents().find("span:nth-child(1)").attr("id");
    var element = $('body').find('#' + id);

    var displayAppDetails = function(){
            $('#opac_screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
            $('body').css({"overflow":"hidden"});
            element.fadeIn(800);
            $('.app_details_closebtn').click(function(){$('.app_details_modal').css("display", "none");$('#opac_screen').css("display", "none")});
            $('.close_app_details').click(function(){$('.app_details_modal').css("display", "none");$('#opac_screen').css("display", "none")});
        }

    $('.show_this_app_details').click(displayAppDetails);
});



$(function(){

$('.read_app_details').hover(function(){

    var state = $(this).contents().children("span:nth-child(2)").attr("id");

    if(state == "stopped" || state == "STOPPED")
    {
        $('.stopApp_btn').css("display", "none");
        $('.startApp_btn').css("display", "block");
    }
    else
    {
        $('.stopApp_btn').css("display", "block");
        $('.startApp_btn').css("display", "none");
    }
    });
});

//THIS GETS ALL THE VALUES TO EACH MODAL

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

    var changed = false;


    var instance = $('.app_instances_count').text();
    var memory = $('.app_memory_count').text();
    //alert(instance);
    var firstMemory = $('.send_app_memory').val();
    var firstInstance = $('.send_app_instances').val();

    instance = parseInt(instance);
    memory = parseInt(memory);


    var plus_instance = function(){
            instance+=1;
            instance = instance + ""
            $('.app_instances_count').text(instance);
            $('.send_app_instances').val(instance);
            instance = parseInt(instance);

            showButton();
    }

    var minus_instance = function(){
        if(instance > 0)
        {
            instance-=1;
            instance = instance + ""
            $('.app_instances_count').text(instance);
            $('.send_app_instances').val(instance);
            instance = parseInt(instance);

            showButton();
        }
    }

     //
        //plus and minus memory at app details
    //

    var plus_memory = function(){
        if(memory < 2048)
        {
            memory+=32;
            memory = memory + ""
            $('.app_memory_count').text(memory);
            $('.send_app_memory').val(memory);
            memory = parseInt(memory);

            showButton();
        }
    }

    var minus_memory = function(){
        if(memory > 0)
        {
            memory-=32;
            memory = memory + ""
            $('.app_memory_count').text(memory);
            $('.send_app_memory').val(memory);
            memory = parseInt(memory);

            showButton();
        }
    }


//PLUS AND MINUS

    $('.app_plus_instance').click(plus_instance);
    $('.app_minus_instance').click(minus_instance);

    $('.app_plus_memory').click(plus_memory);
    $('.app_minus_memory').click(minus_memory);



    $( "#slider" ).slider({
        value:memory,
        min: 0,
        max: 2048,
        step: 32,
        slide: function( event, ui ) {
            $( ".app_memory_count" ).text( ui.value );
        }
    });
    $( ".app_memory_count" ).text( $( "#slider" ).slider( "value" ) );



    function showButton()
    {
        $('.hidden_app_details_submit_button').show();
    }



});



