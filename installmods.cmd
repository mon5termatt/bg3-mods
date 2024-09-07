@echo off
setlocal enabledelayedexpansion
mode con:cols=100 lines=40 

@REM these change whenever the game or script updates
@REM THIS IS THE GITHUB RELEASE
set localver=0007

@REM VERSION WE WANT
set gamever=4.1.1.5022896

@REM PATCHES
set p7=4.1.1.5849914
set p6=4.1.1.5022896

@REM in case anything changes leave this as a variable.
set "targetFolder=SteamLibrary\steamapps\common\Baldurs Gate 3"
set "GOGFolder=GOG GAMES\Baldurs Gate 3"

@REM this is not used yet
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
if "%localver%" LSS "%remver%" (
echo.[93mA new version of the program has been released. The program will now restart[0m
timeout 2 >nul
curl "https://raw.githubusercontent.com/mon5termatt/bg3-mods/main/update.bat" -o ./update.bat -s -L
start cmd /k update.bat
exit
)
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



:startup
@REM find the f**king game
@REM if it didnt find it last launch, just go to manual
if exist "%temp%/bg3mi.tmp" (
del "%temp%\bg3mi.tmp"
goto manual)


@REM for the normies that dont have multiple drives
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

@REM check all other drives in the normal folder steam makes for you.
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
@REM you are a f**king tech guy, you didnt just hit install in a normal place steam prompts you for.
if not defined gamepath (
    echo Game directory not found automatically.
    echo Please enter your Game Directory: (e.g., E:\SteamLibrary\steamapps\common\Baldurs Gate 3)
    echo to rerun game path detection just hit enter.
	set /P gamepath=PATH: || goto :startup
)

:end_loop 
@REM get to the f**king game directory, no matter what.
cd /D %gamepath%


if exist ".\bin\bg3.exe" (
powershell "(Get-Item -path .\bin\bg3.exe).VersionInfo.ProductVersion">tmp
set /p bg3cur1=<tmp
) else (
set /a bg3cur1=0
set error1=true
)
if exist ".\bin\bg3_dx11.exe" (
powershell "(Get-Item -path .\bin\bg3_dx11.exe).VersionInfo.ProductVersion">tmp
set /p bg3cur2=<tmp
) else (
set /a bg3cur2=0
set error2=true)

@REM This is looking for "backups" With patch 7 this isnt needed anymore due to a different mod which no longer requires patching the EXE's

@REM ONLY RUN FOR PATCH 6
if %bg3cur1% EQU %p6% (

if exist ".\bin\bg3.exe.backup" (
powershell "(Get-Item -path .\bin\bg3.exe.backup).VersionInfo.ProductVersion">tmp 
set /p bg3bak1=<tmp 
) else (set /a bg3bak1=0)
if exist ".\bin\bg3_dx11.exe.backup" (
powershell "(Get-Item -path .\bin\bg3_dx11.exe.backup).VersionInfo.ProductVersion">tmp
set /p bg3bak2=<tmp
) else (set /a bg3bak2=0)

)

if "%error1%" EQU "true" (
echo.[41mCould not find BG3 EXE, this is crucial for running the game.[0m
echo.
)
if "%error2%" EQU "true" (
echo.[41mCould not find BG3 DX11 EXE, this is crucial for running the game.[0m
echo.
)

echo.
@REM ONLY RUN FOR PATCH 6
if %bg3cur1% EQU %p6% (
echo.[94mBackup versions  = %bg3bak1% - %bg3bak2%[0m
)
echo.[94mCurrent versions = %bg3cur1% - %bg3cur2% [0m 
@REM if %bg3cur1% EQU %p7% (echo.Patch 7)
@REM if %bg3cur1% EQU %p6% (echo.Patch 6)

echo.

if %bg3cur1% NEQ %bg3bak1% (set mismatch=true)


@REM CHECK FOR PATCH 7
echo.
if %bg3cur1% EQU %p7% (
echo.[31mTHIS SCRIPT IS NOT COMPATABLE WITH PATCH 7 YET.
echo.NOW LAUNCHING INSTRUCTIONS ON HOW TO DOWNGRADE.
explorer "https://www.dexerto.com/baldurs-gate/larian-lets-you-stay-on-baldurs-gate-3-patch-6-to-avoid-breaking-mods-2890361/"
echo. hit any key to remove the mods for patch 7.
pause >nul
echo.[0m
goto remove)

if %bg3cur1% EQU %p6% (
echo.[92mCONGRATS, YOU ARE ON PATCH 6. YOU CAN USE THIS SCRIPT![0m
timeout 2 >nul)




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


move ".\appdata\Show Approval Ratings - English.pak" "%localappdata%\Larian Studios\Baldur's Gate 3\Mods"
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










@REM REMOVAL

:remove
echo Removing Mods - %gamepath%\Data\Mods\*
::\Data\Mods\GustavDev
del /Q /S %gamepath%\Data\Mods\GustavDev\meta.lsx
del /Q "%localappdata%\Larian Studios\Baldur's Gate 3\Mods\*"
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
echo.Backups not found, Not restoring
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



@REM PRETTY GRAPHICS :)
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
