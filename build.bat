@echo off
cls

set "DCC32=dcc32.exe"
set "PROJECT_FILE=gbdpi.dpr"
set "OUTPUT_EXE=gbdpi.exe"

if not exist "%PROJECT_FILE%" (
    echo.
    echo ??  Project not found: %PROJECT_FILE%
    echo.
    pause
    exit /b
)

"%DCC32%" %PROJECT_FILE% -U"\" -E%OUTPUT_EXE% -NSWinapi -O -J -Q -U -V -VN -VE -NX

if exist "StripReloc.exe" (
    echo.
    echo ??  Delete relocatrion table stripReloc...
    echo.
    StripReloc.exe "%OUTPUT_EXE%"
    echo    Success.
)