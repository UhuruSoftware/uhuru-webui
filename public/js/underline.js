

$('.link_tiles_org').hover(function(){
   $(this).find('span').css("border-bottom", "3px solid #005162");
}, function(){
   $('.to_be_underlined').css("border-bottom", "0px solid #0071b7");
});

//THIS LOADS THE NEW TEMP AP NAME TO BE SENT ON POST "/"

$('#create_tempcta_modal').mousemove(function(){
    var txt=$('input:text[name=user_app]').val();
    $('input:text[name=appName]').val(txt);
});




