//Show hide Members and Spaces from Organization page

var Hspaces = false;
var Hmembers = true;

var Happs = false;
var Hservices = true;
var Hbillings = true;

function showSpaces()
{
     document.getElementById('spaces').style.display = 'block';
        document.getElementById('spaces_btn_link').style.paddingBottom = '1px';
        document.getElementById('spaces_btn_link').style.borderTop = '1px solid #0e4769';
        document.getElementById('spaces_btn_link').style.borderLeft = '1px solid #0e4769';
        document.getElementById('spaces_btn_link').style.borderRight = '1px solid #0e4769';
        document.getElementById('spaces_btn_link').style.backgroundColor = '#09293e';
        document.getElementById('spaces_btn_link').style.color = "#ffffff";



        document.getElementById('members_btn_link').style.paddingBottom = '0px';
        document.getElementById('members_btn_link').style.borderTop = '0px solid #0e4769';
        document.getElementById('members_btn_link').style.borderLeft = '0px solid #0e4769';
        document.getElementById('members_btn_link').style.borderRight = '0px solid #0e4769';

        document.getElementById('members_btn_link').style.color = "#ffffff";

        document.getElementById('tabs').style.borderBottom = '1px solid #0e4769';
     document.getElementById('members').style.display = 'none';


    document.getElementById('add_user_btn_owner').style.display = "none";
    document.getElementById('create_space_btn').style.display = "block";

    Hspaces = false;
    Hmembers = true;
}

function showMembers()
{
        document.getElementById('members').style.display = 'block';
        document.getElementById('members_btn_link').style.paddingBottom = '1px';
        document.getElementById('members_btn_link').style.borderTop = '1px solid #0e4769';
        document.getElementById('members_btn_link').style.borderLeft = '1px solid #0e4769';
        document.getElementById('members_btn_link').style.borderRight = '1px solid #0e4769';
        document.getElementById('members_btn_link').style.backgroundColor = '#09293e';
        document.getElementById('members_btn_link').style.color = "#ffffff";



        document.getElementById('spaces_btn_link').style.paddingBottom = '0px';
        document.getElementById('spaces_btn_link').style.borderTop = '0px solid #0e4769';
        document.getElementById('spaces_btn_link').style.borderLeft = '0px solid #0e4769';
        document.getElementById('spaces_btn_link').style.borderRight = '0px solid #0e4769';
        document.getElementById('spaces_btn_link').style.color = "#ffffff";


        document.getElementById('billings_li').style.paddingBottom = '0px';
        document.getElementById('billings_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('billings_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('billings_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('billings_li').style.color = "#ffffff";




     document.getElementById('tabs').style.borderBottom = '1px solid #0e4769';
     document.getElementById('spaces').style.display = 'none';
     document.getElementById('members').style.display = 'block';
     document.getElementById('billings').style.display = 'none';
     document.getElementById('create_space_btn').style.display = 'none';
     document.getElementById('add_user_btn_owner').style.display = 'none';

     document.getElementById('edit_space_btn').style.right = '50px';


}


function showBillings()
{
        document.getElementById('billings_li').style.paddingBottom = '1px';
        document.getElementById('billings_li').style.borderTop = '1px solid #0e4769';
        document.getElementById('billings_li').style.borderLeft = '1px solid #0e4769';
        document.getElementById('billings_li').style.borderRight = '1px solid #0e4769';
        document.getElementById('billings_li').style.backgroundColor = '#09293e';
        document.getElementById('billings_li').style.color = "#ffffff";





        document.getElementById('spaces_btn_link').style.paddingBottom = '0px';
        document.getElementById('spaces_btn_link').style.borderTop = '0px solid #0e4769';
        document.getElementById('spaces_btn_link').style.borderLeft = '0px solid #0e4769';
        document.getElementById('spaces_btn_link').style.borderRight = '0px solid #0e4769';
        document.getElementById('spaces_btn_link').style.color = "#ffffff";


        document.getElementById('members_btn_link').style.paddingBottom = '0px';
        document.getElementById('members_btn_link').style.borderTop = '0px solid #0e4769';
        document.getElementById('members_btn_link').style.borderLeft = '0px solid #0e4769';
        document.getElementById('members_btn_link').style.borderRight = '0px solid #0e4769';
        document.getElementById('members_btn_link').style.color = "#ffffff";




     document.getElementById('tabs').style.borderBottom = '1px solid #0e4769';
     document.getElementById('spaces').style.display = 'none';
     document.getElementById('members').style.display = 'none';
     document.getElementById('billings').style.display = 'block';
     document.getElementById('create_space_btn').style.display = 'none';
     document.getElementById('add_user_btn_owner').style.display = 'none';

     document.getElementById('edit_space_btn').style.right = '50px';

    Hservices = true;
    Happs = true;
    Hbillings = false;
}

















function showApps()
{
        document.getElementById('apps_li').style.paddingBottom = '1px';
        document.getElementById('apps_li').style.borderTop = '1px solid #0e4769';
        document.getElementById('apps_li').style.borderLeft = '1px solid #0e4769';
        document.getElementById('apps_li').style.borderRight = '1px solid #0e4769';
        document.getElementById('apps_li').style.backgroundColor = '#09293e';
        document.getElementById('apps_li').style.color = "#ffffff";





        document.getElementById('services_li').style.paddingBottom = '0px';
        document.getElementById('services_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('services_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('services_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('services_li').style.color = "#ffffff";


        document.getElementById('billings_li').style.paddingBottom = '0px';
        document.getElementById('billings_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('billings_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('billings_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('billings_li').style.color = "#ffffff";




     document.getElementById('spaces_tabs').style.borderBottom = '1px solid #0e4769';
     document.getElementById('apps').style.display = 'block';
     document.getElementById('services').style.display = 'none';
     document.getElementById('billings').style.display = 'none';
     document.getElementById('create_app').style.display = 'block';
     document.getElementById('create_service').style.display = 'none';


     document.getElementById('edit_space_btn').style.right = '100px';

    Happs = false;
    Hservices = true;
    Hbillings = true;
}

function showServices()
{
        document.getElementById('services_li').style.paddingBottom = '1px';
        document.getElementById('services_li').style.borderTop = '1px solid #0e4769';
        document.getElementById('services_li').style.borderLeft = '1px solid #0e4769';
        document.getElementById('services_li').style.borderRight = '1px solid #0e4769';
        document.getElementById('services_li').style.backgroundColor = '#09293e';
        document.getElementById('services_li').style.color = "#ffffff";





        document.getElementById('billings_li').style.paddingBottom = '0px';
        document.getElementById('billings_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('billings_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('billings_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('billings_li').style.color = "#ffffff";


        document.getElementById('apps_li').style.paddingBottom = '0px';
        document.getElementById('apps_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('apps_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('apps_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('apps_li').style.color = "#ffffff";




     document.getElementById('spaces_tabs').style.borderBottom = '1px solid #0e4769';
     document.getElementById('apps').style.display = 'none';
     document.getElementById('services').style.display = 'block';
     document.getElementById('billings').style.display = 'none';
     document.getElementById('create_app').style.display = 'none';
     document.getElementById('create_service').style.display = 'block';


     document.getElementById('edit_space_btn').style.right = '100px';

    Hservices = false;
    Happs = true;
    Hbillings = true;
}






function editUsernameDiv()
{
    document.getElementById('welcome').style.display = 'block';
}

function editUser()
{
    document.getElementById('the_user_name').innerHTML = document.getElementById('user_name_input').value;
    document.getElementById('the_user_name').style.display = 'block';
}