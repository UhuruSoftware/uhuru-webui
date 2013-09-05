using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using MongoDB.Driver;

namespace dotnetwithmongo
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string connectionString = ConfigurationManager.AppSettings["cnnString"];
            
            try
            {
                var server = MongoServer.Create(connectionString);
                Response.Write("success");
            }
            catch (Exception ex)
            {
                Response.StatusCode = 500;
                Response.Write(ex.Message + Environment.NewLine + ex.StackTrace);
            }
            
        }
    }
}