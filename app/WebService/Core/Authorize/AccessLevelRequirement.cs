using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebService.Core.Authorize
{
    /// <summary>
    /// 自定義『存取等級』授權需求
    /// 當此類別撰寫完成，請至 Startup.ConfigureServices 註冊處理函式內，使用 services.AddAuthorization 增加授權原則
    /// 參考文獻 https://docs.microsoft.com/zh-tw/aspnet/core/security/authorization/policies?view=aspnetcore-3.1#requirements
    /// </summary>
    public class AccessLevelRequirement : IAuthorizationRequirement
    {
        public int AccessLevel { get; set; }
        public AccessLevelRequirement(int level)
        {
            AccessLevel = level;
        }
    }
}
