
$(window).load(function () {
var login = $('#login_failed').html();
var signup = $('#sign_up_failed').html();

    if(login == "Wrong email and/or password!")
    {
        $('input[name=username]').trigger('focus');
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#login_modal').fadeIn(60);
        $('.close').click(function(){$("#login_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#login_failed').html('');});
        $('.btn').click(function(){$("#login_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#login_failed').html('');});
   }

    if(signup == "Email already exists try another one!")
    {
        $('input[name=email]').trigger('focus');
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#signup_modal').fadeIn(60);
        $('.close').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#sign_up_failed').html('');});
        $('.btn').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#sign_up_failed').html('');});
   }
});