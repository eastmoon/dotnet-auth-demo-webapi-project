@rem
@rem Copyright 2020 the original author jacky.eastmoon
@rem All commad module need 3 method :
@rem [command]        : Command script
@rem [command]-args   : Command script options setting function
@rem [command]-help   : Command description
@rem Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
@rem But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
@rem NOTE, batch call [command]-args it could call correct one or call [command] and "-args" is parameter.
@rem

:: ------------------- batch setting -------------------
@rem setting batch file
@rem ref : https://www.tutorialspoint.com/batch_script/batch_script_if_else_statement.htm
@rem ref : https://poychang.github.io/note-batch/

@echo off
setlocal
setlocal enabledelayedexpansion

:: ------------------- declare CLI file variable -------------------
@rem retrieve project name
@rem Ref : https://www.robvanderwoude.com/ntfor.php
@rem Directory = %~dp0
@rem Object Name With Quotations=%0
@rem Object Name Without Quotes=%~0
@rem Bat File Drive = %~d0
@rem Full File Name = %~n0%~x0
@rem File Name Without Extension = %~n0
@rem File Extension = %~x0

set CLI_DIRECTORY=%~dp0
set CLI_FILE=%~n0%~x0
set CLI_FILENAME=%~n0
set CLI_FILEEXTENSION=%~x0

:: ------------------- declare CLI variable -------------------

set BREADCRUMB=cli
set COMMAND=
set COMMAND_BC_AGRS=
set COMMAND_AC_AGRS=

:: ------------------- declare variable -------------------

for %%a in ("%cd%") do (
    set PROJECT_NAME=%%~na
)
set PROJECT_ENV=dev
set PROJECT_SSH_USER=somesshuser
set PROJECT_SSH_PASS=somesshpass

:: ------------------- execute script -------------------

call :main %*
goto end

:: ------------------- declare function -------------------

:main (
    call :argv-parser %*
    call :%BREADCRUMB%-args %COMMAND_BC_AGRS%
    call :main-args %COMMAND_BC_AGRS%
    IF defined COMMAND (
        set BREADCRUMB=%BREADCRUMB%-%COMMAND%
        call :main %COMMAND_AC_AGRS%
    ) else (
        call :%BREADCRUMB%
    )
    goto end
)
:main-args (
    for %%p in (%*) do (
        if "%%p"=="-h" ( set BREADCRUMB=%BREADCRUMB%-help )
        if "%%p"=="--help" ( set BREADCRUMB=%BREADCRUMB%-help )
    )
    goto end
)
:argv-parser (
    set COMMAND=
    set COMMAND_BC_AGRS=
    set COMMAND_AC_AGRS=
    set is_find_cmd=
    for %%p in (%*) do (
        IF NOT defined is_find_cmd (
            echo %%p | findstr /r "\-" >nul 2>&1
            if errorlevel 1 (
                set COMMAND=%%p
                set is_find_cmd=TRUE
            ) else (
                set COMMAND_BC_AGRS=!COMMAND_BC_AGRS! %%p
            )
        ) else (
            set COMMAND_AC_AGRS=!COMMAND_AC_AGRS! %%p
        )
    )
    goto end
)

:: ------------------- Main mathod -------------------

:cli (
    goto cli-help
)

:cli-args (
    goto end
)

:cli-help (
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo If not input any command, at default will show HELP
    echo.
    echo Options:
    echo      --help, -h        Show more information with CLI.
    echo.
    echo Command:
    echo      dev               Startup sdk container and go into container.
    echo      publish           Build and Publish project assembly file.
    echo      swagger           Generate project api-doc with Swagger and OpenAPI format.
    echo      run               Startup runtime container with publish assembly file.
    echo      package           Package published file in docker image.
    echo      db                Start local database.
    echo      ef                Generate ORM entities object with .NET entities framework.
    echo.
    echo Run 'cli [COMMAND] --help' for more information on a command.
    goto end
)

:: ------------------- Command "dev" mathod -------------------

:cli-dev-prepare (
    echo ^> Initial cache
    IF NOT EXIST cache\published (
        mkdir cache\published
    )
    IF NOT EXIST cache\api-doc (
        mkdir cache\api-doc
    )

    echo ^> Build image
    docker build --rm^
        -t dotnet.webapi.sdk:%PROJECT_NAME%^
        ./docker/dotnet-sdk

    goto end
)

:cli-dev (
    call :cli-dev-prepare

    echo ^> Startup docker container instance
    docker run --rm -ti ^
        -v %cd%\app\:/repo^
        -p 5000:5000^
        -p 5001:5001^
        --name %PROJECT_NAME%-dotnet-server^
        dotnet.webapi.sdk:%PROJECT_NAME%

    goto end
)

:cli-dev-args (
    goto end
)

:cli-dev-help (
    echo Startup sdk container and go into container.
    echo.
    echo Options:
    echo.
    goto end
)

:: ------------------- Command "publish" mathod -------------------

:cli-publish (
    call :cli-dev-prepare

    echo ^> Startup docker container instance
    docker rm -f %PROJECT_NAME%-dotnet-server
    docker run -ti -d ^
        -v %cd%\app\:/repo^
        -v %cd%\cache\published:/repo/published^
        --name %PROJECT_NAME%-dotnet-server^
        dotnet.webapi.sdk:%PROJECT_NAME%

    @rem Execute command
    echo ^> Publish .NET Core project
    docker exec -ti %PROJECT_NAME%-dotnet-server bash -l -c "rm -rf published/* && dotnet publish --configuration Release -o published"

    @rem close server
    docker rm -f %PROJECT_NAME%-dotnet-server
    goto end
)

