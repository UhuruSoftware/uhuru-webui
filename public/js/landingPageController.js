$(function() {

var login_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#login_modal').fadeIn(600);
    $('.close').click(function(){$("#login_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");});
    $('.btn').click(function(){$("#login_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");});
}


var signup_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#signup_modal').fadeIn(600);
    $('.close').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");});
    $('.btn').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");});
}


$('#login_button').click(login_modal);
$('#signup_button').click(signup_modal);

});