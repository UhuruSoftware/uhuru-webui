using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.IO;
using System.Configuration;

namespace dotnetwithuhurufs
{
    public partial class Default : System.Web.UI.Page
    {
        string ftpUser = ConfigurationManager.AppSettings["ftpUser"];
        string ftpPass = ConfigurationManager.AppSettings["ftpPass"];
        string ftpServer = ConfigurationManager.AppSettings["ftpServer"];
        string ftpPort = ConfigurationManager.AppSettings["ftpPort"];

        string uri;

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                string fileName = Server.MapPath("TransferFile.txt");
                
                Upload(fileName);
                if (DoesFtpFileExists(fileName))
                    Response.Write("success");
                else
                {
                    //Response.StatusCode = 500;
                    File.WriteAllText(Server.MapPath("error.txt"), "file not found");
                    Response.Write("file not found");
                }
            }
            catch (Exception ex)
            {
                //Response.StatusCode = 500;
                File.WriteAllText(Server.MapPath("error.txt"), ex.Message + Environment.NewLine + ex.StackTrace);
                Response.Write(ex.Message + Environment.NewLine + ex.StackTrace);
            }
        }

        private void Upload(string filename)
        {
            FileInfo fileInf = new FileInfo(filename);
            uri = string.Format("ftp://{0}:{1}@{4}:{2}/{3}", ftpUser, ftpPass, ftpPort, fileInf.Name, ftpServer);

            FtpWebRequest reqFTP;

            // Create FtpWebRequest object from the Uri provided
            reqFTP = (FtpWebRequest)FtpWebRequest.Create(new Uri(uri));

            // Specify the command to be executed.
            reqFTP.Method = WebRequestMethods.Ftp.UploadFile;

            // Specify the data transfer type.
            reqFTP.UseBinary = true;

            // Notify the server about the size of the uploaded file
            reqFTP.ContentLength = fileInf.Length;

            // The buffer size is set to 2kb
            int buffLength = 2048;
            byte[] buff = new byte[buffLength];
            int contentLen;

            // Opens a file stream (System.IO.FileStream) to read the file to be uploaded
            FileStream fs = fileInf.OpenRead();

            
            // Stream to which the file to be upload is written
            Stream strm = reqFTP.GetRequestStream();

            // Read from the file stream 2kb at a time
            contentLen = fs.Read(buff, 0, buffLength);

            // Till Stream content ends
            while (contentLen != 0)
            {
                // Write Content from the file stream to the FTP Upload Stream
                strm.Write(buff, 0, contentLen);
                contentLen = fs.Read(buff, 0, buffLength);
            }

            // Close the file stream and the Request Stream
            strm.Close();
            fs.Close();
            
        }

        public bool DoesFtpFileExists(string remoteUri)
        {
            FtpWebRequest request = (FtpWebRequest)WebRequest.Create(new Uri(uri));
            FtpWebResponse response;

            request.Method = WebRequestMethods.Ftp.GetFileSize;
            
            try
            {
                response = (FtpWebResponse)request.GetResponse();
                long remFileSize = response.ContentLength;
                return true;
            }
            catch (WebException we)
            {
                response = we.Response as FtpWebResponse;
                if (response != null && response.StatusCode == FtpStatusCode.ActionNotTakenFileUnavailable)
                {
                    
                    return false;
                }

                throw;
            }
        }
    }
}