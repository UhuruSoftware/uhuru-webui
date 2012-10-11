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
