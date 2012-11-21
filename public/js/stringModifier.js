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
    $('.submit_form1').click(function(event){

        var first_name = $('input[name=first_name]').val();
        var last_name = $('input[name=last_name]').val();

        if(last_name.length < 2 || last_name == '... last name') {
            event.preventDefault();
            $('.form_errors1').hide().text("Please enter you're last name name!").fadeIn(200);
        }

        if(first_name.length < 2 || first_name == '... first name') {
            event.preventDefault();
            $('.form_errors1').hide().text("Please enter you're first name!").fadeIn(200);
        }
    });
});

$(function() {
    $('.submit_form2').click(function(event){

        var new_pass = $('#old_pass').val();
        var old_pass = $('#new_pass1').val();

        if(old_pass.length < 1) {
            event.preventDefault();
            $('.form_errors2').hide().text("Old password can not be blank!").fadeIn(200);
        }

        if(new_pass.length < 1) {
            event.preventDefault();
            $('.form_errors2').hide().text("Password can not be blank!").fadeIn(200);
        }

        if($('#new_pass1').val() == $('#old_pass').val()) {
            event.preventDefault();
            $('.form_errors2').hide().text("New and old password are the same!").fadeIn(200);
        }

        if($('#new_pass1').val() != $('#new_pass2').val()) {
            event.preventDefault();
            $('.form_errors2').hide().text("Password and Confirm Password don't match!").fadeIn(200);
        }
    });
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

$('.clear_form1').click(function(){
    $('input[name=first_name]').val('');
    $('input[name=last_name]').val('');
    $('.form_errors1').hide();
});

$('.clear_form2').click(function(){
    $('input[name=old_pass]').val('');
    $('input[name=new_pass1]').val('');
    $('input[name=new_pass2]').val('');
    $('.form_errors2').hide();
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

