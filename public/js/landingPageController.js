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
    $('.btn').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#show_modal_errors').text('');});
}


$('#login_button').click(login_modal);
$('#signup_button').click(signup_modal);

});


  jQuery(function(){
        $(".sign_up_footer_modal").hover(function(){
        $("#submit").hide();
        var hasError = false;
        var passwordVal = $("#password").val();
        var checkVal = $("#confirm_password").val();
        if (passwordVal == '') {
            $('#show_modal_errors').text("Please enter a password");
            hasError = true;
        } else if (checkVal == '') {
            $('#show_modal_errors').text("Please re-type the password to avoid mistake");
            hasError = true;
        } else if (passwordVal != checkVal ) {
            $('#show_modal_errors').text("Passwords do not match!");
            hasError = true;
        }
        if(hasError == true)
        {
            return false;
        }
        else
        {
            $("#submit").show();
            $('#show_modal_errors').text("");
        }
    },
        function(){
            //$("#submit").show();
        });
});
