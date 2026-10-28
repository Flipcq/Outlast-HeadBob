@echo off
setlocal
cd /d "%~dp0"

echo Este script gera OutlastHeadBobPatcher.exe com PyInstaller.
echo O decompress.exe continua sendo necessario ao lado do .exe.
pause

py -3 -m pip install --upgrade pyinstaller
if errorlevel 1 goto :error

py -3 -m PyInstaller --noconfirm --onefile --windowed ^
    --name "OutlastHeadBobPatcher" ^
    OutlastHeadBobPatcher.py
if errorlevel 1 goto :error

echo.
echo Pronto: dist\OutlastHeadBobPatcher.exe
echo Copie o .exe e o decompress.exe para a CookedPCConsole.
pause
goto :end

:error
echo Falha ao gerar o executavel.
pause

:end
endlocal
