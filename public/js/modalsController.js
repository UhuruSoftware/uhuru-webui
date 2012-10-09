
//THIS FUNCTION SETS THE VARIABLES TO THE APP DETAILS ON THE CURRENT HOWERED APP TILE

$(function(){

$('.show_this_app_details').hover(function(){


        var name = $(this).contents().find("span:nth-child(1)").attr("id");
        var state = $(this).contents().children("span:nth-child(2)").attr("id");
        var instances = $(this).contents().children("span:nth-child(3)").attr("id");
        var memory = $(this).contents().children("span:nth-child(4)").attr("id");
        var services = $(this).contents().children("span:nth-child(5)").attr("id");


        $('#app_name_big').text(name);
        $('#send_app_name').val(name);
        $('#pass_service_name').text(services);
        $('#pass_app_status').text(state);

        $('.pass_app_instances').text(instances);
        $('.pass_app_memory').text(memory);

        $('#details_app_name_start').val(name);
        $('#details_app_name_stop').val(name);


        //this sets the button startapp/stopapp poses

        if(state == "stopped" || state == "STOPPED")
        {
            $('#stopApp_btn').css("display", "none");
            $('#startApp_btn').css("display", "block");
        }
        else
        {
            $('#stopApp_btn').css("display", "block");
            $('#startApp_btn').css("display", "none");
        }


    });
});

$(function(){

    var changed = false;


    var instance = $('#app_instances_count span').text();
    var memory = $('#app_instances_count span').text();

    var firstMemory = $('#app_instances_count span').html();
    var firstInstance = $('#app_instances_count span').html();

    //instance = parseInt(instance);
    //memory = parseInt(memory);
     //
        //plus and minus instances at app details
    //

    var plus_instance = function(){
            instance+=1;
            instance = instance + ""
            $('#app_instances_count').text(instance);
            $('#send_app_instances').val(instance);
            instance = parseInt(instance);

            showButton();
    }

    var minus_instance = function(){
        if(instance > 0)
        {
            instance-=1;
            instance = instance + ""
            $('#app_instances_count').text(instance);
            $('#send_app_instances').val(instance);
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
            $('#app_memory_count').text(memory);
            $('#send_app_memory').val(memory);
            memory = parseInt(memory);

            showButton();
        }
    }

    var minus_memory = function(){
        if(memory > 0)
        {
            memory-=32;
            memory = memory + ""
            $('#app_memory_count').text(memory);
            $('#send_app_memory').val(memory);
            memory = parseInt(memory);

            showButton();
        }
    }


//PLUS AND MINUS

    $('#app_plus_instance').click(plus_instance);
    $('#app_minus_instance').click(minus_instance);

    $('#app_plus_memory').click(plus_memory);
    $('#app_minus_memory').click(minus_memory);

    function showButton()
    {
        $('#hidden_app_details_submit_button').show();
    }

});




