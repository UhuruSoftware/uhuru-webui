using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SampleApp
{
    public partial class _Default : Page
    {
        string createTableCommand = @"IF NOT EXISTS (SELECT * FROM sys.tables
WHERE name = N'{0}' AND type = 'U')

BEGIN
CREATE TABLE {0} (
ID INT IDENTITY PRIMARY KEY, 
DATE Varchar(MAX),
IP Varchar(MAX)
)

END";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Environment.GetEnvironmentVariables().Contains("VCAP_APPLICATION"))
            {
                Label1.Text = Environment.GetEnvironmentVariable("VCAP_APP_HOST");
                string json = Environment.GetEnvironmentVariable("VCAP_APPLICATION");
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                Dictionary<string, object> app = serializer.Deserialize<Dictionary<string, object>>(json);
                Label2.Text = Environment.GetEnvironmentVariable("VCAP_APP_PORT");
                Label3.Text = app["instance_id"].ToString();
            }
            string connString = WebConfigurationManager.ConnectionStrings["db"].ConnectionString;
            string tableName = "visitors";

            HttpRequest currentRequest = HttpContext.Current.Request;
            string ipAddress = currentRequest.ServerVariables["HTTP_X_FORWARDED_FOR"];

            if (ipAddress == null || ipAddress.ToLower() == "unknown")
                ipAddress = currentRequest.ServerVariables["REMOTE_ADDR"];

            SqlConnection conn; conn = new SqlConnection(connString);
            conn.Open();
            try
            {
                SqlCommand command = conn.CreateCommand();
                command.CommandText = string.Format(createTableCommand, tableName);
                command.ExecuteNonQuery();
                command.CommandText = string.Format("insert into {0} (date, ip) values ('{1}', '{2}')", tableName, DateTime.Now, ipAddress);
                command.ExecuteNonQuery();
                command.CommandText = string.Format("select top 10 date as 'Date', ip as 'Visitor IP' from {0} order by id desc", tableName);
                SqlDataReader reader = command.ExecuteReader();
                GridView1.DataSource = reader;
                GridView1.DataBind();
            }
            catch (Exception ex)
            {
                Response.Write("oops, something went terribly wrong:" + ex.ToString());
            }
            finally
            {
                conn.Close();
            }
        }
    }
}