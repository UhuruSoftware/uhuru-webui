function loadXml(){
    if(window.XMLHttpRequest)
    {
        xmlhttp = new XMLHttpRequest();
    }
    else
    {
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.open("GET", "/xml");
    xmlhttp.send();
    xmlDoc = xmlhttp.responseXML;
    var appList = new Array();

    for(i=0; i<=xmlDoc.length; i++)
    {
        appList = xmlDoc.getElementByTagName("template")[i].getAttributeNode("name");
        alert(appList);

    alert("dsds");
    }
}