@echo off
setlocal
setlocal enabledelayedexpansion

@rem Test method

echo ^> Auth GET Method for default username
curl -s --request GET "https://localhost:44386/auth"

echo.
echo.

echo ^> Auth POST Method for custom username "customuser"
curl -s --request POST -d '{}' "https://localhost:44386/auth/token/customuser" > .token
more .token

echo.
echo.

set /p TOKEN=<.token
echo ^> Auth POST Method for check authorization token
echo ^> No pass token in header
curl -s --request POST -d '{}' "https://localhost:44386/auth/check"
echo.
echo ^> Pass token in header
curl -s --request POST --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/check"
echo.
echo ^> Check Role : Admin
curl -s --request GET --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/CheckAdminRole"
echo.
echo ^> Check Role : Developer ( It will failed, because token didn't ​add developer roles)
curl -s --request GET --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/CheckDeveloperRole"
echo.
echo ^> Check Role : User
curl -s --request GET --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/CheckUserRole"
