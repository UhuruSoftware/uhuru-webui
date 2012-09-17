//Show hide Members and Spaces from Organization page

function showSpaces()
{
     document.getElementById('spaces').style.display = 'block';
        document.getElementById('spaces_btn_link').style.paddingBottom = '1px';
        document.getElementById('spaces_btn_link').style.borderTop = '1px solid #DDD';
        document.getElementById('spaces_btn_link').style.borderLeft = '1px solid #DDD';
        document.getElementById('spaces_btn_link').style.borderRight = '1px solid #DDD';
        document.getElementById('spaces_btn_link').style.backgroundColor = 'white';

        document.getElementById('members_btn_link').style.paddingBottom = '0px';
        document.getElementById('members_btn_link').style.borderTop = '0px solid #DDD';
        document.getElementById('members_btn_link').style.borderLeft = '0px solid #DDD';
        document.getElementById('members_btn_link').style.borderRight = '0px solid #DDD';
        document.getElementById('tabs').style.borderBottom = '1px solid #DDD';
     document.getElementById('members').style.display = 'none';
}

function showMembers()
{
     document.getElementById('members').style.display = 'block';
        document.getElementById('members_btn_link').style.paddingBottom = '1px';
        document.getElementById('members_btn_link').style.borderTop = '1px solid #DDD';
        document.getElementById('members_btn_link').style.borderLeft = '1px solid #DDD';
        document.getElementById('members_btn_link').style.borderRight = '1px solid #DDD';
        document.getElementById('members_btn_link').style.backgroundColor = 'white';

        document.getElementById('spaces_btn_link').style.paddingBottom = '0px';
        document.getElementById('spaces_btn_link').style.borderTop = '0px solid #DDD';
        document.getElementById('spaces_btn_link').style.borderLeft = '0px solid #DDD';
        document.getElementById('spaces_btn_link').style.borderRight = '0px solid #DDD';
        document.getElementById('tabs').style.borderBottom = '1px solid #DDD';
     document.getElementById('spaces').style.display = 'none';
}

function hoverSpaces()
{
    document.getElementById('spaces_btn_link').style.backgroundColor = '#effbfb';
}
function unhoverSpaces()
{
    document.getElementById('spaces_btn_link').style.backgroundColor = 'white';
}

function hoverMembers()
{
    document.getElementById('members_btn_link').style.backgroundColor = '#effbfb';
}
function unhoverMembers()
{
    document.getElementById('members_btn_link').style.backgroundColor = 'white';
}





//Show hide Apps, Services and Subscriptions from Spaces page

function showApps()
{
     document.getElementById('apps').style.display = 'block';
        document.getElementById('apps_li').style.paddingBottom = '1px';
        document.getElementById('apps_li').style.borderTop = '1px solid #DDD';
        document.getElementById('apps_li').style.borderLeft = '1px solid #DDD';
        document.getElementById('apps_li').style.borderRight = '1px solid #DDD';
        document.getElementById('apps_li').style.backgroundColor = 'white';



        document.getElementById('services_li').style.paddingBottom = '0px';
        document.getElementById('services_li').style.borderTop = '0px solid #DDD';
        document.getElementById('services_li').style.borderLeft = '0px solid #DDD';
        document.getElementById('services_li').style.borderRight = '0px solid #DDD';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #DDD';
     document.getElementById('services').style.display = 'none';

        document.getElementById('subscriptions_li').style.paddingBottom = '0px';
        document.getElementById('subscriptions_li').style.borderTop = '0px solid #DDD';
        document.getElementById('subscriptions_li').style.borderLeft = '0px solid #DDD';
        document.getElementById('subscriptions_li').style.borderRight = '0px solid #DDD';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #DDD';
     document.getElementById('subscriptions').style.display = 'none';
}

function showServices()
{
     document.getElementById('services').style.display = 'block';
        document.getElementById('services_li').style.paddingBottom = '1px';
        document.getElementById('services_li').style.borderTop = '1px solid #DDD';
        document.getElementById('services_li').style.borderLeft = '1px solid #DDD';
        document.getElementById('services_li').style.borderRight = '1px solid #DDD';
        document.getElementById('services_li').style.backgroundColor = 'white';




        document.getElementById('apps_li').style.paddingBottom = '0px';
        document.getElementById('apps_li').style.borderTop = '0px solid #DDD';
        document.getElementById('apps_li').style.borderLeft = '0px solid #DDD';
        document.getElementById('apps_li').style.borderRight = '0px solid #DDD';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #DDD';
     document.getElementById('apps').style.display = 'none';

        document.getElementById('subscriptions_li').style.paddingBottom = '0px';
        document.getElementById('subscriptions_li').style.borderTop = '0px solid #DDD';
        document.getElementById('subscriptions_li').style.borderLeft = '0px solid #DDD';
        document.getElementById('subscriptions_li').style.borderRight = '0px solid #DDD';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #DDD';
     document.getElementById('subscriptions').style.display = 'none';
}

function showSubscriptions()
{
     document.getElementById('subscriptions').style.display = 'block';
        document.getElementById('subscriptions_li').style.paddingBottom = '1px';
        document.getElementById('subscriptions_li').style.borderTop = '1px solid #DDD';
        document.getElementById('subscriptions_li').style.borderLeft = '1px solid #DDD';
        document.getElementById('subscriptions_li').style.borderRight = '1px solid #DDD';
        document.getElementById('subscriptions_li').style.backgroundColor = 'white';




        document.getElementById('services_li').style.paddingBottom = '0px';
        document.getElementById('services_li').style.borderTop = '0px solid #DDD';
        document.getElementById('services_li').style.borderLeft = '0px solid #DDD';
        document.getElementById('services_li').style.borderRight = '0px solid #DDD';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #DDD';
     document.getElementById('services').style.display = 'none';

        document.getElementById('apps_li').style.paddingBottom = '0px';
        document.getElementById('apps_li').style.borderTop = '0px solid #DDD';
        document.getElementById('apps_li').style.borderLeft = '0px solid #DDD';
        document.getElementById('apps_li').style.borderRight = '0px solid #DDD';
        document.getElementById('spaces_tabs').style.borderBottom = '1px solid #DDD';
     document.getElementById('apps').style.display = 'none';
}


function hoverApps()
{
    document.getElementById('apps_li').style.backgroundColor = '#effbfb';
}
function unhoverApps()
{
    document.getElementById('apps_li').style.backgroundColor = 'white';
}

function hoverServices()
{
    document.getElementById('services_li').style.backgroundColor = '#effbfb';
}
function unhoverServices()
{
    document.getElementById('services_li').style.backgroundColor = 'white';
}

function hoverSubscriptions()
{
    document.getElementById('subscriptions_li').style.backgroundColor = '#effbfb';
}
function unhoverSubscribtions()
{
    document.getElementById('subscriptions_li').style.backgroundColor = 'white';
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