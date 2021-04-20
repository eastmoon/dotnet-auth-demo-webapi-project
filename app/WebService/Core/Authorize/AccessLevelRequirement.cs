using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebService.Core.Authorize
{
    public class AccessLevelRequirement : IAuthorizationRequirement
    {
        public int AccessLevel { get; set; }
        public AccessLevelRequirement(int level)
        {
            AccessLevel = level;
        }
    }
}
