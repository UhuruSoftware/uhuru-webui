$('#organizations_page').fadeIn(200);
$('#organization_page').fadeIn(200);
$('#space_page').fadeIn(200);

$(function(){



var delete_space_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_space_modal').slideDown(200);
    $('.close').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#delete_space_modal").css("display", "none");$('#screen').css("display", "none")});
}

var delete_organization_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_organization_modal').slideDown(200);
    $('.close').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#delete_organization_modal").css("display", "none");$('#screen').css("display", "none")});
}

var delete_app = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_app').slideDown(200);
    $('.close').click(function(){$("#delete_app").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#delete_app").css("display", "none");$('#screen').css("display", "none")});
}

var delete_service = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_service').slideDown(200);
    $('.close').click(function(){$("#delete_service").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#delete_service").css("display", "none");$('#screen').css("display", "none")});
}









var create_tempcta_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_tempcta_modal').slideDown(200);
    $('.close').click(function(){$("#create_tempcta_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#create_tempcta_modal").css("display", "none");$('#screen').css("display", "none")});
}


var add_ctService_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#add_ctService_modal').slideDown(1000);
    $('.close').click(function(){$("#add_ctService_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#add_ctService_modal").css("display", "none");$('#screen').css("display", "none")});
}


var saving_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#saving_modal').slideDown(1000);
    $('.close').click(function(){$("#saving_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#saving_modal").css("display", "none");$('#screen').css("display", "none")});
}


var unbind_ctsTOcta_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#unbind_ctsTOcta_modal').slideDown(1000);
    $('.close').click(function(){$("#unbind_ctsTOcta_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#unbind_ctsTOcta_modal").css("display", "none");$('#screen').css("display", "none")});
}


var bind_ctsTOcta_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#bind_ctsTOcta_modal').slideDown(1000);
    $('.close').click(function(){$("#bind_ctsTOcta_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#bind_ctsTOcta_modal").css("display", "none");$('#screen').css("display", "none")});
}


var bind_uriTOcta_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#bind_uriTOcta_modal').slideDown(1000);
    $('.close').click(function(){$("#bind_uriTOcta_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#bind_uriTOcta_modal").css("display", "none");$('#screen').css("display", "none")});
}


var unbind_uriTOcta_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#unbind_uriTOcta_modal').slideDown(1000);
    $('.close').click(function(){$("#unbind_uriTOcta_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#unbind_uriTOcta_modal").css("display", "none");$('#screen').css("display", "none")});
}


var inv_ctUser_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#inv_ctUser_modal').slideDown(1000);
    $('.close').click(function(){$("#inv_ctUser_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#inv_ctUser_modal").css("display", "none");$('#screen').css("display", "none")});
}


var delete_ctUser_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#delete_ctUser_modal').slideDown(1000);
    $('.close').click(function(){$("#delete_ctUser_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#delete_ctUser_modal").css("display", "none");$('#screen').css("display", "none")});
}


var cannot_delete_ctUser_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#cannot_delete_ctUser_modal').slideDown(1000);
    $('.close').click(function(){$("#cannot_delete_ctUser_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#cannot_delete_ctUser_modal").css("display", "none");$('#screen').css("display", "none")});
}


var toggle_user_admin_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#toggle_user_admin_modal').slideDown(1000);
    $('.close').click(function(){$("#toggle_user_admin_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#toggle_user_admin_modal").css("display", "none");$('#screen').css("display", "none")});
}


var show_CT_token = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#show_CT_token').slideDown(1000);
    $('.close').click(function(){$("#show_CT_token").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#show_CT_token").css("display", "none");$('#screen').css("display", "none")});
}


var app_details_modal = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#app_details_modal').slideDown(1000);
    $('.close').click(function(){$("#app_details_modal").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#app_details_modal").css("display", "none");$('#screen').css("display", "none")});
}


var create_organization = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_organization').slideDown(300);
    $('.close').click(function(){$("#create_organization").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#create_organization").css("display", "none");$('#screen').css("display", "none")});
    $('#org_name').focus();
}

var create_space = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#create_space').slideDown(300);
    $('.close').click(function(){$("#create_space").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#create_space").css("display", "none");$('#screen').css("display", "none")});
    $('#org_name').focus();
}

var add_user = function(){
	$('#screen').css({	"display": "block", opacity: 0.7, "width": "10000px", "height": "10000px"});
	$('body').css({"overflow":"hidden"});
	$('#add_user').slideDown(1000);
    $('.close').click(function(){$("#add_user").css("display", "none");$('#screen').css("display", "none")});
    $('.btn').click(function(){$("#add_user").css("display", "none");$('#screen').css("display", "none")});
}



$('#add_ctService_modal_btn').click(add_ctService_modal);
$('#saving_modalb').click(saving_modal);
$('#unbind_ctsTOcta_modalb').click(unbind_ctsTOcta_modal);
$('#bind_ctsTOcta_modalb').click(bind_ctsTOcta_modal);
$('#bind_uriTOcta_modalb').click(bind_uriTOcta_modal);
$('#unbind_uriTOcta_modalb').click(unbind_uriTOcta_modal);
$('#inv_ctUser_modalb').click(inv_ctUser_modal);
$('#delete_ctUser_modalb').click(delete_ctUser_modal);
$('#cannot_delete_ctUser_modalb').click(cannot_delete_ctUser_modal);
$('#toggle_user_admin_modalb').click(toggle_user_admin_modal);
$('#show_CT_tokenb').click(show_CT_token);




$('.delete-organization-button').click(delete_organization_modal);
$('.delete-space-button').click(delete_space_modal);
    $('.delete-app-button').click(delete_app);
    $('.delete-service-button').click(delete_service);
$('.show_this_app_details').click(app_details_modal);



$('#create_app').click(create_tempcta_modal);
$('#create_organization_btn').click(create_organization);
$('#create_space_btn').click(create_space);
$('#add_user_btn1').click(add_user);
$('#add_user_btn2').click(add_user);
$('#add_user_btn3').click(add_user);

$('#plus_service').click(add_ctService_modal);





//
    //plus and minus memory at SUBSCRIPTIONS
//

//var counter = document.getElementById('memory_number').innerHTML;

//var plus = function(){
  //  if(counter < 2048)
  //  {
  //      counter = parseInt(counter);
  //      counter+=32;
  //      document.getElementById('memory_number').innerHTML = counter;
  //  }
//}

//var minus = function(){
    //if(counter > 0)
    //{
      //  counter = parseInt(counter);
      // counter-=32;
      //  document.getElementById('memory_number').innerHTML = counter;
    //}
//}


//$('#plus_memory').click(plus);
//$('#minus_memory').click(minus);
});

