

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

$('#create_tempcta_modal').mousemove(function(){
    var txt=$('input:text[name=user_app]').val();
    $('input:text[name=appName]').val(txt);
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





$('.tiped').bind({
  focus: function() {
    $('.tooltips').show(200);
  },
  blur: function() {
    $('.tooltips').hide(300);
  }
});
