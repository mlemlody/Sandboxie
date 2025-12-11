@echo off
setlocal

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "TARGET_DIR=C:\Program Files\Sandboxie"

echo Installing Sandboxie-Plus to %TARGET_DIR%...

if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
)

echo Copying files...
if exist "SandMan.exe" (
    copy /Y "SandMan.exe" "%TARGET_DIR%\"
    copy /Y "SbieCtrl.exe" "%TARGET_DIR%\"
    copy /Y "Start.exe" "%TARGET_DIR%\"
    copy /Y "SbieDrv.sys" "%TARGET_DIR%\"
    copy /Y "SbieSvc.exe" "%TARGET_DIR%\"
    copy /Y "SbieMsg.dll" "%TARGET_DIR%\"
    copy /Y "KmdUtil.exe" "%TARGET_DIR%\"
    if exist "Sandboxie.ini" copy /Y "Sandboxie.ini" "%TARGET_DIR%\"
) else (
    echo SandMan.exe not found in current directory.
    echo Please run this script from the folder containing the built binaries.
    pause
    exit /b 1
)

echo Installing Driver and Service...
cd /d "%TARGET_DIR%"

if exist "KmdUtil.exe" (
    KmdUtil.exe install SbieDrv "SbieDrv.sys" type=kernel start=demand msgfile="SbieMsg.dll" altitude=86900
    KmdUtil.exe install SbieSvc "SbieSvc.exe" type=own start=auto msgfile="SbieMsg.dll" display="Sandboxie Service" group=UIGroup
    
    echo Starting Service...
    KmdUtil.exe start SbieSvc
) else (
    echo KmdUtil.exe not found in target directory. Cannot install driver.
    pause
    exit /b 1
)

echo Installation Complete.
pause
