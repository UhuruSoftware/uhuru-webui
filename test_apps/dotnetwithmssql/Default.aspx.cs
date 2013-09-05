using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Data.SqlClient;

namespace dotnetwithmssql
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string serverConnectionString = ConfigurationManager.ConnectionStrings["testDb"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(serverConnectionString))
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