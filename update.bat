@echo off

REM Backup files before Deleting
IF EXIST "installmods.cmd" (
    copy "installmods.cmd" "installmods.cmd.bak"
)
cls
echo.Updating. Please wait while the new file is downloaded.
powershell -c "$data = curl https://api.github.com/repos/mon5termatt/bg3-mods/git/refs/tag -UseBasicParsing | ConvertFrom-Json; $data[-1].ref -replace 'refs/tags/', '' | Out-File -Encoding 'UTF8' -FilePath './ver.ini'"
set /p ver= < ver.ini
set ver=%ver:~-6%
del ver.ini /Q
echo.Version %ver% found
curl https://github.com/mon5termatt/bg3-mods/releases/download/%ver%/installmods.cmd -o installmods.cmd -q -L
REM Check if the download was successful
IF NOT EXIST "installmods.cmd" (
    echo ERROR: Failed to download the new file.
    REM Restore the backup if it exists
    IF EXIST "installmods.cmd.bak" (
        copy "installmods.cmd.bak" "installmods.cmd"
    )
    pause
    exit /b 1
)

cls
start cmd /k installmods.cmd
del %0 && exit
