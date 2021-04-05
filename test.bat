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
