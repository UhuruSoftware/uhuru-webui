$(function(){


var saving_modal_start = function()
{
	$('#screen').css({	display: "block", opacity: 0.9, width: "10000px", height: "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#saving_modal').fadeIn(200);
    $('#stopApp_btn').css("display", "block");
    $('#startApp_btn').css("display", "none");
}

var saving_modal_stop = function()
{
	$('#screen').css({	display: "block", opacity: 0.9, width: "10000px", height: "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#saving_modal').fadeIn(200);
    $('#startApp_btn').css("display", "block");
    $('#stopApp_btn').css("display", "none");
}

$('#startApp_btn').click(saving_modal_start);
$('#stopApp_btn').click(saving_modal_stop);

});
