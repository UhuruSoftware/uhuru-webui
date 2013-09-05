using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using RabbitMQ.Client;
using System.Configuration;
using System.Text;
using RabbitMQ.Client.MessagePatterns;
using RabbitMQ.Client.Events;
using System.Runtime.Serialization.Json;
using System.Web.Script.Serialization;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            var connectionFactory = new ConnectionFactory();
            connectionFactory.HostName = ConfigurationManager.AppSettings["hostname"];
            connectionFactory.UserName = ConfigurationManager.AppSettings["username"];
            connectionFactory.Password = ConfigurationManager.AppSettings["password"];
            connectionFactory.Port = Convert.ToInt32(ConfigurationManager.AppSettings["port"]);
            connectionFactory.Protocol = Protocols.FromEnvironment();
            connectionFactory.VirtualHost = GetVirtualHost();

            //Response.Write(connectionFactory.HostName + " " + connectionFactory.UserName + " " +
            //                    connectionFactory.Port.ToString() + " " + connectionFactory.Password);

            string message = "Hello!!";

            //send message to queue
            using (IConnection connection =
                        connectionFactory.CreateConnection())
            {
                using (IModel model = connection.CreateModel())
                {
                    model.ExchangeDeclare("MyExchange", ExchangeType.Fanout, true);
                    model.QueueDeclare("MyQueue", true, false, false, new Dictionary<string, object>());
                    model.QueueBind("MyQueue", "MyExchange", "",
                            new Dictionary<string, object>());


                    IBasicProperties basicProperties = model.CreateBasicProperties();
                    model.BasicPublish("MyExchange", "", false, false,
                        basicProperties, Encoding.UTF8.GetBytes(message));
                }
            }

            //consume message from queue
            using (IConnection connection = connectionFactory.CreateConnection())
            {
                using (IModel model = connection.CreateModel())
                {
                    var subscription = new Subscription(model, "MyQueue", false);
                    while (true)
                    {
                        BasicDeliverEventArgs basicDeliveryEventArgs =
                            subscription.Next();
                        string messageContent =
                            Encoding.UTF8.GetString(basicDeliveryEventArgs.Body);
                        //Response.Write(messageContent);
                        subscription.Ack(basicDeliveryEventArgs);

                        if (messageContent == message)
                        {
                            break;
                        }
                    }
                }
            }

            Response.Write("OK");
        }
        catch (Exception ex)
        {
            Response.StatusCode = 500;
            if (ex.InnerException != null)
                Response.Write(ex.InnerException.Message);

            Response.Write(ex.Message + Environment.NewLine + ex.StackTrace);
        }
    }

    private string GetVirtualHost()
    {
        string vcapInfo = ConfigurationManager.AppSettings["VCAP_SERVICES"];
       
        var json_serializer = new JavaScriptSerializer();
        Dictionary<string, object> values = (Dictionary<string, object>)json_serializer.DeserializeObject(vcapInfo);
        
        object[] tmp = values["rabbitmq-2.4"] as object[];
        values = tmp[0] as Dictionary<string, object>;
        values = values["credentials"] as Dictionary<string, object>;
        
        return values["vhost"].ToString();
    }
}