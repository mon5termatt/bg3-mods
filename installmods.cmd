@echo off
setlocal enabledelayedexpansion
mode con:cols=100 lines=40 

::these change whenever the game or script updates
set localver=0004
::built for game version
set gamever=4.1.1.5009956

::in case anything changes leave this as a variable.
set "targetFolder=SteamLibrary\steamapps\common\Baldurs Gate 3"
set "GOGFolder=GOG GAMES\Baldurs Gate 3"

::this is not used yet
if "%1" == "s" (set silent=true)


:checkupdate
echo.Checking for Script updates.
echo.
powershell -c "$data = curl https://api.github.com/repos/mon5termatt/bg3-mods/git/refs/tag -UseBasicParsing | ConvertFrom-Json; $data[-1].ref -replace 'refs/tags/', '' | Out-File -Encoding 'UTF8' -FilePath './curver.ini'"
set /p remver= < curver.ini
set remver=%remver:~-4%
del curver.ini /Q
cls
call :logo
if "%localver%" EQU "%remver%" (
echo.[92mScript is up to date[0m
echo.
goto startup
)
if "%localver%" GEQ "%remver%" (
echo.[93mScript is running a version newer then on the github[0m
echo.
goto startup
)


:updateprogram
echo.A new version of the program has been released. The program will now restart.
curl "https://raw.githubusercontent.com/mon5termatt/bg3-mods/main/update.bat" -o ./update.bat -s -L
start cmd /k update.bat
exit


:startup
::find the f**king game

::if it didnt find it last launch, just go to manual
if exist "%temp%/bg3mi.tmp" (
del "%temp%\bg3mi.tmp"
goto manual)


::for the normies that dont have multiple drives
if exist "%programfiles(x86)%\Steam\steamapps\common\Baldurs Gate 3\" (
	echo.[92mFound at "%programfiles(x86)%\Steam\steamapps\common\Baldurs Gate 3"[0m
	set "gamepath=C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3"
	goto :end_loop
)
if exist "%programfiles%\Steam\steamapps\common\Baldurs Gate 3\" (
	echo.[92mFound at "%programfiles%\Steam\steamapps\common\Baldurs Gate 3"[0m
	set "gamepath=C:\Program Files\Steam\steamapps\common\Baldurs Gate 3"
	goto :end_loop
)

::check all other drives in the normal folder steam makes for you.
for %%I in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "drive=%%I:"
    if exist "!drive!\%targetFolder%\" (
        echo [92mFound at !drive!\%targetFolder%[0m
        set "gamepath=!drive!\%targetFolder%"
        goto :end_loop
    )
)

:gog
for %%I in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "drive=%%I:"
    if exist "!drive!\%GOGFolder%\" (
        echo [92mFound at !drive!\%GOGFolder%[0m
        set "gamepath=!drive!\%GOGFolder%"
        goto :end_loop
    )
)


:manual
::you are a f**king tech guy, you didnt just hit install in a normal place steam prompts you for.
if not defined gamepath (
    echo Game directory not found automatically.
    echo Please enter your Game Directory: (e.g., E:\SteamLibrary\steamapps\common\Baldurs Gate 3)
    set /P gamepath=PATH: || goto :manual
)

:end_loop 
::get to the f**king game directory, no matter what.
cd /D %gamepath%

:checkbackups


::THIS CODE IS F**KING BROKEN

::if this doesnt exist it means either the game is corrupt of it didnt find the right path
::if not exist "%gamepath%\bin\bg3.exe" (

::echo.Could not find the game files. Please make sure it detected the right folder.
::echo.EXITING THE SCRIPT. FIX YOUR DRIVE. (make sure that the folder it detected above is right)
::echo.If it found the wrong folder it means that you may have an old install there.
::echo.verify you only have the game installed in ONE location.
::echo.
::echo.Relaunch the script and it will ask for the proper location
::echo.>%temp%/bg3mi.tmp

::write a file to let the script know that it couldnt find the proper install
::on relaunch it will check for the file and just ask for the proper install location

)

if exist ".\bin\bg3.exe" (
powershell "(Get-Item -path .\bin\bg3.exe).VersionInfo.ProductVersion">tmp
set /p bg3cur1=<tmp
)
if exist ".\bin\bg3_dx11.exe" (
powershell "(Get-Item -path .\bin\bg3_dx11.exe).VersionInfo.ProductVersion">tmp
set /p bg3cur2=<tmp
)
if exist ".\bin\bg3.exe.backup" (
powershell "(Get-Item -path .\bin\bg3.exe.backup).VersionInfo.ProductVersion">tmp 
set /p bg3bak1=<tmp 
) else (set /a bg3bak1=0)
if exist ".\bin\bg3_dx11.exe.backup" (
powershell "(Get-Item -path .\bin\bg3_dx11.exe.backup).VersionInfo.ProductVersion">tmp
set /p bg3bak2=<tmp
) else (set /a bg3bak2=0)
echo.
echo.[94mBackup versions  = %bg3bak1% - %bg3bak2%[0m
echo.[94mCurrent versions = %bg3cur1% - %bg3cur2%[0m
echo.

if %bg3cur1% NEQ %gamever% (
echo.[41mThis script was built for game version[94m %gamever%[41m
echo.Your current game version is not compatable with this build.
echo.Please confirm that you have updated via Steam/GOG
echo.if this persists you may need to verify your game files.[0m
)
if %bg3cur1% EQU %bg3bak1% (
set mismatch=false
echo.[92mBackup versions match.[0m
) else (
if exist ".\bin\bg3.exe.backup" (
echo.[41mBackup versions mismatch. was there a recent update?
echo.Plase run the install again using the update option.[0m
) else (
echo.[41mBackups Not found!
echo.This could be because you dont have this modlist installed.[0m
))
if %bg3cur1% NEQ %bg3bak1% (
set mismatch=true)


::pass in a variable from the console to automatically select 
if "%1" == "1" (goto install)
if "%1" == "2" (goto update)
if "%1" == "3" (goto remove)


:menu
echo.[?25l
ECHO.1 - INSTALL
Echo.2 - REINSTALL/UPDATE
Echo.3 - UNINSTALL
echo.
Set /P _num="Select 1-3:"
If /i "%_num%"=="1" goto:install
If /i "%_num%"=="2" goto:update
If /i "%_num%"=="3" goto:remove

cls
goto menu

:UPDATE
set update=true
goto remove

:install
echo Downloading Patch Files.
curl -# https://raw.githubusercontent.com/mon5termatt/bg3-mods/main/files.zip -o files.zip
powershell -command "Expand-Archive -Force '%gamepath%\files.zip' '%gamepath%'"
del files.zip


move ".\appdata\ShowApprovalRatings - English.pak" "%localappdata%\Larian Studios\Baldur's Gate 3\Mods"
move ".\appdata\NoRomanceLimit.pak" "%localappdata%\Larian Studios\Baldur's Gate 3\Mods"
move ".\appdata\modsettings.lsx" "%localappdata%\Larian Studios\Baldur's Gate 3\PlayerProfiles\Public"


:MPPREP

if exist "%gamepath%\bin\bg3.exe.backup" (
if %mismatch% EQU true (goto mppatch)
if %mismatch% EQU false (goto skip)
) else (goto mppatch)

:MPPATCH
Set "GetFileName=%gamepath%\bin\bg3.exe"
Set "GetPatcherPath=%gamepath%\PatchFiles"
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

:skip
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

if %bg3cur1% EQU %bg3bak1% (
goto opt2
) else (
echo.Version mismatch...
echo.this could be because of a recent update.
)
if exist ".\bin\bg3.exe.backup" (
echo.backups do however exist.
goto opt1
) else (
goto opt3)







:: option 1 - just remove files
:: this is for when the versions DO NOT match
:opt1
del /Q .\bin\bg3.exe.backup
del /Q .\bin\bg3_dx11.exe.backup
goto remscriptextender

:: option 2 - remove patched files and restore backups
:: this is for when the files match versions
:opt2
del /Q .\bin\bg3.exe
move /y .\bin\bg3.exe.backup .\bin\bg3.exe
del /Q .\bin\bg3_dx11.exe
move /y .\bin\bg3_dx11.exe.backup .\bin\bg3_dx11.exe
goto remscriptextender

:: option 3 - dont do shit
:: this is for when the backups dont exist
:opt3
echo.Backup not found, Not restoring
echo.
goto remscriptextender













:remscriptextender
echo Removing - Script Extender.
del /Q .\bin\DWrite.dll
del /Q .\bin\ScriptExtenderSettings.json
echo.

echo Mods and Patch Removed

if "%update%" == "true" (
cls
goto install
) else (
goto exit)

:exit

echo.[92m       __               
echo.  ____/ /___  ____  ___ 
echo. / __  / __ \/ __ \/ _ \
echo./ /_/ / /_/ / / / /  __/
echo.\__,_/\____/_/ /_/\___/ [0m
pause
exit /b




:logo
echo.[1m
echo.[92m    ____  ___________   [33m __  ___          __ [35m  ____           __        ____         
echo.[92m   / __ )/ ____/__  /  [33m /  \/  /___  ____/ /[35m  /  _/___  _____/ /_____ _/ / /__  _____
echo.[92m  / __  / / __  /_ \  [33m / /\_/ / __ \/ __  /[35m   / // __ \/ ___/ __/ __ `/ / / _ \/ ___/
echo.[92m / /_/ / /_/ /___/ / [33m / /  / / /_/ / /_/ /[35m  _/ // / / (__  ) /_/ /_/ / / /  __/ /    
echo.[92m/_____/\____//____/ [33m /_/  /_/\____/\__,_/[35m  /___/_/ /_/____/\__/\__,_/_/_/\___/_/     [0m
echo.[1m
echo.[36m    __          [31m   ______                        ________                            __  __ 
echo.[36m   / /_  __  __[31m   / ____ \____ ___  ____  ____  / ____/ /____  _________ ___  ____ _/ /_/ /_
echo.[36m  / __ \/ / / /[31m  / / __ `/ __ `__ \/ __ \/ __ \/___ \/ __/ _ \/ ___/ __ `__ \/ __ `/ __/ __/
echo.[36m / /_/ / /_/ /[31m  / / /_/ / / / / / / /_/ / / / /___/ / /_/  __/ /  / / / / / / /_/ / /_/ /_  
echo.[36m/_.___/\__, / [31m  \ \__,_/_/ /_/ /_/\____/_/ /_/_____/\__/\___/_/  /_/ /_/ /_/\__,_/\__/\__/  
echo.[36m      /____/  [31m   \____/                                                                     [0m
echo.
exit /b