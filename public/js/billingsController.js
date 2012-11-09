
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

        var card_number = $('input[name=card_number]').val();
        var cvv = $('input[name=cvv]').val();

        var card_t = document.getElementById("credit_card_type");
        var exp_year = document.getElementById("credit_card_expiration_year");
        var exp_month = document.getElementById("credit_card_expiration_month");
        var country = document.getElementById("country_drop_down"); //$('input[name=country]').val();

        var card_type = card_t.options[card_t.selectedIndex];
        var expiration_year = exp_year.options[exp_year.selectedIndex];
        var expiration_month = exp_month.options[exp_month.selectedIndex];

        if(expiration_month.text == '-select-') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please select a month!").fadeIn(200);
        }

        if(expiration_year.text == '-select-') {
            event.preventDefault();
            $('#show_modal_errors').hide().text("Please select a year").fadeIn(200);
        }

        if(card_type.text == '-select-') {
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

        if(country.text == '-select-') {
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