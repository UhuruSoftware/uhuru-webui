

//$('.link_tiles_org').hover(function(){
//   $(this).find('span').css("padding-bottom", "5px");
//   $(this).find('span').css("border-bottom", "1px solid #ffffff");
//}, function(){
//   $('.to_be_underlined').css("border-bottom", "0px solid #0071b7");
//});

//$('.link_tiles_space').hover(function(){
//   $(this).find('.space_name').css("padding-bottom", "5px");
//   $(this).find('.space_name').css("border-bottom", "1px solid #ffffff");
//}, function(){
//   $('.to_underlined').css("border-bottom", "0px solid #0071b7");
//});



//THIS LOADS THE NEW TEMP AP NAME TO BE SENT ON POST "/"


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
