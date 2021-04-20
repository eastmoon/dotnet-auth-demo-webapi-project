using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebService.Core.Authorize
{
    public class AccessLevelHandler :
         AuthorizationHandler<AccessLevelRequirement>
    {
        protected override Task HandleRequirementAsync(
               AuthorizationHandlerContext context,
               AccessLevelRequirement requirement)
        {
            var user = context.User;
            var claim = context.User.FindFirst("accesslevel");
            if (claim != null)
            {
                var level = int.Parse(claim?.Value);
                if (level >= requirement.AccessLevel)
                    context.Succeed(requirement);
            }
            return Task.CompletedTask;
        }
    }
}
