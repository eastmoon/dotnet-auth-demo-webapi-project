# dotnet-lifetime-demo-webapi-project

此專案為 .NET Core 生命週期範例專案。

本專案基於 [docker-dotnet-webapi](https://github.com/eastmoon/docker-dotnet-webapi) 設立：

+ [執行專案說明](https://github.com/eastmoon/docker-dotnet-webapi#%E5%9F%B7%E8%A1%8C%E5%B0%88%E6%A1%88)
+ 測試與驗證
    - 以 VS Code 開啟專案並編譯已啟動服務
    - 執行 ```test.bat``` 逐步執行服務
    - 確認回傳結果與檢查 ```Console``` 輸出結果

## 驗證與授權

**Authentication and authorization are two closely related concepts, which are used to build security mechanism in systems and applications. Information security is the practice of protecting information from unauthorized access, use or even modification.** - From [Introduction to Claims-Based Authentication and Authorization in .NET](https://kariera.future-processing.pl/blog/introduction-to-claims-based-authentication-and-authorization-in-net/)

Restful API 規範的僅是對 WebAPI 的設計原則，但設計原則並不包括資訊安全的管理與使用授權，在大部分的設計範例中，對用戶的驗證、授權反而是基本專案範本；然而在 .NET 框架下，驗證與授權是則可以匡列在其軟體框架之下，但也因此較難以理解其運作中隱含的技術與觀念。

+ 驗證 ( Authentication )

驗證是指檢查需求 ( Request ) 是否為本服務認可的來源，以加密原則來看，便是在需求中加上由伺服器提供的金鑰，而服務會解析其金鑰內容後才判斷是否讓需求繼續執行。

+ 授權 ( Authorization )

授權是指檢查需求 ( Request ) 是否具有執行本服務的權限，以加密操作來看，便是此金鑰是否具有使用此服務的權限，若無權限則應拒絕需求繼續執行。

## 設定與說明

ASP.NET 軟體框架中有提供完成的中介軟體，並提供開發者使用，但需注意 .NET Core 中的設定原則與 .NET MVC 類似，因此容易在文件中受到過量資訊混淆，在解讀文獻上需更加注意；本專案範本是依據文獻的程式範本為基礎，並綜合對語法的疑惑收尋資料以供框架理解。

### 啟用服務

依據 .NET Core 框架文獻，驗證與授權是其已提供的中介軟體，開發者僅需啟用服務並引入對應軟體框架版本的函式庫。

+ 於 ```Startup.ConfigureServices``` 設定 Authentication 並注意需要引用的框架函式庫
    - 為提供 JWT 操作，對此需於 NuGet 中引用正確版本的 ```Microsoft.AspNetCore.Authentication.JwtBearer```
+ 於 ```Startup.Configure``` 設定啟用中介軟體 ```UseAuthentication```、```UseAuthorization```

### 生成 JWT

JSON Web Token (JWT) 是一個開放標準 ( RFC 7519 )，是通過一種緊湊、自洽的方式定義了在多點間以安全協議傳輸 JSON 物件的方法；透過 JWT 可以依據用戶資訊生成一個對應用戶的 Token，當用戶存取服務時，則透過解析 Token 取得的資訊來取回用戶的認證、權限、資訊，以此提供後續服務的做資訊提取的數據。

+ 於 ```WebService.Controllers.AuthController``` 設置 WebAPI 介面，並使用 ```curl``` 指令測試存取結果
+ 依據設計原則，Controller 僅為介面，實際使用 ```WebService.Services.JwtService``` 產生 JWT
+ JWT 共分為三個編碼組成 ```Header.Payload.Signature```
+ JWT 中的用戶資訊主要存在於 Payload，其為符合 RFC 7519 規定或使用者自定義的資訊域，亦稱為 "Claim"
+ JWT 生成中的 issuer、signKey 等會用於驗證的資訊應存於系統啟動的 Configuration 中

### 驗證 JWT

依據 JSON Web Token (JWT) 文獻與相關 .NET Core 框架文獻，可以理解 JWT 是一組基於物件內邏輯生成的字串，而驗證則是基於反向操作設計；簡單的測試可以將字串傳入後將字串反解析為物件，亦可如下操作：

+ 於 ```Startup.ConfigureServices``` 設定 ```services.AddJwtBearer( ... )``` 內的操作細節
+ 透過 TokenValidationParameters 設定 JWT 驗證與資訊解析細節
+ 驗證用的 issuer、signKey 應存於系統啟動的 Configuration 中

可以注意到，JWT 驗證是否成功，主要是 issuer、signKey 等驗證資訊是否正確，且最重要 signKey 為私鑰並不可對外公開。

### 加入授權

依據 JSON Web Token (JWT) 文獻，可在 JWT 中加入角色授權，以符合角色為基礎的存取控制 ( Role-based access control、RBAC )，其方式如下：

+ 依據設計原則，修改 ```WebService.Services.JwtService``` 產生 JWT 的 Claim 內容
+ ```claims.Add(new Claim("roles", "Admin"));``` 以 kye-value 的方式填入角色

一個 JWT 中可以有複數的 Roles 資訊，但需注意若設定過多會導致 JWT 過長的問題。

### 角色授權屬性

在 JSON Web Token (JWT) 驗證後，開發者可以透過簡易授權來管理服務是否受驗證影響，若服務不受影響則表示該服務為開放介面

```
[Authorize]
public class AuthController : ControllerBase {
    [AllowAnonymous]
    public string demo() { ... }
}
```
> 此 Controller 下屬的服務需經過簡易授權 ```Authorize```，亦即需驗證通過才可操作；但設定為 ```AllowAnonymous``` 的行為不需驗證也可使用。

倘若 JWT 有提供 Roles 則需確保驗證過程中有解析 Roles 資料

```
services..AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, options => {
    ...
    options.TokenValidationParameters = new TokenValidationParameters
    {
          RoleClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role",
          ...
    }
});
```
> 指定 TokenValidationParameters.RoleClaimType 數值為上述網址 ( 此網址資訊根源於 [CliamsType](https://docs.microsoft.com/zh-tw/dotnet/api/system.security.claims.claimtypes?view=net-5.0) 說明 )，在解析原則應該是基於 RoleClaimType 定義並在 JWT 的 Cliams 列表中搜尋具有此字串的內容，並解析出角色資訊。

```
[Authorize]
public class AuthController : ControllerBase {
    [Authorize(Roles = "Admin")]
    [HttpGet("[action]")]
    public string CheckAdminRole() { ... }
}
```
> 此 Controller 下屬的服務需經過簡易授權 ```Authorize```，亦即需驗證通過才可操作；但設定為 ```Authorize(Roles = "Admin")``` 的行為則需是具有 Admin 角色的 JWT 才可使用。

### 相關設計與應用說明

+ [使用 Entity Framework (EF) 的自訂 Identity 模型](https://docs.microsoft.com/zh-tw/aspnet/core/security/authentication/customize-identity-model?view=aspnetcore-3.1)

此方式為透過 EF 產生 Identity 模型，讓驗證與授權可以從 JWT 中轉換資料為 Identity 模型需要，此項設計與應用需要綁定 EF 的資料模型與對資料庫操作，雖資料轉換的類別有助理解物件操作，但其對資料庫的對應會使服務與資料庫行為綁定，產生不必要的依賴性。

+ [使用原則 ( Policy ) 授權](https://docs.microsoft.com/zh-tw/aspnet/core/security/authorization/policies?view=aspnetcore-3.1)

從 .NET 文獻可知，其授權機制共分簡易、角色、原則，簡易與角色於前述說明，而原則適用於複雜的授權條件或需調用額外數據運算後的授權判斷；亦可解釋為當角色提供的資訊不足時，需額外提供相關資訊時可使用的方式。

## 文獻

+ [ASP.NET Core 驗證的總覽](https://docs.microsoft.com/zh-tw/aspnet/core/security/authentication/?view=aspnetcore-3.1)
    - [JWT.io](https://jwt.io/)
+ [ASP.NET Core 的授權簡介](https://docs.microsoft.com/zh-tw/aspnet/core/security/authorization/introduction?view=aspnetcore-3.1)
    - [ASP.NET Core 中以角色為基礎的授權](https://docs.microsoft.com/zh-tw/aspnet/core/security/authorization/roles?view=aspnetcore-3.1)
        + [Advanced ASP.NET Programming for Windows Identity Foundation](https://www.microsoftpressstore.com/articles/article.aspx?p=2225067&seqNum=3)
        + [宣告的角色](https://docs.microsoft.com/zh-tw/windows-server/identity/ad-fs/technical-reference/the-role-of-claims)
    - [ASP.NET Core 中以宣告為基礎的授權](https://docs.microsoft.com/zh-tw/aspnet/core/security/authorization/claims?view=aspnetcore-3.1)
    - [ASP.NET Core 中以原則為基礎的授權](https://docs.microsoft.com/zh-tw/aspnet/core/security/authorization/policies?view=aspnetcore-3.1)
        + [Policy-based Authorization in ASP.NET Core – A Deep Dive](https://www.red-gate.com/simple-talk/dotnet/c-programming/policy-based-authorization-in-asp-net-core-a-deep-dive/)
        + [Asp.Net Core MVC RC2 授權(Authorization) 機制](https://dotblogs.com.tw/raymondfan/2016/05/25/aspnet_core_mvc_rc2_authorization)
+ 實務範例
    - [實作 System.IdentityModel.Tokens.Jwt 進行身分驗證](https://dotblogs.com.tw/yc421206/2019/01/08/authentication_via_ms_system_identitymodel_tokens_jwt)
    - [如何在 ASP.NET Core 3 使用 Token-based 身分驗證與授權 (JWT)](https://blog.miniasp.com/post/2019/12/16/How-to-use-JWT-token-based-auth-in-aspnet-core-31)
    - [如何實作沒有 ASP.NET Core Identity 的 Cookie-based 身分驗證機制](https://blog.miniasp.com/post/2019/12/25/asp-net-core-3-cookie-based-authentication)
    - [Day17 實作 Identity ASP.NET Core](https://ithelp.ithome.com.tw/articles/10238429)
    - [Authentication And Authorization In ASP.NET Core Web API With JSON Web Tokens](https://www.c-sharpcorner.com/article/authentication-and-authorization-in-asp-net-core-web-api-with-json-web-tokens/)
    - [Authentication & Authorization in ASP .NET Core 3.1](https://wakeupandcode.com/authentication-authorization-in-asp-net-core-3-1/)
    - [ASP.NET Core Web API: Authorization](https://auth0.com/docs/quickstart/backend/aspnet-core-webapi/01-authorization)
