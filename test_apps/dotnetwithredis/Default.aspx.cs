using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ServiceStack.Redis;
using System.Configuration;

namespace dotnetwithredis
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string host = ConfigurationManager.AppSettings["host"];
            int port = Convert.ToInt32(ConfigurationManager.AppSettings["port"]);
            string password = ConfigurationManager.AppSettings["password"];

            try
            {
                var server = new RedisClient(host, port, password);
                server.Echo("success!!");
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
