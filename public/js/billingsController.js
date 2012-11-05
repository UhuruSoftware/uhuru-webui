
var create_credit_card = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_credit_card_modal').fadeIn(600);
    $('.close').click(function(){$("#create_credit_card_modal").css("display", "none");$('#screen').css("display", "none");$('#show_modal_errors').hide();});
    $('.btn_cancel').click(function(){$("#create_credit_card_modal").css("display", "none");$('#screen').css("display", "none");$('#show_modal_errors').hide();});
}



$('#create_credit_card').click(create_credit_card);




$(function() {
    $('.submit_credit_card').click(function(event){
        var first_name = $('input[name=first_name]').val();
        var last_name = $('input[name=last_name]').val();
        var address1 = $('input[name=address1]').val();


        var city = $('input[name=city]').val();
        var state = $('input[name=state]').val();
        var zip = $('input[name=zip]').val();
        var country = $('input[name=country]').val();


        var card_number = $('input[name=card_number]').val();
        var cvv = $('input[name=cvv]').val();
        var card_type = $('input[name=card_type]').val();
        var exp_year = $('input[name=expiration_year]').val();
        var exp_month = $('input[name=expiration_month').val();



        if(exp_month == -1 || exp_month == '-select-') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please select the expiration month!").fadeIn(200);
        }

        if(exp_year == -1 || exp_year == '-select-') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please select the expiration year!").fadeIn(200);
        }

        if(card_type == -1 || card_type == '-select-') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please select a card type!").fadeIn(200);
        }



        if(!cvv.match(/^\d+$/)) {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please enter you're card cvv code! ( 3/4 digit )").fadeIn(200);
        }

        if(!card_number.match(/^\d{16}$/)) {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please enter you're valid card number! ( 16 digits)").fadeIn(200);
        }



        if(country.length < 2 || country == '... country') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please enter you're country!").fadeIn(200);
        }

        if(!zip.match(/^\d{5}$/)) {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please enter you're zip code! ( 5 digit )").fadeIn(200);
        }

        if(state.length < 2 || state == '... state') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please enter you're state!").fadeIn(200);
        }

        if(city.length < 2 || city == '... city') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please enter you're city!").fadeIn(200);
        }


        if(address1.length < 2 || address1 == '... address1') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please enter you're address! ( 10 characters )").fadeIn(200);
        }


        if(last_name.length < 2 || last_name == '... last name') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please enter you're last name name!").fadeIn(200);
        }

        if(first_name.length < 2 || first_name == '... first name') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please enter you're first name!").fadeIn(200);
        }
    });
});