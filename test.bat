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
echo ^> Check Role : Developer ( It will failed, because token did not add developer roles)
curl -s --request GET --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/CheckDeveloperRole"
echo.
echo ^> Check Role : User
curl -s --request GET --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/CheckUserRole"
echo.
echo ^> Check AccessLevel : 1
curl -s --request GET --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/CheckLevel1"
echo.
echo ^> Check AccessLevel : 2 ( It will failed, because token only have level 1)
curl -s --request GET --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/CheckLevel2"
echo.
echo ^> Check Role = Admin, AccessLevel = 1
curl -s --request GET --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/CheckMultiRule1"
echo.
echo ^> Check Role = Admin, AccessLevel = 2 ( It will failed )
curl -s --request GET --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/CheckMultiRule2"
echo.
echo ^> Check Role = Developer, AccessLevel = 1 ( It will failed )
curl -s --request GET --header "Authorization: Bearer %TOKEN%" -d '{}' "https://localhost:44386/auth/CheckMultiRule3"
