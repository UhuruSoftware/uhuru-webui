
var create_credit_card = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_credit_card_modal').fadeIn(600);
    $('.close').click(function(){$("#create_credit_card_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#create_credit_card_modal").css("display", "none");$('#screen').css("display", "none")});
}



$('#create_credit_card').click(create_credit_card);