:cli-publish-args (
    goto end
)

:cli-publish-help (
    echo Build and Publish project assembly file.
    echo.
    echo Options:
    echo.
    goto end
)

:: ------------------- Command "swagger" mathod -------------------

:cli-swagger (
    call :cli-dev-prepare

    echo ^> Startup docker container instance
    docker rm -f %PROJECT_NAME%-dotnet-server
    docker run -ti -d ^
        -v %cd%\app\:/repo^
        -v %cd%\cache\published:/repo/published^
        -v %cd%\cache\api-doc:/repo/api-doc^
        --name %PROJECT_NAME%-dotnet-server^
        dotnet.webapi.sdk:%PROJECT_NAME%

    @rem Execute command
    echo ^> Generate .NET Core project api-doc
    docker exec -ti %PROJECT_NAME%-dotnet-server bash -c "swagger tofile --output ./api-doc/swagger.json ./published/WebService.dll v1"

    @rem close server
    docker rm -f %PROJECT_NAME%-dotnet-server
    goto end
)

:cli-swagger-args (
    goto end
)

:cli-swagger-help (
    echo Generate project api-doc with Swagger and OpenAPI format.
    echo.
    echo Options:
    echo.
    goto end
)

:: ------------------- Command "run" mathod -------------------

:cli-run (
    echo ^> Startup docker container instance
    echo ^> Port map : 5000:80, 5001:443
    docker run --rm -ti ^
        -v %cd%\cache\published:/repo^
        -p 5000:80^
        -p 5001:443^
        --name %PROJECT_NAME%-dotnet-server^
        mcr.microsoft.com/dotnet/aspnet:5.0^
        bash -l -c "cd /repo && dotnet WebService.dll"

    goto end
)

:cli-run-args (
    goto end
)

:cli-run-help (
    echo Startup runtime container with publish assembly file.
    echo.
    echo Options:
    echo.
    goto end
)

:: ------------------- Command "package" mathod -------------------

:cli-package (
    echo ^> Initial cache
    IF NOT EXIST cache\package (
        mkdir cache\package
    )

    echo ^> Copy Dockerfile to cache
    copy %cd%\docker\dotnet-runtime\Dockerfile %cd%\cache\

    echo ^> Package docker image
    docker build --rm^
        -t dotnet.webapi.runtime:publish^
        ./cache
    docker save ^
        --output %cd%\cache\package\dotnet.webapi.runtime.tar^
        dotnet.webapi.runtime:publish

    IF defined PACKAGE_RUN (
        echo ^> Package run at background
        echo ^> Port map : 5000:80, 5001:443
        docker rm -f %PROJECT_NAME%-package-test-run
        docker run -ti -d ^
            -p 5000:80^
            -p 5001:443^
            --name %PROJECT_NAME%-package-test-run^
            dotnet.webapi.runtime:publish
    )

    goto end
)

:cli-package-args (
    for %%p in (%*) do (
        if "%%p"=="--run" (
            set PACKAGE_RUN=1
        )
    )
    goto end
)

:cli-package-help (
    echo Package published file in docker image.
    echo.
    echo Options:
    echo      --run            Package and run image at background.
    echo.
    goto end
)

:: ------------------- Command "db" mathod -------------------

:cli-db-docker-prepare (
    @rem Create .env for docker-compose
    echo Current Environment %PROJECT_ENV%
    echo TAG=%PROJECT_NAME% > .env
    echo ROOT_DIR=%cd% >> .env

    echo ^> Initial cache
    IF NOT EXIST cache\db (
        mkdir cache\db
    )

    goto end
)

:cli-db (
    IF defined DB_DOWN (
        echo ^> Close MySQL container instance
        docker-compose -f .\docker\mysql\docker-compose.yml down
    ) else (
        echo ^> Build Docker images
        docker build --rm^
            -t mysql:%PROJECT_NAME%^
            .\docker\mysql
        call :cli-db-docker-prepare

        echo ^> Startup MySQL container instance
        docker-compose -f .\docker\mysql\docker-compose.yml up -d

        echo ^> Migration database with dbmate
        docker exec -ti mysql_%PROJECT_NAME% bash -l -c "cd /repo && source integrate.sh && cd / && dbmate up"
    )

    goto end
)

:cli-db-args (
    for %%p in (%*) do (
        if "%%p"=="--down" ( set DB_DOWN=1 )
    )
    goto end
)

:cli-db-help (
    echo Start service with docker compose.
    echo.
    echo Options:
    echo      --down           Close service.
    echo.
    goto end
)

:: ------------------- Command "ef" mathod -------------------

:cli-ef (

    echo ^> Startup docker container instance
    docker rm -f %PROJECT_NAME%-dotnet-server
    docker run -ti -d ^
        -v %cd%\app\WebService.Entities\:/repo^
        --network mysql_dotnet_webapi_network^
        --name %PROJECT_NAME%-dotnet-server^
        dotnet.webapi.sdk:%PROJECT_NAME%

    @rem Execute command
    echo ^> Generate entities object with dotnet-ef tool
    docker exec -ti %PROJECT_NAME%-dotnet-server bash -c "source gen-entities.sh"

    @rem close server
    docker rm -f %PROJECT_NAME%-dotnet-server
    goto end
)

:cli-ef-args (
    for %%p in (%*) do (
        if "%%p"=="--down" ( set DB_DOWN=1 )
    )
    goto end
)

:cli-ef-help (
    echo Generate ORM entities object with .NET entities framework.
    echo.
    echo Options:
    echo.
    goto end
)

:: ------------------- End method-------------------

:end (
    endlocal
)
