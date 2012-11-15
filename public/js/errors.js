
$(window).load(function () {
var login = $('#login_failed').html();
var signup = $('#sign_up_failed').html();

var error_create_organization = $('#create_organization_failed').html();
var error_delete_organization = $('#delete_organization_failed').html();

var error_create_space = $('#create_space_failed').html();
var error_delete_space = $('#delete_space_failed').html();

    if(login == "Wrong email and/or password!")
    {
        $('input[name=username]').trigger('focus');
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#login_modal').fadeIn(60);
        $('.close').click(function(){$("#login_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#login_failed').html('');});
        $('.btn').click(function(){$("#login_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#login_failed').html('');});
   }

    if(signup == "Email already exists try another one!" || signup == "Server couldn't create the default organization!" || signup == "Server did not respond!")
    {
        $('input[name=email]').trigger('focus');
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#signup_modal').fadeIn(60);
        $('.close').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#sign_up_failed').html('');});
        $('.btn').click(function(){$("#signup_modal").css("display", "none");$('#screen').css("display", "none");$('body').css("overflow", "auto");$('#video_placeholder').css('display', 'block'); $('#sign_up_failed').html('');});
   }

    if(error_create_organization == "You are not authorized to create organizations!")
    {
        $('#screen').css({"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#create_organization').fadeIn(600);
        $('.close').click(function(){$("#create_organization").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#create_organization_failed').html('');});
        $('#org_name').focus();
    }

    if(error_create_space == "You are not authorized to create spaces!")
    {
        $('#screen').css({"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#create_space').fadeIn(600);
        $('.close').click(function(){$("#create_space").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#create_space_failed').html('');});
        $('#space_name').focus();
    }

    if(error_delete_organization == "You are not authorized to delete this organization!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#delete_organization_modal').fadeIn(600);
        $('.close').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#delete_organization_failed').html('');});
    }

    if(error_delete_space == "You are not authorized to delete this space!")
    {
        $('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
        $('body').css({"overflow":"hidden"});
        $('#delete_space_modal').fadeIn(600);
        $('.close').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none");$('body').css({"overflow":"auto"}); $('#delete_space_failed').html('');});
    }

});