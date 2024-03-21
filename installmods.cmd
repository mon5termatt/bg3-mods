@echo off
setlocal enabledelayedexpansion
mode con:cols=100 lines=22
set localver=0002
::built for game version
set gamever=4.1.1.4905117
set "targetFolder=SteamLibrary\steamapps\common\Baldurs Gate 3"
set "GOGFolder=GOG GAMES\Baldurs Gate 3"


:checkupdate
echo.Checking for Script updates.
echo.
powershell -c "$data = curl https://api.github.com/repos/mon5termatt/bg3-mods/git/refs/tag -UseBasicParsing | ConvertFrom-Json; $data[-1].ref -replace 'refs/tags/', '' | Out-File -Encoding 'UTF8' -FilePath './curver.ini'"
set /p remver= < curver.ini
set remver=%remver:~-4%
del curver.ini /Q
cls
if "%localver%" EQU "%remver%" (
echo.[42mScript is up to date[0m
echo.
goto startup
)
if "%localver%" GEQ "%remver%" (
echo.[43mScript is running a version newer then on the github[0m
echo.
timeout 3 > nul
goto startup
)


:updateprogram
echo.A new version of the program has been released. The program will now restart.
curl "https://raw.githubusercontent.com/mon5termatt/bg3-mods/main/update.bat" -o ./update.bat -s -L
start cmd /k update.bat
exit


:startup
if exist "%programfiles(x86)%\Steam\steamapps\common\Baldurs Gate 3\" (
	echo.[42mFound at "%programfiles(x86)%\Steam\steamapps\common\Baldurs Gate 3[0m"
	set "gamepath=C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3"
	goto :end_loop
)
if exist "%programfiles%\Steam\steamapps\common\Baldurs Gate 3\" (
	echo.[42mFound at "%programfiles%\Steam\steamapps\common\Baldurs Gate 3[0m"
	set "gamepath=C:\Program Files\Steam\steamapps\common\Baldurs Gate 3"
	goto :end_loop
)
for %%I in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "drive=%%I:"
    if exist "!drive!\%targetFolder%\" (
        echo [42mFound at !drive!\%targetFolder%[0m
        set "gamepath=!drive!\%targetFolder%"
        goto :end_loop
    )
)

:gog
for %%I in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "drive=%%I:"
    if exist "!drive!\%GOGFolder%\" (
        echo [42mFound at !drive!\%GOGFolder%[0m
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

:checkbackups

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
echo.[44mBackup versions  = %bg3bak1% - %bg3bak2%[0m
echo.[44mCurrent versions = %bg3cur1% - %bg3cur2%[0m
echo.
if %bg3cur1% NEQ %bg3bak1% (
set mismatch=true
echo.[41mBackup versions mismatch. was there a recent update?[0m
) else (
set mismatch=false
echo.[42mBackup versions match.[0m
)
if %bg3cur1% NEQ %gamever% (
echo.[41mThis script was built for game version[44m %gamever%[41m
echo.Your current game version is not compatable with this build.
echo.Please confirm that you have updated via Steam/GOG
echo.if this persists you may need to verify your game files.[0m
)


::pass in a variable from the console to automatically select 
if "%1" == "1" (goto install)
if "%1" == "2" (goto update)
if "%1" == "3" (goto remove)


:menu
echo.[?25l

echo.
ECHO.    [1] [92mINSTALL[37m
Echo.    [2] REINSTALL/UPDATE
Echo.    [3] UNINSTALL
Set /P _num="    choose dammit:"
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


move "%gamepath%\appdata\ShowApprovalRatings - English.pak" "%localappdata%\Larian Studios\Baldur's Gate 3\Mods"
move "%gamepath%\appdata\NoRomanceLimit.pak" "%localappdata%\Larian Studios\Baldur's Gate 3\Mods"
move "%gamepath%\appdata\modsettings.lsx" "%localappdata%\Larian Studios\Baldur's Gate 3\PlayerProfiles\Public"


:MPPREP

if exist ".\bin\bg3.exe.backup" (
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
echo.Press any key to exit.
pause>nul
exit
