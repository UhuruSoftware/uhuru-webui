/*

    These are a set of functions for the landing page "/" the login and sign up modal, and all the input box checkers

*/

$(function() {

var login_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
    $('#video_placeholder').css("position", "absolute");
    $('#video_placeholder').css("top", "-2000px");
	$('body').css({"overflow":"hidden"});
	$('#login_modal').fadeIn(600);
    $('.close').click(function(){$("#login_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('position', 'relative'); $('#video_placeholder').css('top', '0');});
    $('.cancel').click(function(){$("#login_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('position', 'relative'); $('#video_placeholder').css('top', '0');});
}

var signup_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
    $('#video_placeholder').css("position", "absolute");
    $('#video_placeholder').css("top", "-2000px");
	$('body').css({"overflow":"hidden"});
    $('#password').val('');
    $('#confirm_password').val('');
    $('#username').val('');
    $('#email').val('');
	$('#signup_modal').fadeIn(600);
    $('.close').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#show_modal_errors').text('');$('#video_placeholder').css('position', 'relative'); $('#video_placeholder').css('top', '0');});
    $('.cancel').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#show_modal_errors').text('');$('#video_placeholder').css('position', 'relative'); $('#video_placeholder').css('top', '0');});

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
        var email = $('input[name=email]').val();
        data = $('#password').val();
        var len = data.length;
        var first = $('input[name=first_name]').val();
        var last = $('input[name=last_name]').val();
        var first_name = first.length;
        var last_name = last.length;

        if(last_name < 2 || last == '... last name') {
            event.preventDefault();
            $('.server_errors').hide();
            $('#show_modal_errors').hide().text("Please enter you're last name name!").fadeIn(200);
        }

        passwordStrength(data);

        if(first_name < 2 || first == '... first name') {
            event.preventDefault();
            $('.server_errors').hide();
            $('#show_modal_errors').hide().text("Please enter you're first name!").fadeIn(200);
        }

        if($('#password').val() != $('#confirm_password').val()) {
            event.preventDefault();
            $('.server_errors').hide();
            $('#show_modal_errors').hide().text("Password and Confirm Password don't match!").fadeIn(200);
        }

        if( /(.+)@(.+){2,}\.(.+){2,}/.test(email) ){
            //
        } else {
            event.preventDefault();
            $('.server_errors').hide();
            $('#show_modal_errors').hide().text("Please type a valid email address!").fadeIn(200);
        }
    });
});

function passwordStrength(password)
{
    if(password.length < 4) {
        $('.server_errors').hide();
        $('#show_modal_errors').hide().text("Password is to weak!").fadeIn(200);
        event.preventDefault();
    }
    if(password.length > 20) {
        $('.server_errors').hide();
        $('#show_modal_errors').hide().text("Password is to long!").fadeIn(200);
        event.preventDefault();
    }
}
