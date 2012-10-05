$(function(){

$('.show_this_app_details').hover(function(){

    var name = $(this).contents().find("span:nth-child(1)").attr("id");
    var state = $(this).contents().children("span:nth-child(2)").attr("id");
    var instances = $(this).contents().children("span:nth-child(3)").attr("id");
    var memory = $(this).contents().children("span:nth-child(4)").attr("id");
    var services = $(this).contents().children("span:nth-child(5)").attr("id");



    $('#app_name_big').text(name);
    $('#pass_service_name').text(services);
    $('#pass_app_instances').text(instances);
    $('#pass_app_status').text(state);
    $('#pass_app_memory').text(memory);

    $('#details_app_name_start').val(name);
    $('#details_app_name_stop').val(name);


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



}, function(){
});

});