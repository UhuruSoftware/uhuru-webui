$(function(){
var saving_modal_start = function()
{
	$('#screen').css({	display: "block", opacity: 0.9, width: "10000px", height: "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#saving_modal').fadeIn(200);
    $('.stopApp_btn').css("display", "block");
    $('.startApp_btn').css("display", "none");
}

var saving_modal_stop = function()
{
	$('#screen').css({	display: "block", opacity: 0.9, width: "10000px", height: "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#saving_modal').fadeIn(200);
    $('.startApp_btn').css("display", "block");
    $('.stopApp_btn').css("display", "none");
}

var add_template_app_modal = function()
{
	$('body').css({"overflow":"hidden"});
	$('#add_new_template_app_modal').fadeIn(200);
	$('#create_tempcta_modal').fadeOut(200);
}

var delete_organization_message = function()
{
	$('#cancel_b_d_organization').fadeOut(200);
	$('#b_d_organization').fadeOut(200);
    $('#p_d_organization').fadeIn(200);
}

var delete_space_message = function()
{
	$('#cancel_b_d_space').fadeOut(200);
	$('#b_d_space').fadeOut(200);
    $('#p_d_space').fadeIn(200);
}

$('.startApp_btn').click(saving_modal_start);
$('.stopApp_btn').click(saving_modal_stop);
$('.app_tiles_cloudpush').click(add_template_app_modal);

$('#b_d_organization').click(delete_organization_message);
$('#b_d_space').click(delete_space_message);

});




