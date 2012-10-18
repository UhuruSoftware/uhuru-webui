$(function() {

    var select = $( "#memory_slider_subscriptions" );
            var slider = $( "<div id='sub'></div>" ).insertAfter( select ).slider({
                min: 0,
                max: 64,
                step: 1,
            value: 1,
                range: "min",
    change: function(event, ui) {
             var sliderValue = $( "#sub" ).slider( "option", "value" );
            $('.sub_memory_count').html(sliderValue);
            }
            });


    $('.sub_plus_memory').click(function() {
    var sliderCurrentValue = $( "#sub" ).slider( "option", "value" );
      slider.slider( "value", sliderCurrentValue + 1 );
    });

    $('.sub_minus_memory').click(function() {
    var sliderCurrentValue = $( "#sub" ).slider( "option", "value" );
      slider.slider( "value", sliderCurrentValue - 1 );
    });


 });




$('.add_subscription_services_list_li').click(function(){
    var element = $(this).next();
    $('.add_subscription_services_list_hidden').not(element).slideUp(800);

    $('.add_subscription_services_list_li').css("background-image", "url('../images/plus_24px.png')");
    $('.add_subscription_services_list_li').css("background-repeat", "no-repeat");
    $('.add_subscription_services_list_li').css("background-position", "10px 10px");

    element.slideToggle(1000);

    $(this).css("background-image", "url('../images/minus_24px.png')");
    $(this).css("background-repeat", "no-repeat");
    $(this).css("background-position", "10px 10px");
});

$('.add_subscription_services_list_li').hover(function(){
   $(this).animate({
       opacity: 1
   }, 400, function(){});
}, function(){
   $(this).animate({
       opacity: .7
   }, 400, function(){});
});