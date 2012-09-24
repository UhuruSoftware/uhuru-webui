$('.link_tiles_').hover(function(){
   $(this).find('span').css("border-bottom", "1px solid #0071b7");
}, function(){
   $('.to_be_underlined').css("border-bottom", "0px solid #0071b7");
});
