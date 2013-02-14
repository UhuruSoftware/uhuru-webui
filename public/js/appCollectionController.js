


$('.create_app_side_list_templates_li').click(function(){
    var th = $(this).html();

    $('.create_app_side_list_templates_li').css('border-bottom', '0px solid #ffffff');
    $('.create_app_side_list_templates_li').css('font-weight', '200');
    $(this).css('border-bottom', '1px solid #ffffff');
    $(this).css('font-weight', '800');

    $('.create_app_side_container').hide();
    $('#' + th + '').fadeIn(600);
});