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
    $('#password').val('');
    $('#confirm_password').val('');
    $('#username').val('');
    $('#email').val('');
	$('#signup_modal').fadeIn(600);
    $('.close').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#show_modal_errors').text('');});
    $('.cancel_btn').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#show_modal_errors').text('');});
}


$('#login_button').click(login_modal);
$('#signup_button').click(signup_modal);

});





$('[placeholder]').focus(function() {
  var input = $(this);
    input.css("font-style", "normal");
    input.css("color", "#ffffff");
  if (input.val() == input.attr('placeholder')) {
    input.val('');
    input.removeClass('placeholder');
  }
}).blur(function() {
  var input = $(this);
    input.css("font-style", "italic");
    input.css("color", "gray");
  if (input.val() == '' || input.val() == input.attr('placeholder')) {
    input.addClass('placeholder');
    input.val(input.attr('placeholder'));
  }
}).blur();

$('[placeholder]').parents('form').submit(function() {
  $(this).find('[placeholder]').each(function() {
    var input = $(this);
    if (input.val() == input.attr('placeholder')) {
      input.val('');
    }
  })
});





$(function() {
    $('.submit_form').click(function(event){

        data = $('#password').val();
        var len = data.length;

        if(len < 1) {
            $('#show_modal_errors').hide().text("Password can not be blank!").fadeIn(200);
            event.preventDefault();
            // Prevent form submission
        }

        if($('#password').val() != $('#confirm_password').val()) {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Password and Confirm Password don't match!").fadeIn(200);
            // Prevent form submission
        }
    });
});
