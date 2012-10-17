//Show hide Members and Spaces from Organization page

var Hspaces = false;
var Hmembers = true;

var Happs = false;
var Hservices = true;
var Hsubscriptions = true;

function showSpaces()
{
     document.getElementById('spaces').style.display = 'block';
        document.getElementById('spaces_btn_link').style.paddingBottom = '1px';
        document.getElementById('spaces_btn_link').style.borderTop = '1px solid #0e4769';
        document.getElementById('spaces_btn_link').style.borderLeft = '1px solid #0e4769';
        document.getElementById('spaces_btn_link').style.borderRight = '1px solid #0e4769';
        document.getElementById('spaces_btn_link').style.backgroundColor = '#187ebc';
        document.getElementById('spaces_btn_link').style.color = "#ffffff";



        document.getElementById('members_btn_link').style.paddingBottom = '0px';
        document.getElementById('members_btn_link').style.borderTop = '0px solid #0e4769';
        document.getElementById('members_btn_link').style.borderLeft = '0px solid #0e4769';
        document.getElementById('members_btn_link').style.borderRight = '0px solid #0e4769';

        document.getElementById('members_btn_link').style.color = "#ffffff";

        document.getElementById('tabs').style.borderBottom = '1px solid #0e4769';
     document.getElementById('members').style.display = 'none';

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
        document.getElementById('members_btn_link').style.backgroundColor = '#187ebc';
        document.getElementById('members_btn_link').style.color = "#ffffff";



        document.getElementById('spaces_btn_link').style.paddingBottom = '0px';
        document.getElementById('spaces_btn_link').style.borderTop = '0px solid #0e4769';
        document.getElementById('spaces_btn_link').style.borderLeft = '0px solid #0e4769';
        document.getElementById('spaces_btn_link').style.borderRight = '0px solid #0e4769';


        document.getElementById('spaces_btn_link').style.color = "#ffffff";

        document.getElementById('tabs').style.borderBottom = '1px solid #0e4769';
     document.getElementById('spaces').style.display = 'none';

    Hmembers = false;
    Hspaces = true;
}

function hoverSpaces()
{
    if(Hspaces)
    {
    //    document.getElementById('spaces_btn_link').style.backgroundColor = '#efefef';
    }
}
function unhoverSpaces()
{
    //document.getElementById('spaces_btn_link').style.backgroundColor = 'white';
}

function hoverMembers()
{
    if(Hmembers)
    {
    //  document.getElementById('members_btn_link').style.backgroundColor = '#efefef';
    }
}
function unhoverMembers()
{
    //document.getElementById('members_btn_link').style.backgroundColor = 'white';
}





//Show hide Apps, Services and Subscriptions from Spaces page

function showApps()
{
     document.getElementById('apps').style.display = 'block';
        document.getElementById('apps_li').style.paddingBottom = '1px';
        document.getElementById('apps_li').style.borderTop = '1px solid #0e4769';
        document.getElementById('apps_li').style.borderLeft = '1px solid #0e4769';
        document.getElementById('apps_li').style.borderRight = '1px solid #0e4769';
        document.getElementById('apps_li').style.backgroundColor = '#187ebc';

        document.getElementById('apps_li').style.color = "#ffffff";



        document.getElementById('services_li').style.paddingBottom = '0px';
        document.getElementById('services_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('services_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('services_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #0e4769';

        document.getElementById('services_li').style.color = "#ffffff";

     document.getElementById('services').style.display = 'none';

        document.getElementById('subscriptions_li').style.paddingBottom = '0px';
        document.getElementById('subscriptions_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('subscriptions_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('subscriptions_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #0e4769';

        document.getElementById('subscriptions_li').style.color = "#ffffff";
        document.getElementById('subscriptions_li').style.fontWeight = "normal";

     document.getElementById('subscriptions').style.display = 'none';

    Happs = false;
    Hservices = true;
    Hsubscriptions = true;
}

function showServices()
{
     document.getElementById('services').style.display = 'block';
        document.getElementById('services_li').style.paddingBottom = '1px';
        document.getElementById('services_li').style.borderTop = '1px solid #0e4769';
        document.getElementById('services_li').style.borderLeft = '1px solid #0e4769';
        document.getElementById('services_li').style.borderRight = '1px solid #0e4769';
        document.getElementById('services_li').style.backgroundColor = '#187ebc';
        document.getElementById('services_li').style.color = "#ffffff";




        document.getElementById('apps_li').style.paddingBottom = '0px';
        document.getElementById('apps_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('apps_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('apps_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #0e4769';

        document.getElementById('apps_li').style.color = "#ffffff";

     document.getElementById('apps').style.display = 'none';

        document.getElementById('subscriptions_li').style.paddingBottom = '0px';
        document.getElementById('subscriptions_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('subscriptions_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('subscriptions_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #0e4769';

        document.getElementById('subscriptions_li').style.color = "#ffffff";
        document.getElementById('subscriptions_li').style.fontWeight = "normal";

     document.getElementById('subscriptions').style.display = 'none';

    Hservices = false;
    Happs = true;
    Hsubscriptions = true;
}

function showSubscriptions()
{
     document.getElementById('subscriptions').style.display = 'block';
        document.getElementById('subscriptions_li').style.paddingBottom = '1px';
        document.getElementById('subscriptions_li').style.borderTop = '1px solid #0e4769';
        document.getElementById('subscriptions_li').style.borderLeft = '1px solid #0e4769';
        document.getElementById('subscriptions_li').style.borderRight = '1px solid #0e4769';
        document.getElementById('subscriptions_li').style.backgroundColor = '#187ebc';
        document.getElementById('subscriptions_li').style.color = "#ffffff";




        document.getElementById('services_li').style.paddingBottom = '0px';
        document.getElementById('services_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('services_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('services_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #0e4769';

        document.getElementById('services_li').style.color = "#ffffff";

     document.getElementById('services').style.display = 'none';

        document.getElementById('apps_li').style.paddingBottom = '0px';
        document.getElementById('apps_li').style.borderTop = '0px solid #0e4769';
        document.getElementById('apps_li').style.borderLeft = '0px solid #0e4769';
        document.getElementById('apps_li').style.borderRight = '0px solid #0e4769';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #0e4769';

        document.getElementById('apps_li').style.color = "#ffffff";
        document.getElementById('apps_li').style.fontWeight = "normal";

     document.getElementById('apps').style.display = 'none';

    Hsubscriptions = false;
    Happs = true;
    Hservices = true;
}


function hoverApps()
{
    if(Happs)
    {
    //    document.getElementById('apps_li').style.backgroundColor = '#efefef';
    }
}
function unhoverApps()
{
    //document.getElementById('apps_li').style.backgroundColor = 'white';
}

function hoverServices()
{
    if(Hservices)
    {
    //document.getElementById('services_li').style.backgroundColor = '#efefef';
    }
}
function unhoverServices()
{
    //document.getElementById('services_li').style.backgroundColor = 'white';
}

function hoverSubscriptions()
{
    if(Hsubscriptions)
    {
    //document.getElementById('subscriptions_li').style.backgroundColor = '#efefef';
    }
}
function unhoverSubscribtions()
{
    //document.getElementById('subscriptions_li').style.backgroundColor = 'white';
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