@echo off
setlocal enabledelayedexpansion
set localver=03.12.24
echo.Checking for Script updates
:curver
mode con:cols=64 lines=18
cls
powershell -c "$data = curl https://api.github.com/repos/mon5termatt/bg3-mods/git/refs/tag -UseBasicParsing | ConvertFrom-Json; $data[-1].ref -replace 'refs/tags/', '' | Out-File -Encoding 'UTF8' -FilePath './curver.ini'"
set /p remver= < curver.ini
set remver=%remver:~-8%
del curver.ini /Q
if "%localver%" GEQ "%remver%" (goto startup)

:updateprogram
cls
echo.A new version of the program has been released. The program will now restart.
curl "https://raw.githubusercontent.com/mon5termatt/bg3-mods/main/update.bat" -o ./update.bat -s -L
start cmd /k update.bat
exit


:startup
echo.GOG Installs are untested. 
echo.While it does have support for it, I dont own the game on GOG 
::GOG   Library: C:\GOG GAMES\Baldurs Gate 3
::Steam Library: C:\Program Files (x86)\Steam\steamapps\common
::Steam Library: C:\Program Files\Steam\steamapps\common
set "targetFolder=SteamLibrary\steamapps\common\Baldurs Gate 3"
set "GOGFolder=GOG GAMES\Baldurs Gate 3"


if exist "%programfiles(x86)%\Steam\steamapps\common\Baldurs Gate 3\" (
	echo.Found at "%programfiles(x86)%\Steam\steamapps\common\Baldurs Gate 3"
	set "gamepath=C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3"
	goto :end_loop
)
if exist "%programfiles%\Steam\steamapps\common\Baldurs Gate 3\" (
	echo.Found at "%programfiles%\Steam\steamapps\common\Baldurs Gate 3"
	set "gamepath=C:\Program Files\Steam\steamapps\common\Baldurs Gate 3"
	goto :end_loop
)
for %%I in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "drive=%%I:"
    if exist "!drive!\%targetFolder%\" (
        echo Found at !drive!\%targetFolder%
        set "gamepath=!drive!\%targetFolder%"
        goto :end_loop
    )
)

:gog
for %%I in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "drive=%%I:"
    if exist "!drive!\%GOGFolder%\" (
        echo Found at !drive!\%GOGFolder%
        set "gamepath=!drive!\%GOGFolder%"
        goto :end_loop
    )
)


:manual
if not defined gamepath (
    echo Game directory not found automatically.
    echo Please enter your Game Directory: (e.g., E:\SteamLibrary\steamapps\common\Baldurs Gate 3)
    set /P gamepath=PATH: || goto :manual
)

:end_loop 
cd /D %gamepath%

if "%1" == "1" (goto install)
if "%1" == "2" (goto update)
if "%1" == "3" (goto remove)

:menu
ECHO.    [1] [92mINSTALL[37m
Echo.    [2] REINSTALL/UPDATE
Echo.    [3] UNINSTALL
Set /P _num="    choose dammit:"
If /i "%_num%"=="1" goto:install
If /i "%_num%"=="2" goto:update
If /i "%_num%"=="3" goto:remove
goto menu

:UPDATE
set update=true
goto remove

:install
echo Downloading Patch Files.
curl -# https://cloud.mon5termatt.com/index.php/s/AjYdWRzMcrCR4ob/download/files.zip -o files.zip
powershell -command "Expand-Archive -Force '%gamepath%\files.zip' '%gamepath%'"
del files.zip


move "%gamepath%\appdata\ShowApprovalRatings - English.pak" "%localappdata%\Larian Studios\Baldur's Gate 3\Mods"
move "%gamepath%\appdata\NoRomanceLimit.pak" "%localappdata%\Larian Studios\Baldur's Gate 3\Mods"
move "%gamepath%\appdata\modsettings.lsx" "%localappdata%\Larian Studios\Baldur's Gate 3\PlayerProfiles\Public"


:MPPREP

Set "GetFileName=%gamepath%\bin\bg3.exe"
if exist "%GetFileName%.backup" (goto askbackup) else (goto MPPATCH)

:askbackup
echo.It looks like a backup already exists.
echo.Would you like to skip the patch?
echo.    [1] YES
Echo.    [2] NO
Set /P _num="1/2:"
If /i "%_num%"=="1" goto:exit
If /i "%_num%"=="2" goto:mppatch
:MPPATCH
Set "GetFileName=%gamepath%\bin\bg3.exe"
Set "GetPatcherPath=%gamepath%\PatchFiles"

if exist "%GetFileName%.backup" goto askbackup
echo Backing up %gamepath%\bin\bg3.exe
copy /y "%GetFileName%" "%GetFileName%.backup"
echo Patching %gamepath%\bin\bg3.exe
if exist "%GetFileName%.backup" "%GetPatcherPath%\XVI32.exe" "%GetFileName%" /S="%GetPatcherPath%\PartyLimitBegonePatch.xsc"
echo Patched %gamepath%\bin\bg3.exe
echo.
Set "GetFileName=%gamepath%\bin\bg3_dx11.exe"
Set "GetPatcherPath=%gamepath%\PatchFiles"
echo Backing up %gamepath%\bin\bg3_dx11.exe
copy /y "%GetFileName%" "%GetFileName%.backup"
echo Patching %gamepath%\bin\bg3_dx11.exe
if exist "%GetFileName%.backup" "%GetPatcherPath%\XVI32.exe" "%GetFileName%" /S="%GetPatcherPath%\PartyLimitBegonePatch.xsc"
echo Patched %gamepath%\bin\bg3_dx11.exe
goto exit



:remove
echo.
echo Removing - Party Limit Begone
rmdir /Q /S .\Data\Mods
mkdir .\Data\Mods
echo.
echo Removing - Show Approval Ratings \ Limits
del /Q "%localappdata%\Larian Studios\Baldur's Gate 3\Mods\ShowApprovalRatings - English.pak"
del /Q "%localappdata%\Larian Studios\Baldur's Gate 3\Mods\NoRomanceLimit.pak"
del /Q "%localappdata%\Larian Studios\Baldur's Gate 3\PlayerProfiles\Public\modsettings.lsx"
echo.
echo Restoring Original EXE's, IF THIS FAILS VERIFY YOUR GAME FILES.
if exist ".\bin\bg3.exe.backup" (
del /Q .\bin\bg3.exe
move /y .\bin\bg3.exe.backup .\bin\bg3.exe
) else (echo.Backup not found, Not restoring)
if exist ".\bin\bg3_dx11.exe.backup" (
del /Q .\bin\bg3_dx11.exe
move /y .\bin\bg3_dx11.exe.backup .\bin\bg3_dx11.exe
) else (
::echo..\bin\bg3_dx11.exe.backup
echo.Backup not found, Not restoring)
echo.
echo Removing - Script Extender.
del /Q .\bin\DWrite.dll
del /Q .\bin\ScriptExtenderSettings.json
echo.

echo Mods and Patch Removed

if "%update%" == "true" (goto install) else (goto exit)

:exit
echo.Press any key to exit.
pause>nul
exit /b





