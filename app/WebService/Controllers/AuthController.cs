using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using WebService.Services;

namespace WebService.Controllers
{
    [Route("[controller]")]
    [ApiController]
    [Authorize]
    public class AuthController : ControllerBase
    {
        private readonly JwtService JWT;
        public AuthController(JwtService jwt)
        {
            this.JWT = jwt;
        }

        [AllowAnonymous]
        [HttpGet]
        public string demo()
        {
            return JWT.GenerateToken("demo-user");
        }

        [AllowAnonymous]
        [HttpPost("[action]/{username}")]
        public string Token(string username)
        {
            Console.WriteLine("> Token call " + username);
            return JWT.GenerateToken(username);
        }

        [HttpPost("[action]")]
        public string Check()
        {
            Console.WriteLine("> Check call " + Request.Headers["Authorization"]);
            User.Claims.ToList().ForEach(p => Console.WriteLine($"> {p.Type} - {p.Value}"));
            Console.WriteLine("> Claims.jti = " + User.Claims.FirstOrDefault(p => p.Type == "jti").Value);
            return User.Identity.Name;
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("[action]")]
        public string CheckAdminRole()
        {
            return "Token has admin roles";
        }

        [Authorize(Roles = "Developer")]
        [HttpGet("[action]")]
        public string CheckDeveloperRole()
        {
            return "Token has developer roles";
        }

        [Authorize(Roles = "Users")]
        [HttpGet("[action]")]
        public string CheckUserRole()
        {
            return "Token has users roles";
        }

        [Authorize(Policy = "AccessLevel-1")]
        [HttpGet("[action]")]
        public string CheckLevel1()
        {
            return "Token has AccessLevel 1";
        }

        [Authorize(Policy = "AccessLevel-2")]
        [HttpGet("[action]")]
        public string CheckLevel2()
        {
            return "Token has AccessLevel 2";
        }

        [Authorize(Policy = "AccessLevel-1")]
        [Authorize(Roles = "Admin")]
        [HttpGet("[action]")]
        public string CheckMultiRule1()
        {
            return "Token has AccessLevel 1 and Role Admin";
        }

        [Authorize(Policy = "AccessLevel-2")]
        [Authorize(Roles = "Admin")]
        [HttpGet("[action]")]
        public string CheckMultiRule2()
        {
            return "Token has AccessLevel 2 and Role Admin";
        }

        [Authorize(Policy = "AccessLevel-1")]
        [Authorize(Roles = "Developer")]
        [HttpGet("[action]")]
        public string CheckMultiRule3()
        {
            return "Token has AccessLevel 1 and Role Developer";
        }
    }
}
