@echo off
setlocal
cd /d "%~dp0"

where py >nul 2>nul
if %errorlevel%==0 (
    py -3 OutlastHeadBobPatcher.py
    goto :end
)

where python >nul 2>nul
if %errorlevel%==0 (
    python OutlastHeadBobPatcher.py
    goto :end
)

echo Python 3 nao foi encontrado.
echo Instale em https://www.python.org/downloads/ e marque "Add Python to PATH".
pause

:end
endlocal
