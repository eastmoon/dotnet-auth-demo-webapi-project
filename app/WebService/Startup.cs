using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Authorization;

namespace WebService
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // 註冊使用 Controllers 
            services.AddControllers();

            // 註冊使用 Authentication 服務
            // 於專案設定 NuGet 套件引用 Microsoft.AspNetCore.Authentication.JwtBearer，並依據專案框架版本選用套件
            // Ref : https://www.nuget.org/packages/Microsoft.AspNetCore.Authentication.JwtBearer/3.0.0
            // .NET Core 共有兩種驗證機制，JwtBearer、Cookie，兩者差別可參考說明文獻
            services
                .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, options => {
                    // 當驗證失敗時，回應標頭會包含 WWW-Authenticate 標頭，這裡會顯示失敗的詳細錯誤原因
                    options.IncludeErrorDetails = true;

                    // 設定驗證程序須執行的動作項目
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        // 透過這項宣告，就可以從 "sub" 取值並設定給 User.Identity.Name
                        NameClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier",

                        // 透過這項宣告，就可以從 "roles" 取值，並可讓 [Authorize] 判斷角色
                        RoleClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role",

                        // 驗證 Issuer 資訊，若驗證失敗則表示該 JWT 非本系統發出
                        ValidateIssuer = true,
                        ValidIssuer = Configuration.GetValue<string>("JwtSettings:Issuer"),

                        // 驗證 Audience 資訊，若驗證失敗則表示該 JWT 非本系統發出
                        // 若不驗證就不需要填寫並設為 false
                        ValidateAudience = true,
                        ValidAudience = Configuration.GetValue<string>("JwtSettings:Issuer"),

                        // 驗證 Token 的有效期間
                        ValidateLifetime = true,

                        // 若 Token 中包含 key 需要驗證其內容，若未提供則應避免驗證
                        ValidateIssuerSigningKey = false,

                        // 提供自 IConfiguration 取得的驗證碼
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Configuration.GetValue<string>("JwtSettings:SignKey")))
                    };

                    //
                    Configuration.Bind("JwtSettings", options);
                    });

            // 註冊 JWT 處理服務
            services.AddSingleton<WebService.Services.JwtService>();

            // 註冊原則授權處理函式
            services.AddSingleton<IAuthorizationHandler, Core.Authorize.AccessLevelHandler>();

            // 註冊原則授權
            services.AddAuthorization(options =>
            {
                options.AddPolicy("AccessLevel-1", policy => policy.Requirements.Add(new Core.Authorize.AccessLevelRequirement(1)));
                options.AddPolicy("AccessLevel-2", policy => policy.Requirements.Add(new Core.Authorize.AccessLevelRequirement(2)));
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseHttpsRedirection();

            app.UseRouting();

            // 啟用 Authentication 中介軟體
            app.UseAuthentication();
            // 啟用 Authorization 中介軟體
            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }
    }
}
