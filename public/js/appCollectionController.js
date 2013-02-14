$(".collection_tab_btn").click(function(){
    var tab = $(this).attr("id");

    $(".hide_all_collections").hide();
    $(".hide_all_apps").hide();
    $(".collection_tab_btn").css("background-color", "#0e4769");

    $("#" + tab).css("background-color", "#000000");
    $("#" + tab + "_div").show();
    $("." + tab + "_div_apps").show();
});

//$('.create_app_side_list_templates_li').click(function(){
//    var th = $(this).html();
//
//    $('.create_app_side_list_templates_li').css('border-bottom', '0px solid #ffffff');
//    $('.create_app_side_list_templates_li').css('font-weight', '200');
//    $(this).css('border-bottom', '1px solid #ffffff');
//    $(this).css('font-weight', '800');
//
//    $('.create_app_side_container').hide();
//    $('#' + th + '').fadeIn(600);
//});