using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;
using System.Web.Script.Serialization;
using System.Collections;

namespace dotnetwithmysql
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string serverConnectionString = ConfigurationManager.AppSettings["cnnString"];
            using (MySqlConnection conn = new MySqlConnection(serverConnectionString))
            {
                try
                {
                    conn.Open();
                    Response.Write("success");
                }
                catch (Exception ex)
                {
                    Response.StatusCode = 500;
                    Response.Write(ex.Message);
                }
            }
        }
    }
}