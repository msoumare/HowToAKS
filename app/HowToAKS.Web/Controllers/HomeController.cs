using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using HowToAKS.Web.Models;
using System.Net.Http;

namespace HowToAKS.Web.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        public async Task<IActionResult> Test()
        {
            try  
            {
                using (var client = new HttpClient())
                {
                    var request = new HttpRequestMessage
                    {
                        RequestUri = new Uri("http://howtoaks-webapi:8081/api/values") // When deploying in the default namespace, then you only use the container/pod name in the dns.                        
                        // RequestUri = new Uri("http://howtoaks-webapi.back-end:8081/api/values") // When deploying in custom namespaces, then you must include the namespace in the dns.
                    };

                    var response = await client.SendAsync(request);
                    ViewBag.Result = await response.Content.ReadAsStringAsync();
                }
            }
            catch (Exception ex)
            {
                ViewBag.Result = ex;
            }

            return View();
        }


        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
