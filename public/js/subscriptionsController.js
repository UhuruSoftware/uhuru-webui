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



var showmysql = function(){
	$('.subscription_plans_list_mysql').fadeIn(1500);
	$('.subscription_plans_list_mysql').css("display", "inline-block");
	$('.subscription_plans_list_mssql').css("display", "none");
	$('.subscription_plans_list_redis').css("display", "none");
	$('.subscription_plans_list_rabbitmq').css("display", "none");
	$('.subscription_plans_list_mongo_db').css("display", "none");
	$('.subscription_plans_list_uhurufs').css("display", "none");

    $('.subscription_qt_list_li_mysql').css("display", "list-item");
    $('.subscription_qt_list_li_mssql').css("display", "none");
    $('.subscription_qt_list_li_redis').css("display", "none");
    $('.subscription_qt_list_li_rabbitmq').css("display", "none");
    $('.subscription_qt_list_li_mongo_db').css("display", "none");
    $('.subscription_qt_list_li_uhurufs').css("display", "none");

    $('#mysql_btn').css("background-color", "#050368");
    $('#mssql_btn').css("background-color", "#232323");
    $('#redis_btn').css("background-color", "#232323");
    $('#rabbitmq_btn').css("background-color", "#232323");
    $('#mongo_db_btn').css("background-color", "#232323");
    $('#uhurufs_btn').css("background-color", "#232323");

    $('#quantity_slider').css("display", "block");
}

 var showmssql = function(){
	$('.subscription_plans_list_mssql').fadeIn(1500);
	$('.subscription_plans_list_mysql').css("display", "none");
	$('.subscription_plans_list_mssql').css("display", "inline-block");
	$('.subscription_plans_list_redis').css("display", "none");
	$('.subscription_plans_list_rabbitmq').css("display", "none");
	$('.subscription_plans_list_mongo_db').css("display", "none");
	$('.subscription_plans_list_uhurufs').css("display", "none");

    $('.subscription_qt_list_li_mysql').css("display", "none");
    $('.subscription_qt_list_li_mssql').css("display", "list-item");
    $('.subscription_qt_list_li_redis').css("display", "none");
    $('.subscription_qt_list_li_rabbitmq').css("display", "none");
    $('.subscription_qt_list_li_mongo_db').css("display", "none");
    $('.subscription_qt_list_li_uhurufs').css("display", "none");

    $('#mysql_btn').css("background-color", "#232323");
    $('#mssql_btn').css("background-color", "#0317af");
    $('#redis_btn').css("background-color", "#232323");
    $('#rabbitmq_btn').css("background-color", "#232323");
    $('#mongo_db_btn').css("background-color", "#232323");
    $('#uhurufs_btn').css("background-color", "#232323");


    $('#quantity_slider').css("display", "block");
}

 var showredis = function(){
	$('.subscription_plans_list_redis').fadeIn(1500);
	$('.subscription_plans_list_mysql').css("display", "none");
	$('.subscription_plans_list_mssql').css("display", "none");
	$('.subscription_plans_list_redis').css("display", "inline-block");
	$('.subscription_plans_list_rabbitmq').css("display", "none");
	$('.subscription_plans_list_mongo_db').css("display", "none");
	$('.subscription_plans_list_uhurufs').css("display", "none");

    $('.subscription_qt_list_li_mysql').css("display", "none");
    $('.subscription_qt_list_li_mssql').css("display", "none");
    $('.subscription_qt_list_li_redis').css("display", "list-item");
    $('.subscription_qt_list_li_rabbitmq').css("display", "none");
    $('.subscription_qt_list_li_mongo_db').css("display", "none");
    $('.subscription_qt_list_li_uhurufs').css("display", "none");

    $('#mysql_btn').css("background-color", "#232323");
    $('#mssql_btn').css("background-color", "#232323");
    $('#redis_btn').css("background-color", "#0956d2");
    $('#rabbitmq_btn').css("background-color", "#232323");
    $('#mongo_db_btn').css("background-color", "#232323");
    $('#uhurufs_btn').css("background-color", "#232323");


    $('#quantity_slider').css("display", "block");
}

 var showrabbitmq = function(){
	$('.subscription_plans_list_rabbitmq').fadeIn(1500);
	$('.subscription_plans_list_mysql').css("display", "none");
	$('.subscription_plans_list_mssql').css("display", "none");
	$('.subscription_plans_list_redis').css("display", "none");
	$('.subscription_plans_list_rabbitmq').css("display", "inline-block");
	$('.subscription_plans_list_mongo_db').css("display", "none");
	$('.subscription_plans_list_uhurufs').css("display", "none");

    $('.subscription_qt_list_li_mysql').css("display", "none");
    $('.subscription_qt_list_li_mssql').css("display", "none");
    $('.subscription_qt_list_li_redis').css("display", "none");
    $('.subscription_qt_list_li_rabbitmq').css("display", "list-item");
    $('.subscription_qt_list_li_mongo_db').css("display", "none");
    $('.subscription_qt_list_li_uhurufs').css("display", "none");

    $('#mysql_btn').css("background-color", "#232323");
    $('#mssql_btn').css("background-color", "#232323");
    $('#redis_btn').css("background-color", "#232323");
    $('#rabbitmq_btn').css("background-color", "#450368");
    $('#mongo_db_btn').css("background-color", "#232323");
    $('#uhurufs_btn').css("background-color", "#232323");


    $('#quantity_slider').css("display", "block");
}

 var showmongo_db = function(){
	$('.subscription_plans_list_mongo_db').fadeIn(1500);
	$('.subscription_plans_list_mysql').css("display", "none");
	$('.subscription_plans_list_mssql').css("display", "none");
	$('.subscription_plans_list_redis').css("display", "none");
	$('.subscription_plans_list_rabbitmq').css("display", "none");
	$('.subscription_plans_list_mongo_db').css("display", "inline-block");
	$('.subscription_plans_list_uhurufs').css("display", "none");

    $('.subscription_qt_list_li_mysql').css("display", "none");
    $('.subscription_qt_list_li_mssql').css("display", "none");
    $('.subscription_qt_list_li_redis').css("display", "none");
    $('.subscription_qt_list_li_rabbitmq').css("display", "none");
    $('.subscription_qt_list_li_mongo_db').css("display", "list-item");
    $('.subscription_qt_list_li_uhurufs').css("display", "none");

    $('#mysql_btn').css("background-color", "#232323");
    $('#mssql_btn').css("background-color", "#232323");
    $('#redis_btn').css("background-color", "#232323");
    $('#rabbitmq_btn').css("background-color", "#232323");
    $('#mongo_db_btn').css("background-color", "#7f058c");
    $('#uhurufs_btn').css("background-color", "#232323");


    $('#quantity_slider').css("display", "block");
}

 var showuhurufs = function(){
	$('.subscription_plans_list_uhurufs').fadeIn(1500);
	$('.subscription_plans_list_mysql').css("display", "none");
	$('.subscription_plans_list_mssql').css("display", "none");
	$('.subscription_plans_list_redis').css("display", "none");
	$('.subscription_plans_list_rabbitmq').css("display", "none");
	$('.subscription_plans_list_mongo_db').css("display", "none");
	$('.subscription_plans_list_uhurufs').css("display", "inline-block");

    $('.subscription_qt_list_li_mysql').css("display", "none");
    $('.subscription_qt_list_li_mssql').css("display", "none");
    $('.subscription_qt_list_li_redis').css("display", "none");
    $('.subscription_qt_list_li_rabbitmq').css("display", "none");
    $('.subscription_qt_list_li_mongo_db').css("display", "none");
    $('.subscription_qt_list_li_uhurufs').css("display", "list-item");

    $('#mysql_btn').css("background-color", "#232323");
    $('#mssql_btn').css("background-color", "#232323");
    $('#redis_btn').css("background-color", "#232323");
    $('#rabbitmq_btn').css("background-color", "#232323");
    $('#mongo_db_btn').css("background-color", "#232323");
    $('#uhurufs_btn').css("background-color", "#0996d2");


    $('#quantity_slider').css("display", "block");
}







 $('#mysql_btn').click(showmysql);
 $('#mssql_btn').click(showmssql);
 $('#redis_btn').click(showredis);
 $('#rabbitmq_btn').click(showrabbitmq);
 $('#mongo_db_btn').click(showmongo_db);
 $('#uhurufs_btn').click(showuhurufs);




  $(function() {

    var select = $( "#plan_quantity" );
            var slider = $( "<div id='quantity'></div>" ).insertAfter( select ).slider({
                min: 1,
                max: 20,
                step: 1,
            value: 1,
                range: "min",
    change: function(event, ui) {
             var sliderValue = $( "#quantity" ).slider( "option", "value" );
            $('.qt_count').html(sliderValue);
            }
            });


    $('.qt_plus').click(function() {
    var sliderCurrentValue = $( "#quantity" ).slider( "option", "value" );
      slider.slider( "value", sliderCurrentValue + 1 );
    });

    $('.qt_minus').click(function() {
    var sliderCurrentValue = $( "#quantity" ).slider( "option", "value" );
      slider.slider( "value", sliderCurrentValue - 1 );
    });


 });