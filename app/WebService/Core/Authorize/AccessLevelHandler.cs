using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebService.Core.Authorize
{
    /// <summary>
    /// 自定義『存取等級』授權處理函式
    /// 針對特定授權需求，可以存在多個授權處理函式，只要此類別繼承的 AuthorizationHandler<TRequirement>，在 TRequirement 相同
    /// 當此類別撰寫完成，請至 Startup.ConfigureServices 註冊處理函式
    /// 參考文獻 https://docs.microsoft.com/zh-tw/aspnet/core/security/authorization/policies?view=aspnetcore-3.1#authorization-handlers
    /// </summary>
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
