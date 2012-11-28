/*
    These 2 functions are for updating the Organization and Space names
*/

function showSpacesInput()
{
    document.getElementById('space_input').style.display = 'block';
    document.getElementById('space_input').value = document.getElementById('space_name').innerHTML;
    document.getElementById('space_input').focus();
    document.getElementById('space_input').style.border = '1px solid #2eccfa';
    document.getElementById('space_name').style.display = 'none';
}

function showOrganizationsInput()
{
    document.getElementById('organization_input').style.display = 'block';
    document.getElementById('organization_input').value = document.getElementById('organization_name').innerHTML;
    document.getElementById('organization_input').focus();
    document.getElementById('organization_input').style.border = '1px solid #2eccfa';
    document.getElementById('organization_name').style.display = 'none';
}

function sleep(milliseconds) {
  var on = new Date().getTime();
  for (var i = 0; i < 1e7; i++) {
    if ((new Date().getTime() - on) > milliseconds){
      break;
    }
  }
}