/*

    This file contains string functions for checking passwords or removing placeholders

*/

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

$('.tiped').bind({
  focus: function() {
    $('.tooltips').show(200);
  },
  blur: function() {
    $('.tooltips').hide(300);
  }
});


$(function() {
    $('#b_c_organization').click(function(event){
        var org = $('#org_name').val();

        if(org.length < 4) {
            event.preventDefault();
            $('.server_errors').hide().text("Please enter a name(4 letters)!").fadeIn(200);
        }
        else
        {
            $('#cancel_b_c_organization').fadeOut(200);
            $('#b_c_organization').fadeOut(200);
            $('#p_c_organization').fadeIn(200);
        }
    });

    $('#b_c_space').click(function(event){
        var space = $('.space_name_i').val();

        if(space.length < 4) {
            event.preventDefault();
            $('.server_errors').hide().text("Please enter a name(4 letters)!").fadeIn(200);
        }
        else
        {
            $('#cancel_b_c_space').fadeOut(200);
            $('#b_c_space').fadeOut(200);
            $('#p_c_space').fadeIn(200);
        }
    });

    $('#b_add_user').click(function(event){
        var user = $('#user_email').val();

        if( /(.+)@(.+){2,}\.(.+){2,}/.test(user) ){
            $('#b_add_user').fadeOut(200);
            $('#p_add_user').fadeIn(200);
        } else {
            event.preventDefault();
            $('.server_errors').hide().text("Please type a valid email address!").fadeIn(200);
        }
    });

    $('#b_delete_user').click(function(){
        $('#b_delete_user').fadeOut(200);
        $('#cancel_b_delete_user').fadeOut(200);
        $('#p_delete_user').fadeIn(200);
    });

    $('#b_add_credit').click(function(){
        $('#b_add_credit').fadeOut(200);
        $('#cancel_b_add_credit').fadeOut(200);
        $('#p_add_credit').fadeIn(200);
    });

    $('#b_delete_space').click(function(){
        $('#b_delete_space').fadeOut(200);
        $('#cancel_b_d_space').fadeOut(200);
        $('#p_delete_space').fadeIn(200);
    });

});

$(function(){
    $('#organization_input').keypress(function(event){
        var org = $(this).val();
        if(event.which == 13 && org.length < 2)
        {
            event.preventDefault();
        }
    });

    $('#space_input').keypress(function(event){
        var space = $(this).val();
        if(event.which == 13 && space.length < 2)
        {
            event.preventDefault();
        }
    });
});

