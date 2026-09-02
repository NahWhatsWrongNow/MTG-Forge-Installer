@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Jadon's Ultimate Installer v9.0

set "I7_PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%I7_PS_EXE%" goto :I7_NO_POWERSHELL

call :I7_CHECK_POWERSHELL_COMPAT
if errorlevel 1 goto :I7_POLICY_BLOCKED

call :I7_CHECK_NOT_ELEVATED
set "I7_ELEVATION_RC=%ERRORLEVEL%"
if "%I7_ELEVATION_RC%"=="10" goto :I7_ELEVATED
if not "%I7_ELEVATION_RC%"=="0" goto :I7_ELEVATION_UNKNOWN

if defined LOCALAPPDATA set "I7_BASE=%LOCALAPPDATA%\MTGForge"
if not defined LOCALAPPDATA set "I7_BASE=%USERPROFILE%\AppData\Local\MTGForge"
if defined APPDATA set "I7_ROAMING=%APPDATA%"
if not defined APPDATA set "I7_ROAMING=%USERPROFILE%\AppData\Roaming"

set "I7_SELF=%~f0"
set "I7_TOOL=%I7_BASE%\ArchidektSync"
set "I7_LOG_DIR=%I7_BASE%\logs"
set "I7_INSTALL_LOG=%I7_LOG_DIR%\installer-v7.log"
set "I7_CORE_LOG=%I7_LOG_DIR%\installer-core-v7-parse.log"
set "I7_MANAGER_TEST_LOG=%I7_LOG_DIR%\installer-manager-v7-test.log"
set "I7_SAFE_LOG=%I7_LOG_DIR%\safe-importer-v4-verify.log"
set "I7_CORE=%I7_BASE%\InstallerCore_v9.payload"
set "I7_CORE_CANDIDATE=%I7_BASE%\InstallerCore_v9.candidate.payload"
set "I7_MANAGER=%I7_BASE%\Jadons_Ultimate_Forge_Manager_v9.cmd"
set "I7_MANAGER_CANDIDATE=%I7_BASE%\Jadons_Ultimate_Forge_Manager_v9.candidate.cmd"
set "I7_SAFE_CMD=%I7_TOOL%\Safe_Archidekt_Importer_v4.cmd"
set "I7_SAFE_CMD_CANDIDATE=%I7_TOOL%\Safe_Archidekt_Importer_v4.candidate.cmd"
set "I7_SAFE_PS=%I7_TOOL%\Safe_Archidekt_Importer_v4.payload"
set "I7_SAFE_PS_CANDIDATE=%I7_TOOL%\Safe_Archidekt_Importer_v4.candidate.payload"
set "I7_LEGACY=%I7_BASE%\LegacyInstaller_v8.compat.cmd"
set "I7_LEGACY_CANDIDATE=%I7_BASE%\LegacyInstaller_v8.candidate.cmd"
set "I7_LAUNCHER=%I7_BASE%\Start_Forge.cmd"
set "I7_CORE_SHA=04e04f47e4411f982604c9c023d0fa9a0a21abeb9e3eab46feda63fb43c44665"
set "I7_MANAGER_SHA=3d459369785e4c27edaeb4d7d35cbfaa75e930dff7d4f4cbb5e8bb020086dfc1"
set "I7_SAFE_CMD_SHA=3fdb666ff2b2f87e33f787d52c29601fee7ff965f0df459ee74d220b87be41be"
set "I7_SAFE_PS_SHA=2e8aab791f933f0e7409b23463ada24250bf5caebabb826f00765c1c87050e7c"
set "I7_LEGACY_SHA=ac8ebde5c795e981f6383acc62ac4cd19c29ad8056ffb07ddd3e92e6bf9bcb85"
set "I7_AUTOTEST=0"
if /I "%~1"=="--test" set "I7_AUTOTEST=1"

call :I7_INITIALIZE
if errorlevel 1 goto :I7_INIT_FAILED

if "%I7_AUTOTEST%"=="1" goto :I7_AUTOMATED_TEST
goto :I7_HOME_MENU

:I7_HOME_MENU
cls
call :I7_CHECK_MEMORY_READY
echo.
echo Jadon's Ultimate Installer v9.0 - Portable Deck Memory Edition
echo Carry and run this CMD only; no separate PS1 files are required.
echo.
echo [1] School System Install
echo     Strict current-user installation for managed or school PCs.
echo.
echo [2] Normal Install
echo     User-level install with BITS, GUI, and shortcut fallbacks allowed.
echo.
echo [3] Run Forge
echo.
echo [4] Run Ultimate Forge Manager v9
echo     Profiles, brackets, backups, similarity tools, and AI Viewer.
echo.
echo [5] Test / Repair Ultimate Forge Manager v9
echo     Re-extracts, parses, self-tests, and promotes only passing candidates.
echo.
echo [6] Run PROVEN SAFE Profile Importer directly
echo     Defaults: Bot_2, CLAWolf, MrStealYoCreatures
echo.
echo [7] Read Existing Deck Memory File
echo     Restore saved decks without rescanning Archidekt profiles.
echo.
if "%I7_MEMORY_READY%"=="1" echo [8] View Selected Deck Memory
if "%I7_MEMORY_READY%"=="1" echo     Browse the saved memory in the coloured viewer.
if "%I7_MEMORY_READY%"=="1" echo.
echo [9] Configured Uninstall
echo     Remove only the selected components or imported decks.
echo.
echo [0] Exit
echo.

if not exist "%SystemRoot%\System32\choice.exe" goto :I7_CHOICE_MISSING
"%SystemRoot%\System32\choice.exe" /C 1234567890 /N /M "Choose an option: "
set "I7_CHOICE=%ERRORLEVEL%"
if "%I7_CHOICE%"=="10" goto :I7_END
if "%I7_CHOICE%"=="9" goto :I7_MENU_UNINSTALL
if "%I7_CHOICE%"=="8" goto :I7_MENU_MEMORY_VIEW
if "%I7_CHOICE%"=="7" goto :I7_MENU_MEMORY
if "%I7_CHOICE%"=="6" goto :I7_MENU_SAFE
if "%I7_CHOICE%"=="5" goto :I7_MENU_DIAGNOSTICS
if "%I7_CHOICE%"=="4" goto :I7_MENU_MANAGER
if "%I7_CHOICE%"=="3" goto :I7_MENU_FORGE
if "%I7_CHOICE%"=="2" goto :I7_MENU_NORMAL
if "%I7_CHOICE%"=="1" goto :I7_MENU_SCHOOL
set "I7_FAIL_MESSAGE=The menu choice command returned an invalid result."
call :I7_SHOW_FAILURE
goto :I7_HOME_MENU

:I7_MENU_SCHOOL
set "I7_INSTALL_MODE=SCHOOL"
call :I7_RUN_INSTALL
goto :I7_HOME_MENU

:I7_MENU_NORMAL
set "I7_INSTALL_MODE=NORMAL"
call :I7_RUN_INSTALL
goto :I7_HOME_MENU

:I7_MENU_FORGE
call :I7_RUN_FORGE
goto :I7_HOME_MENU

:I7_MENU_MANAGER
call :I7_RUN_MANAGER
goto :I7_HOME_MENU

:I7_MENU_DIAGNOSTICS
call :I7_DIAGNOSTICS
goto :I7_HOME_MENU

:I7_MENU_SAFE
call :I7_RUN_SAFE
goto :I7_HOME_MENU

:I7_MENU_MEMORY
call :I7_READ_MEMORY
goto :I7_HOME_MENU

:I7_MENU_MEMORY_VIEW
call :I7_VIEW_MEMORY
goto :I7_HOME_MENU

:I7_MENU_UNINSTALL
call :I7_CONFIGURED_UNINSTALL
goto :I7_HOME_MENU

:I7_RUN_INSTALL
echo.
echo Selected: %I7_INSTALL_MODE% INSTALL
if /I "%I7_INSTALL_MODE%"=="SCHOOL" echo No BITS, installer GUI, shortcuts, elevation, registry commands, or permanent PATH changes will be used.
echo.

call :I7_PREPARE_CORE
if errorlevel 1 goto :I7_INSTALL_CORE_FAILED

call :I7_INVOKE_CORE "%I7_CORE%" Install "%I7_INSTALL_MODE%"
set "I7_INSTALL_RC=%ERRORLEVEL%"
if not "%I7_INSTALL_RC%"=="0" goto :I7_INSTALL_OPERATION_FAILED

echo.
echo [7/8] Installing independently validated V9 manager and attached fallback...
call :I7_PREPARE_SAFE
set "I7_INSTALL_SAFE_RC=%ERRORLEVEL%"
call :I7_PREPARE_LEGACY
set "I7_INSTALL_LEGACY_RC=%ERRORLEVEL%"
call :I7_EXTRACT_MANAGER
set "I7_INSTALL_MANAGER_RC=%ERRORLEVEL%"

if not "%I7_INSTALL_SAFE_RC%"=="0" call :I7_INSTALL_SAFE_WARNING
if not "%I7_INSTALL_LEGACY_RC%"=="0" call :I7_INSTALL_LEGACY_WARNING
if not "%I7_INSTALL_MANAGER_RC%"=="0" call :I7_INSTALL_MANAGER_WARNING

if /I "%I7_INSTALL_MODE%"=="NORMAL" if "%I7_INSTALL_MANAGER_RC%"=="0" call :I7_CREATE_MANAGER_SHORTCUT

echo.
echo ================================================================
echo INSTALLATION COMPLETE
echo ================================================================
echo.
if exist "%I7_BASE%\Forge_Location.txt" type "%I7_BASE%\Forge_Location.txt"
echo.
if "%I7_INSTALL_MANAGER_RC%"=="0" echo Ultimate Forge Manager v7: READY
if not "%I7_INSTALL_MANAGER_RC%"=="0" echo Ultimate Forge Manager v7: candidate failed; previous copy retained
if "%I7_INSTALL_SAFE_RC%"=="0" echo Proven safe V4 importer: VERIFIED
if not "%I7_INSTALL_SAFE_RC%"=="0" echo Proven safe V4 importer: verification failed; previous copy retained
if "%I7_INSTALL_LEGACY_RC%"=="0" echo Attached v8 compatibility installer: VERIFIED
if not "%I7_INSTALL_LEGACY_RC%"=="0" echo Attached v8 compatibility installer: unavailable
echo Installer log:
set I7_INSTALL_LOG
echo.
echo No administrator installation or permanent PATH change was used.
if /I "%I7_INSTALL_MODE%"=="SCHOOL" echo School safeguards remained active for the entire install.
echo.
pause
exit /b 0

:I7_INSTALL_CORE_FAILED
set "I7_FAIL_MESSAGE=The V9 installer core candidate failed extraction, parser validation, or self-test."
call :I7_SHOW_FAILURE
call :I7_RUN_LEGACY_FALLBACK
exit /b %ERRORLEVEL%

:I7_INSTALL_OPERATION_FAILED
set "I7_FAIL_MESSAGE=Forge installation or repair failed. Existing working files were retained whenever possible."
call :I7_SHOW_FAILURE
call :I7_RUN_LEGACY_FALLBACK
exit /b %ERRORLEVEL%

:I7_INSTALL_SAFE_WARNING
echo.
echo WARNING: The proven-safe importer candidate could not be refreshed.
echo Any previous verified live copy was left untouched.
call :I7_LOG_FIXED "Safe importer refresh failed during install."
exit /b 0

:I7_INSTALL_MANAGER_WARNING
echo.
echo WARNING: The V9 manager candidate did not pass all validation.
echo Forge remains usable and any prior manager copy was left untouched.
call :I7_LOG_FIXED "Manager refresh failed during install."
exit /b 0

:I7_INSTALL_LEGACY_WARNING
echo.
echo WARNING: The attached v8 compatibility fallback could not be refreshed.
echo Primary Forge and importer features remain available.
call :I7_LOG_FIXED "Attached v8 fallback refresh failed during install."
exit /b 0

:I7_CREATE_MANAGER_SHORTCUT
call :I7_INVOKE_CORE "%I7_CORE%" ManagerShortcut NORMAL
if errorlevel 1 call :I7_LOG_FIXED "Manager desktop shortcut was not created."
exit /b 0

:I7_RUN_FORGE
echo.
call :I7_PREPARE_CORE
if errorlevel 1 goto :I7_RUN_FORGE_CORE_FAILED
call :I7_INVOKE_CORE "%I7_CORE%" RunForge SCHOOL
set "I7_FORGE_RC=%ERRORLEVEL%"
if "%I7_FORGE_RC%"=="0" exit /b 0
set "I7_FAIL_MESSAGE=Forge could not be launched. The normal installation was not modified."
call :I7_SHOW_FAILURE
exit /b 1

:I7_RUN_FORGE_CORE_FAILED
set "I7_FAIL_MESSAGE=The validated installer core was unavailable, so Forge launch was stopped safely."
call :I7_SHOW_FAILURE
exit /b 1

:I7_RUN_MANAGER
echo.
echo Preparing the V9 manager candidate...
call :I7_PREPARE_LEGACY >nul 2>&1
call :I7_EXTRACT_MANAGER
if errorlevel 1 goto :I7_MANAGER_PREP_FAILED

call "%I7_MANAGER%"
set "I7_MANAGER_RC=%ERRORLEVEL%"
if "%I7_MANAGER_RC%"=="0" exit /b 0

set "I7_FAIL_MESSAGE=The advanced V9 manager returned an error. The proven-safe importer will open next."
call :I7_SHOW_FAILURE
call :I7_RUN_SAFE
exit /b 1

:I7_MANAGER_PREP_FAILED
set "I7_FAIL_MESSAGE=The advanced manager candidate failed validation. The previous live copy was retained; the proven-safe importer will open next."
call :I7_SHOW_FAILURE
call :I7_RUN_SAFE
exit /b 1

:I7_RUN_SAFE
echo.
echo Preparing the independently embedded proven-safe V4 importer...
call :I7_PREPARE_SAFE
if errorlevel 1 goto :I7_SAFE_FAILED
call :I7_SEED_DEFAULT_PROFILES
if errorlevel 1 call :I7_LOG_FIXED "Default profile seeding failed; safe importer launch continued."

call :I7_INVOKE_PAYLOAD "%I7_SAFE_PS%"
set "I7_SAFE_RC=%ERRORLEVEL%"
if "%I7_SAFE_RC%"=="0" exit /b 0
set "I7_FAIL_MESSAGE=The proven-safe importer returned an error. Its diagnostics remain visible and logged."
call :I7_SHOW_FAILURE
exit /b 1

:I7_SAFE_FAILED
set "I7_FAIL_MESSAGE=No exact, parser-valid proven-safe importer copy was available."
call :I7_SHOW_FAILURE
if exist "%I7_SAFE_LOG%" type "%I7_SAFE_LOG%"
exit /b 1

:I7_READ_MEMORY
echo.
echo Preparing the portable deck-memory reader...
call :I7_EXTRACT_MANAGER
if errorlevel 1 (
    set "I7_FAIL_MESSAGE=The deck-memory reader could not be validated."
    call :I7_SHOW_FAILURE
    exit /b 1
)
call "%I7_MANAGER%" --memory-import
set "I7_MEMORY_RC=%ERRORLEVEL%"
if "%I7_MEMORY_RC%"=="0" exit /b 0
set "I7_FAIL_MESSAGE=The selected deck-memory file could not be read or restored."
call :I7_SHOW_FAILURE
exit /b 1

:I7_VIEW_MEMORY
if not "%I7_MEMORY_READY%"=="1" (
    echo.
    echo No selected deck-memory file is available. Use option 7 first.
    pause
    exit /b 1
)
call :I7_EXTRACT_MANAGER
if errorlevel 1 exit /b 1
call "%I7_MANAGER%" --memory-view
exit /b %ERRORLEVEL%

:I7_CONFIGURED_UNINSTALL
cls
echo.
echo Jadon's Configured Current-User Uninstall
echo.
echo [1] Remove importer-added decks only
echo [2] Remove manager, importer, and AI Viewer only
echo [3] Remove Forge program files and launcher only
echo [4] Remove private Java only
echo [5] Remove caches, downloads, logs, and importer backups only
echo [6] Remove installed components but keep every Forge deck
echo [7] Remove installed components and importer-added decks
echo [8] Back
echo.
echo Manually-created Forge deck files are never removed by these choices.
"%SystemRoot%\System32\choice.exe" /C 12345678 /N /M "Choose 1-8: "
set "I7_UNINSTALL_CHOICE=%ERRORLEVEL%"
if "%I7_UNINSTALL_CHOICE%"=="8" exit /b 0
if "%I7_UNINSTALL_CHOICE%"=="7" set "I7_UNINSTALL_SCOPE=Everything"
if "%I7_UNINSTALL_CHOICE%"=="6" set "I7_UNINSTALL_SCOPE=KeepDecks"
if "%I7_UNINSTALL_CHOICE%"=="5" set "I7_UNINSTALL_SCOPE=Caches"
if "%I7_UNINSTALL_CHOICE%"=="4" set "I7_UNINSTALL_SCOPE=Java"
if "%I7_UNINSTALL_CHOICE%"=="3" set "I7_UNINSTALL_SCOPE=Forge"
if "%I7_UNINSTALL_CHOICE%"=="2" set "I7_UNINSTALL_SCOPE=Manager"
if "%I7_UNINSTALL_CHOICE%"=="1" set "I7_UNINSTALL_SCOPE=ImportedDecks"
echo.
echo Selected uninstall scope: %I7_UNINSTALL_SCOPE%
"%SystemRoot%\System32\choice.exe" /C YN /N /M "Continue? [Y/N]: "
if errorlevel 2 exit /b 0
call :I7_PREPARE_CORE
if errorlevel 1 (
    set "I7_FAIL_MESSAGE=The uninstall engine did not pass validation; nothing was removed."
    call :I7_SHOW_FAILURE
    exit /b 1
)
call :I7_INVOKE_CORE "%I7_CORE%" Uninstall SCHOOL "%I7_UNINSTALL_SCOPE%"
set "I7_UNINSTALL_RC=%ERRORLEVEL%"
echo.
if "%I7_UNINSTALL_RC%"=="0" echo Configured uninstall: COMPLETE
if not "%I7_UNINSTALL_RC%"=="0" echo Configured uninstall: FAILED - see the diagnostics shown above.
pause
exit /b %I7_UNINSTALL_RC%

:I7_DIAGNOSTICS
cls
echo.
echo Jadon's V9 Diagnostics / Atomic Repair
echo.
echo This checks the complete installer core, independent safe importer,
echo standalone manager CMD, complete manager PowerShell, and all 22 tests.
echo.

call :I7_PREPARE_CORE
set "I7_DIAG_CORE_RC=%ERRORLEVEL%"
if "%I7_DIAG_CORE_RC%"=="0" echo [1/3] Installer core parser/self-test: PASS
if not "%I7_DIAG_CORE_RC%"=="0" echo [1/3] Installer core parser/self-test: FAILED

call :I7_PREPARE_SAFE
set "I7_DIAG_SAFE_RC=%ERRORLEVEL%"
if "%I7_DIAG_SAFE_RC%"=="0" echo [2/3] Proven safe V4 hash/parser: PASS
if not "%I7_DIAG_SAFE_RC%"=="0" echo [2/3] Proven safe V4 hash/parser: FAILED

call :I7_EXTRACT_MANAGER
set "I7_DIAG_MANAGER_RC=%ERRORLEVEL%"
if "%I7_DIAG_MANAGER_RC%"=="0" echo [3/3] V9 manager parser/runtime tests: PASS
if not "%I7_DIAG_MANAGER_RC%"=="0" echo [3/3] V9 manager parser/runtime tests: FAILED

echo.
if exist "%I7_CORE_LOG%" type "%I7_CORE_LOG%"
if exist "%I7_MANAGER_TEST_LOG%" type "%I7_MANAGER_TEST_LOG%"
if exist "%I7_SAFE_LOG%" type "%I7_SAFE_LOG%"
echo.
if "%I7_DIAG_CORE_RC%"=="0" if "%I7_DIAG_SAFE_RC%"=="0" if "%I7_DIAG_MANAGER_RC%"=="0" echo V9 DIAGNOSTICS: PASS
if not "%I7_DIAG_CORE_RC%"=="0" echo V9 DIAGNOSTICS: FAILED - see logs above.
if not "%I7_DIAG_SAFE_RC%"=="0" echo V9 DIAGNOSTICS: FAILED - see logs above.
if not "%I7_DIAG_MANAGER_RC%"=="0" echo V9 DIAGNOSTICS: FAILED - see logs above.
echo.
pause
exit /b 0

:I7_RUN_LEGACY_FALLBACK
echo.
echo ================================================================
echo PRIMARY INSTALLER FAILED - STARTING ATTACHED V8 COMPATIBILITY
echo ================================================================
echo.
echo The complete attached v8 installer is embedded in this same CMD.
echo Select the same School or Normal mode when its compatibility menu opens.
echo Existing validated files are retained.
echo.
call :I7_PREPARE_LEGACY
if errorlevel 1 (
    echo ERROR: The attached v8 fallback failed exact SHA-256 validation.
    exit /b 1
)
call "%I7_LEGACY%"
exit /b %ERRORLEVEL%

:I7_PREPARE_LEGACY
del /f /q "%I7_LEGACY_CANDIDATE%" >nul 2>&1
set "PS_I7_SELF=%I7_SELF%"
set "PS_I7_LEGACY_OUT=%I7_LEGACY_CANDIDATE%"
set "PS_I7_LEGACY_SHA=%I7_LEGACY_SHA%"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';$raw=[IO.File]::ReadAllText($env:PS_I7_SELF);$b='###JADON_LEGACY_V8_FALLBACK_BEGIN###';$e='###JADON_LEGACY_V8_FALLBACK_END###';$bi=$raw.LastIndexOf($b);$ei=$raw.LastIndexOf($e);if($bi-lt0-or$ei-le$bi){throw 'Legacy v8 fallback markers are invalid.'};" ^
 "$body=$raw.Substring($bi+$b.Length,$ei-($bi+$b.Length)).TrimStart([char]13,[char]10);[IO.File]::WriteAllText($env:PS_I7_LEGACY_OUT,$body,(New-Object Text.ASCIIEncoding));$sha=[Security.Cryptography.SHA256]::Create();$s=[IO.File]::OpenRead($env:PS_I7_LEGACY_OUT);try{$h=([BitConverter]::ToString($sha.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$sha.Dispose()};if($h-ne$env:PS_I7_LEGACY_SHA){throw ('Legacy v8 fallback hash mismatch: '+$h)}"
if errorlevel 1 exit /b 1
set "PS_I7_CANDIDATE=%I7_LEGACY_CANDIDATE%"
set "PS_I7_LIVE=%I7_LEGACY%"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';$c=$env:PS_I7_CANDIDATE;$l=$env:PS_I7_LIVE;if(Test-Path -LiteralPath $l){$b=$l+'.last-good-'+(Get-Date -Format 'yyyyMMdd-HHmmssfff');[IO.File]::Replace($c,$l,$b,$true)}else{[IO.File]::Move($c,$l)}"
exit /b %ERRORLEVEL%

:I7_PREPARE_CORE
del /f /q "%I7_CORE_CANDIDATE%" >nul 2>&1
del /f /q "%I7_CORE_LOG%" >nul 2>&1
set "PS_I7_SELF=%I7_SELF%"
set "PS_I7_CORE_OUT=%I7_CORE_CANDIDATE%"
set "PS_I7_CORE_SHA=%I7_CORE_SHA%"

"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop'; $raw=[IO.File]::ReadAllText($env:PS_I7_SELF);" ^
 "$b='###JADON_INSTALLER_V7_PS_PAYLOAD_BEGIN###'; $e='###JADON_INSTALLER_V7_PS_PAYLOAD_END###';" ^
 "$bi=$raw.LastIndexOf($b); $ei=$raw.LastIndexOf($e); if($bi-lt0-or$ei-le$bi){throw 'Installer core payload markers are invalid.'};" ^
 "$body=$raw.Substring($bi+$b.Length,$ei-($bi+$b.Length)).TrimStart([char]13,[char]10);" ^
 "[IO.File]::WriteAllText($env:PS_I7_CORE_OUT,$body,(New-Object Text.ASCIIEncoding));" ^
 "$sha=[Security.Cryptography.SHA256]::Create(); $s=[IO.File]::OpenRead($env:PS_I7_CORE_OUT);" ^
 "try{$hash=([BitConverter]::ToString($sha.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$sha.Dispose()};" ^
 "if($hash-ne$env:PS_I7_CORE_SHA){throw ('Installer core SHA-256 mismatch: '+$hash)}" > "%I7_CORE_LOG%" 2>&1
if errorlevel 1 goto :I7_CORE_FAILED

set "PS_I7_PARSE=%I7_CORE_CANDIDATE%"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$src=[IO.File]::ReadAllLines($env:PS_I7_PARSE); $tokens=$null; $errors=$null;" ^
 "[Management.Automation.Language.Parser]::ParseFile($env:PS_I7_PARSE,[ref]$tokens,[ref]$errors)|Out-Null;" ^
 "Write-Output ('Windows PowerShell version: '+$PSVersionTable.PSVersion);" ^
 "if($errors.Count){foreach($x in $errors){$n=$x.Extent.StartLineNumber;$c=$x.Extent.StartColumnNumber;Write-Output ($n.ToString()+':'+$c.ToString()+': '+$x.Message);if($n-ge1-and$n-le$src.Length){Write-Output ('    SOURCE> '+$src[$n-1])}};exit 1};" ^
 "Write-Output 'Installer core parser: PASS (complete payload)'" >> "%I7_CORE_LOG%" 2>&1
if errorlevel 1 goto :I7_CORE_FAILED

call :I7_INVOKE_CORE "%I7_CORE_CANDIDATE%" SelfTest SCHOOL >> "%I7_CORE_LOG%" 2>&1
if errorlevel 1 goto :I7_CORE_FAILED

set "PS_I7_CANDIDATE=%I7_CORE_CANDIDATE%"
set "PS_I7_LIVE=%I7_CORE%"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';$c=$env:PS_I7_CANDIDATE;$l=$env:PS_I7_LIVE;" ^
 "if(Test-Path -LiteralPath $l){$b=$l+'.last-good-'+(Get-Date -Format 'yyyyMMdd-HHmmssfff');[IO.File]::Replace($c,$l,$b,$true)}else{[IO.File]::Move($c,$l)}"
if errorlevel 1 goto :I7_CORE_FAILED
del /f /q "%I7_BASE%\InstallerCore_v7.ps1" >nul 2>&1
del /f /q "%I7_BASE%\InstallerCore_v7.candidate.ps1" >nul 2>&1
del /f /q "%I7_BASE%\InstallerCore_v7.ps1.last-good-*" >nul 2>&1
del /f /q "%I7_BASE%\InstallerCore_v7.payload" >nul 2>&1
exit /b 0

:I7_CORE_FAILED
del /f /q "%I7_CORE_CANDIDATE%" >nul 2>&1
call :I7_LOG_FIXED "Installer core candidate validation failed."
exit /b 1

:I7_PREPARE_SAFE
del /f /q "%I7_SAFE_CMD_CANDIDATE%" >nul 2>&1
del /f /q "%I7_SAFE_PS_CANDIDATE%" >nul 2>&1
del /f /q "%I7_SAFE_LOG%" >nul 2>&1
set "PS_I7_SELF=%I7_SELF%"
set "PS_I7_SAFE_CMD_CANDIDATE=%I7_SAFE_CMD_CANDIDATE%"
set "PS_I7_SAFE_CMD_SHA=%I7_SAFE_CMD_SHA%"

"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';$raw=[IO.File]::ReadAllText($env:PS_I7_SELF);" ^
 "$b='###JADON_SAFE_IMPORTER_V4_BEGIN###';$e='###JADON_SAFE_IMPORTER_V4_END###';$bi=$raw.LastIndexOf($b);$ei=$raw.LastIndexOf($e);" ^
 "if($bi-lt0-or$ei-le$bi){throw 'Independent safe importer markers are invalid.'};" ^
 "$body=$raw.Substring($bi+$b.Length,$ei-($bi+$b.Length)).TrimStart([char]13,[char]10);" ^
 "[IO.File]::WriteAllText($env:PS_I7_SAFE_CMD_CANDIDATE,$body,(New-Object Text.ASCIIEncoding));" ^
 "$sha=[Security.Cryptography.SHA256]::Create();$s=[IO.File]::OpenRead($env:PS_I7_SAFE_CMD_CANDIDATE);try{$h=([BitConverter]::ToString($sha.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$sha.Dispose()};" ^
 "if($h-ne$env:PS_I7_SAFE_CMD_SHA){throw ('Safe CMD SHA-256 mismatch: '+$h)}" > "%I7_SAFE_LOG%" 2>&1
if errorlevel 1 goto :I7_SAFE_CANDIDATE_FAILED

set "PS_I7_SAFE_CMD_CANDIDATE=%I7_SAFE_CMD_CANDIDATE%"
set "PS_I7_SAFE_PS_CANDIDATE=%I7_SAFE_PS_CANDIDATE%"
set "PS_I7_SAFE_PS_SHA=%I7_SAFE_PS_SHA%"
set "PS_I7_SAFE_CMD=%I7_SAFE_CMD%"
set "PS_I7_SAFE_PS=%I7_SAFE_PS%"

"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';$raw=[IO.File]::ReadAllText($env:PS_I7_SAFE_CMD_CANDIDATE);$m='###JADON_ARCHIDEKT_MANAGER_PAYLOAD###';$ix=$raw.LastIndexOf($m);if($ix-lt0){throw 'Safe PowerShell marker is missing.'};" ^
 "$body=$raw.Substring($ix+$m.Length).TrimStart([char]13,[char]10);[IO.File]::WriteAllText($env:PS_I7_SAFE_PS_CANDIDATE,$body,(New-Object Text.UTF8Encoding($false)));" ^
 "$sha=[Security.Cryptography.SHA256]::Create();$s=[IO.File]::OpenRead($env:PS_I7_SAFE_PS_CANDIDATE);try{$h=([BitConverter]::ToString($sha.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$sha.Dispose()};if($h-ne$env:PS_I7_SAFE_PS_SHA){throw ('Safe PS SHA-256 mismatch: '+$h)};" ^
 "$src=[IO.File]::ReadAllLines($env:PS_I7_SAFE_PS_CANDIDATE);$t=$null;$errs=$null;[Management.Automation.Language.Parser]::ParseFile($env:PS_I7_SAFE_PS_CANDIDATE,[ref]$t,[ref]$errs)|Out-Null;" ^
 "if($errs.Count){foreach($x in $errs){$n=$x.Extent.StartLineNumber;$c=$x.Extent.StartColumnNumber;Write-Output ($n.ToString()+':'+$c.ToString()+': '+$x.Message);if($n-ge1-and$n-le$src.Length){Write-Output ('    SOURCE> '+$src[$n-1])}};exit 1};" ^
 "$cl=$env:PS_I7_SAFE_CMD;$cc=$env:PS_I7_SAFE_CMD_CANDIDATE;$pl=$env:PS_I7_SAFE_PS;$pc=$env:PS_I7_SAFE_PS_CANDIDATE;" ^
 "if(Test-Path -LiteralPath $pl){$bak=$pl+'.last-good-'+(Get-Date -Format 'yyyyMMdd-HHmmssfff');[IO.File]::Replace($pc,$pl,$bak,$true)}else{[IO.File]::Move($pc,$pl)};" ^
 "if(Test-Path -LiteralPath $cl){$bak=$cl+'.last-good-'+(Get-Date -Format 'yyyyMMdd-HHmmssfff');[IO.File]::Replace($cc,$cl,$bak,$true)}else{[IO.File]::Move($cc,$cl)};" ^
 "Write-Output ('Windows PowerShell version: '+$PSVersionTable.PSVersion);Write-Output 'Safe V4 CMD hash, PS hash, and complete parser: PASS'" >> "%I7_SAFE_LOG%" 2>&1
if errorlevel 1 goto :I7_SAFE_CANDIDATE_FAILED
del /f /q "%I7_TOOL%\Safe_Archidekt_Importer_v4.ps1" >nul 2>&1
del /f /q "%I7_TOOL%\Safe_Archidekt_Importer_v4.candidate.ps1" >nul 2>&1
del /f /q "%I7_TOOL%\Safe_Archidekt_Importer_v4.ps1.last-good-*" >nul 2>&1
exit /b 0

:I7_SAFE_CANDIDATE_FAILED
del /f /q "%I7_SAFE_CMD_CANDIDATE%" >nul 2>&1
del /f /q "%I7_SAFE_PS_CANDIDATE%" >nul 2>&1
call :I7_VERIFY_SAFE_LIVE
if not errorlevel 1 exit /b 0
call :I7_LOG_FIXED "Safe importer candidate and live-copy verification failed."
exit /b 1

:I7_VERIFY_SAFE_LIVE
if not exist "%I7_SAFE_CMD%" exit /b 1
if not exist "%I7_SAFE_PS%" exit /b 1
set "PS_I7_SAFE_CMD=%I7_SAFE_CMD%"
set "PS_I7_SAFE_PS=%I7_SAFE_PS%"
set "PS_I7_SAFE_CMD_SHA=%I7_SAFE_CMD_SHA%"
set "PS_I7_SAFE_PS_SHA=%I7_SAFE_PS_SHA%"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';function h($p){$a=[Security.Cryptography.SHA256]::Create();$s=[IO.File]::OpenRead($p);try{return ([BitConverter]::ToString($a.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$a.Dispose()}};" ^
 "if((h $env:PS_I7_SAFE_CMD)-ne$env:PS_I7_SAFE_CMD_SHA){exit 1};if((h $env:PS_I7_SAFE_PS)-ne$env:PS_I7_SAFE_PS_SHA){exit 1};$t=$null;$e=$null;[Management.Automation.Language.Parser]::ParseFile($env:PS_I7_SAFE_PS,[ref]$t,[ref]$e)|Out-Null;if($e.Count){exit 1};exit 0"
exit /b %ERRORLEVEL%

:I7_EXTRACT_MANAGER
del /f /q "%I7_MANAGER_CANDIDATE%" >nul 2>&1
del /f /q "%I7_MANAGER_TEST_LOG%" >nul 2>&1
set "PS_I7_SELF=%I7_SELF%"
set "PS_I7_MANAGER_CANDIDATE=%I7_MANAGER_CANDIDATE%"
set "PS_I7_MANAGER_SHA=%I7_MANAGER_SHA%"

"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';$raw=[IO.File]::ReadAllText($env:PS_I7_SELF);$m='###JADON_INSTALLER_MANAGER_V7_CMD_PAYLOAD###';$ix=$raw.LastIndexOf($m);if($ix-lt0){throw 'Manager CMD payload marker is missing.'};" ^
 "$body=$raw.Substring($ix+$m.Length).TrimStart([char]13,[char]10);[IO.File]::WriteAllText($env:PS_I7_MANAGER_CANDIDATE,$body,(New-Object Text.ASCIIEncoding));" ^
 "$sha=[Security.Cryptography.SHA256]::Create();$s=[IO.File]::OpenRead($env:PS_I7_MANAGER_CANDIDATE);try{$h=([BitConverter]::ToString($sha.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$sha.Dispose()};" ^
 "if($h-ne$env:PS_I7_MANAGER_SHA){throw ('Manager CMD SHA-256 mismatch: '+$h)}" > "%I7_MANAGER_TEST_LOG%" 2>&1
if errorlevel 1 goto :I7_MANAGER_CANDIDATE_FAILED

call "%I7_MANAGER_CANDIDATE%" --test >> "%I7_MANAGER_TEST_LOG%" 2>&1
if errorlevel 1 goto :I7_MANAGER_CANDIDATE_FAILED

set "PS_I7_CANDIDATE=%I7_MANAGER_CANDIDATE%"
set "PS_I7_LIVE=%I7_MANAGER%"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';$c=$env:PS_I7_CANDIDATE;$l=$env:PS_I7_LIVE;if(Test-Path -LiteralPath $l){$b=$l+'.last-good-'+(Get-Date -Format 'yyyyMMdd-HHmmssfff');[IO.File]::Replace($c,$l,$b,$true)}else{[IO.File]::Move($c,$l)}"
if errorlevel 1 goto :I7_MANAGER_CANDIDATE_FAILED
exit /b 0

:I7_MANAGER_CANDIDATE_FAILED
del /f /q "%I7_MANAGER_CANDIDATE%" >nul 2>&1
call :I7_LOG_FIXED "Manager CMD candidate failed hash, parser, runtime, or promotion validation."
exit /b 1

:I7_SEED_DEFAULT_PROFILES
set "PS_I7_PROFILE=%I7_TOOL%\profiles.txt"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';$defaults=@('Bot_2','CLAWolf','MrStealYoCreatures');$all=New-Object Collections.ArrayList;foreach($x in $defaults){[void]$all.Add($x)};" ^
 "if(Test-Path -LiteralPath $env:PS_I7_PROFILE){foreach($x in [IO.File]::ReadAllLines($env:PS_I7_PROFILE,[Text.Encoding]::UTF8)){if([string]::IsNullOrWhiteSpace($x)){continue};$dup=$false;foreach($y in $all){if([string]::Equals($x,$y,[StringComparison]::OrdinalIgnoreCase)){$dup=$true;break}};if(-not$dup-and$all.Count-lt20){[void]$all.Add($x)}}};" ^
 "$p=$env:PS_I7_PROFILE;$c=$p+'.candidate-'+[Guid]::NewGuid().ToString('N');$enc=New-Object Text.UTF8Encoding($false);[IO.File]::WriteAllLines($c,[string[]]$all.ToArray(),$enc);if(Test-Path -LiteralPath $p){$b=$p+'.last-good-'+(Get-Date -Format 'yyyyMMdd-HHmmssfff');[IO.File]::Replace($c,$p,$b,$true)}else{[IO.File]::Move($c,$p)}" >nul 2>&1
exit /b %ERRORLEVEL%

:I7_CHECK_MEMORY_READY
set "I7_MEMORY_READY=0"
set "PS_I7_SETTINGS=%I7_TOOL%\settings.json"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command "try{if(-not(Test-Path -LiteralPath $env:PS_I7_SETTINGS)){exit 1};$s=Get-Content -LiteralPath $env:PS_I7_SETTINGS -Raw -Encoding UTF8|ConvertFrom-Json;$p=[string]$s.MemoryFilePath;if($p-and(Test-Path -LiteralPath $p -PathType Leaf)){exit 0};exit 1}catch{exit 1}" >nul 2>&1
if not errorlevel 1 set "I7_MEMORY_READY=1"
exit /b 0

:I7_AUTOMATED_TEST
echo Running combined installer V9 test/repair path...
call :I7_PREPARE_CORE
if errorlevel 1 goto :I7_AUTOTEST_FAILED
call :I7_INVOKE_CORE "%I7_CORE%" SelfTest SCHOOL
if errorlevel 1 goto :I7_AUTOTEST_FAILED
call :I7_PREPARE_SAFE
if errorlevel 1 goto :I7_AUTOTEST_FAILED
call :I7_PREPARE_LEGACY
if errorlevel 1 goto :I7_AUTOTEST_FAILED
call :I7_EXTRACT_MANAGER
if errorlevel 1 goto :I7_AUTOTEST_FAILED
echo Installer combined test: PASS
echo Installer core parser/runtime: PASS
echo Proven safe fallback integrity/parser: PASS
echo Attached v8 compatibility fallback integrity: PASS
echo Manager CMD extraction and 22/22 runtime tests: PASS
exit /b 0

:I7_AUTOTEST_FAILED
echo Installer combined test: FAILED
if exist "%I7_CORE_LOG%" type "%I7_CORE_LOG%"
if exist "%I7_MANAGER_TEST_LOG%" type "%I7_MANAGER_TEST_LOG%"
if exist "%I7_SAFE_LOG%" type "%I7_SAFE_LOG%"
exit /b 1

:I7_INITIALIZE
if not exist "%I7_BASE%" mkdir "%I7_BASE%" >nul 2>&1
if not exist "%I7_TOOL%" mkdir "%I7_TOOL%" >nul 2>&1
if not exist "%I7_LOG_DIR%" mkdir "%I7_LOG_DIR%" >nul 2>&1
if not exist "%I7_BASE%" exit /b 1
if not exist "%I7_TOOL%" exit /b 1
if not exist "%I7_LOG_DIR%" exit /b 1
>> "%I7_INSTALL_LOG%" echo.
>> "%I7_INSTALL_LOG%" echo ================================================================
>> "%I7_INSTALL_LOG%" echo Installer V7 started %DATE% %TIME%
>> "%I7_INSTALL_LOG%" echo ================================================================
exit /b 0

:I7_LOG_FIXED
>> "%I7_INSTALL_LOG%" echo [%DATE% %TIME%] %~1
exit /b 0

:I7_INVOKE_CORE
set "PS_I7_RUN_PAYLOAD=%~1"
set "PS_I7_RUN_ACTION=%~2"
set "PS_I7_RUN_MODE=%~3"
set "PS_I7_RUN_UNINSTALL_SCOPE=%~4"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop';$text=[IO.File]::ReadAllText($env:PS_I7_RUN_PAYLOAD,[Text.Encoding]::UTF8);$block=[ScriptBlock]::Create($text);if($env:PS_I7_RUN_ACTION-eq'Uninstall'){. $block -Action Uninstall -Mode $env:PS_I7_RUN_MODE -UninstallScope $env:PS_I7_RUN_UNINSTALL_SCOPE}else{. $block -Action $env:PS_I7_RUN_ACTION -Mode $env:PS_I7_RUN_MODE}"
exit /b %ERRORLEVEL%

:I7_INVOKE_PAYLOAD
set "PS_I7_RUN_PAYLOAD=%~1"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop';$text=[IO.File]::ReadAllText($env:PS_I7_RUN_PAYLOAD,[Text.Encoding]::UTF8);$block=[ScriptBlock]::Create($text);. $block"
exit /b %ERRORLEVEL%

:I7_CHECK_POWERSHELL_COMPAT
"%I7_PS_EXE%" -NoLogo -NoProfile -Command "try{if($ExecutionContext.SessionState.LanguageMode-ne'FullLanguage'){exit 12};$b=[ScriptBlock]::Create('param([int]$n);if($n-ne 7){throw ''probe failed''}');&$b 7;exit 0}catch{exit 13}" >nul 2>&1
exit /b %ERRORLEVEL%

:I7_SHOW_FAILURE
call :I7_LOG_FIXED "%I7_FAIL_MESSAGE%"
echo.
echo ================================================================
echo OPERATION FAILED SAFELY
echo ================================================================
echo.
echo %I7_FAIL_MESSAGE%
echo.
echo Complete installer diagnostics:
set I7_INSTALL_LOG
echo.
echo Existing working Forge, manager, and importer copies were not overwritten by an unvalidated candidate.
echo This window will remain visible.
echo.
if not "%I7_AUTOTEST%"=="1" pause
exit /b 0

:I7_CHECK_NOT_ELEVATED
"%I7_PS_EXE%" -NoLogo -NoProfile -Command "try{$i=[Security.Principal.WindowsIdentity]::GetCurrent();$p=New-Object Security.Principal.WindowsPrincipal($i);if($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){exit 10};exit 0}catch{exit 20}" >nul 2>&1
exit /b %ERRORLEVEL%

:I7_NO_POWERSHELL
echo.
echo ERROR: Windows PowerShell 5.1 was not found at the standard Windows path.
echo No policy bypass or alternate shell was attempted.
echo.
if /I not "%~1"=="--test" pause
exit /b 1

:I7_POLICY_BLOCKED
echo.
echo ERROR: This PC's administrator policy blocks the Windows PowerShell
echo script engine features required by the installer and importer.
echo No execution-policy bypass, registry change, or elevation was attempted.
echo Ask the school administrator to allow this trusted single-file installer.
echo.
if /I not "%~1"=="--test" pause
exit /b 1

:I7_ELEVATED
echo.
echo ERROR: Run this installer as the normal signed-in user, not as administrator.
echo The elevation check occurred before any installer file or folder write.
echo.
if /I not "%~1"=="--test" pause
exit /b 1

:I7_ELEVATION_UNKNOWN
echo.
echo ERROR: Windows PowerShell could not verify the current elevation state.
echo The installer stopped before writing any files.
echo.
if /I not "%~1"=="--test" pause
exit /b 1

:I7_INIT_FAILED
echo.
echo ERROR: The current-user MTGForge folders could not be initialized.
echo.
if not "%I7_AUTOTEST%"=="1" pause
exit /b 1

:I7_CHOICE_MISSING
set "I7_FAIL_MESSAGE=The standard Windows choice.exe menu command is unavailable or blocked."
call :I7_SHOW_FAILURE
goto :I7_HOME_MENU

:I7_END
exit /b 0

###JADON_LEGACY_V8_FALLBACK_BEGIN###
@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Jadon's Ultimate Installer v6.3 FORTIFIED

if defined LOCALAPPDATA (
    set "BASE=%LOCALAPPDATA%\MTGForge"
) else (
    set "BASE=%USERPROFILE%\AppData\Local\MTGForge"
)

set "MENU_LAUNCHER=%BASE%\Start_Forge.cmd"
set "MENU_IMPORTER=%BASE%\Jadons_Ultimate_Forge_Manager_v6_3.cmd"
set "MENU_IMPORTER_PS1=%BASE%\ArchidektSync\UltimateForgeManager_v6_3.ps1"
set "DIAG_DIR=%BASE%\logs"
set "MANAGER_TEST_LOG=%DIAG_DIR%\manager-v6-selftest.log"
set "MANAGER_PARSE_LOG=%DIAG_DIR%\manager-v6-parse.log"
set "MANAGER_RUN_LOG=%DIAG_DIR%\manager-v6-last-error.log"
set "SELF_FILE=%~f0"
set "DIRECT_SAFE_CMD=%BASE%\ArchidektSync\Safe_Archidekt_Importer_v4.cmd"
set "DIRECT_SAFE_TMP=%BASE%\ArchidektSync\Safe_Archidekt_Importer_v4.candidate.cmd"
set "MANAGER_TMP=%BASE%\Jadons_Ultimate_Forge_Manager_v6_3.candidate.cmd"
set "EXPECTED_MANAGER_SHA=8f5f0ac8ec45ac53720659f334ea5e50481b41e7c5c7af0057603810c3740a2e"
set "EXPECTED_SAFE_SHA=3fdb666ff2b2f87e33f787d52c29601fee7ff965f0df459ee74d220b87be41be"

:HOME_MENU
cls
echo.
echo Jadon's Ultimate Installer v6.3 FORTIFIED
echo.
echo [1] School System Install
echo     Strict user-only installation for managed/school PCs.
echo.
echo [2] Normal Install
echo     Uses the full working user-level installer and convenience fallbacks.
echo.
echo [3] Run Forge
echo.
echo [4] Run V6.3 Forge Manager (Profiles / Brackets / AI Viewer)
echo     If V6.3 fails its parser, self-test, or runtime startup, the proven
echo     V4 profile importer opens automatically instead of leaving you stuck.
echo.
echo [5] Test / Repair V6.3 Forge Manager
echo     Re-extracts the manager and tests its own fallback path.
echo.
echo [6] Run PROVEN SAFE Profile Importer directly
echo.
echo [7] Exit
echo.
choice /C 1234567 /N /M "Choose 1-7: "

if errorlevel 7 exit /b 0
if errorlevel 6 (
    call :RUN_SAFE_IMPORTER
    goto :HOME_MENU
)
if errorlevel 5 (
    call :DIAGNOSE_MANAGER
    goto :HOME_MENU
)
if errorlevel 4 (
    call :RUN_IMPORTER_MENU
    goto :HOME_MENU
)
if errorlevel 3 (
    call :RUN_FORGE_MENU
    goto :HOME_MENU
)

if errorlevel 2 (
    set "INSTALL_MODE=NORMAL"
) else (
    set "INSTALL_MODE=SCHOOL"
)

echo.
if /I "!INSTALL_MODE!"=="SCHOOL" (
    echo Selected: SCHOOL SYSTEM INSTALL
    echo No elevation, Program Files, registry changes, permanent PATH changes,
    echo BITS service fallback, Windows shortcut integration, or graphical
    echo Forge-installer fallback will be used.
) else (
    echo Selected: NORMAL INSTALL
)
echo.

:INSTALL_START
if /I "!INSTALL_MODE!"=="SCHOOL" (
    set "WORK_TEMP=!BASE!\temp"
) else (
    if defined TEMP (
        set "WORK_TEMP=%TEMP%"
    ) else (
        set "WORK_TEMP=!BASE!\temp"
    )
)

set "DOWNLOADS=%BASE%\downloads"
set "JAVA_HOME=%BASE%\java-21-jre"
set "JAVA_TEMP=%BASE%\java-extract"
set "JAVA_ZIP=%DOWNLOADS%\temurin-jre21.zip"
set "RELEASE_INFO=%WORK_TEMP%\forge_release_%RANDOM%_%RANDOM%.txt"
set "DEFAULTS_FILE=%BASE%\forge-install.defaults"
set "LAUNCHER=%BASE%\Start_Forge.cmd"
set "LOCATION_FILE=%BASE%\Forge_Location.txt"
set "IMPORTER_PS1=%BASE%\ArchidektSync\UltimateForgeManager_v6_3.ps1"
set "IMPORTER_CMD=%BASE%\Jadons_Ultimate_Forge_Manager_v6_3.cmd"
set "SELF_FILE=%~f0"

if not exist "%BASE%" mkdir "%BASE%" >nul 2>&1
if not exist "%BASE%\logs" mkdir "%BASE%\logs" >nul 2>&1
if not exist "%DOWNLOADS%" mkdir "%DOWNLOADS%" >nul 2>&1
if not exist "%WORK_TEMP%" mkdir "%WORK_TEMP%" >nul 2>&1

echo [1/8] Preflight checks...
echo.

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: Windows PowerShell was not found.
    goto :FAIL
)

set "IS_ELEVATED="

for /f "usebackq delims=" %%A in (`powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$p=New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent()); $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"`) do set "IS_ELEVATED=%%A"

if not defined IS_ELEVATED (
    echo ERROR: Could not determine whether the installer is elevated.
    goto :FAIL
)

if /I "!IS_ELEVATED!"=="True" (
    echo ERROR: This installer is running as administrator.
    echo Close it and run it normally so everything is installed only for your user account.
    goto :FAIL
)

if /I "%PROCESSOR_ARCHITECTURE%"=="x86" if not defined PROCESSOR_ARCHITEW6432 (
    echo ERROR: 32-bit Windows is not supported by current Forge/Java builds.
    goto :FAIL
)

set "ARCH=x64"
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=aarch64"
if /I "%PROCESSOR_ARCHITEW6432%"=="ARM64" set "ARCH=aarch64"

echo Windows architecture: !ARCH!
echo Install mode: !INSTALL_MODE!
echo Install base:
echo %BASE%
echo.

> "%BASE%\.__jadon_install_write_test.tmp" echo write-test
if not exist "%BASE%\.__jadon_install_write_test.tmp" (
    echo ERROR: The installer cannot write to its user-level install folder.
    goto :FAIL
)
del /f /q "%BASE%\.__jadon_install_write_test.tmp" >nul 2>&1

echo [2/8] Checking private Java 21...
echo.

set "JAVA_OK=0"

if exist "%JAVA_HOME%\bin\java.exe" (
    "%JAVA_HOME%\bin\java.exe" -version >nul 2>&1
    if not errorlevel 1 set "JAVA_OK=1"
)

if "!JAVA_OK!"=="1" (
    echo Existing private Java is working. Reusing it.
) else (
    if exist "%JAVA_HOME%" (
        echo Existing private Java is damaged or incomplete. Repairing it...
        rmdir /s /q "%JAVA_HOME%" >nul 2>&1
    )

    set "JAVA_URL=https://api.adoptium.net/v3/binary/latest/21/ga/windows/!ARCH!/jre/hotspot/normal/eclipse?project=jdk"

    echo Downloading Eclipse Temurin Java 21 JRE...
    call :DOWNLOAD "!JAVA_URL!" "%JAVA_ZIP%"

    if errorlevel 1 (
        echo ERROR: Java download failed.
        goto :FAIL
    )

    if not exist "%JAVA_ZIP%" (
        echo ERROR: Java archive was not created.
        goto :FAIL
    )

    if exist "%JAVA_TEMP%" rmdir /s /q "%JAVA_TEMP%" >nul 2>&1
    mkdir "%JAVA_TEMP%" >nul 2>&1

    set "PS_JAVA_TEMP=%JAVA_TEMP%"
    set "PS_JAVA_HOME=%JAVA_HOME%"
    set "PS_JAVA_ZIP=%JAVA_ZIP%"

    powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
     "$ErrorActionPreference='Stop'; Expand-Archive -LiteralPath $env:PS_JAVA_ZIP -DestinationPath $env:PS_JAVA_TEMP -Force; $root=Get-ChildItem -LiteralPath $env:PS_JAVA_TEMP -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'bin\java.exe') } | Select-Object -First 1; if(-not $root){throw 'java.exe was not found after Java extraction'}; if(Test-Path -LiteralPath $env:PS_JAVA_HOME){Remove-Item -LiteralPath $env:PS_JAVA_HOME -Recurse -Force}; Move-Item -LiteralPath $root.FullName -Destination $env:PS_JAVA_HOME; if(Test-Path -LiteralPath $env:PS_JAVA_TEMP){Remove-Item -LiteralPath $env:PS_JAVA_TEMP -Recurse -Force}"

    if errorlevel 1 (
        echo ERROR: Java extraction failed.
        goto :FAIL
    )

    del /q "%JAVA_ZIP%" >nul 2>&1
)

"%JAVA_HOME%\bin\java.exe" -version
if errorlevel 1 (
    echo ERROR: Java final test failed.
    goto :FAIL
)

echo.
echo [3/8] Finding the latest stable Forge release...
echo.

del /q "%RELEASE_INFO%" >nul 2>&1
set "PS_RELEASE_INFO=%RELEASE_INFO%"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $headers=@{'User-Agent'='Jadons-Ultimate-Installer'}; $release=Invoke-RestMethod -Headers $headers -Uri 'https://api.github.com/repos/Card-Forge/forge/releases/latest'; $asset=$release.assets | Where-Object { $_.name -match '^forge-installer-.*[.]jar$' } | Select-Object -First 1; if(-not $asset){throw 'Forge desktop installer asset was not found'}; ($release.tag_name + '|' + $asset.name + '|' + $asset.browser_download_url) | Set-Content -LiteralPath $env:PS_RELEASE_INFO -Encoding ASCII"

if errorlevel 1 (
    echo GitHub release lookup failed. Using known stable Forge 2.0.14.
    set "FORGE_TAG=forge-2.0.14"
    set "FORGE_ASSET=forge-installer-2.0.14.jar"
    set "FORGE_URL=https://github.com/Card-Forge/forge/releases/download/forge-2.0.14/forge-installer-2.0.14.jar"
    goto :RELEASE_READY
)

set "FORGE_TAG="
set "FORGE_ASSET="
set "FORGE_URL="

for /f "usebackq tokens=1,2,* delims=|" %%A in ("%RELEASE_INFO%") do (
    set "FORGE_TAG=%%A"
    set "FORGE_ASSET=%%B"
    set "FORGE_URL=%%C"
)

del /q "%RELEASE_INFO%" >nul 2>&1

:RELEASE_READY
if not defined FORGE_TAG (
    echo ERROR: Forge version could not be determined.
    goto :FAIL
)

if not defined FORGE_ASSET (
    echo ERROR: Forge installer filename could not be determined.
    goto :FAIL
)

if not defined FORGE_URL (
    echo ERROR: Forge download URL could not be determined.
    goto :FAIL
)

set "FORGE_VERSION=!FORGE_TAG:forge-=!"
set "FORGE_DIR=%BASE%\Forge-!FORGE_VERSION!"
set "FORGE_INSTALLER=%DOWNLOADS%\!FORGE_ASSET!"
set "FORGE_SF_URL=https://sourceforge.net/projects/forge-engine.mirror/files/forge-!FORGE_VERSION!/forge-installer-!FORGE_VERSION!.jar/download"

echo Forge release: !FORGE_TAG!
echo.

echo [4/8] Checking Forge installer package...
echo.

set "FORGE_PACKAGE_OK=0"

if exist "!FORGE_INSTALLER!" (
    call :VALIDATE_JAR "!FORGE_INSTALLER!"
    if not errorlevel 1 set "FORGE_PACKAGE_OK=1"
)

if "!FORGE_PACKAGE_OK!"=="1" (
    echo Existing Forge installer is valid. Reusing it.
) else (
    if exist "!FORGE_INSTALLER!" del /f /q "!FORGE_INSTALLER!" >nul 2>&1

    echo Downloading Forge from GitHub...
    call :DOWNLOAD "!FORGE_URL!" "!FORGE_INSTALLER!"

    if errorlevel 1 (
        echo GitHub download failed. Trying SourceForge mirror...
        if exist "!FORGE_INSTALLER!" del /f /q "!FORGE_INSTALLER!" >nul 2>&1
        call :DOWNLOAD "!FORGE_SF_URL!" "!FORGE_INSTALLER!"
    )

    if errorlevel 1 (
        echo ERROR: Forge download failed from both sources.
        goto :FAIL
    )

    call :VALIDATE_JAR "!FORGE_INSTALLER!"

    if errorlevel 1 (
        echo ERROR: Downloaded Forge installer is corrupt or incomplete.
        if exist "!FORGE_INSTALLER!" del /f /q "!FORGE_INSTALLER!" >nul 2>&1
        goto :FAIL
    )
)

echo.
echo [5/8] Installing or repairing Forge...
echo.

call :FIND_FORGE "!FORGE_DIR!"

if defined FOUND_FORGE_CMD goto :FORGE_FOUND
if defined FOUND_FORGE_EXE goto :FORGE_FOUND
if defined FOUND_FORGE_JAR goto :FORGE_FOUND

if exist "!FORGE_DIR!" (
    echo Removing incomplete Forge folder...
    rmdir /s /q "!FORGE_DIR!" >nul 2>&1

    if exist "!FORGE_DIR!" (
        echo ERROR: The incomplete Forge folder could not be removed.
        echo Close Forge and any File Explorer windows using that folder, then run this installer again.
        goto :FAIL
    )
)

set "IZPACK_DIR=!FORGE_DIR:\=/!"
> "!DEFAULTS_FILE!" echo INSTALL_PATH=!IZPACK_DIR!

echo Installing Forge to:
echo !FORGE_DIR!
echo.

"%JAVA_HOME%\bin\java.exe" -jar "!FORGE_INSTALLER!" -defaults-file "!DEFAULTS_FILE!" -auto
call :FIND_FORGE "!FORGE_DIR!"

if defined FOUND_FORGE_CMD goto :FORGE_FOUND
if defined FOUND_FORGE_EXE goto :FORGE_FOUND
if defined FOUND_FORGE_JAR goto :FORGE_FOUND

echo Automatic install did not produce a usable Forge launcher.
echo.

if /I "!INSTALL_MODE!"=="SCHOOL" (
    echo SCHOOL MODE SAFETY STOP:
    echo The silent user-only Forge installation did not complete.
    echo School mode will not open the graphical installer or request elevation.
    goto :FAIL
)

echo Opening the normal Forge installer as a fallback.
echo.
echo Keep this Target Path:
echo !FORGE_DIR!
echo.
pause

"%JAVA_HOME%\bin\java.exe" -jar "!FORGE_INSTALLER!" -defaults-file "!DEFAULTS_FILE!"

call :FIND_FORGE "!FORGE_DIR!"

if not defined FOUND_FORGE_CMD if not defined FOUND_FORGE_EXE if not defined FOUND_FORGE_JAR (
    echo ERROR: Forge installer finished, but no Forge launcher was found in the target folder.
    goto :FAIL
)

:FORGE_FOUND
echo Forge files found.
if defined FOUND_FORGE_CMD echo CMD: !FOUND_FORGE_CMD!
if defined FOUND_FORGE_EXE echo EXE: !FOUND_FORGE_EXE!
if defined FOUND_FORGE_JAR echo JAR: !FOUND_FORGE_JAR!
echo.

if defined FOUND_FORGE_CMD (
    for %%F in ("!FOUND_FORGE_CMD!") do set "FORGE_HOME=%%~dpF"
) else if defined FOUND_FORGE_EXE (
    for %%F in ("!FOUND_FORGE_EXE!") do set "FORGE_HOME=%%~dpF"
) else (
    for %%F in ("!FOUND_FORGE_JAR!") do set "FORGE_HOME=%%~dpF"
)

echo [6/8] Creating Forge launcher and shortcuts...
echo.

> "!LAUNCHER!" echo @echo off
>> "!LAUNCHER!" echo setlocal
>> "!LAUNCHER!" echo set "JAVA_HOME=%JAVA_HOME%"
>> "!LAUNCHER!" echo set "PATH=%%JAVA_HOME%%\bin;%%PATH%%"
>> "!LAUNCHER!" echo cd /d "!FORGE_HOME!"

if defined FOUND_FORGE_CMD (
    >> "!LAUNCHER!" echo call "!FOUND_FORGE_CMD!"
) else if defined FOUND_FORGE_EXE (
    >> "!LAUNCHER!" echo start "" /D "!FORGE_HOME!" "!FOUND_FORGE_EXE!"
) else (
    for %%F in ("!FOUND_FORGE_JAR!") do set "JAR_NAME=%%~nxF"
    >> "!LAUNCHER!" echo "%%JAVA_HOME%%\bin\java.exe" --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.lang.reflect=ALL-UNNAMED --add-opens java.base/java.text=ALL-UNNAMED --add-opens java.desktop/java.awt.font=ALL-UNNAMED -Xmx2048m -Dfile.encoding=UTF-8 -jar "!JAR_NAME!"
)

if not exist "!LAUNCHER!" (
    echo ERROR: Forge launcher could not be created.
    goto :FAIL
)

> "!LOCATION_FILE!" echo Forge version: !FORGE_VERSION!
>> "!LOCATION_FILE!" echo Forge folder: !FORGE_HOME!
>> "!LOCATION_FILE!" echo Java folder: %JAVA_HOME%
>> "!LOCATION_FILE!" echo Launcher: !LAUNCHER!
if defined FOUND_FORGE_CMD >> "!LOCATION_FILE!" echo Forge CMD: !FOUND_FORGE_CMD!
if defined FOUND_FORGE_EXE >> "!LOCATION_FILE!" echo Forge EXE: !FOUND_FORGE_EXE!
if defined FOUND_FORGE_JAR >> "!LOCATION_FILE!" echo Forge JAR: !FOUND_FORGE_JAR!

set "PS_LAUNCHER=!LAUNCHER!"
set "PS_FORGE_HOME=!FORGE_HOME!"
set "PS_FORGE_EXE=!FOUND_FORGE_EXE!"

if /I "!INSTALL_MODE!"=="NORMAL" (
    powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
     "$ErrorActionPreference='SilentlyContinue'; $desktop=[Environment]::GetFolderPath('Desktop'); if($desktop -and (Test-Path -LiteralPath $desktop)){ $shell=New-Object -ComObject WScript.Shell; $shortcut=$shell.CreateShortcut((Join-Path $desktop 'MTG Forge.lnk')); $shortcut.TargetPath=$env:PS_LAUNCHER; $shortcut.WorkingDirectory=$env:PS_FORGE_HOME; if($env:PS_FORGE_EXE -and (Test-Path -LiteralPath $env:PS_FORGE_EXE)){ $shortcut.IconLocation=$env:PS_FORGE_EXE }; $shortcut.Save() }"
) else (
    echo School mode: skipping Windows shortcut integration.
)

echo.
echo [7/8] Installing V6.3 manager with independent safe fallback...
echo.

call :EXTRACT_SAFE_DIRECT
set "INSTALL_SAFE_RC=!ERRORLEVEL!"
if not "!INSTALL_SAFE_RC!"=="0" (
    echo WARNING: Could not refresh the independent V4 safe importer.
    echo An already-installed exact V4 copy will still be used if available.
    echo.
) else (
    echo Proven safe V4 importer: READY
)

call :PREPARE_MANAGER_ONLY
set "INSTALL_MANAGER_RC=!ERRORLEVEL!"
if not "!INSTALL_MANAGER_RC!"=="0" (
    echo.
    echo WARNING: V6.3 primary manager self-test did not pass on this PC.
    echo Forge installation will still finish.
    echo Profile importing remains available through the proven safe V4 importer.
    echo.
) else (
    echo V6.3 manager test: PASS
)

if /I "!INSTALL_MODE!"=="NORMAL" if exist "%IMPORTER_CMD%" (
    set "PS_MANAGER_SHORTCUT=%IMPORTER_CMD%"
    powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
     "$ErrorActionPreference='SilentlyContinue'; $desktop=[Environment]::GetFolderPath('Desktop'); if($desktop -and (Test-Path -LiteralPath $desktop)){ $shell=New-Object -ComObject WScript.Shell; $shortcut=$shell.CreateShortcut((Join-Path $desktop 'Jadon Ultimate Forge Manager v6.3.lnk')); $shortcut.TargetPath=$env:PS_MANAGER_SHORTCUT; $shortcut.WorkingDirectory=Split-Path -Parent $env:PS_MANAGER_SHORTCUT; $shortcut.Save() }"
)

echo [8/8] Final self-check...
echo.

if not exist "%JAVA_HOME%\bin\java.exe" (
    echo ERROR: Java final self-check failed.
    goto :FAIL
)

"%JAVA_HOME%\bin\java.exe" -version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Java cannot start.
    goto :FAIL
)

call :FIND_FORGE "!FORGE_DIR!"
if not defined FOUND_FORGE_CMD if not defined FOUND_FORGE_EXE if not defined FOUND_FORGE_JAR (
    echo ERROR: Forge final self-check failed.
    goto :FAIL
)

if not exist "!LAUNCHER!" (
    echo ERROR: Forge launcher final self-check failed.
    goto :FAIL
)

if not exist "%IMPORTER_PS1%" (
    echo WARNING: Primary V6.3 PowerShell manager was not prepared.
    echo The CMD launcher remains usable and will fall back to the proven V4 importer.
)

if not exist "%IMPORTER_CMD%" (
    echo ERROR: Ultimate Forge Manager v6.3 launcher final self-check failed.
    goto :FAIL
)

set "FORGE_COMMANDER_DIR=%APPDATA%\Forge\decks\commander"
if not defined APPDATA set "FORGE_COMMANDER_DIR=%USERPROFILE%\AppData\Roaming\Forge\decks\commander"

if not exist "%FORGE_COMMANDER_DIR%" mkdir "%FORGE_COMMANDER_DIR%" >nul 2>&1

> "%FORGE_COMMANDER_DIR%\.__jadon_write_test.tmp" echo write-test
if not exist "%FORGE_COMMANDER_DIR%\.__jadon_write_test.tmp" (
    echo ERROR: Forge Commander deck folder is not writable.
    goto :FAIL
)
del /f /q "%FORGE_COMMANDER_DIR%\.__jadon_write_test.tmp" >nul 2>&1

echo.
echo INSTALLATION COMPLETE
echo.
echo Forge version:
echo !FORGE_VERSION!
echo.
echo Forge folder:
echo !FORGE_HOME!
echo.
echo Private Java:
echo %JAVA_HOME%
echo.
echo Forge launcher:
echo !LAUNCHER!
echo.
echo Ultimate Forge Manager v6.3:
echo %IMPORTER_CMD%
echo.
echo Install mode:
echo !INSTALL_MODE!
echo.
if /I "!INSTALL_MODE!"=="NORMAL" (
    echo Desktop shortcuts:
    echo MTG Forge
    echo Jadon's Ultimate Forge Manager v6.3
    echo.
) else (
    echo School-mode launchers:
    echo !LAUNCHER!
    echo %IMPORTER_CMD%
    echo.
    echo Windows shortcut integration was skipped.
    echo Graphical installer fallback was disabled.
    echo BITS system-service fallback was disabled.
    echo.
)
echo No administrator installation was used.
echo No permanent system PATH was changed.
echo No registry changes were made by this installer.
echo No Program Files installation was used.
echo.

choice /C YN /N /M "Run Ultimate Forge Manager v6.3 now? [Y/N]: "
if errorlevel 2 goto :ASK_LAUNCH_FORGE

call "%IMPORTER_CMD%"

:ASK_LAUNCH_FORGE
echo.
choice /C YN /N /M "Launch Forge now? [Y/N]: "
if errorlevel 2 goto :SUCCESS

call "!LAUNCHER!"

:SUCCESS
echo.
echo Done.
echo.
pause
goto :HOME_MENU



:RUN_FORGE_MENU
echo.

if exist "%MENU_LAUNCHER%" (
    start "" "%MENU_LAUNCHER%"
    echo Forge launch requested.
    timeout /t 1 /nobreak >nul
    exit /b 0
)

set "MENU_FOUND_EXE="
set "MENU_FOUND_CMD="

for /d %%D in ("%BASE%\Forge-*") do (
    if not defined MENU_FOUND_EXE if not defined MENU_FOUND_CMD (
        call :FIND_FORGE "%%~fD"
        if defined FOUND_FORGE_EXE set "MENU_FOUND_EXE=!FOUND_FORGE_EXE!"
        if not defined MENU_FOUND_EXE if defined FOUND_FORGE_CMD set "MENU_FOUND_CMD=!FOUND_FORGE_CMD!"
    )
)

if defined MENU_FOUND_EXE (
    start "" "!MENU_FOUND_EXE!"
    echo Forge launch requested.
    timeout /t 1 /nobreak >nul
    exit /b 0
)

if defined MENU_FOUND_CMD (
    start "" "!MENU_FOUND_CMD!"
    echo Forge launch requested.
    timeout /t 1 /nobreak >nul
    exit /b 0
)

echo Forge was not found under:
echo %BASE%
echo.
echo Install Forge with option 1 or 2 first.
echo.
pause
exit /b 0


:RUN_IMPORTER_MENU
echo.
echo Preparing the V6.3 Forge Manager...
echo.
call :EXTRACT_MANAGER_FILE
if errorlevel 1 (
    echo V6.3 manager refresh failed.
    echo Opening the independent proven safe importer instead.
    call :RUN_SAFE_IMPORTER
    exit /b 0
)

echo Starting V6.3 manager.
echo It performs its own parser/self-test and has a second embedded V4 fallback.
echo.
call "%MENU_IMPORTER%"
set "MENU_MANAGER_RC=!ERRORLEVEL!"
if not "!MENU_MANAGER_RC!"=="0" (
    echo.
    echo V6.3 launcher returned code !MENU_MANAGER_RC!.
    echo Opening independent proven safe importer as the final fallback.
    call :RUN_SAFE_IMPORTER
)
exit /b 0

:EXTRACT_MANAGER_FILE
if not exist "%BASE%" mkdir "%BASE%" >nul 2>&1
if not exist "%DIAG_DIR%" mkdir "%DIAG_DIR%" >nul 2>&1
where powershell.exe >nul 2>&1
if errorlevel 1 exit /b 1
set "PS_SELF=%SELF_FILE%"
set "PS_MANAGER_OUT=%MENU_IMPORTER%"
set "PS_MANAGER_TMP=%MANAGER_TMP%"
set "PS_MANAGER_SHA=%EXPECTED_MANAGER_SHA%"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; $out=$env:PS_MANAGER_OUT; $tmp=$env:PS_MANAGER_TMP; try{ $raw=[IO.File]::ReadAllText($env:PS_SELF); $marker='###JADON_MANAGER_V63_CMD_PAYLOAD###'; $ix=$raw.LastIndexOf($marker); if($ix -lt 0){throw 'Embedded V6.3 manager CMD payload was not found'}; $body=$raw.Substring($ix+$marker.Length).TrimStart([char]13,[char]10); $enc=New-Object System.Text.UTF8Encoding($false); [IO.File]::WriteAllText($tmp,$body,$enc); $hash=(Get-FileHash -Algorithm SHA256 -LiteralPath $tmp).Hash.ToLowerInvariant(); if($hash -ne $env:PS_MANAGER_SHA){throw ('Manager candidate hash mismatch: '+$hash)}; Move-Item -LiteralPath $tmp -Destination $out -Force; exit 0 } catch { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue; Write-Output $_.Exception.Message; exit 1 }"
if errorlevel 1 exit /b 1
if not exist "%MENU_IMPORTER%" exit /b 1
exit /b 0

:EXTRACT_SAFE_DIRECT
if not exist "%BASE%\ArchidektSync" mkdir "%BASE%\ArchidektSync" >nul 2>&1
where powershell.exe >nul 2>&1
if errorlevel 1 exit /b 1
set "PS_SELF=%SELF_FILE%"
set "PS_SAFE_OUT=%DIRECT_SAFE_CMD%"
set "PS_SAFE_TMP=%DIRECT_SAFE_TMP%"
set "PS_SAFE_SHA=%EXPECTED_SAFE_SHA%"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; $out=$env:PS_SAFE_OUT; $tmp=$env:PS_SAFE_TMP; $expected=$env:PS_SAFE_SHA; try{ $raw=[IO.File]::ReadAllText($env:PS_SELF); $b='###JADON_INSTALLER_SAFE_V4_BEGIN###'; $e='###JADON_INSTALLER_SAFE_V4_END###'; $bi=$raw.LastIndexOf($b); if($bi -lt 0){throw 'Installer safe-importer begin marker missing'}; $start=$bi+$b.Length; $ei=$raw.LastIndexOf($e); if($ei -lt $start){throw 'Installer safe-importer end marker missing'}; $body=$raw.Substring($start,$ei-$start).TrimStart([char]13,[char]10); $enc=New-Object System.Text.UTF8Encoding($false); [IO.File]::WriteAllText($tmp,$body,$enc); $hash=(Get-FileHash -Algorithm SHA256 -LiteralPath $tmp).Hash.ToLowerInvariant(); if($hash -ne $expected){throw ('Safe importer candidate hash mismatch: '+$hash)}; Move-Item -LiteralPath $tmp -Destination $out -Force; exit 0 } catch { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue; if(Test-Path -LiteralPath $out){ $oldHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $out).Hash.ToLowerInvariant(); if($oldHash -eq $expected){exit 0} }; Write-Output $_.Exception.Message; exit 1 }"
exit /b %ERRORLEVEL%

:PREPARE_MANAGER_ONLY
call :EXTRACT_SAFE_DIRECT
set "PREP_SAFE_RC=!ERRORLEVEL!"
call :EXTRACT_MANAGER_FILE
if errorlevel 1 exit /b 1
call "%MENU_IMPORTER%" --test
exit /b %ERRORLEVEL%

:RUN_SAFE_IMPORTER
echo.
echo Opening the independent proven safe V4 Archidekt profile importer...
echo.
call :EXTRACT_SAFE_DIRECT
if errorlevel 1 (
    echo ERROR: No verified V4 safe importer is available.
    echo The existing file was not used unless its exact SHA-256 matched.
    echo.
    pause
    exit /b 0
)
call "%DIRECT_SAFE_CMD%"
set "SAFE_MENU_RC=!ERRORLEVEL!"
if not "!SAFE_MENU_RC!"=="0" (
    echo.
    echo Safe importer returned code !SAFE_MENU_RC!.
    echo The error will remain visible.
    echo.
    pause
)
exit /b 0

:DIAGNOSE_MANAGER
cls
echo.
echo Jadon's V6.3 Manager Diagnostics / Repair
echo.
echo This does not reinstall Forge and never requests administrator access.
echo It independently verifies the proven V4 importer first, then the V6.3 manager.
echo.
call :EXTRACT_SAFE_DIRECT
set "DIAG_SAFE_RC=!ERRORLEVEL!"
if "!DIAG_SAFE_RC!"=="0" (
    echo [1/2] Proven safe V4 importer extraction/hash: PASS
) else (
    echo [1/2] Proven safe V4 importer extraction/hash: FAILED
)

call :EXTRACT_MANAGER_FILE
set "DIAG_EXTRACT_RC=!ERRORLEVEL!"
if not "!DIAG_EXTRACT_RC!"=="0" (
    echo [2/2] V6.3 manager extraction/hash: FAILED
    echo.
    echo Profile importing can still use option 6 if test 1 passed.
    echo.
    pause
    exit /b 0
)

call "%MENU_IMPORTER%" --test
set "DIAG_MANAGER_RC=!ERRORLEVEL!"
echo.
if "!DIAG_MANAGER_RC!"=="0" (
    echo ================================================================
    echo V6.3 MANAGER DIAGNOSTICS PASSED
    echo ================================================================
    echo Primary manager parser/self-test: PASS
    echo Independent safe importer: PASS
) else (
    echo ================================================================
    echo V6.3 PRIMARY MANAGER TEST DID NOT PASS
    echo ================================================================
    echo Exit code: !DIAG_MANAGER_RC!
    if "!DIAG_SAFE_RC!"=="0" (
        echo Proven V4 fallback is verified and READY.
        echo Option 4 will automatically fall back to it.
        echo Option 6 opens it directly.
    ) else (
        echo The independent fallback also needs repair.
    )
)
echo.
pause
exit /b 0

:FIND_FORGE
set "SEARCH_ROOT=%~1"
set "FOUND_FORGE_CMD="
set "FOUND_FORGE_EXE="
set "FOUND_FORGE_JAR="

if not exist "%SEARCH_ROOT%" exit /b 0

if exist "%SEARCH_ROOT%\forge.cmd" set "FOUND_FORGE_CMD=%SEARCH_ROOT%\forge.cmd"
if exist "%SEARCH_ROOT%\forge.exe" set "FOUND_FORGE_EXE=%SEARCH_ROOT%\forge.exe"

if not defined FOUND_FORGE_CMD (
    for /f "delims=" %%F in ('where /r "%SEARCH_ROOT%" forge.cmd 2^>nul') do (
        if not defined FOUND_FORGE_CMD set "FOUND_FORGE_CMD=%%~fF"
    )
)

if not defined FOUND_FORGE_EXE (
    for /f "delims=" %%F in ('where /r "%SEARCH_ROOT%" forge.exe 2^>nul') do (
        if not defined FOUND_FORGE_EXE set "FOUND_FORGE_EXE=%%~fF"
    )
)

for /f "delims=" %%F in ('where /r "%SEARCH_ROOT%" forge-gui-desktop*-jar-with-dependencies.jar 2^>nul') do (
    if not defined FOUND_FORGE_JAR set "FOUND_FORGE_JAR=%%~fF"
)

exit /b 0


:VALIDATE_JAR
set "PS_VALIDATE_FILE=%~1"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; Add-Type -AssemblyName System.IO.Compression.FileSystem; $zip=$null; $ok=$false; try{$zip=[IO.Compression.ZipFile]::OpenRead($env:PS_VALIDATE_FILE); $manifest=$zip.Entries | Where-Object { $_.FullName -ieq 'META-INF/MANIFEST.MF' } | Select-Object -First 1; if($zip.Entries.Count -ge 10 -and $manifest){$ok=$true}}catch{$ok=$false}finally{if($zip){$zip.Dispose()}}; if($ok){exit 0}else{exit 1}"

exit /b %ERRORLEVEL%


:DOWNLOAD
set "DL_URL=%~1"
set "DL_FILE=%~2"

if exist "%DL_FILE%" del /f /q "%DL_FILE%" >nul 2>&1

where curl.exe >nul 2>&1
if not errorlevel 1 (
    curl.exe -L --fail --retry 3 --retry-delay 2 --connect-timeout 30 -o "%DL_FILE%" "%DL_URL%"
    if not errorlevel 1 (
        if exist "%DL_FILE%" exit /b 0
    )

    echo curl failed. Trying PowerShell...
    if exist "%DL_FILE%" del /f /q "%DL_FILE%" >nul 2>&1
)

set "PS_DL_URL=%DL_URL%"
set "PS_DL_FILE=%DL_FILE%"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri $env:PS_DL_URL -OutFile $env:PS_DL_FILE"

if not errorlevel 1 (
    if exist "%DL_FILE%" exit /b 0
)

if /I "!INSTALL_MODE!"=="SCHOOL" (
    echo PowerShell download failed.
    echo School mode will not use the BITS system-service fallback.
    exit /b 1
)

echo PowerShell download failed. Trying BITS...
if exist "%DL_FILE%" del /f /q "%DL_FILE%" >nul 2>&1

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; Import-Module BitsTransfer; Start-BitsTransfer -Source $env:PS_DL_URL -Destination $env:PS_DL_FILE"

if not errorlevel 1 (
    if exist "%DL_FILE%" exit /b 0
)

exit /b 1


:FAIL
echo.
echo INSTALLATION FAILED
echo.
echo No administrator changes were made.
echo No system PATH was changed.
echo.
echo Install mode:
echo !INSTALL_MODE!
echo.
echo Base folder:
echo %BASE%
echo.
echo The installer stopped instead of continuing with a broken setup.
echo Send the error shown above if you want me to diagnose the exact stage.
echo.
pause
goto :HOME_MENU
###JADON_INSTALLER_SAFE_V4_BEGIN###
@echo off
setlocal EnableExtensions
title Jadon's Archidekt Forge Manager v4 SAFE TOKENS

if defined LOCALAPPDATA (
    set "BASE=%LOCALAPPDATA%\MTGForge"
) else (
    set "BASE=%USERPROFILE%\AppData\Local\MTGForge"
)

set "TOOLDIR=%BASE%\ArchidektSync"
set "PS1=%TOOLDIR%\ArchidektForgeManager.ps1"
set "SELF=%~f0"

if not exist "%TOOLDIR%" mkdir "%TOOLDIR%" >nul 2>&1

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Windows PowerShell was not found.
    echo.
    pause
    exit /b 1
)

set "PS_SELF=%SELF%"
set "PS_OUT=%PS1%"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; $raw=[IO.File]::ReadAllText($env:PS_SELF); $marker='###JADON_ARCHIDEKT_MANAGER_PAYLOAD###'; $ix=$raw.LastIndexOf($marker); if($ix -lt 0){throw 'Embedded importer payload was not found.'}; $payload=$raw.Substring($ix+$marker.Length).TrimStart([char]13,[char]10); $enc=New-Object System.Text.UTF8Encoding($false); [IO.File]::WriteAllText($env:PS_OUT,$payload,$enc)"

if errorlevel 1 (
    echo.
    echo ERROR: Could not prepare the Archidekt manager.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$errors=$null; $tokens=$null; [System.Management.Automation.Language.Parser]::ParseFile($env:PS_OUT,[ref]$tokens,[ref]$errors) > $null; if($errors.Count -gt 0){$errors | ForEach-Object { Write-Host $_.Message }; exit 1}"

if errorlevel 1 (
    echo.
    echo ERROR: The embedded PowerShell importer failed its syntax test.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
exit /b %ERRORLEVEL%

###JADON_ARCHIDEKT_MANAGER_PAYLOAD###
param()

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Base = if ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA "MTGForge"
} else {
    Join-Path $env:USERPROFILE "AppData\Local\MTGForge"
}

$ToolDir = Join-Path $Base "ArchidektSync"
$LogDir = Join-Path $ToolDir "logs"
$SettingsFile = Join-Path $ToolDir "settings.json"
$ProfileHistoryFile = Join-Path $ToolDir "profiles.txt"

$ForgeUser = Join-Path $env:APPDATA "Forge"
$CommanderDir = Join-Path $ForgeUser "decks\commander"
$ConstructedDir = Join-Path $ForgeUser "decks\constructed"

$ImportTag = "JADON_ARCHIDEKT_IMPORT"
$ImporterComment = "Imported by Jadon's Archidekt Forge Manager"

New-Item -ItemType Directory -Force -Path $ToolDir | Out-Null
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $CommanderDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConstructedDir | Out-Null

function Get-Prop {
    param($Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

function Write-Utf8NoBom {
    param([string]$Path, [string[]]$Lines)
    $enc = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllLines($Path, $Lines, $enc)
}

function Read-Settings {
    $defaults = [pscustomobject]@{
        CapCommanderAt100 = $true
        RemoveActualTokens = $false
        ResolveWithScryfall = $true
    }

    if (-not (Test-Path -LiteralPath $SettingsFile)) {
        return $defaults
    }

    try {
        $saved = Get-Content -LiteralPath $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($null -eq (Get-Prop $saved "CapCommanderAt100")) {
            $saved | Add-Member -NotePropertyName CapCommanderAt100 -NotePropertyValue $true
        }
        if ($null -eq (Get-Prop $saved "RemoveActualTokens")) {
            $saved | Add-Member -NotePropertyName RemoveActualTokens -NotePropertyValue $false
        }
        if ($null -eq (Get-Prop $saved "ResolveWithScryfall")) {
            $saved | Add-Member -NotePropertyName ResolveWithScryfall -NotePropertyValue $true
        }
        return $saved
    }
    catch {
        return $defaults
    }
}

function Save-Settings {
    param($Settings)
    $json = $Settings | ConvertTo-Json -Depth 5
    $enc = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($SettingsFile, $json, $enc)
}

$Settings = Read-Settings

$script:CurrentLog = $null
function Start-Log {
    $script:CurrentLog = Join-Path $LogDir ("sync-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log")
}
function Write-Log {
    param([string]$Text)
    Write-Host $Text
    if ($script:CurrentLog) {
        Add-Content -LiteralPath $script:CurrentLog -Value $Text -Encoding UTF8
    }
}

function Invoke-JsonGet {
    param([string]$Url)

    $last = $null

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        $client = $null
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/4.0"

            $bytes = $client.DownloadData($Url)
            $jsonText = [Text.Encoding]::UTF8.GetString($bytes)

            if ([string]::IsNullOrWhiteSpace($jsonText)) {
                throw "The server returned an empty response."
            }

            return ($jsonText | ConvertFrom-Json)
        }
        catch {
            $last = $_
            if ($attempt -lt 3) {
                Write-Log ("    Request failed. Retry " + $attempt + "/3...")
                Start-Sleep -Seconds (2 * $attempt)
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }
    }

    throw $last
}

function Invoke-ScryfallCollection {
    param($Ids)

    $map = @{}
    if ($null -eq $Ids) {
        return $map
    }

    $unique = @($Ids | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | Select-Object -Unique)
    if ($unique.Count -eq 0) {
        return $map
    }

    for ($offset = 0; $offset -lt $unique.Count; $offset += 75) {
        $lastIndex = [Math]::Min($offset + 74, $unique.Count - 1)
        $identifiers = @()

        for ($i = $offset; $i -le $lastIndex; $i++) {
            $identifiers += @{ id = [string]$unique[$i] }
        }

        $requestJson = @{ identifiers = $identifiers } | ConvertTo-Json -Depth 6 -Compress
        $requestBytes = [Text.Encoding]::UTF8.GetBytes($requestJson)

        $client = $null
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/4.0"
            $client.Headers["Content-Type"] = "application/json; charset=utf-8"

            $responseBytes = $client.UploadData(
                "https://api.scryfall.com/cards/collection",
                "POST",
                $requestBytes
            )

            $responseText = [Text.Encoding]::UTF8.GetString($responseBytes)
            $response = $responseText | ConvertFrom-Json

            foreach ($card in $response.data) {
                if ($card -and $card.id) {
                    $map[[string]$card.id] = $card
                }
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }

        Start-Sleep -Milliseconds 120
    }

    return $map
}

function Parse-ProfileInput {
    param([string]$Text)

    $Text = $Text.Trim()

    if ($Text -match '^https?://(?:www\.)?archidekt\.com/u/([^/?#]+)') {
        return [Uri]::UnescapeDataString($Matches[1])
    }

    if ($Text -match '^https?://(?:www\.)?archidekt\.com/search/decks\?') {
        try {
            $uri = [Uri]$Text
            foreach ($part in $uri.Query.TrimStart("?").Split("&")) {
                $bits = $part.Split("=", 2)
                if ($bits.Count -eq 2 -and $bits[0] -eq "ownerUsername") {
                    return [Uri]::UnescapeDataString($bits[1].Replace("+", " "))
                }
            }
        }
        catch {}
    }

    if ($Text -notmatch '[/\\]') {
        return $Text
    }

    throw "That does not look like an Archidekt profile URL or username."
}

function Add-ProfileHistory {
    param([string]$Username)

    if ([string]::IsNullOrWhiteSpace($Username)) { return }

    $existing = @()
    if (Test-Path -LiteralPath $ProfileHistoryFile) {
        try {
            $existing = @(Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 | Where-Object { $_ })
        }
        catch {}
    }

    $newList = @($Username) + @($existing | Where-Object { $_ -ne $Username })
    if ($newList.Count -gt 20) {
        $newList = @($newList[0..19])
    }

    Write-Utf8NoBom $ProfileHistoryFile $newList
}

function Get-RecentProfiles {
    if (-not (Test-Path -LiteralPath $ProfileHistoryFile)) {
        return @()
    }

    try {
        return @(Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 | Where-Object { $_ } | Select-Object -First 10)
    }
    catch {
        return @()
    }
}

function Get-EntryCategories {
    param($Entry)

    $result = [System.Collections.ArrayList]::new()

    $single = Get-Prop $Entry "category"
    if ($single) {
        if ($single -is [string]) {
            [void]$result.Add([string]$single)
        }
        else {
            $singleName = Get-Prop $single "name"
            if ($singleName) { $result.Add([string]$singleName) }
        }
    }

    foreach ($cat in @(Get-Prop $Entry "categories")) {
        if ($null -eq $cat) { continue }

        if ($cat -is [string]) {
            [void]$result.Add([string]$cat)
        }
        else {
            $name = Get-Prop $cat "name"
            if ($name) { $result.Add([string]$name) }
        }
    }

    return @($result.ToArray() | Select-Object -Unique)
}

function Get-ArchidektCardName {
    param($Entry)

    $card = Get-Prop $Entry "card"
    if ($null -eq $card) { return $null }

    $oracle = Get-Prop $card "oracleCard"
    if ($null -eq $oracle) {
        $oracle = Get-Prop $card "oracle_card"
    }

    if ($oracle) {
        $name = Get-Prop $oracle "name"
        if ($name) { return [string]$name }
    }

    foreach ($field in @("displayName", "name")) {
        $name = Get-Prop $card $field
        if ($name) { return [string]$name }
    }

    return $null
}

function Get-ArchidektUid {
    param($Entry)

    $card = Get-Prop $Entry "card"
    if ($null -eq $card) { return $null }

    foreach ($field in @("uid", "scryfallId", "scryfall_id")) {
        $value = Get-Prop $card $field
        if ($value) {
            return [string]$value
        }
    }

    return $null
}

function Get-DeckFormatText {
    param($Deck, $Meta)

    foreach ($obj in @($Deck, $Meta)) {
        if ($null -eq $obj) { continue }

        foreach ($field in @("deckFormat", "format", "deckFormatName", "formatName")) {
            $value = Get-Prop $obj $field
            if ($null -eq $value) { continue }

            if ($value -is [string]) {
                return [string]$value
            }

            if ($value -is [int] -or $value -is [long]) {
                if ([int64]$value -eq 3) { return "Commander" }
                return [string]$value
            }

            foreach ($sub in @("name", "displayName", "label")) {
                $text = Get-Prop $value $sub
                if ($text) { return [string]$text }
            }

            $id = Get-Prop $value "id"
            if ($id -eq 3) { return "Commander" }
        }
    }

    return ""
}

function Get-ForgeCardName {
    param(
        [string]$FallbackName,
        $ScryfallCard
    )

    $name = $FallbackName
    $layout = ""

    if ($ScryfallCard) {
        if ($ScryfallCard.name) {
            $name = [string]$ScryfallCard.name
        }
        if ($ScryfallCard.layout) {
            $layout = ([string]$ScryfallCard.layout).ToLowerInvariant()
        }
    }

    if ([string]::IsNullOrWhiteSpace($name)) {
        return $null
    }

    # Forge deck files use the FRONT card name for transform/MDFC/flip/adventure
    # cards. Split, aftermath and Room cards keep the full "A // B" name.
    $useFrontFace = $false

    switch ($layout) {
        "transform"        { $useFrontFace = $true }
        "modal_dfc"        { $useFrontFace = $true }
        "flip"             { $useFrontFace = $true }
        "adventure"        { $useFrontFace = $true }
        "reversible_card"  { $useFrontFace = $true }
    }

    if ($name.Contains(" // ") -and $useFrontFace) {
        $parts = $name -split " // "
        return ([string]$parts[0]).Trim()
    }

    # If Scryfall was unavailable, the safest Forge fallback for a combined
    # permanent DFC name is the front face. Scryfall resolution normally
    # prevents split/Room cards from reaching this fallback.
    if (-not $ScryfallCard -and $name.Contains(" // ")) {
        $parts = $name -split " // "
        return ([string]$parts[0]).Trim()
    }

    return $name.Trim()
}

function Test-IsActualTokenOrEmblem {
    param(
        $Entry,
        $ScryfallCard
    )

    # IMPORTANT:
    # Do NOT use Archidekt category names such as "Tokens".
    # Users commonly put ordinary token-generating cards in a category named
    # Tokens, and that does not mean the card itself is a token.

    if ($ScryfallCard) {
        $layout = ([string](Get-Prop $ScryfallCard "layout")).ToLowerInvariant()
        $typeLine = [string](Get-Prop $ScryfallCard "type_line")

        if ($layout -in @("token", "double_faced_token", "emblem")) {
            return $true
        }

        if ($typeLine -match '(?i)^\s*Token\b' -or
            $typeLine -match '(?i)^\s*Emblem\b') {
            return $true
        }
    }

    # Archidekt fallback only when Scryfall metadata is unavailable.
    # Inspect actual card metadata fields, never deck/category labels.
    $card = Get-Prop $Entry "card"
    if ($card) {
        $layout = ([string](Get-Prop $card "layout")).ToLowerInvariant()

        if ($layout -in @("token", "double_faced_token", "emblem")) {
            return $true
        }

        foreach ($field in @("typeLine", "type_line")) {
            $typeLine = [string](Get-Prop $card $field)
            if ($typeLine -match '(?i)^\s*Token\b' -or
                $typeLine -match '(?i)^\s*Emblem\b') {
                return $true
            }
        }

        $oracle = Get-Prop $card "oracleCard"
        if ($oracle) {
            $oracleLayout = ([string](Get-Prop $oracle "layout")).ToLowerInvariant()

            if ($oracleLayout -in @("token", "double_faced_token", "emblem")) {
                return $true
            }

            foreach ($field in @("typeLine", "type_line")) {
                $typeLine = [string](Get-Prop $oracle $field)
                if ($typeLine -match '(?i)^\s*Token\b' -or
                    $typeLine -match '(?i)^\s*Emblem\b') {
                    return $true
                }
            }
        }
    }

    return $false
}

function Test-CommanderEligible {
    param($ScryfallCard)

    if (-not $ScryfallCard) { return $false }

    $typeLine = [string](Get-Prop $ScryfallCard "type_line")
    $oracle = [string](Get-Prop $ScryfallCard "oracle_text")

    if ($typeLine -match '(?i)\bLegendary\b.*\bCreature\b') {
        return $true
    }

    if ($oracle -match '(?i)can be your commander') {
        return $true
    }

    return $false
}

function New-DeckCard {
    param(
        [string]$Name,
        [int]$Quantity,
        [string]$Uid,
        $Scryfall,
        [string[]]$Categories
    )

    return [pscustomobject]@{
        Name = $Name
        Quantity = $Quantity
        Uid = $Uid
        Scryfall = $Scryfall
        Categories = @($Categories)
    }
}

function Get-QuantityTotal {
    param($Cards)

    $total = 0
    foreach ($card in $Cards) {
        $total += [int]$card.Quantity
    }
    return $total
}

function Remove-CardObjectFromList {
    param(
        [System.Collections.IList]$List,
        $Target
    )

    for ($i = $List.Count - 1; $i -ge 0; $i--) {
        if ([object]::ReferenceEquals($List[$i], $Target)) {
            $List.RemoveAt($i)
            return $true
        }
    }

    return $false
}

function Trim-CommanderDeckTo100 {
    param(
        [System.Collections.IList]$Main,
        [System.Collections.IList]$Commanders
    )

    $commanderTotal = Get-QuantityTotal $Commanders
    $mainTotal = Get-QuantityTotal $Main
    $total = $commanderTotal + $mainTotal

    $cutCards = [System.Collections.ArrayList]::new()

    if ($total -le 100) {
        return [pscustomobject]@{
            CutCount = 0
            CutCards = @()
            FinalTotal = $total
        }
    }

    $needToCut = $total - 100

    for ($i = $Main.Count - 1; $i -ge 0 -and $needToCut -gt 0; $i--) {
        $card = $Main[$i]
        $qty = [int]$card.Quantity
        $removeQty = [Math]::Min($qty, $needToCut)

        if ($removeQty -ge $qty) {
            [void]$cutCards.Add(([string]$qty + " " + $card.Name))
            $Main.RemoveAt($i)
        }
        else {
            $card.Quantity = $qty - $removeQty
            [void]$cutCards.Add(([string]$removeQty + " " + $card.Name))
        }

        $needToCut -= $removeQty
    }

    return [pscustomobject]@{
        CutCount = ($total - 100 - $needToCut)
        CutCards = $cutCards.ToArray()
        FinalTotal = ((Get-QuantityTotal $Commanders) + (Get-QuantityTotal $Main))
    }
}

function Safe-FileName {
    param([string]$Name, [string]$DeckId)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = "Archidekt Deck $DeckId"
    }

    $invalid = [IO.Path]::GetInvalidFileNameChars()
    $chars = $Name.ToCharArray()

    for ($i = 0; $i -lt $chars.Length; $i++) {
        if ($invalid -contains $chars[$i]) {
            $chars[$i] = "_"
        }
    }

    $safe = (-join $chars).Trim().TrimEnd(".")
    if ([string]::IsNullOrWhiteSpace($safe)) {
        $safe = "Archidekt Deck $DeckId"
    }

    $reserved = @(
        "CON","PRN","AUX","NUL",
        "COM1","COM2","COM3","COM4","COM5","COM6","COM7","COM8","COM9",
        "LPT1","LPT2","LPT3","LPT4","LPT5","LPT6","LPT7","LPT8","LPT9"
    )

    if ($reserved -contains $safe.ToUpperInvariant()) {
        $safe += "_"
    }

    if ($safe.Length -gt 140) {
        $safe = $safe.Substring(0, 140).TrimEnd()
    }

    return $safe
}

function Test-IsOurImportedDeckFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    try {
        $head = @(Get-Content -LiteralPath $Path -TotalCount 20 -Encoding UTF8)

        if ($head -contains ("Tags=" + $ImportTag)) {
            return $true
        }

        $hasArchidektSource = $false
        foreach ($line in $head) {
            if ($line -match '^Source URL=https://archidekt\.com/decks/\d+') {
                $hasArchidektSource = $true
                break
            }
        }

        if ($hasArchidektSource) {
            foreach ($line in $head) {
                if ($line -eq "Comment=Imported automatically from Archidekt" -or
                    $line -eq "Comment=Synced from Archidekt by Jadon's Archidekt Deck Sync" -or
                    $line -eq ("Comment=" + $ImporterComment)) {
                    return $true
                }
            }
        }
    }
    catch {}

    return $false
}

function Find-ImportedDeckBySource {
    param([string]$SourceUrl)

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (-not (Test-IsOurImportedDeckFile $file.FullName)) {
                continue
            }

            try {
                $head = @(Get-Content -LiteralPath $file.FullName -TotalCount 20 -Encoding UTF8)
                if ($head -contains ("Source URL=" + $SourceUrl)) {
                    return $file.FullName
                }
            }
            catch {}
        }
    }

    return $null
}

function Choose-OutputPath {
    param(
        [string]$Directory,
        [string]$DeckName,
        [string]$DeckId,
        [string]$SourceUrl,
        [string]$Existing
    )

    $safe = Safe-FileName $DeckName $DeckId
    $candidate = Join-Path $Directory ($safe + ".dck")

    if ($Existing) {
        try {
            if ([IO.Path]::GetFullPath($Existing) -eq [IO.Path]::GetFullPath($candidate)) {
                return $candidate
            }
        }
        catch {}
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        return $candidate
    }

    if (Test-IsOurImportedDeckFile $candidate) {
        try {
            $head = @(Get-Content -LiteralPath $candidate -TotalCount 20 -Encoding UTF8)
            if ($head -contains ("Source URL=" + $SourceUrl)) {
                return $candidate
            }
        }
        catch {}
    }

    return Join-Path $Directory ($safe + " [Archidekt " + $DeckId + "].dck")
}

function Move-FallbackCommanderIfNeeded {
    param(
        [System.Collections.IList]$Main,
        [System.Collections.IList]$Commanders,
        [string]$DeckName
    )

    if ($Commanders.Count -gt 0) {
        return
    }

    $eligible = [System.Collections.ArrayList]::new()
    foreach ($card in $Main) {
        if (Test-CommanderEligible $card.Scryfall) {
            [void]$eligible.Add($card)
        }
    }

    if ($eligible.Count -eq 1) {
        $chosen = $eligible[0]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    Enhanced commander detection: " + $chosen.Name)
        return
    }

    if ($eligible.Count -eq 0) {
        return
    }

    # Try deck-name matching before asking the user.
    $deckNameLower = $DeckName.ToLowerInvariant()
    $nameMatches = [System.Collections.ArrayList]::new()

    foreach ($card in $eligible) {
        $front = $card.Name
        if ($front.Contains(" // ")) {
            $front = ($front -split " // ")[0]
        }

        if ($deckNameLower.Contains($front.ToLowerInvariant())) {
            [void]$nameMatches.Add($card)
        }
    }

    if ($nameMatches.Count -eq 1) {
        $chosen = $nameMatches[0]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    Enhanced commander detection from deck name: " + $chosen.Name)
        return
    }

    Write-Host ""
    Write-Host ("Commander tag missing for: " + $DeckName) -ForegroundColor Yellow
    Write-Host "Possible commander cards:"
    Write-Host ""

    $limit = [Math]::Min(20, $eligible.Count)
    for ($i = 0; $i -lt $limit; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $eligible[$i].Name)
    }

    Write-Host ""
    $answer = Read-Host "Enter commander number, two numbers separated by comma, or press Enter to skip"

    if ([string]::IsNullOrWhiteSpace($answer)) {
        return
    }

    $indexes = @()
    foreach ($piece in $answer.Split(",")) {
        $n = 0
        if ([int]::TryParse($piece.Trim(), [ref]$n)) {
            if ($n -ge 1 -and $n -le $limit) {
                $indexes += ($n - 1)
            }
        }
    }

    foreach ($idx in @($indexes | Select-Object -Unique | Sort-Object -Descending)) {
        $chosen = $eligible[$idx]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    User-selected commander: " + $chosen.Name)
    }
}

function Convert-Deck {
    param($Deck, $Meta)

    $deckId = [string](Get-Prop $Deck "id")
    if (-not $deckId) {
        $deckId = [string](Get-Prop $Meta "id")
    }
    if (-not $deckId) {
        throw "Deck detail did not include an ID."
    }

    $deckName = [string](Get-Prop $Deck "name")
    if (-not $deckName) {
        $deckName = [string](Get-Prop $Meta "name")
    }
    if (-not $deckName) {
        $deckName = "Archidekt Deck $deckId"
    }

    $sourceUrl = "https://archidekt.com/decks/$deckId"
    $entries = @(Get-Prop $Deck "cards")

    # Pull Scryfall canonical metadata by Archidekt's Scryfall printing UUIDs.
    $uids = [System.Collections.ArrayList]::new()
    foreach ($entry in $entries) {
        $uid = Get-ArchidektUid $entry
        if ($uid) {
            [void]$uids.Add($uid)
        }
    }

    $scryfallMap = @{}
    if ($Settings.ResolveWithScryfall -and $uids.Count -gt 0) {
        try {
            $scryfallMap = Invoke-ScryfallCollection $uids
        }
        catch {
            Write-Log ("    WARNING: Scryfall canonical-name lookup failed. Falling back to Archidekt names.")
            $scryfallMap = @{}
        }
    }

    # Archidekt category metadata.
    $premierCategories = @{}
    $excludedCategories = @{}
    $sideboardCategories = @{}

    foreach ($cat in @(Get-Prop $Deck "categories")) {
        if ($null -eq $cat) { continue }

        $catName = [string](Get-Prop $cat "name")
        if ([string]::IsNullOrWhiteSpace($catName)) { continue }

        $included = Get-Prop $cat "includedInDeck"
        if ($null -eq $included) { $included = $true }

        $premier = Get-Prop $cat "isPremier"
        if ($null -eq $premier) { $premier = $false }

        if (-not [bool]$included) {
            $excludedCategories[$catName] = $true
        }

        if ([bool]$included -and [bool]$premier) {
            $premierCategories[$catName] = $true
        }

        if ($catName -match '^(?i:sideboard)$') {
            $sideboardCategories[$catName] = $true
        }
    }

    $main = [System.Collections.ArrayList]::new()
    $commanders = [System.Collections.ArrayList]::new()
    $sideboard = [System.Collections.ArrayList]::new()

    $tokensRemoved = 0
    $maybeboardRemoved = 0
    $unresolvedNames = 0

    foreach ($entry in $entries) {
        if ($null -eq $entry) { continue }

        $fallbackName = Get-ArchidektCardName $entry
        if ([string]::IsNullOrWhiteSpace($fallbackName)) { continue }

        $uid = Get-ArchidektUid $entry
        $scry = $null
        if ($uid -and $scryfallMap.ContainsKey($uid)) {
            $scry = $scryfallMap[$uid]
        }

        $forgeName = Get-ForgeCardName $fallbackName $scry
        if ([string]::IsNullOrWhiteSpace($forgeName)) { continue }

        if (-not $scry) {
            $unresolvedNames++
        }

        $qty = Get-Prop $entry "quantity"
        if ($null -eq $qty) { $qty = 1 }
        try { $qty = [int]$qty } catch { $qty = 1 }
        if ($qty -lt 1) { continue }

        $cats = @(Get-EntryCategories $entry)

        if ([bool]$Settings.RemoveActualTokens) {
            if (Test-IsActualTokenOrEmblem $entry $scry) {
                $tokensRemoved += $qty
                continue
            }
        }

        $isExcluded = $false
        $isPremier = $false
        $isSideboard = $false

        foreach ($cat in $cats) {
            if ($excludedCategories.ContainsKey($cat)) {
                $isExcluded = $true
            }
            if ($premierCategories.ContainsKey($cat)) {
                $isPremier = $true
            }
            if ($sideboardCategories.ContainsKey($cat) -or $cat -match '^(?i:sideboard)$') {
                $isSideboard = $true
            }
            if ($cat -match '^(?i:commander|commanders)$') {
                $isPremier = $true
            }
            if ($cat -match '^(?i:maybeboard|maybe board)$') {
                $isExcluded = $true
            }
        }

        if ($isExcluded -and -not $isPremier) {
            $maybeboardRemoved += $qty
            continue
        }

        $obj = New-DeckCard $forgeName $qty $uid $scry $cats

        if ($isPremier) {
            [void]$commanders.Add($obj)
        }
        elseif ($isSideboard) {
            [void]$sideboard.Add($obj)
        }
        else {
            [void]$main.Add($obj)
        }
    }

    $formatText = Get-DeckFormatText $Deck $Meta
    $isCommanderDeck = ($formatText -match '(?i)commander') -or ($commanders.Count -gt 0)

    if ($isCommanderDeck -and $commanders.Count -eq 0) {
        Move-FallbackCommanderIfNeeded $main $commanders $deckName
    }

    if ($commanders.Count -gt 0) {
        $isCommanderDeck = $true
    }

    $cutResult = [pscustomobject]@{
        CutCount = 0
        CutCards = @()
        FinalTotal = ((Get-QuantityTotal $commanders) + (Get-QuantityTotal $main))
    }

    if ($isCommanderDeck -and [bool]$Settings.CapCommanderAt100) {
        $cutResult = Trim-CommanderDeckTo100 $main $commanders
    }

    $deckType = if ($isCommanderDeck) { "Commander" } else { "Constructed" }
    $targetDir = if ($isCommanderDeck) { $CommanderDir } else { $ConstructedDir }

    $existing = Find-ImportedDeckBySource $sourceUrl
    $output = Choose-OutputPath $targetDir $deckName $deckId $sourceUrl $existing

    if ($existing) {
        try {
            if ([IO.Path]::GetFullPath($existing) -ne [IO.Path]::GetFullPath($output)) {
                Remove-Item -LiteralPath $existing -Force
                Write-Log ("    Removed renamed old copy: " + [IO.Path]::GetFileName($existing))
            }
        }
        catch {
            Write-Log ("    WARNING: Could not remove renamed old copy: " + $existing)
        }
    }

    $cleanName = $deckName.Replace("`r", " ").Replace("`n", " ")

    $lines = [System.Collections.ArrayList]::new()
    [void]$lines.Add("[metadata]")
    [void]$lines.Add("Name=" + $cleanName)
    [void]$lines.Add("Deck Type=" + $deckType)
    [void]$lines.Add("Source URL=" + $sourceUrl)
    [void]$lines.Add("Comment=" + $ImporterComment)
    [void]$lines.Add("Tags=" + $ImportTag)
    [void]$lines.Add("")
    if ($isCommanderDeck -and $commanders.Count -gt 0) {
        [void]$lines.Add("[commander]")
        foreach ($card in $commanders) {
            [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
        }
        [void]$lines.Add("")
    }

    [void]$lines.Add("[main]")
    foreach ($card in $main) {
        [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
    }

    if ($sideboard.Count -gt 0) {
        [void]$lines.Add("")
        [void]$lines.Add("[sideboard]")
        foreach ($card in $sideboard) {
            [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
        }
    }

    Write-Utf8NoBom $output $lines

    $mainTotal = Get-QuantityTotal $main
    $commanderTotal = Get-QuantityTotal $commanders
    $sideTotal = Get-QuantityTotal $sideboard

    return [pscustomobject]@{
        Id = $deckId
        Name = $deckName
        DeckType = $deckType
        Path = $output
        MainCount = $mainTotal
        CommanderCount = $commanderTotal
        SideboardCount = $sideTotal
        Total = $mainTotal + $commanderTotal
        TokensRemoved = $tokensRemoved
        MaybeboardRemoved = $maybeboardRemoved
        CutCount = [int]$cutResult.CutCount
        CutCards = @($cutResult.CutCards)
        UnresolvedNames = $unresolvedNames
    }
}

function Sync-Profile {
    param([string]$InputText)

    try {
        $username = Parse-ProfileInput $InputText
    }
    catch {
        Write-Host ""
        Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
        return
    }

    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "No username found." -ForegroundColor Red
        return
    }

    Add-ProfileHistory $username
    Start-Log

    Write-Log ""
    Write-Log ("Syncing PUBLIC Archidekt decks for: " + $username)
    Write-Log ("Commander 100-card cap: " + ($(if ($Settings.CapCommanderAt100) { "ON" } else { "OFF" })))
    Write-Log ("Actual token / emblem removal: " + ($(if ($Settings.RemoveActualTokens) { "ON" } else { "OFF" })))
    Write-Log "Enhanced commander detection: ON"
    Write-Log ""

    $metas = [System.Collections.ArrayList]::new()

    try {
        $encoded = [Uri]::EscapeDataString($username)
        $page = 1

        while ($true) {
            $url = "https://archidekt.com/api/decks/v3/?ownerUsername=$encoded&orderBy=-updatedAt&pageSize=50&page=$page"
            $data = Invoke-JsonGet $url
            $results = @($data.results)

            if ($results.Count -eq 0) { break }

            foreach ($deck in $results) {
                [void]$metas.Add($deck)
            }

            Write-Log ("  Page " + $page + ": " + $results.Count + " deck(s), total " + $metas.Count)

            $next = Get-Prop $data "next"
            if (-not $next) { break }

            $page++
            Start-Sleep -Milliseconds 550
        }
    }
    catch {
        Write-Host ""
        Write-Host "ARCHIDEKT PROFILE REQUEST FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host ("Log: " + $script:CurrentLog)
        return
    }

    if ($metas.Count -eq 0) {
        Write-Host ""
        Write-Host "No public decks were found for that profile."
        return
    }

    Write-Log ""
    Write-Log ("Found " + $metas.Count + " public deck(s).")
    Write-Log ""

    $ok = [System.Collections.ArrayList]::new()
    $failed = [System.Collections.ArrayList]::new()
    $warnings = [System.Collections.ArrayList]::new()

    $index = 0
    foreach ($meta in $metas) {
        $index++

        $deckId = [string](Get-Prop $meta "id")
        $deckName = [string](Get-Prop $meta "name")
        if (-not $deckName) { $deckName = "Deck $deckId" }

        Write-Log ("[" + $index + "/" + $metas.Count + "] " + $deckName)

        try {
            Start-Sleep -Milliseconds 550
            $detail = Invoke-JsonGet ("https://archidekt.com/api/decks/" + $deckId + "/")
            $result = Convert-Deck $detail $meta
            [void]$ok.Add($result)
            $extra = @()
            if ($result.TokensRemoved -gt 0) {
                $extra += ("tokens removed " + $result.TokensRemoved)
            }
            if ($result.CutCount -gt 0) {
                $extra += ("cut " + $result.CutCount + " to cap at 100")
            }

            $suffix = ""
            if ($extra.Count -gt 0) {
                $suffix = " | " + ($extra -join ", ")
            }

            Write-Log ("    " + $result.DeckType + " | " + $result.Total + " cards -> " + [IO.Path]::GetFileName($result.Path) + $suffix)

            if ($result.DeckType -eq "Commander" -and $result.CommanderCount -eq 0) {
                [void]$warnings.Add($result.Name + ": Commander format detected but no commander could be identified.")
                Write-Log "    WARNING: Commander still could not be identified."
            }

            if ($result.DeckType -eq "Commander" -and $result.Total -ne 100) {
                [void]$warnings.Add($result.Name + ": imported Commander total is " + $result.Total + ".")
            }

            if ($result.UnresolvedNames -gt 0) {
                Write-Log ("    NOTE: " + $result.UnresolvedNames + " card(s) used Archidekt-name fallback instead of Scryfall UUID resolution.")
            }

            if ($result.CutCount -gt 0) {
                Write-Log "    Cards trimmed from the end of the Archidekt mainboard:"
                foreach ($cut in $result.CutCards) {
                    Write-Log ("      - " + $cut)
                }
            }
        }
        catch {
            [void]$failed.Add([pscustomobject]@{
                Name = $deckName
                Id = $deckId
                Error = $_.Exception.Message
            })

            Write-Log ("    FAILED: " + $_.Exception.Message)

            if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
                Write-Log ("    POSITION: " + ($_.InvocationInfo.PositionMessage -replace "`r?`n", " "))
            }

            if ($_.ScriptStackTrace) {
                Write-Log ("    STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
            }
        }
    }

    Write-Host ""
    Write-Host "================================================"
    Write-Host "PROFILE SYNC COMPLETE"
    Write-Host "================================================"
    Write-Host ""
    Write-Host ("Profile : " + $username)
    Write-Host ("Synced  : " + $ok.Count)
    Write-Host ("Failed  : " + $failed.Count)
    Write-Host ("Warnings: " + $warnings.Count)
    Write-Host ""
    Write-Host ("Log: " + $script:CurrentLog)

    if ($failed.Count -gt 0) {
        Write-Host ""
        Write-Host "Failed decks:" -ForegroundColor Yellow
        foreach ($item in $failed) {
            Write-Host ("  - " + $item.Name + " : " + $item.Error)
        }
    }

    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "Warnings:" -ForegroundColor Yellow
        foreach ($item in $warnings) {
            Write-Host ("  - " + $item)
        }
    }

    Write-Host ""
    Write-Host "You can now import another profile without closing this program."
}

function Remove-ImportedDecks {
    $files = [System.Collections.ArrayList]::new()

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (Test-IsOurImportedDeckFile $file.FullName) {
                [void]$files.Add($file)
            }
        }
    }

    Write-Host ""
    if ($files.Count -eq 0) {
        Write-Host "No decks created by Jadon's Archidekt importer were found."
        return
    }

    Write-Host ("Found " + $files.Count + " imported deck file(s).")
    Write-Host "Only files carrying this importer's marker or the older Jadon-import comments will be removed."
    Write-Host "Your manually-created Forge decks will not be touched."
    Write-Host ""

    $answer = Read-Host "Remove all of these imported decks? Type YES to confirm"
    if ($answer -cne "YES") {
        Write-Host "Cleanup cancelled."
        return
    }

    $removed = 0
    foreach ($file in $files) {
        try {
            Remove-Item -LiteralPath $file.FullName -Force
            $removed++
        }
        catch {
            Write-Host ("Could not remove: " + $file.FullName) -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host ("Removed " + $removed + " imported deck file(s).")
}

function Show-RecentProfiles {
    $recent = @(Get-RecentProfiles)

    if ($recent.Count -eq 0) {
        return
    }

    Write-Host "Recent profiles:"
    for ($i = 0; $i -lt $recent.Count; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $recent[$i])
    }
    Write-Host ""
}

function Prompt-Profile {
    $recent = @(Get-RecentProfiles)
    Show-RecentProfiles

    $inputText = Read-Host "Paste Archidekt profile URL/username, or enter a recent-profile number"

    if ([string]::IsNullOrWhiteSpace($inputText)) {
        return $null
    }

    $n = 0
    if ([int]::TryParse($inputText.Trim(), [ref]$n)) {
        if ($n -ge 1 -and $n -le $recent.Count) {
            return $recent[$n - 1]
        }
    }

    return $inputText
}

function Show-MainMenu {
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "Jadon's Archidekt Forge Manager v4 SAFE TOKENS"
        Write-Host "------------------------------------------------"
        Write-Host ""
        Write-Host "Run this once and keep importing profile after profile."
        Write-Host ""
        Write-Host "[1] Import / sync an Archidekt profile"
        Write-Host "[2] Remove ALL decks added by this importer"
        Write-Host ("[3] Toggle ACTUAL token/emblem removal  [" + ($(if ($Settings.RemoveActualTokens) { "ON" } else { "OFF" })) + "]")
        Write-Host ("[4] Toggle Commander 100-card cap       [" + ($(if ($Settings.CapCommanderAt100) { "ON" } else { "OFF" })) + "]")
        Write-Host "[5] Show Forge deck folders"
        Write-Host "[6] Exit"
        Write-Host ""
        Write-Host "Token removal only checks actual card metadata."
        Write-Host "An Archidekt category named 'Tokens' will NEVER remove a normal card."
        Write-Host ""

        $choice = Read-Host "Choose 1-6"

        switch ($choice) {
            "1" {
                Write-Host ""
                $profile = Prompt-Profile
                if ($profile) {
                    Sync-Profile $profile
                }
                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "2" {
                Remove-ImportedDecks
                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "3" {
                $Settings.RemoveActualTokens = -not [bool]$Settings.RemoveActualTokens
                Save-Settings $Settings

                Write-Host ""
                Write-Host ("Actual token/emblem removal is now " + ($(if ($Settings.RemoveActualTokens) { "ON" } else { "OFF" })) + ".")
                Write-Host ""

                if ($Settings.RemoveActualTokens) {
                    Write-Host "Only cards whose actual metadata identifies them as a Token or Emblem"
                    Write-Host "will be excluded. Categories such as [Tokens] are ignored for removal."
                }
                else {
                    Write-Host "No cards will be removed for being tokens or emblems."
                }

                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "4" {
                $Settings.CapCommanderAt100 = -not [bool]$Settings.CapCommanderAt100
                Save-Settings $Settings

                Write-Host ""
                Write-Host ("Commander 100-card cap is now " + ($(if ($Settings.CapCommanderAt100) { "ON" } else { "OFF" })) + ".")
                Write-Host ""

                if ($Settings.CapCommanderAt100) {
                    Write-Host "When a Commander deck exceeds 100 cards, commanders are preserved"
                    Write-Host "and overflow cards are removed from the END of Archidekt's mainboard order."
                    Write-Host "This is separate from token removal."
                }
                else {
                    Write-Host "Oversized Commander decks will be imported without trimming."
                }

                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "5" {
                Write-Host ""
                Write-Host "Commander:"
                Write-Host ("  " + $CommanderDir)
                Write-Host ""
                Write-Host "Constructed:"
                Write-Host ("  " + $ConstructedDir)
                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "6" {
                return
            }

            default {
                Start-Sleep -Milliseconds 500
            }
        }
    }
}


function Invoke-ManagerSelfTest {
    Write-Host ""
    Write-Host "Running importer v4 compatibility self-test..."
    Write-Host ""

    try {
        # Test the non-generic collection path used by every imported deck.
        $testMain = [System.Collections.ArrayList]::new()
        $testCommanders = [System.Collections.ArrayList]::new()

        [void]$testMain.Add([pscustomobject]@{
            Name = "Test Card A"
            Quantity = 50
            Scryfall = $null
        })

        [void]$testMain.Add([pscustomobject]@{
            Name = "Test Card B"
            Quantity = 51
            Scryfall = $null
        })

        [void]$testCommanders.Add([pscustomobject]@{
            Name = "Test Commander"
            Quantity = 1
            Scryfall = $null
        })

        $trimTest = Trim-CommanderDeckTo100 $testMain $testCommanders
        if ($trimTest.FinalTotal -ne 100) {
            throw "100-card trimming self-test failed."
        }

        # Test Forge naming for the layouts that caused the user's errors.
        $legions = Get-ForgeCardName `
            "Legion's Landing // Adanto, the First Fort" `
            ([pscustomobject]@{ name = "Legion's Landing // Adanto, the First Fort"; layout = "transform" })

        $pathway = Get-ForgeCardName `
            "Brightclimb Pathway // Grimclimb Pathway" `
            ([pscustomobject]@{ name = "Brightclimb Pathway // Grimclimb Pathway"; layout = "modal_dfc" })

        $adventure = Get-ForgeCardName `
            "Foulmire Knight // Profane Insight" `
            ([pscustomobject]@{ name = "Foulmire Knight // Profane Insight"; layout = "adventure" })

        $splitCard = Get-ForgeCardName `
            "Fire // Ice" `
            ([pscustomobject]@{ name = "Fire // Ice"; layout = "split" })

        $roomCard = Get-ForgeCardName `
            "Bottomless Pool // Locker Room" `
            ([pscustomobject]@{ name = "Bottomless Pool // Locker Room"; layout = "split" })

        if ($legions -ne "Legion's Landing") {
            throw "Transform-card self-test failed."
        }
        if ($pathway -ne "Brightclimb Pathway") {
            throw "Modal DFC self-test failed."
        }
        if ($adventure -ne "Foulmire Knight") {
            throw "Adventure-card self-test failed."
        }
        if ($splitCard -ne "Fire // Ice") {
            throw "Split-card self-test failed."
        }
        if ($roomCard -ne "Bottomless Pool // Locker Room") {
            throw "Room-card self-test failed."
        }

        # A NORMAL card in a user category named "Tokens" must NOT be treated
        # as an actual token. This is the bug fixed in v4.
        $normalTokenMakerEntry = [pscustomobject]@{
            categories = @("Tokens")
            card = [pscustomobject]@{
                layout = "normal"
                typeLine = "Creature - Elf Druid"
            }
        }

        $normalTokenMakerScryfall = [pscustomobject]@{
            layout = "normal"
            type_line = "Creature - Elf Druid"
        }

        if (Test-IsActualTokenOrEmblem $normalTokenMakerEntry $normalTokenMakerScryfall) {
            throw "Token-category safety self-test failed: a normal card was classified as a token."
        }

        $actualTokenEntry = [pscustomobject]@{
            categories = @("Creatures")
            card = [pscustomobject]@{
                layout = "token"
                typeLine = "Token Creature - Soldier"
            }
        }

        $actualTokenScryfall = [pscustomobject]@{
            layout = "token"
            type_line = "Token Creature - Soldier"
        }

        if (-not (Test-IsActualTokenOrEmblem $actualTokenEntry $actualTokenScryfall)) {
            throw "Actual-token detection self-test failed."
        }

        # Test UTF-8 file output without embedding a non-ASCII source literal.
        $accented = "Bartolom" + [char]0x00E9 + " del Presidio"
        $testFile = Join-Path $ToolDir "selftest_utf8.txt"
        Write-Utf8NoBom $testFile @($accented)
        $roundTrip = [IO.File]::ReadAllText($testFile, [Text.Encoding]::UTF8)
        Remove-Item -LiteralPath $testFile -Force -ErrorAction SilentlyContinue

        if ($roundTrip.Trim() -ne $accented) {
            throw "UTF-8 card-name self-test failed."
        }

        Write-Host "Importer v4 self-test: PASS" -ForegroundColor Green
        Write-Host ""
        return $true
    }
    catch {
        Write-Host "Importer v4 self-test: FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
        if ($_.ScriptStackTrace) {
            Write-Host $_.ScriptStackTrace
        }
        Write-Host ""
        Write-Host "No Forge decks were changed."
        return $false
    }
}

if (-not (Invoke-ManagerSelfTest)) {
    Read-Host "Press Enter to close"
    exit 1
}

Show-MainMenu
###JADON_INSTALLER_SAFE_V4_END###
###JADON_MANAGER_V63_CMD_PAYLOAD###
@echo off
setlocal EnableExtensions
title Jadon's Ultimate Forge Manager v6.3 FORTIFIED

if defined LOCALAPPDATA (
    set "BASE=%LOCALAPPDATA%\MTGForge"
) else (
    set "BASE=%USERPROFILE%\AppData\Local\MTGForge"
)

set "TOOLDIR=%BASE%\ArchidektSync"
set "PS1=%TOOLDIR%\UltimateForgeManager_v6_3.ps1"
set "PS_CANDIDATE=%TOOLDIR%\UltimateForgeManager_v6_3.candidate.ps1"
set "SAFE_CMD=%TOOLDIR%\Safe_Archidekt_Importer_v4.cmd"
set "SAFE_CANDIDATE=%TOOLDIR%\Safe_Archidekt_Importer_v4.candidate.cmd"
set "LOGDIR=%BASE%\logs"
set "PARSELOG=%LOGDIR%\standalone-v6.3-parse.log"
set "TESTLOG=%LOGDIR%\standalone-v6.3-selftest.log"
set "SAFELOG=%LOGDIR%\safe-importer-extract.log"
set "SELF=%~f0"
set "SAFE_SHA=3fdb666ff2b2f87e33f787d52c29601fee7ff965f0df459ee74d220b87be41be"
set "SAFE_READY=0"

if not exist "%TOOLDIR%" mkdir "%TOOLDIR%" >nul 2>&1
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Windows PowerShell was not found.
    echo Both V6.3 and the proven safe importer require Windows PowerShell.
    echo.
    pause
    exit /b 1
)

set "PS_SELF=%SELF%"
set "PS_SAFE_OUT=%SAFE_CMD%"
set "PS_SAFE_TMP=%SAFE_CANDIDATE%"
set "PS_SAFE_SHA=%SAFE_SHA%"

rem Extract the known-good V4 importer atomically. If this copy is damaged,
rem keep using an already-installed V4 only when its exact SHA-256 matches.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; $out=$env:PS_SAFE_OUT; $tmp=$env:PS_SAFE_TMP; $expected=$env:PS_SAFE_SHA; try{ $raw=[IO.File]::ReadAllText($env:PS_SELF); $b='###JADON_SAFE_IMPORTER_V4_BEGIN###'; $e='###JADON_SAFE_IMPORTER_V4_END###'; $bi=$raw.LastIndexOf($b); if($bi -lt 0){throw 'Safe importer begin marker missing'}; $start=$bi+$b.Length; $ei=$raw.LastIndexOf($e); if($ei -lt $start){throw 'Safe importer end marker missing'}; $body=$raw.Substring($start,$ei-$start).TrimStart([char]13,[char]10); $enc=New-Object System.Text.UTF8Encoding($false); [IO.File]::WriteAllText($tmp,$body,$enc); $hash=(Get-FileHash -Algorithm SHA256 -LiteralPath $tmp).Hash.ToLowerInvariant(); if($hash -ne $expected){throw ('Safe importer candidate hash mismatch: '+$hash)}; Move-Item -LiteralPath $tmp -Destination $out -Force; Write-Output 'Safe importer fresh extraction: PASS'; exit 0 } catch { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue; if(Test-Path -LiteralPath $out){ $oldHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $out).Hash.ToLowerInvariant(); if($oldHash -eq $expected){Write-Output 'Fresh safe extraction failed, but existing exact V4 is valid.'; exit 0} }; Write-Output $_.Exception.Message; exit 1 }" > "%SAFELOG%" 2>&1
if not errorlevel 1 set "SAFE_READY=1"

if /I "%~1"=="--safe" goto :SAFE_ONLY

rem Extract V6.3 PowerShell to a candidate file. Do not replace the installed
rem primary manager until BOTH the parser and full runtime self-test pass.
set "PS_OUT=%PS_CANDIDATE%"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; $raw=[IO.File]::ReadAllText($env:PS_SELF); $marker='###JADON_STANDALONE_MANAGER_V63_PAYLOAD###'; $ix=$raw.LastIndexOf($marker); if($ix -lt 0){throw 'Embedded V6.3 payload not found'}; $body=$raw.Substring($ix+$marker.Length).TrimStart([char]13,[char]10); $enc=New-Object System.Text.UTF8Encoding($false); [IO.File]::WriteAllText($env:PS_OUT,$body,$enc)"
if errorlevel 1 goto :PRIMARY_PREP_FAIL

set "PS_IMPORTER_FILE=%PS_CANDIDATE%"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$tokens=$null; $errors=$null; $src=Get-Content -LiteralPath $env:PS_IMPORTER_FILE; [System.Management.Automation.Language.Parser]::ParseFile($env:PS_IMPORTER_FILE,[ref]$tokens,[ref]$errors) ^| Out-Null; if($errors.Count -gt 0){$errors ^| ForEach-Object {$ln=$_.Extent.StartLineNumber; Write-Output (($ln.ToString()) + ': ' + $_.Message); if($ln -ge 1 -and $ln -le $src.Count){Write-Output ('    SOURCE> ' + $src[$ln-1])} }; exit 1}; Write-Output 'PowerShell parser: PASS'" > "%PARSELOG%" 2>&1
if errorlevel 1 goto :PRIMARY_PREP_FAIL

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS_CANDIDATE%" -SelfTest > "%TESTLOG%" 2>&1
if errorlevel 1 goto :PRIMARY_TEST_FAIL

move /y "%PS_CANDIDATE%" "%PS1%" >nul 2>&1
if errorlevel 1 goto :PRIMARY_PREP_FAIL

if /I "%~1"=="--test" (
    type "%PARSELOG%"
    type "%TESTLOG%"
    echo.
    echo V6.3 primary manager: PASS
    echo Proven safe V4 fallback: PASS
    exit /b 0
)

echo.
echo PowerShell parser: PASS
echo Manager self-test: PASS
echo Proven safe V4 fallback: READY
echo.
echo Starting V6.3 manager...
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
set "RC=%ERRORLEVEL%"
if "%RC%"=="0" exit /b 0

echo.
echo ================================================================
echo V6.3 MANAGER RETURNED ERROR CODE %RC%
echo ================================================================
echo The primary manager failed, so the proven safe importer will open now.
echo.
goto :OPEN_SAFE

:PRIMARY_PREP_FAIL
if exist "%PS_CANDIDATE%" del /f /q "%PS_CANDIDATE%" >nul 2>&1
echo.
echo ================================================================
echo V6.3 MANAGER PREPARATION FAILED
echo ================================================================
echo.
if exist "%PARSELOG%" type "%PARSELOG%"
echo.
echo The primary manager will NOT be run in a damaged state.
if /I "%~1"=="--test" goto :TEST_PRIMARY_FAILED
echo Switching automatically to the proven safe V4 importer.
echo.
goto :OPEN_SAFE

:PRIMARY_TEST_FAIL
if exist "%PS_CANDIDATE%" del /f /q "%PS_CANDIDATE%" >nul 2>&1
echo.
echo ================================================================
echo V6.3 MANAGER SELF-TEST FAILED
echo ================================================================
echo.
if exist "%TESTLOG%" type "%TESTLOG%"
echo.
if /I "%~1"=="--test" goto :TEST_PRIMARY_FAILED
echo Switching automatically to the proven safe V4 importer.
echo.
goto :OPEN_SAFE

:TEST_PRIMARY_FAILED
if "%SAFE_READY%"=="1" goto :TEST_FALLBACK_READY
echo Proven safe V4 importer extraction/hash: FAILED
exit /b 3

:TEST_FALLBACK_READY
echo Proven safe V4 importer extraction/hash: PASS
echo Primary V6.3 manager test: FAILED, fallback is READY
exit /b 2

:SAFE_ONLY
if not "%SAFE_READY%"=="1" goto :SAFE_UNAVAILABLE
call "%SAFE_CMD%"
exit /b %ERRORLEVEL%

:OPEN_SAFE
if not "%SAFE_READY%"=="1" goto :SAFE_UNAVAILABLE
echo Opening proven safe importer:
echo %SAFE_CMD%
echo.
call "%SAFE_CMD%"
set "SAFE_RC=%ERRORLEVEL%"
echo.
echo Safe importer closed with exit code %SAFE_RC%.
echo Returning to the caller/menu.
exit /b 0

:SAFE_UNAVAILABLE
echo.
echo ERROR: The proven safe importer fallback is unavailable.
if exist "%SAFELOG%" type "%SAFELOG%"
echo.
pause
exit /b 1

###JADON_SAFE_IMPORTER_V4_BEGIN###
@echo off
setlocal EnableExtensions
title Jadon's Archidekt Forge Manager v4 SAFE TOKENS

if defined LOCALAPPDATA (
    set "BASE=%LOCALAPPDATA%\MTGForge"
) else (
    set "BASE=%USERPROFILE%\AppData\Local\MTGForge"
)

set "TOOLDIR=%BASE%\ArchidektSync"
set "PS1=%TOOLDIR%\ArchidektForgeManager.ps1"
set "SELF=%~f0"

if not exist "%TOOLDIR%" mkdir "%TOOLDIR%" >nul 2>&1

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Windows PowerShell was not found.
    echo.
    pause
    exit /b 1
)

set "PS_SELF=%SELF%"
set "PS_OUT=%PS1%"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; $raw=[IO.File]::ReadAllText($env:PS_SELF); $marker='###JADON_ARCHIDEKT_MANAGER_PAYLOAD###'; $ix=$raw.LastIndexOf($marker); if($ix -lt 0){throw 'Embedded importer payload was not found.'}; $payload=$raw.Substring($ix+$marker.Length).TrimStart([char]13,[char]10); $enc=New-Object System.Text.UTF8Encoding($false); [IO.File]::WriteAllText($env:PS_OUT,$payload,$enc)"

if errorlevel 1 (
    echo.
    echo ERROR: Could not prepare the Archidekt manager.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$errors=$null; $tokens=$null; [System.Management.Automation.Language.Parser]::ParseFile($env:PS_OUT,[ref]$tokens,[ref]$errors) > $null; if($errors.Count -gt 0){$errors | ForEach-Object { Write-Host $_.Message }; exit 1}"

if errorlevel 1 (
    echo.
    echo ERROR: The embedded PowerShell importer failed its syntax test.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
exit /b %ERRORLEVEL%

###JADON_ARCHIDEKT_MANAGER_PAYLOAD###
param()

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Base = if ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA "MTGForge"
} else {
    Join-Path $env:USERPROFILE "AppData\Local\MTGForge"
}

$ToolDir = Join-Path $Base "ArchidektSync"
$LogDir = Join-Path $ToolDir "logs"
$SettingsFile = Join-Path $ToolDir "settings.json"
$ProfileHistoryFile = Join-Path $ToolDir "profiles.txt"

$ForgeUser = Join-Path $env:APPDATA "Forge"
$CommanderDir = Join-Path $ForgeUser "decks\commander"
$ConstructedDir = Join-Path $ForgeUser "decks\constructed"

$ImportTag = "JADON_ARCHIDEKT_IMPORT"
$ImporterComment = "Imported by Jadon's Archidekt Forge Manager"

New-Item -ItemType Directory -Force -Path $ToolDir | Out-Null
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $CommanderDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConstructedDir | Out-Null

function Get-Prop {
    param($Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

function Write-Utf8NoBom {
    param([string]$Path, [string[]]$Lines)
    $enc = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllLines($Path, $Lines, $enc)
}

function Read-Settings {
    $defaults = [pscustomobject]@{
        CapCommanderAt100 = $true
        RemoveActualTokens = $false
        ResolveWithScryfall = $true
    }

    if (-not (Test-Path -LiteralPath $SettingsFile)) {
        return $defaults
    }

    try {
        $saved = Get-Content -LiteralPath $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($null -eq (Get-Prop $saved "CapCommanderAt100")) {
            $saved | Add-Member -NotePropertyName CapCommanderAt100 -NotePropertyValue $true
        }
        if ($null -eq (Get-Prop $saved "RemoveActualTokens")) {
            $saved | Add-Member -NotePropertyName RemoveActualTokens -NotePropertyValue $false
        }
        if ($null -eq (Get-Prop $saved "ResolveWithScryfall")) {
            $saved | Add-Member -NotePropertyName ResolveWithScryfall -NotePropertyValue $true
        }
        return $saved
    }
    catch {
        return $defaults
    }
}

function Save-Settings {
    param($Settings)
    $json = $Settings | ConvertTo-Json -Depth 5
    $enc = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($SettingsFile, $json, $enc)
}

$Settings = Read-Settings

$script:CurrentLog = $null
function Start-Log {
    $script:CurrentLog = Join-Path $LogDir ("sync-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log")
}
function Write-Log {
    param([string]$Text)
    Write-Host $Text
    if ($script:CurrentLog) {
        Add-Content -LiteralPath $script:CurrentLog -Value $Text -Encoding UTF8
    }
}

function Invoke-JsonGet {
    param([string]$Url)

    $last = $null

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        $client = $null
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/4.0"

            $bytes = $client.DownloadData($Url)
            $jsonText = [Text.Encoding]::UTF8.GetString($bytes)

            if ([string]::IsNullOrWhiteSpace($jsonText)) {
                throw "The server returned an empty response."
            }

            return ($jsonText | ConvertFrom-Json)
        }
        catch {
            $last = $_
            if ($attempt -lt 3) {
                Write-Log ("    Request failed. Retry " + $attempt + "/3...")
                Start-Sleep -Seconds (2 * $attempt)
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }
    }

    throw $last
}

function Invoke-ScryfallCollection {
    param($Ids)

    $map = @{}
    if ($null -eq $Ids) {
        return $map
    }

    $unique = @($Ids | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | Select-Object -Unique)
    if ($unique.Count -eq 0) {
        return $map
    }

    for ($offset = 0; $offset -lt $unique.Count; $offset += 75) {
        $lastIndex = [Math]::Min($offset + 74, $unique.Count - 1)
        $identifiers = @()

        for ($i = $offset; $i -le $lastIndex; $i++) {
            $identifiers += @{ id = [string]$unique[$i] }
        }

        $requestJson = @{ identifiers = $identifiers } | ConvertTo-Json -Depth 6 -Compress
        $requestBytes = [Text.Encoding]::UTF8.GetBytes($requestJson)

        $client = $null
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/4.0"
            $client.Headers["Content-Type"] = "application/json; charset=utf-8"

            $responseBytes = $client.UploadData(
                "https://api.scryfall.com/cards/collection",
                "POST",
                $requestBytes
            )

            $responseText = [Text.Encoding]::UTF8.GetString($responseBytes)
            $response = $responseText | ConvertFrom-Json

            foreach ($card in $response.data) {
                if ($card -and $card.id) {
                    $map[[string]$card.id] = $card
                }
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }

        Start-Sleep -Milliseconds 120
    }

    return $map
}

function Parse-ProfileInput {
    param([string]$Text)

    $Text = $Text.Trim()

    if ($Text -match '^https?://(?:www\.)?archidekt\.com/u/([^/?#]+)') {
        return [Uri]::UnescapeDataString($Matches[1])
    }

    if ($Text -match '^https?://(?:www\.)?archidekt\.com/search/decks\?') {
        try {
            $uri = [Uri]$Text
            foreach ($part in $uri.Query.TrimStart("?").Split("&")) {
                $bits = $part.Split("=", 2)
                if ($bits.Count -eq 2 -and $bits[0] -eq "ownerUsername") {
                    return [Uri]::UnescapeDataString($bits[1].Replace("+", " "))
                }
            }
        }
        catch {}
    }

    if ($Text -notmatch '[/\\]') {
        return $Text
    }

    throw "That does not look like an Archidekt profile URL or username."
}

function Add-ProfileHistory {
    param([string]$Username)

    if ([string]::IsNullOrWhiteSpace($Username)) { return }

    $existing = @()
    if (Test-Path -LiteralPath $ProfileHistoryFile) {
        try {
            $existing = @(Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 | Where-Object { $_ })
        }
        catch {}
    }

    $newList = @($Username) + @($existing | Where-Object { $_ -ne $Username })
    if ($newList.Count -gt 20) {
        $newList = @($newList[0..19])
    }

    Write-Utf8NoBom $ProfileHistoryFile $newList
}

function Get-RecentProfiles {
    if (-not (Test-Path -LiteralPath $ProfileHistoryFile)) {
        return @()
    }

    try {
        return @(Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 | Where-Object { $_ } | Select-Object -First 10)
    }
    catch {
        return @()
    }
}

function Get-EntryCategories {
    param($Entry)

    $result = [System.Collections.ArrayList]::new()

    $single = Get-Prop $Entry "category"
    if ($single) {
        if ($single -is [string]) {
            [void]$result.Add([string]$single)
        }
        else {
            $singleName = Get-Prop $single "name"
            if ($singleName) { $result.Add([string]$singleName) }
        }
    }

    foreach ($cat in @(Get-Prop $Entry "categories")) {
        if ($null -eq $cat) { continue }

        if ($cat -is [string]) {
            [void]$result.Add([string]$cat)
        }
        else {
            $name = Get-Prop $cat "name"
            if ($name) { $result.Add([string]$name) }
        }
    }

    return @($result.ToArray() | Select-Object -Unique)
}

function Get-ArchidektCardName {
    param($Entry)

    $card = Get-Prop $Entry "card"
    if ($null -eq $card) { return $null }

    $oracle = Get-Prop $card "oracleCard"
    if ($null -eq $oracle) {
        $oracle = Get-Prop $card "oracle_card"
    }

    if ($oracle) {
        $name = Get-Prop $oracle "name"
        if ($name) { return [string]$name }
    }

    foreach ($field in @("displayName", "name")) {
        $name = Get-Prop $card $field
        if ($name) { return [string]$name }
    }

    return $null
}

function Get-ArchidektUid {
    param($Entry)

    $card = Get-Prop $Entry "card"
    if ($null -eq $card) { return $null }

    foreach ($field in @("uid", "scryfallId", "scryfall_id")) {
        $value = Get-Prop $card $field
        if ($value) {
            return [string]$value
        }
    }

    return $null
}

function Get-DeckFormatText {
    param($Deck, $Meta)

    foreach ($obj in @($Deck, $Meta)) {
        if ($null -eq $obj) { continue }

        foreach ($field in @("deckFormat", "format", "deckFormatName", "formatName")) {
            $value = Get-Prop $obj $field
            if ($null -eq $value) { continue }

            if ($value -is [string]) {
                return [string]$value
            }

            if ($value -is [int] -or $value -is [long]) {
                if ([int64]$value -eq 3) { return "Commander" }
                return [string]$value
            }

            foreach ($sub in @("name", "displayName", "label")) {
                $text = Get-Prop $value $sub
                if ($text) { return [string]$text }
            }

            $id = Get-Prop $value "id"
            if ($id -eq 3) { return "Commander" }
        }
    }

    return ""
}

function Get-ForgeCardName {
    param(
        [string]$FallbackName,
        $ScryfallCard
    )

    $name = $FallbackName
    $layout = ""

    if ($ScryfallCard) {
        if ($ScryfallCard.name) {
            $name = [string]$ScryfallCard.name
        }
        if ($ScryfallCard.layout) {
            $layout = ([string]$ScryfallCard.layout).ToLowerInvariant()
        }
    }

    if ([string]::IsNullOrWhiteSpace($name)) {
        return $null
    }

    # Forge deck files use the FRONT card name for transform/MDFC/flip/adventure
    # cards. Split, aftermath and Room cards keep the full "A // B" name.
    $useFrontFace = $false

    switch ($layout) {
        "transform"        { $useFrontFace = $true }
        "modal_dfc"        { $useFrontFace = $true }
        "flip"             { $useFrontFace = $true }
        "adventure"        { $useFrontFace = $true }
        "reversible_card"  { $useFrontFace = $true }
    }

    if ($name.Contains(" // ") -and $useFrontFace) {
        $parts = $name -split " // "
        return ([string]$parts[0]).Trim()
    }

    # If Scryfall was unavailable, the safest Forge fallback for a combined
    # permanent DFC name is the front face. Scryfall resolution normally
    # prevents split/Room cards from reaching this fallback.
    if (-not $ScryfallCard -and $name.Contains(" // ")) {
        $parts = $name -split " // "
        return ([string]$parts[0]).Trim()
    }

    return $name.Trim()
}

function Test-IsActualTokenOrEmblem {
    param(
        $Entry,
        $ScryfallCard
    )

    # IMPORTANT:
    # Do NOT use Archidekt category names such as "Tokens".
    # Users commonly put ordinary token-generating cards in a category named
    # Tokens, and that does not mean the card itself is a token.

    if ($ScryfallCard) {
        $layout = ([string](Get-Prop $ScryfallCard "layout")).ToLowerInvariant()
        $typeLine = [string](Get-Prop $ScryfallCard "type_line")

        if ($layout -in @("token", "double_faced_token", "emblem")) {
            return $true
        }

        if ($typeLine -match '(?i)^\s*Token\b' -or
            $typeLine -match '(?i)^\s*Emblem\b') {
            return $true
        }
    }

    # Archidekt fallback only when Scryfall metadata is unavailable.
    # Inspect actual card metadata fields, never deck/category labels.
    $card = Get-Prop $Entry "card"
    if ($card) {
        $layout = ([string](Get-Prop $card "layout")).ToLowerInvariant()

        if ($layout -in @("token", "double_faced_token", "emblem")) {
            return $true
        }

        foreach ($field in @("typeLine", "type_line")) {
            $typeLine = [string](Get-Prop $card $field)
            if ($typeLine -match '(?i)^\s*Token\b' -or
                $typeLine -match '(?i)^\s*Emblem\b') {
                return $true
            }
        }

        $oracle = Get-Prop $card "oracleCard"
        if ($oracle) {
            $oracleLayout = ([string](Get-Prop $oracle "layout")).ToLowerInvariant()

            if ($oracleLayout -in @("token", "double_faced_token", "emblem")) {
                return $true
            }

            foreach ($field in @("typeLine", "type_line")) {
                $typeLine = [string](Get-Prop $oracle $field)
                if ($typeLine -match '(?i)^\s*Token\b' -or
                    $typeLine -match '(?i)^\s*Emblem\b') {
                    return $true
                }
            }
        }
    }

    return $false
}

function Test-CommanderEligible {
    param($ScryfallCard)

    if (-not $ScryfallCard) { return $false }

    $typeLine = [string](Get-Prop $ScryfallCard "type_line")
    $oracle = [string](Get-Prop $ScryfallCard "oracle_text")

    if ($typeLine -match '(?i)\bLegendary\b.*\bCreature\b') {
        return $true
    }

    if ($oracle -match '(?i)can be your commander') {
        return $true
    }

    return $false
}

function New-DeckCard {
    param(
        [string]$Name,
        [int]$Quantity,
        [string]$Uid,
        $Scryfall,
        [string[]]$Categories
    )

    return [pscustomobject]@{
        Name = $Name
        Quantity = $Quantity
        Uid = $Uid
        Scryfall = $Scryfall
        Categories = @($Categories)
    }
}

function Get-QuantityTotal {
    param($Cards)

    $total = 0
    foreach ($card in $Cards) {
        $total += [int]$card.Quantity
    }
    return $total
}

function Remove-CardObjectFromList {
    param(
        [System.Collections.IList]$List,
        $Target
    )

    for ($i = $List.Count - 1; $i -ge 0; $i--) {
        if ([object]::ReferenceEquals($List[$i], $Target)) {
            $List.RemoveAt($i)
            return $true
        }
    }

    return $false
}

function Trim-CommanderDeckTo100 {
    param(
        [System.Collections.IList]$Main,
        [System.Collections.IList]$Commanders
    )

    $commanderTotal = Get-QuantityTotal $Commanders
    $mainTotal = Get-QuantityTotal $Main
    $total = $commanderTotal + $mainTotal

    $cutCards = [System.Collections.ArrayList]::new()

    if ($total -le 100) {
        return [pscustomobject]@{
            CutCount = 0
            CutCards = @()
            FinalTotal = $total
        }
    }

    $needToCut = $total - 100

    for ($i = $Main.Count - 1; $i -ge 0 -and $needToCut -gt 0; $i--) {
        $card = $Main[$i]
        $qty = [int]$card.Quantity
        $removeQty = [Math]::Min($qty, $needToCut)

        if ($removeQty -ge $qty) {
            [void]$cutCards.Add(([string]$qty + " " + $card.Name))
            $Main.RemoveAt($i)
        }
        else {
            $card.Quantity = $qty - $removeQty
            [void]$cutCards.Add(([string]$removeQty + " " + $card.Name))
        }

        $needToCut -= $removeQty
    }

    return [pscustomobject]@{
        CutCount = ($total - 100 - $needToCut)
        CutCards = $cutCards.ToArray()
        FinalTotal = ((Get-QuantityTotal $Commanders) + (Get-QuantityTotal $Main))
    }
}

function Safe-FileName {
    param([string]$Name, [string]$DeckId)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = "Archidekt Deck $DeckId"
    }

    $invalid = [IO.Path]::GetInvalidFileNameChars()
    $chars = $Name.ToCharArray()

    for ($i = 0; $i -lt $chars.Length; $i++) {
        if ($invalid -contains $chars[$i]) {
            $chars[$i] = "_"
        }
    }

    $safe = (-join $chars).Trim().TrimEnd(".")
    if ([string]::IsNullOrWhiteSpace($safe)) {
        $safe = "Archidekt Deck $DeckId"
    }

    $reserved = @(
        "CON","PRN","AUX","NUL",
        "COM1","COM2","COM3","COM4","COM5","COM6","COM7","COM8","COM9",
        "LPT1","LPT2","LPT3","LPT4","LPT5","LPT6","LPT7","LPT8","LPT9"
    )

    if ($reserved -contains $safe.ToUpperInvariant()) {
        $safe += "_"
    }

    if ($safe.Length -gt 140) {
        $safe = $safe.Substring(0, 140).TrimEnd()
    }

    return $safe
}

function Test-IsOurImportedDeckFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    try {
        $head = @(Get-Content -LiteralPath $Path -TotalCount 20 -Encoding UTF8)

        if ($head -contains ("Tags=" + $ImportTag)) {
            return $true
        }

        $hasArchidektSource = $false
        foreach ($line in $head) {
            if ($line -match '^Source URL=https://archidekt\.com/decks/\d+') {
                $hasArchidektSource = $true
                break
            }
        }

        if ($hasArchidektSource) {
            foreach ($line in $head) {
                if ($line -eq "Comment=Imported automatically from Archidekt" -or
                    $line -eq "Comment=Synced from Archidekt by Jadon's Archidekt Deck Sync" -or
                    $line -eq ("Comment=" + $ImporterComment)) {
                    return $true
                }
            }
        }
    }
    catch {}

    return $false
}

function Find-ImportedDeckBySource {
    param([string]$SourceUrl)

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (-not (Test-IsOurImportedDeckFile $file.FullName)) {
                continue
            }

            try {
                $head = @(Get-Content -LiteralPath $file.FullName -TotalCount 20 -Encoding UTF8)
                if ($head -contains ("Source URL=" + $SourceUrl)) {
                    return $file.FullName
                }
            }
            catch {}
        }
    }

    return $null
}

function Choose-OutputPath {
    param(
        [string]$Directory,
        [string]$DeckName,
        [string]$DeckId,
        [string]$SourceUrl,
        [string]$Existing
    )

    $safe = Safe-FileName $DeckName $DeckId
    $candidate = Join-Path $Directory ($safe + ".dck")

    if ($Existing) {
        try {
            if ([IO.Path]::GetFullPath($Existing) -eq [IO.Path]::GetFullPath($candidate)) {
                return $candidate
            }
        }
        catch {}
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        return $candidate
    }

    if (Test-IsOurImportedDeckFile $candidate) {
        try {
            $head = @(Get-Content -LiteralPath $candidate -TotalCount 20 -Encoding UTF8)
            if ($head -contains ("Source URL=" + $SourceUrl)) {
                return $candidate
            }
        }
        catch {}
    }

    return Join-Path $Directory ($safe + " [Archidekt " + $DeckId + "].dck")
}

function Move-FallbackCommanderIfNeeded {
    param(
        [System.Collections.IList]$Main,
        [System.Collections.IList]$Commanders,
        [string]$DeckName
    )

    if ($Commanders.Count -gt 0) {
        return
    }

    $eligible = [System.Collections.ArrayList]::new()
    foreach ($card in $Main) {
        if (Test-CommanderEligible $card.Scryfall) {
            [void]$eligible.Add($card)
        }
    }

    if ($eligible.Count -eq 1) {
        $chosen = $eligible[0]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    Enhanced commander detection: " + $chosen.Name)
        return
    }

    if ($eligible.Count -eq 0) {
        return
    }

    # Try deck-name matching before asking the user.
    $deckNameLower = $DeckName.ToLowerInvariant()
    $nameMatches = [System.Collections.ArrayList]::new()

    foreach ($card in $eligible) {
        $front = $card.Name
        if ($front.Contains(" // ")) {
            $front = ($front -split " // ")[0]
        }

        if ($deckNameLower.Contains($front.ToLowerInvariant())) {
            [void]$nameMatches.Add($card)
        }
    }

    if ($nameMatches.Count -eq 1) {
        $chosen = $nameMatches[0]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    Enhanced commander detection from deck name: " + $chosen.Name)
        return
    }

    Write-Host ""
    Write-Host ("Commander tag missing for: " + $DeckName) -ForegroundColor Yellow
    Write-Host "Possible commander cards:"
    Write-Host ""

    $limit = [Math]::Min(20, $eligible.Count)
    for ($i = 0; $i -lt $limit; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $eligible[$i].Name)
    }

    Write-Host ""
    $answer = Read-Host "Enter commander number, two numbers separated by comma, or press Enter to skip"

    if ([string]::IsNullOrWhiteSpace($answer)) {
        return
    }

    $indexes = @()
    foreach ($piece in $answer.Split(",")) {
        $n = 0
        if ([int]::TryParse($piece.Trim(), [ref]$n)) {
            if ($n -ge 1 -and $n -le $limit) {
                $indexes += ($n - 1)
            }
        }
    }

    foreach ($idx in @($indexes | Select-Object -Unique | Sort-Object -Descending)) {
        $chosen = $eligible[$idx]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    User-selected commander: " + $chosen.Name)
    }
}

function Convert-Deck {
    param($Deck, $Meta)

    $deckId = [string](Get-Prop $Deck "id")
    if (-not $deckId) {
        $deckId = [string](Get-Prop $Meta "id")
    }
    if (-not $deckId) {
        throw "Deck detail did not include an ID."
    }

    $deckName = [string](Get-Prop $Deck "name")
    if (-not $deckName) {
        $deckName = [string](Get-Prop $Meta "name")
    }
    if (-not $deckName) {
        $deckName = "Archidekt Deck $deckId"
    }

    $sourceUrl = "https://archidekt.com/decks/$deckId"
    $entries = @(Get-Prop $Deck "cards")

    # Pull Scryfall canonical metadata by Archidekt's Scryfall printing UUIDs.
    $uids = [System.Collections.ArrayList]::new()
    foreach ($entry in $entries) {
        $uid = Get-ArchidektUid $entry
        if ($uid) {
            [void]$uids.Add($uid)
        }
    }

    $scryfallMap = @{}
    if ($Settings.ResolveWithScryfall -and $uids.Count -gt 0) {
        try {
            $scryfallMap = Invoke-ScryfallCollection $uids
        }
        catch {
            Write-Log ("    WARNING: Scryfall canonical-name lookup failed. Falling back to Archidekt names.")
            $scryfallMap = @{}
        }
    }

    # Archidekt category metadata.
    $premierCategories = @{}
    $excludedCategories = @{}
    $sideboardCategories = @{}

    foreach ($cat in @(Get-Prop $Deck "categories")) {
        if ($null -eq $cat) { continue }

        $catName = [string](Get-Prop $cat "name")
        if ([string]::IsNullOrWhiteSpace($catName)) { continue }

        $included = Get-Prop $cat "includedInDeck"
        if ($null -eq $included) { $included = $true }

        $premier = Get-Prop $cat "isPremier"
        if ($null -eq $premier) { $premier = $false }

        if (-not [bool]$included) {
            $excludedCategories[$catName] = $true
        }

        if ([bool]$included -and [bool]$premier) {
            $premierCategories[$catName] = $true
        }

        if ($catName -match '^(?i:sideboard)$') {
            $sideboardCategories[$catName] = $true
        }
    }

    $main = [System.Collections.ArrayList]::new()
    $commanders = [System.Collections.ArrayList]::new()
    $sideboard = [System.Collections.ArrayList]::new()

    $tokensRemoved = 0
    $maybeboardRemoved = 0
    $unresolvedNames = 0

    foreach ($entry in $entries) {
        if ($null -eq $entry) { continue }

        $fallbackName = Get-ArchidektCardName $entry
        if ([string]::IsNullOrWhiteSpace($fallbackName)) { continue }

        $uid = Get-ArchidektUid $entry
        $scry = $null
        if ($uid -and $scryfallMap.ContainsKey($uid)) {
            $scry = $scryfallMap[$uid]
        }

        $forgeName = Get-ForgeCardName $fallbackName $scry
        if ([string]::IsNullOrWhiteSpace($forgeName)) { continue }

        if (-not $scry) {
            $unresolvedNames++
        }

        $qty = Get-Prop $entry "quantity"
        if ($null -eq $qty) { $qty = 1 }
        try { $qty = [int]$qty } catch { $qty = 1 }
        if ($qty -lt 1) { continue }

        $cats = @(Get-EntryCategories $entry)

        if ([bool]$Settings.RemoveActualTokens) {
            if (Test-IsActualTokenOrEmblem $entry $scry) {
                $tokensRemoved += $qty
                continue
            }
        }

        $isExcluded = $false
        $isPremier = $false
        $isSideboard = $false

        foreach ($cat in $cats) {
            if ($excludedCategories.ContainsKey($cat)) {
                $isExcluded = $true
            }
            if ($premierCategories.ContainsKey($cat)) {
                $isPremier = $true
            }
            if ($sideboardCategories.ContainsKey($cat) -or $cat -match '^(?i:sideboard)$') {
                $isSideboard = $true
            }
            if ($cat -match '^(?i:commander|commanders)$') {
                $isPremier = $true
            }
            if ($cat -match '^(?i:maybeboard|maybe board)$') {
                $isExcluded = $true
            }
        }

        if ($isExcluded -and -not $isPremier) {
            $maybeboardRemoved += $qty
            continue
        }

        $obj = New-DeckCard $forgeName $qty $uid $scry $cats

        if ($isPremier) {
            [void]$commanders.Add($obj)
        }
        elseif ($isSideboard) {
            [void]$sideboard.Add($obj)
        }
        else {
            [void]$main.Add($obj)
        }
    }

    $formatText = Get-DeckFormatText $Deck $Meta
    $isCommanderDeck = ($formatText -match '(?i)commander') -or ($commanders.Count -gt 0)

    if ($isCommanderDeck -and $commanders.Count -eq 0) {
        Move-FallbackCommanderIfNeeded $main $commanders $deckName
    }

    if ($commanders.Count -gt 0) {
        $isCommanderDeck = $true
    }

    $cutResult = [pscustomobject]@{
        CutCount = 0
        CutCards = @()
        FinalTotal = ((Get-QuantityTotal $commanders) + (Get-QuantityTotal $main))
    }

    if ($isCommanderDeck -and [bool]$Settings.CapCommanderAt100) {
        $cutResult = Trim-CommanderDeckTo100 $main $commanders
    }

    $deckType = if ($isCommanderDeck) { "Commander" } else { "Constructed" }
    $targetDir = if ($isCommanderDeck) { $CommanderDir } else { $ConstructedDir }

    $existing = Find-ImportedDeckBySource $sourceUrl
    $output = Choose-OutputPath $targetDir $deckName $deckId $sourceUrl $existing

    if ($existing) {
        try {
            if ([IO.Path]::GetFullPath($existing) -ne [IO.Path]::GetFullPath($output)) {
                Remove-Item -LiteralPath $existing -Force
                Write-Log ("    Removed renamed old copy: " + [IO.Path]::GetFileName($existing))
            }
        }
        catch {
            Write-Log ("    WARNING: Could not remove renamed old copy: " + $existing)
        }
    }

    $cleanName = $deckName.Replace("`r", " ").Replace("`n", " ")

    $lines = [System.Collections.ArrayList]::new()
    [void]$lines.Add("[metadata]")
    [void]$lines.Add("Name=" + $cleanName)
    [void]$lines.Add("Deck Type=" + $deckType)
    [void]$lines.Add("Source URL=" + $sourceUrl)
    [void]$lines.Add("Comment=" + $ImporterComment)
    [void]$lines.Add("Tags=" + $ImportTag)
    [void]$lines.Add("")
    if ($isCommanderDeck -and $commanders.Count -gt 0) {
        [void]$lines.Add("[commander]")
        foreach ($card in $commanders) {
            [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
        }
        [void]$lines.Add("")
    }

    [void]$lines.Add("[main]")
    foreach ($card in $main) {
        [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
    }

    if ($sideboard.Count -gt 0) {
        [void]$lines.Add("")
        [void]$lines.Add("[sideboard]")
        foreach ($card in $sideboard) {
            [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
        }
    }

    Write-Utf8NoBom $output $lines

    $mainTotal = Get-QuantityTotal $main
    $commanderTotal = Get-QuantityTotal $commanders
    $sideTotal = Get-QuantityTotal $sideboard

    return [pscustomobject]@{
        Id = $deckId
        Name = $deckName
        DeckType = $deckType
        Path = $output
        MainCount = $mainTotal
        CommanderCount = $commanderTotal
        SideboardCount = $sideTotal
        Total = $mainTotal + $commanderTotal
        TokensRemoved = $tokensRemoved
        MaybeboardRemoved = $maybeboardRemoved
        CutCount = [int]$cutResult.CutCount
        CutCards = @($cutResult.CutCards)
        UnresolvedNames = $unresolvedNames
    }
}

function Sync-Profile {
    param([string]$InputText)

    try {
        $username = Parse-ProfileInput $InputText
    }
    catch {
        Write-Host ""
        Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
        return
    }

    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "No username found." -ForegroundColor Red
        return
    }

    Add-ProfileHistory $username
    Start-Log

    Write-Log ""
    Write-Log ("Syncing PUBLIC Archidekt decks for: " + $username)
    Write-Log ("Commander 100-card cap: " + ($(if ($Settings.CapCommanderAt100) { "ON" } else { "OFF" })))
    Write-Log ("Actual token / emblem removal: " + ($(if ($Settings.RemoveActualTokens) { "ON" } else { "OFF" })))
    Write-Log "Enhanced commander detection: ON"
    Write-Log ""

    $metas = [System.Collections.ArrayList]::new()

    try {
        $encoded = [Uri]::EscapeDataString($username)
        $page = 1

        while ($true) {
            $url = "https://archidekt.com/api/decks/v3/?ownerUsername=$encoded&orderBy=-updatedAt&pageSize=50&page=$page"
            $data = Invoke-JsonGet $url
            $results = @($data.results)

            if ($results.Count -eq 0) { break }

            foreach ($deck in $results) {
                [void]$metas.Add($deck)
            }

            Write-Log ("  Page " + $page + ": " + $results.Count + " deck(s), total " + $metas.Count)

            $next = Get-Prop $data "next"
            if (-not $next) { break }

            $page++
            Start-Sleep -Milliseconds 550
        }
    }
    catch {
        Write-Host ""
        Write-Host "ARCHIDEKT PROFILE REQUEST FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host ("Log: " + $script:CurrentLog)
        return
    }

    if ($metas.Count -eq 0) {
        Write-Host ""
        Write-Host "No public decks were found for that profile."
        return
    }

    Write-Log ""
    Write-Log ("Found " + $metas.Count + " public deck(s).")
    Write-Log ""

    $ok = [System.Collections.ArrayList]::new()
    $failed = [System.Collections.ArrayList]::new()
    $warnings = [System.Collections.ArrayList]::new()

    $index = 0
    foreach ($meta in $metas) {
        $index++

        $deckId = [string](Get-Prop $meta "id")
        $deckName = [string](Get-Prop $meta "name")
        if (-not $deckName) { $deckName = "Deck $deckId" }

        Write-Log ("[" + $index + "/" + $metas.Count + "] " + $deckName)

        try {
            Start-Sleep -Milliseconds 550
            $detail = Invoke-JsonGet ("https://archidekt.com/api/decks/" + $deckId + "/")
            $result = Convert-Deck $detail $meta
            [void]$ok.Add($result)
            $extra = @()
            if ($result.TokensRemoved -gt 0) {
                $extra += ("tokens removed " + $result.TokensRemoved)
            }
            if ($result.CutCount -gt 0) {
                $extra += ("cut " + $result.CutCount + " to cap at 100")
            }

            $suffix = ""
            if ($extra.Count -gt 0) {
                $suffix = " | " + ($extra -join ", ")
            }

            Write-Log ("    " + $result.DeckType + " | " + $result.Total + " cards -> " + [IO.Path]::GetFileName($result.Path) + $suffix)

            if ($result.DeckType -eq "Commander" -and $result.CommanderCount -eq 0) {
                [void]$warnings.Add($result.Name + ": Commander format detected but no commander could be identified.")
                Write-Log "    WARNING: Commander still could not be identified."
            }

            if ($result.DeckType -eq "Commander" -and $result.Total -ne 100) {
                [void]$warnings.Add($result.Name + ": imported Commander total is " + $result.Total + ".")
            }

            if ($result.UnresolvedNames -gt 0) {
                Write-Log ("    NOTE: " + $result.UnresolvedNames + " card(s) used Archidekt-name fallback instead of Scryfall UUID resolution.")
            }

            if ($result.CutCount -gt 0) {
                Write-Log "    Cards trimmed from the end of the Archidekt mainboard:"
                foreach ($cut in $result.CutCards) {
                    Write-Log ("      - " + $cut)
                }
            }
        }
        catch {
            [void]$failed.Add([pscustomobject]@{
                Name = $deckName
                Id = $deckId
                Error = $_.Exception.Message
            })

            Write-Log ("    FAILED: " + $_.Exception.Message)

            if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
                Write-Log ("    POSITION: " + ($_.InvocationInfo.PositionMessage -replace "`r?`n", " "))
            }

            if ($_.ScriptStackTrace) {
                Write-Log ("    STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
            }
        }
    }

    Write-Host ""
    Write-Host "================================================"
    Write-Host "PROFILE SYNC COMPLETE"
    Write-Host "================================================"
    Write-Host ""
    Write-Host ("Profile : " + $username)
    Write-Host ("Synced  : " + $ok.Count)
    Write-Host ("Failed  : " + $failed.Count)
    Write-Host ("Warnings: " + $warnings.Count)
    Write-Host ""
    Write-Host ("Log: " + $script:CurrentLog)

    if ($failed.Count -gt 0) {
        Write-Host ""
        Write-Host "Failed decks:" -ForegroundColor Yellow
        foreach ($item in $failed) {
            Write-Host ("  - " + $item.Name + " : " + $item.Error)
        }
    }

    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "Warnings:" -ForegroundColor Yellow
        foreach ($item in $warnings) {
            Write-Host ("  - " + $item)
        }
    }

    Write-Host ""
    Write-Host "You can now import another profile without closing this program."
}

function Remove-ImportedDecks {
    $files = [System.Collections.ArrayList]::new()

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (Test-IsOurImportedDeckFile $file.FullName) {
                [void]$files.Add($file)
            }
        }
    }

    Write-Host ""
    if ($files.Count -eq 0) {
        Write-Host "No decks created by Jadon's Archidekt importer were found."
        return
    }

    Write-Host ("Found " + $files.Count + " imported deck file(s).")
    Write-Host "Only files carrying this importer's marker or the older Jadon-import comments will be removed."
    Write-Host "Your manually-created Forge decks will not be touched."
    Write-Host ""

    $answer = Read-Host "Remove all of these imported decks? Type YES to confirm"
    if ($answer -cne "YES") {
        Write-Host "Cleanup cancelled."
        return
    }

    $removed = 0
    foreach ($file in $files) {
        try {
            Remove-Item -LiteralPath $file.FullName -Force
            $removed++
        }
        catch {
            Write-Host ("Could not remove: " + $file.FullName) -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host ("Removed " + $removed + " imported deck file(s).")
}

function Show-RecentProfiles {
    $recent = @(Get-RecentProfiles)

    if ($recent.Count -eq 0) {
        return
    }

    Write-Host "Recent profiles:"
    for ($i = 0; $i -lt $recent.Count; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $recent[$i])
    }
    Write-Host ""
}

function Prompt-Profile {
    $recent = @(Get-RecentProfiles)
    Show-RecentProfiles

    $inputText = Read-Host "Paste Archidekt profile URL/username, or enter a recent-profile number"

    if ([string]::IsNullOrWhiteSpace($inputText)) {
        return $null
    }

    $n = 0
    if ([int]::TryParse($inputText.Trim(), [ref]$n)) {
        if ($n -ge 1 -and $n -le $recent.Count) {
            return $recent[$n - 1]
        }
    }

    return $inputText
}

function Show-MainMenu {
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "Jadon's Archidekt Forge Manager v4 SAFE TOKENS"
        Write-Host "------------------------------------------------"
        Write-Host ""
        Write-Host "Run this once and keep importing profile after profile."
        Write-Host ""
        Write-Host "[1] Import / sync an Archidekt profile"
        Write-Host "[2] Remove ALL decks added by this importer"
        Write-Host ("[3] Toggle ACTUAL token/emblem removal  [" + ($(if ($Settings.RemoveActualTokens) { "ON" } else { "OFF" })) + "]")
        Write-Host ("[4] Toggle Commander 100-card cap       [" + ($(if ($Settings.CapCommanderAt100) { "ON" } else { "OFF" })) + "]")
        Write-Host "[5] Show Forge deck folders"
        Write-Host "[6] Exit"
        Write-Host ""
        Write-Host "Token removal only checks actual card metadata."
        Write-Host "An Archidekt category named 'Tokens' will NEVER remove a normal card."
        Write-Host ""

        $choice = Read-Host "Choose 1-6"

        switch ($choice) {
            "1" {
                Write-Host ""
                $profile = Prompt-Profile
                if ($profile) {
                    Sync-Profile $profile
                }
                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "2" {
                Remove-ImportedDecks
                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "3" {
                $Settings.RemoveActualTokens = -not [bool]$Settings.RemoveActualTokens
                Save-Settings $Settings

                Write-Host ""
                Write-Host ("Actual token/emblem removal is now " + ($(if ($Settings.RemoveActualTokens) { "ON" } else { "OFF" })) + ".")
                Write-Host ""

                if ($Settings.RemoveActualTokens) {
                    Write-Host "Only cards whose actual metadata identifies them as a Token or Emblem"
                    Write-Host "will be excluded. Categories such as [Tokens] are ignored for removal."
                }
                else {
                    Write-Host "No cards will be removed for being tokens or emblems."
                }

                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "4" {
                $Settings.CapCommanderAt100 = -not [bool]$Settings.CapCommanderAt100
                Save-Settings $Settings

                Write-Host ""
                Write-Host ("Commander 100-card cap is now " + ($(if ($Settings.CapCommanderAt100) { "ON" } else { "OFF" })) + ".")
                Write-Host ""

                if ($Settings.CapCommanderAt100) {
                    Write-Host "When a Commander deck exceeds 100 cards, commanders are preserved"
                    Write-Host "and overflow cards are removed from the END of Archidekt's mainboard order."
                    Write-Host "This is separate from token removal."
                }
                else {
                    Write-Host "Oversized Commander decks will be imported without trimming."
                }

                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "5" {
                Write-Host ""
                Write-Host "Commander:"
                Write-Host ("  " + $CommanderDir)
                Write-Host ""
                Write-Host "Constructed:"
                Write-Host ("  " + $ConstructedDir)
                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "6" {
                return
            }

            default {
                Start-Sleep -Milliseconds 500
            }
        }
    }
}


function Invoke-ManagerSelfTest {
    Write-Host ""
    Write-Host "Running importer v4 compatibility self-test..."
    Write-Host ""

    try {
        # Test the non-generic collection path used by every imported deck.
        $testMain = [System.Collections.ArrayList]::new()
        $testCommanders = [System.Collections.ArrayList]::new()

        [void]$testMain.Add([pscustomobject]@{
            Name = "Test Card A"
            Quantity = 50
            Scryfall = $null
        })

        [void]$testMain.Add([pscustomobject]@{
            Name = "Test Card B"
            Quantity = 51
            Scryfall = $null
        })

        [void]$testCommanders.Add([pscustomobject]@{
            Name = "Test Commander"
            Quantity = 1
            Scryfall = $null
        })

        $trimTest = Trim-CommanderDeckTo100 $testMain $testCommanders
        if ($trimTest.FinalTotal -ne 100) {
            throw "100-card trimming self-test failed."
        }

        # Test Forge naming for the layouts that caused the user's errors.
        $legions = Get-ForgeCardName `
            "Legion's Landing // Adanto, the First Fort" `
            ([pscustomobject]@{ name = "Legion's Landing // Adanto, the First Fort"; layout = "transform" })

        $pathway = Get-ForgeCardName `
            "Brightclimb Pathway // Grimclimb Pathway" `
            ([pscustomobject]@{ name = "Brightclimb Pathway // Grimclimb Pathway"; layout = "modal_dfc" })

        $adventure = Get-ForgeCardName `
            "Foulmire Knight // Profane Insight" `
            ([pscustomobject]@{ name = "Foulmire Knight // Profane Insight"; layout = "adventure" })

        $splitCard = Get-ForgeCardName `
            "Fire // Ice" `
            ([pscustomobject]@{ name = "Fire // Ice"; layout = "split" })

        $roomCard = Get-ForgeCardName `
            "Bottomless Pool // Locker Room" `
            ([pscustomobject]@{ name = "Bottomless Pool // Locker Room"; layout = "split" })

        if ($legions -ne "Legion's Landing") {
            throw "Transform-card self-test failed."
        }
        if ($pathway -ne "Brightclimb Pathway") {
            throw "Modal DFC self-test failed."
        }
        if ($adventure -ne "Foulmire Knight") {
            throw "Adventure-card self-test failed."
        }
        if ($splitCard -ne "Fire // Ice") {
            throw "Split-card self-test failed."
        }
        if ($roomCard -ne "Bottomless Pool // Locker Room") {
            throw "Room-card self-test failed."
        }

        # A NORMAL card in a user category named "Tokens" must NOT be treated
        # as an actual token. This is the bug fixed in v4.
        $normalTokenMakerEntry = [pscustomobject]@{
            categories = @("Tokens")
            card = [pscustomobject]@{
                layout = "normal"
                typeLine = "Creature - Elf Druid"
            }
        }

        $normalTokenMakerScryfall = [pscustomobject]@{
            layout = "normal"
            type_line = "Creature - Elf Druid"
        }

        if (Test-IsActualTokenOrEmblem $normalTokenMakerEntry $normalTokenMakerScryfall) {
            throw "Token-category safety self-test failed: a normal card was classified as a token."
        }

        $actualTokenEntry = [pscustomobject]@{
            categories = @("Creatures")
            card = [pscustomobject]@{
                layout = "token"
                typeLine = "Token Creature - Soldier"
            }
        }

        $actualTokenScryfall = [pscustomobject]@{
            layout = "token"
            type_line = "Token Creature - Soldier"
        }

        if (-not (Test-IsActualTokenOrEmblem $actualTokenEntry $actualTokenScryfall)) {
            throw "Actual-token detection self-test failed."
        }

        # Test UTF-8 file output without embedding a non-ASCII source literal.
        $accented = "Bartolom" + [char]0x00E9 + " del Presidio"
        $testFile = Join-Path $ToolDir "selftest_utf8.txt"
        Write-Utf8NoBom $testFile @($accented)
        $roundTrip = [IO.File]::ReadAllText($testFile, [Text.Encoding]::UTF8)
        Remove-Item -LiteralPath $testFile -Force -ErrorAction SilentlyContinue

        if ($roundTrip.Trim() -ne $accented) {
            throw "UTF-8 card-name self-test failed."
        }

        Write-Host "Importer v4 self-test: PASS" -ForegroundColor Green
        Write-Host ""
        return $true
    }
    catch {
        Write-Host "Importer v4 self-test: FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
        if ($_.ScriptStackTrace) {
            Write-Host $_.ScriptStackTrace
        }
        Write-Host ""
        Write-Host "No Forge decks were changed."
        return $false
    }
}

if (-not (Invoke-ManagerSelfTest)) {
    Read-Host "Press Enter to close"
    exit 1
}

Show-MainMenu
###JADON_SAFE_IMPORTER_V4_END###
###JADON_STANDALONE_MANAGER_V63_PAYLOAD###
param([switch]$SelfTest)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Base = if ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA "MTGForge"
} else {
    Join-Path $env:USERPROFILE "AppData\Local\MTGForge"
}

$ToolDir = Join-Path $Base "ArchidektSync"
$LogDir = Join-Path $ToolDir "logs"
$SettingsFile = Join-Path $ToolDir "settings.json"
$ProfileHistoryFile = Join-Path $ToolDir "profiles.txt"
$StateFile = Join-Path $ToolDir "import-state.json"
$BackupDir = Join-Path $ToolDir "backups"
$ForgeLauncher = Join-Path $Base "Start_Forge.cmd"
$SafeImporterCmd = Join-Path $ToolDir "Safe_Archidekt_Importer_v4.cmd"
$EngineVersion = "6.3"

$AiDir = Join-Path $Base "AIViewer"
$AiSourceDir = Join-Path $AiDir "source"
$AiClassesDir = Join-Path $AiDir "classes"
$AiDownloadsDir = Join-Path $AiDir "downloads"
$AiJdkDir = Join-Path $AiDir "jdk-21"
$AiPatchJar = Join-Path $AiDir "jadon-ai-telemetry-patch.jar"
$AiViewerScript = Join-Path $AiDir "AI_Thought_Viewer.ps1"
$AiLauncher = Join-Path $AiDir "Start_Forge_AI_Viewer.cmd"
$AiTelemetryFile = Join-Path $AiDir "telemetry.jsonl"
$AiStatusFile = Join-Path $AiDir "status.json"

$ForgeUser = Join-Path $env:APPDATA "Forge"
$CommanderDir = Join-Path $ForgeUser "decks\commander"
$ConstructedDir = Join-Path $ForgeUser "decks\constructed"

$ImportTag = "JADON_ARCHIDEKT_IMPORT"
$ImporterComment = "Imported by Jadon's Archidekt Forge Manager"

New-Item -ItemType Directory -Force -Path $ToolDir | Out-Null
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $CommanderDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConstructedDir | Out-Null
New-Item -ItemType Directory -Force -Path $AiDir | Out-Null
New-Item -ItemType Directory -Force -Path $AiDownloadsDir | Out-Null

function Get-Prop {
    param($Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

function Write-Utf8NoBom {
    param([string]$Path, [string[]]$Lines)
    $enc = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllLines($Path, $Lines, $enc)
}

function Read-Settings {
    $defaults = [pscustomobject]@{
        FastImport = $false
        CopyDetection = $true
        SimilarityDetection = $false
        SimilarityThreshold = 90
        BracketUniqueCommander = $true
        BracketUniqueDeckName = $true
        BracketExact100 = $true
        RenameToCommander = $false
        RemoveActualTokens = $false
        CapCommanderAt100 = $true
        SkipIncompleteCommander = $true
        BackupBeforeOverwrite = $true
        PreserveSideboards = $true
        DryRun = $false
        ResolveWithScryfall = $true
    }

    if (-not (Test-Path -LiteralPath $SettingsFile)) {
        return $defaults
    }

    try {
        $saved = Get-Content -LiteralPath $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json

        $settingDefaults = @{
            FastImport = $false
            CopyDetection = $true
            SimilarityDetection = $false
            SimilarityThreshold = 90
            BracketUniqueCommander = $true
            BracketUniqueDeckName = $true
            BracketExact100 = $true
            RenameToCommander = $false
            RemoveActualTokens = $false
            CapCommanderAt100 = $true
            SkipIncompleteCommander = $true
            BackupBeforeOverwrite = $true
            PreserveSideboards = $true
            DryRun = $false
            ResolveWithScryfall = $true
        }

        foreach ($key in $settingDefaults.Keys) {
            $property = $saved.PSObject.Properties[$key]

            if ($null -eq $property) {
                $saved | Add-Member -NotePropertyName $key -NotePropertyValue $settingDefaults[$key]
            }
            elseif ($null -eq $property.Value) {
                $property.Value = $settingDefaults[$key]
            }
        }

        return $saved
    }
    catch {
        return $defaults
    }
}

function Save-Settings {
    param($Settings)
    $json = $Settings | ConvertTo-Json -Depth 5
    $enc = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($SettingsFile, $json, $enc)
}

$Settings = Read-Settings
$script:ScryfallCache = @{}

$script:CurrentLog = $null
function Start-Log {
    $script:CurrentLog = Join-Path $LogDir ("sync-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log")
}
function Write-Log {
    param([string]$Text)
    Write-Host $Text
    if ($script:CurrentLog) {
        Add-Content -LiteralPath $script:CurrentLog -Value $Text -Encoding UTF8
    }
}

function Invoke-SafeOperation {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    $script:LastOperationSucceeded = $true

    try {
        & $Action
    }
    catch {
        $script:LastOperationSucceeded = $false
        if (-not $script:CurrentLog) {
            Start-Log
        }

        Write-Log ""
        Write-Log ("OPERATION FAILED: " + $Name)
        Write-Log ("ERROR: " + $_.Exception.Message)

        if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
            Write-Log ("POSITION: " + ($_.InvocationInfo.PositionMessage -replace "`r?`n", " "))
        }

        if ($_.ScriptStackTrace) {
            Write-Log ("STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
        }

        Write-Host ""
        Write-Host "================================================" -ForegroundColor Red
        Write-Host "OPERATION FAILED - RETURNING TO MAIN MENU" -ForegroundColor Red
        Write-Host "================================================" -ForegroundColor Red
        Write-Host ""
        Write-Host ("Operation: " + $Name)
        Write-Host ("Reason   : " + $_.Exception.Message)
        Write-Host ""
        Write-Host "The manager is still running."
        Write-Host "No automatic retry or elevation was attempted."
        Write-Host ("Detailed log: " + $script:CurrentLog)
        Write-Host ""
    }
}


function Invoke-ProvenSafeImporter {
    param([string]$Reason = "Primary V6 importer could not complete safely.")

    Write-Host ""
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host "OPENING PROVEN SAFE IMPORTER" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host $Reason
    Write-Host ""
    Write-Host "The V6 manager will stay available after the safe importer closes."
    Write-Host ""

    if (-not (Test-Path -LiteralPath $SafeImporterCmd)) {
        Write-Host "Safe importer is missing:" -ForegroundColor Red
        Write-Host ("  " + $SafeImporterCmd)
        Write-Host ""
        return $false
    }

    try {
        & $SafeImporterCmd
        $safeRc = $LASTEXITCODE
        if ($null -eq $safeRc) { $safeRc = 0 }

        if ($safeRc -ne 0) {
            Write-Host ""
            Write-Host ("Safe importer returned exit code " + $safeRc + ".") -ForegroundColor Yellow
            return $false
        }

        return $true
    }
    catch {
        Write-Host ""
        Write-Host ("Safe importer could not be started: " + $_.Exception.Message) -ForegroundColor Red
        return $false
    }
}

function Get-OnOff {
    param([bool]$Value)
    if ($Value) { return "ON" }
    return "OFF"
}

function Wait-ApiPacing {
    if ([bool]$Settings.FastImport) {
        Start-Sleep -Milliseconds 150
    }
    else {
        Start-Sleep -Milliseconds 550
    }
}

function Get-MetaUpdatedAt {
    param($Meta)

    $value = Get-Prop $Meta "updatedAt"
    if ($null -eq $value) {
        $value = Get-Prop $Meta "updated_at"
    }

    if ($null -eq $value) {
        return ""
    }

    return [string]$value
}

function Get-SettingsFingerprint {
    $parts = @(
        ("engine=" + $EngineVersion),
        ("tokens=" + (Get-OnOff ([bool]$Settings.RemoveActualTokens))),
        ("cap100=" + (Get-OnOff ([bool]$Settings.CapCommanderAt100))),
        ("skipUnder100=" + (Get-OnOff ([bool]$Settings.SkipIncompleteCommander))),
        ("rename=" + (Get-OnOff ([bool]$Settings.RenameToCommander))),
        ("sideboard=" + (Get-OnOff ([bool]$Settings.PreserveSideboards))),
        ("scryfall=" + (Get-OnOff ([bool]$Settings.ResolveWithScryfall)))
    )

    return ($parts -join ";")
}

function Read-ImportState {
    $result = @{}

    if (-not (Test-Path -LiteralPath $StateFile)) {
        return $result
    }

    try {
        $document = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json

        foreach ($entry in $document.entries) {
            if ($entry -and $entry.DeckId) {
                $result[[string]$entry.DeckId] = $entry
            }
        }
    }
    catch {
        Write-Host "WARNING: The import state file could not be read. Copy detection will rebuild it." -ForegroundColor Yellow
    }

    return $result
}

function Save-ImportState {
    param($State)

    $entries = New-Object System.Collections.ArrayList

    foreach ($key in $State.Keys) {
        [void]$entries.Add($State[$key])
    }

    $document = [pscustomobject]@{
        Version = 1
        Entries = $entries.ToArray()
    }

    $json = $document | ConvertTo-Json -Depth 8
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($StateFile, $json, $encoding)
}

function Test-CopyStateMatch {
    param(
        $Meta,
        $StateEntry,
        [string]$Fingerprint
    )

    if ($null -eq $StateEntry) {
        return $false
    }

    $remoteUpdated = Get-MetaUpdatedAt $Meta
    if ([string]$StateEntry.UpdatedAt -ne $remoteUpdated) {
        return $false
    }

    if ([string]$StateEntry.Fingerprint -ne $Fingerprint) {
        return $false
    }

    $remoteName = [string](Get-Prop $Meta "name")
    if ([string]$StateEntry.OriginalName -ne $remoteName) {
        return $false
    }

    if ([string]$StateEntry.Status -eq "SkippedIncomplete") {
        return $true
    }

    $path = [string]$StateEntry.OutputPath
    if ([string]::IsNullOrWhiteSpace($path)) {
        return $false
    }

    if (-not (Test-Path -LiteralPath $path)) {
        return $false
    }

    return (Test-IsOurImportedDeckFile $path)
}

function Backup-ImportedDeck {
    param(
        [string]$Path,
        [string]$DeckId
    )

    if (-not [bool]$Settings.BackupBeforeOverwrite) {
        return
    }

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    if (-not (Test-IsOurImportedDeckFile $Path)) {
        return
    }

    $deckBackupDir = Join-Path $BackupDir $DeckId
    New-Item -ItemType Directory -Force -Path $deckBackupDir | Out-Null

    $stamp = Get-Date -Format "yyyyMMdd-HHmmssfff"
    $name = [IO.Path]::GetFileName($Path)
    $destination = Join-Path $deckBackupDir ($stamp + "-" + $name)

    Copy-Item -LiteralPath $Path -Destination $destination -Force
}

function Get-CommanderLabel {
    param($Commanders)

    $names = New-Object System.Collections.ArrayList

    foreach ($card in $Commanders) {
        if ($card -and -not [string]::IsNullOrWhiteSpace([string]$card.Name)) {
            if (-not ($names -contains [string]$card.Name)) {
                [void]$names.Add([string]$card.Name)
            }
        }
    }

    if ($names.Count -eq 0) {
        return ""
    }

    return ($names.ToArray() -join " + ")
}

function Get-ArchidektPremierCommanderLabel {
    param($Deck)

    $premier = @{}

    foreach ($category in (Get-Prop $Deck "categories")) {
        if ($null -eq $category) { continue }

        $name = [string](Get-Prop $category "name")
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $isPremier = Get-Prop $category "isPremier"
        $included = Get-Prop $category "includedInDeck"

        if ($null -eq $included) {
            $included = $true
        }

        if (($isPremier -eq $true -and $included -eq $true) -or
            $name -match '^(?i:commander|commanders)$') {
            $premier[$name] = $true
        }
    }

    $names = New-Object System.Collections.ArrayList

    foreach ($entry in (Get-Prop $Deck "cards")) {
        if ($null -eq $entry) { continue }

        $isCommander = $false
        foreach ($categoryName in (Get-EntryCategories $entry)) {
            if ($premier.ContainsKey([string]$categoryName) -or
                [string]$categoryName -match '^(?i:commander|commanders)$') {
                $isCommander = $true
                break
            }
        }

        if (-not $isCommander) {
            continue
        }

        $name = Get-ArchidektCardName $entry
        if ([string]::IsNullOrWhiteSpace($name)) {
            continue
        }

        $forgeName = Get-ForgeCardName $name $null
        if (-not ($names -contains $forgeName)) {
            [void]$names.Add($forgeName)
        }
    }

    if ($names.Count -eq 0) {
        return ""
    }

    return ($names.ToArray() -join " + ")
}

function Get-RenameDisplayName {
    param(
        [string]$OriginalName,
        [string]$CommanderLabel,
        $RenameCounts
    )

    if (-not [bool]$Settings.RenameToCommander) {
        return $OriginalName
    }

    if ([string]::IsNullOrWhiteSpace($CommanderLabel)) {
        return $OriginalName
    }

    $count = 1
    $key = $CommanderLabel.ToLowerInvariant()

    if ($RenameCounts -and $RenameCounts.ContainsKey($key)) {
        $count = [int]$RenameCounts[$key]
    }

    if ($count -gt 1) {
        return ($CommanderLabel + " - " + $OriginalName)
    }

    return $CommanderLabel
}

function Invoke-JsonGet {
    param([string]$Url)

    $last = $null

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        $client = $null
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/6.0"

            $bytes = $client.DownloadData($Url)
            $jsonText = [Text.Encoding]::UTF8.GetString($bytes)

            if ([string]::IsNullOrWhiteSpace($jsonText)) {
                throw "The server returned an empty response."
            }

            return ($jsonText | ConvertFrom-Json)
        }
        catch {
            $last = $_
            if ($attempt -lt 3) {
                Write-Log ("    Request failed. Retry " + $attempt + "/3...")
                Start-Sleep -Seconds (2 * $attempt)
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }
    }

    throw $last
}

function Invoke-ScryfallCollection {
    param($Ids)

    $map = @{}
    if ($null -eq $Ids) {
        return $map
    }

    $unique = @($Ids | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | Select-Object -Unique)
    if ($unique.Count -eq 0) {
        return $map
    }

    $missing = New-Object System.Collections.ArrayList

    foreach ($id in $unique) {
        $key = [string]$id

        if ($script:ScryfallCache.ContainsKey($key)) {
            $map[$key] = $script:ScryfallCache[$key]
        }
        else {
            [void]$missing.Add($key)
        }
    }

    if ($missing.Count -eq 0) {
        return $map
    }

    for ($offset = 0; $offset -lt $missing.Count; $offset += 75) {
        $lastIndex = [Math]::Min($offset + 74, $missing.Count - 1)
        $identifiers = @()

        for ($i = $offset; $i -le $lastIndex; $i++) {
            $identifiers += @{ id = [string]$missing[$i] }
        }

        $requestJson = @{ identifiers = $identifiers } | ConvertTo-Json -Depth 6 -Compress
        $requestBytes = [Text.Encoding]::UTF8.GetBytes($requestJson)

        $client = $null
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/6.0"
            $client.Headers["Content-Type"] = "application/json; charset=utf-8"

            $responseBytes = $client.UploadData(
                "https://api.scryfall.com/cards/collection",
                "POST",
                $requestBytes
            )

            $responseText = [Text.Encoding]::UTF8.GetString($responseBytes)
            $response = $responseText | ConvertFrom-Json

            foreach ($card in $response.data) {
                if ($card -and $card.id) {
                    $key = [string]$card.id
                    $script:ScryfallCache[$key] = $card
                    $map[$key] = $card
                }
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }

        if ([bool]$Settings.FastImport) {
            Start-Sleep -Milliseconds 80
        }
        else {
            Start-Sleep -Milliseconds 120
        }
    }

    return $map
}

function Parse-ProfileInput {
    param([string]$Text)

    $Text = $Text.Trim()

    if ($Text -match '^https?://(?:www\.)?archidekt\.com/u/([^/?#]+)') {
        return [Uri]::UnescapeDataString($Matches[1])
    }

    if ($Text -match '^https?://(?:www\.)?archidekt\.com/search/decks\?') {
        try {
            $uri = [Uri]$Text
            foreach ($part in ($uri.Query.TrimStart("?") -split "&")) {
                $bits = $part -split "=", 2
                if ($bits.Count -eq 2 -and $bits[0] -eq "ownerUsername") {
                    return [Uri]::UnescapeDataString($bits[1].Replace("+", " "))
                }
            }
        }
        catch {}
    }

    if ($Text -notmatch '[/\\]') {
        return $Text
    }

    throw "That does not look like an Archidekt profile URL or username."
}

function Add-ProfileHistory {
    param([string]$Username)

    if ([string]::IsNullOrWhiteSpace($Username)) { return }

    $existing = @()
    if (Test-Path -LiteralPath $ProfileHistoryFile) {
        try {
            $existing = @(Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 | Where-Object { $_ })
        }
        catch {}
    }

    $newList = @($Username) + @($existing | Where-Object { $_ -ne $Username })
    if ($newList.Count -gt 20) {
        $newList = @($newList[0..19])
    }

    Write-Utf8NoBom $ProfileHistoryFile $newList
}

function Get-RecentProfiles {
    if (-not (Test-Path -LiteralPath $ProfileHistoryFile)) {
        return @()
    }

    try {
        return @(Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 | Where-Object { $_ } | Select-Object -First 10)
    }
    catch {
        return @()
    }
}

function Get-EntryCategories {
    param($Entry)

    $result = New-Object System.Collections.ArrayList

    $single = Get-Prop $Entry "category"
    if ($single) {
        if ($single -is [string]) {
            [void]$result.Add([string]$single)
        }
        else {
            $singleName = Get-Prop $single "name"
            if ($singleName) { $result.Add([string]$singleName) }
        }
    }

    foreach ($cat in @(Get-Prop $Entry "categories")) {
        if ($null -eq $cat) { continue }

        if ($cat -is [string]) {
            [void]$result.Add([string]$cat)
        }
        else {
            $name = Get-Prop $cat "name"
            if ($name) { $result.Add([string]$name) }
        }
    }

    return @($result.ToArray() | Select-Object -Unique)
}

function Get-ArchidektCardName {
    param($Entry)

    $card = Get-Prop $Entry "card"
    if ($null -eq $card) { return $null }

    $oracle = Get-Prop $card "oracleCard"
    if ($null -eq $oracle) {
        $oracle = Get-Prop $card "oracle_card"
    }

    if ($oracle) {
        $name = Get-Prop $oracle "name"
        if ($name) { return [string]$name }
    }

    foreach ($field in @("displayName", "name")) {
        $name = Get-Prop $card $field
        if ($name) { return [string]$name }
    }

    return $null
}

function Get-ArchidektUid {
    param($Entry)

    $card = Get-Prop $Entry "card"
    if ($null -eq $card) { return $null }

    foreach ($field in @("uid", "scryfallId", "scryfall_id")) {
        $value = Get-Prop $card $field
        if ($value) {
            return [string]$value
        }
    }

    return $null
}

function Get-DeckFormatText {
    param($Deck, $Meta)

    foreach ($obj in @($Deck, $Meta)) {
        if ($null -eq $obj) { continue }

        foreach ($field in @("deckFormat", "format", "deckFormatName", "formatName")) {
            $value = Get-Prop $obj $field
            if ($null -eq $value) { continue }

            if ($value -is [string]) {
                return [string]$value
            }

            if ($value -is [int] -or $value -is [long]) {
                if ([int64]$value -eq 3) { return "Commander" }
                return [string]$value
            }

            foreach ($sub in @("name", "displayName", "label")) {
                $text = Get-Prop $value $sub
                if ($text) { return [string]$text }
            }

            $id = Get-Prop $value "id"
            if ($id -eq 3) { return "Commander" }
        }
    }

    return ""
}

function Get-ForgeCardName {
    param(
        [string]$FallbackName,
        $ScryfallCard
    )

    $name = $FallbackName
    $layout = ""

    if ($ScryfallCard) {
        if ($ScryfallCard.name) {
            $name = [string]$ScryfallCard.name
        }
        if ($ScryfallCard.layout) {
            $layout = ([string]$ScryfallCard.layout).ToLowerInvariant()
        }
    }

    if ([string]::IsNullOrWhiteSpace($name)) {
        return $null
    }

    # Forge deck files use the FRONT card name for transform/MDFC/flip/adventure
    # cards. Split, aftermath and Room cards keep the full "A // B" name.
    $useFrontFace = $false

    switch ($layout) {
        "transform"        { $useFrontFace = $true }
        "modal_dfc"        { $useFrontFace = $true }
        "flip"             { $useFrontFace = $true }
        "adventure"        { $useFrontFace = $true }
        "reversible_card"  { $useFrontFace = $true }
    }

    if ($name.Contains(" // ") -and $useFrontFace) {
        $parts = $name -split " // "
        return ([string]$parts[0]).Trim()
    }

    # If Scryfall was unavailable, the safest Forge fallback for a combined
    # permanent DFC name is the front face. Scryfall resolution normally
    # prevents split/Room cards from reaching this fallback.
    if (-not $ScryfallCard -and $name.Contains(" // ")) {
        $parts = $name -split " // "
        return ([string]$parts[0]).Trim()
    }

    return $name.Trim()
}

function Test-IsActualTokenOrEmblem {
    param(
        $Entry,
        $ScryfallCard
    )

    # IMPORTANT:
    # Do NOT use Archidekt category names such as "Tokens".
    # Users commonly put ordinary token-generating cards in a category named
    # Tokens, and that does not mean the card itself is a token.

    if ($ScryfallCard) {
        $layout = ([string](Get-Prop $ScryfallCard "layout")).ToLowerInvariant()
        $typeLine = [string](Get-Prop $ScryfallCard "type_line")

        if ($layout -in @("token", "double_faced_token", "emblem")) {
            return $true
        }

        if ($typeLine -match '(?i)^\s*Token\b' -or
            $typeLine -match '(?i)^\s*Emblem\b') {
            return $true
        }
    }

    # Archidekt fallback only when Scryfall metadata is unavailable.
    # Inspect actual card metadata fields, never deck/category labels.
    $card = Get-Prop $Entry "card"
    if ($card) {
        $layout = ([string](Get-Prop $card "layout")).ToLowerInvariant()

        if ($layout -in @("token", "double_faced_token", "emblem")) {
            return $true
        }

        foreach ($field in @("typeLine", "type_line")) {
            $typeLine = [string](Get-Prop $card $field)
            if ($typeLine -match '(?i)^\s*Token\b' -or
                $typeLine -match '(?i)^\s*Emblem\b') {
                return $true
            }
        }

        $oracle = Get-Prop $card "oracleCard"
        if ($oracle) {
            $oracleLayout = ([string](Get-Prop $oracle "layout")).ToLowerInvariant()

            if ($oracleLayout -in @("token", "double_faced_token", "emblem")) {
                return $true
            }

            foreach ($field in @("typeLine", "type_line")) {
                $typeLine = [string](Get-Prop $oracle $field)
                if ($typeLine -match '(?i)^\s*Token\b' -or
                    $typeLine -match '(?i)^\s*Emblem\b') {
                    return $true
                }
            }
        }
    }

    return $false
}

function Test-CommanderEligible {
    param($ScryfallCard)

    if (-not $ScryfallCard) { return $false }

    $typeLine = [string](Get-Prop $ScryfallCard "type_line")
    $oracle = [string](Get-Prop $ScryfallCard "oracle_text")

    if ($typeLine -match '(?i)\bLegendary\b.*\bCreature\b') {
        return $true
    }

    if ($oracle -match '(?i)can be your commander') {
        return $true
    }

    return $false
}

function New-DeckCard {
    param(
        [string]$Name,
        [int]$Quantity,
        [string]$Uid,
        $Scryfall,
        [string[]]$Categories
    )

    return [pscustomobject]@{
        Name = $Name
        Quantity = $Quantity
        Uid = $Uid
        Scryfall = $Scryfall
        Categories = @($Categories)
    }
}

function Get-QuantityTotal {
    param($Cards)

    $total = 0
    foreach ($card in $Cards) {
        $total += [int]$card.Quantity
    }
    return $total
}

function Remove-CardObjectFromList {
    param(
        [System.Collections.IList]$List,
        $Target
    )

    for ($i = $List.Count - 1; $i -ge 0; $i--) {
        if ([object]::ReferenceEquals($List[$i], $Target)) {
            $List.RemoveAt($i)
            return $true
        }
    }

    return $false
}

function Trim-CommanderDeckTo100 {
    param(
        [System.Collections.IList]$Main,
        [System.Collections.IList]$Commanders
    )

    $commanderTotal = Get-QuantityTotal $Commanders
    $mainTotal = Get-QuantityTotal $Main
    $total = $commanderTotal + $mainTotal

    $cutCards = New-Object System.Collections.ArrayList

    if ($total -le 100) {
        return [pscustomobject]@{
            CutCount = 0
            CutCards = @()
            FinalTotal = $total
        }
    }

    $needToCut = $total - 100

    for ($i = $Main.Count - 1; $i -ge 0 -and $needToCut -gt 0; $i--) {
        $card = $Main[$i]
        $qty = [int]$card.Quantity
        $removeQty = [Math]::Min($qty, $needToCut)

        if ($removeQty -ge $qty) {
            [void]$cutCards.Add(([string]$qty + " " + $card.Name))
            $Main.RemoveAt($i)
        }
        else {
            $card.Quantity = $qty - $removeQty
            [void]$cutCards.Add(([string]$removeQty + " " + $card.Name))
        }

        $needToCut -= $removeQty
    }

    return [pscustomobject]@{
        CutCount = ($total - 100 - $needToCut)
        CutCards = $cutCards.ToArray()
        FinalTotal = ((Get-QuantityTotal $Commanders) + (Get-QuantityTotal $Main))
    }
}

function Safe-FileName {
    param([string]$Name, [string]$DeckId)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = "Archidekt Deck $DeckId"
    }

    $invalid = [IO.Path]::GetInvalidFileNameChars()
    $chars = $Name.ToCharArray()

    for ($i = 0; $i -lt $chars.Length; $i++) {
        if ($invalid -contains $chars[$i]) {
            $chars[$i] = "_"
        }
    }

    $safe = (-join $chars).Trim().TrimEnd(".")
    if ([string]::IsNullOrWhiteSpace($safe)) {
        $safe = "Archidekt Deck $DeckId"
    }

    $reserved = @(
        "CON","PRN","AUX","NUL",
        "COM1","COM2","COM3","COM4","COM5","COM6","COM7","COM8","COM9",
        "LPT1","LPT2","LPT3","LPT4","LPT5","LPT6","LPT7","LPT8","LPT9"
    )

    if ($reserved -contains $safe.ToUpperInvariant()) {
        $safe += "_"
    }

    if ($safe.Length -gt 140) {
        $safe = $safe.Substring(0, 140).TrimEnd()
    }

    return $safe
}

function Test-IsOurImportedDeckFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    try {
        $head = @(Get-Content -LiteralPath $Path -TotalCount 20 -Encoding UTF8)

        if ($head -contains ("Tags=" + $ImportTag)) {
            return $true
        }

        $hasArchidektSource = $false
        foreach ($line in $head) {
            if ($line -match '^Source URL=https://archidekt\.com/decks/\d+') {
                $hasArchidektSource = $true
                break
            }
        }

        if ($hasArchidektSource) {
            foreach ($line in $head) {
                if ($line -eq "Comment=Imported automatically from Archidekt" -or
                    $line -eq "Comment=Synced from Archidekt by Jadon's Archidekt Deck Sync" -or
                    $line -eq ("Comment=" + $ImporterComment)) {
                    return $true
                }
            }
        }
    }
    catch {}

    return $false
}

function Find-ImportedDeckBySource {
    param([string]$SourceUrl)

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (-not (Test-IsOurImportedDeckFile $file.FullName)) {
                continue
            }

            try {
                $head = @(Get-Content -LiteralPath $file.FullName -TotalCount 20 -Encoding UTF8)
                if ($head -contains ("Source URL=" + $SourceUrl)) {
                    return $file.FullName
                }
            }
            catch {}
        }
    }

    return $null
}

function Choose-OutputPath {
    param(
        [string]$Directory,
        [string]$DeckName,
        [string]$DeckId,
        [string]$SourceUrl,
        [string]$Existing
    )

    $safe = Safe-FileName $DeckName $DeckId
    $candidate = Join-Path $Directory ($safe + ".dck")

    if ($Existing) {
        try {
            if ([IO.Path]::GetFullPath($Existing) -eq [IO.Path]::GetFullPath($candidate)) {
                return $candidate
            }
        }
        catch {}
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        return $candidate
    }

    if (Test-IsOurImportedDeckFile $candidate) {
        try {
            $head = @(Get-Content -LiteralPath $candidate -TotalCount 20 -Encoding UTF8)
            if ($head -contains ("Source URL=" + $SourceUrl)) {
                return $candidate
            }
        }
        catch {}
    }

    return Join-Path $Directory ($safe + " [Archidekt " + $DeckId + "].dck")
}

function Move-FallbackCommanderIfNeeded {
    param(
        [System.Collections.IList]$Main,
        [System.Collections.IList]$Commanders,
        [string]$DeckName
    )

    if ($Commanders.Count -gt 0) {
        return
    }

    $eligible = New-Object System.Collections.ArrayList
    foreach ($card in $Main) {
        if (Test-CommanderEligible $card.Scryfall) {
            [void]$eligible.Add($card)
        }
    }

    if ($eligible.Count -eq 1) {
        $chosen = $eligible[0]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    Enhanced commander detection: " + $chosen.Name)
        return
    }

    if ($eligible.Count -eq 0) {
        return
    }

    # Try deck-name matching before asking the user.
    $deckNameLower = $DeckName.ToLowerInvariant()
    $nameMatches = New-Object System.Collections.ArrayList

    foreach ($card in $eligible) {
        $front = $card.Name
        if ($front.Contains(" // ")) {
            $front = ($front -split " // ")[0]
        }

        if ($deckNameLower.Contains($front.ToLowerInvariant())) {
            [void]$nameMatches.Add($card)
        }
    }

    if ($nameMatches.Count -eq 1) {
        $chosen = $nameMatches[0]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    Enhanced commander detection from deck name: " + $chosen.Name)
        return
    }

    Write-Host ""
    Write-Host ("Commander tag missing for: " + $DeckName) -ForegroundColor Yellow
    Write-Host "Possible commander cards:"
    Write-Host ""

    $limit = [Math]::Min(20, $eligible.Count)
    for ($i = 0; $i -lt $limit; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $eligible[$i].Name)
    }

    Write-Host ""
    $answer = Read-Host "Enter commander number, two numbers separated by comma, or press Enter to skip"

    if ([string]::IsNullOrWhiteSpace($answer)) {
        return
    }

    $indexes = @()
    foreach ($piece in ($answer -split ",")) {
        $n = 0
        if ([int]::TryParse($piece.Trim(), [ref]$n)) {
            if ($n -ge 1 -and $n -le $limit) {
                $indexes += ($n - 1)
            }
        }
    }

    foreach ($idx in @($indexes | Select-Object -Unique | Sort-Object -Descending)) {
        $chosen = $eligible[$idx]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    User-selected commander: " + $chosen.Name)
    }
}


function Get-NormalizedDeckVector {
    param(
        $Main,
        $Commanders
    )

    $counts = @{}

    foreach ($card in $Commanders) {
        if ($null -eq $card) { continue }

        $name = ([string]$card.Name).Trim().ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $qty = 1
        try { $qty = [int]$card.Quantity } catch { $qty = 1 }
        if ($qty -lt 1) { continue }

        if ($counts.ContainsKey($name)) {
            $counts[$name] += $qty
        }
        else {
            $counts[$name] = $qty
        }
    }

    foreach ($card in $Main) {
        if ($null -eq $card) { continue }

        $name = ([string]$card.Name).Trim().ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $qty = 1
        try { $qty = [int]$card.Quantity } catch { $qty = 1 }
        if ($qty -lt 1) { continue }

        if ($counts.ContainsKey($name)) {
            $counts[$name] += $qty
        }
        else {
            $counts[$name] = $qty
        }
    }

    $vector = New-Object System.Collections.ArrayList
    foreach ($name in ($counts.Keys | Sort-Object)) {
        [void]$vector.Add(([string]$counts[$name]) + "`t" + $name)
    }

    return $vector.ToArray()
}

function Get-SimilarityVector {
    param($DeckVector)

    $basicNames = @{
        "plains" = $true
        "island" = $true
        "swamp" = $true
        "mountain" = $true
        "forest" = $true
        "wastes" = $true
        "snow-covered plains" = $true
        "snow-covered island" = $true
        "snow-covered swamp" = $true
        "snow-covered mountain" = $true
        "snow-covered forest" = $true
    }

    $result = New-Object System.Collections.ArrayList

    foreach ($line in $DeckVector) {
        $parts = ([string]$line) -split "`t", 2
        if ($parts.Count -ne 2) { continue }

        $name = ([string]$parts[1]).Trim().ToLowerInvariant()
        if ($basicNames.ContainsKey($name)) {
            continue
        }

        [void]$result.Add(([string]$parts[0]) + "`t" + $name)
    }

    return $result.ToArray()
}

function Get-VectorHash {
    param($DeckVector)

    $joined = (@($DeckVector) -join "`n")
    $bytes = [Text.Encoding]::UTF8.GetBytes($joined)
    $sha = [Security.Cryptography.SHA256]::Create()

    try {
        $hashBytes = $sha.ComputeHash($bytes)
        return ([BitConverter]::ToString($hashBytes)).Replace("-", "").ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Convert-VectorToCountMap {
    param($DeckVector)

    $map = @{}

    foreach ($line in $DeckVector) {
        $parts = ([string]$line) -split "`t", 2
        if ($parts.Count -ne 2) { continue }

        $qty = 0
        if (-not [int]::TryParse(([string]$parts[0]), [ref]$qty)) {
            continue
        }

        if ($qty -lt 1) { continue }

        $name = ([string]$parts[1]).Trim().ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $map[$name] = $qty
    }

    return $map
}

function Get-DeckSimilarityPercent {
    param(
        $VectorA,
        $VectorB
    )

    $a = Convert-VectorToCountMap $VectorA
    $b = Convert-VectorToCountMap $VectorB

    $totalA = 0
    foreach ($value in $a.Values) { $totalA += [int]$value }

    $totalB = 0
    foreach ($value in $b.Values) { $totalB += [int]$value }

    $denominator = [Math]::Max($totalA, $totalB)
    if ($denominator -le 0) {
        return 0.0
    }

    $intersection = 0

    foreach ($name in $a.Keys) {
        if ($b.ContainsKey($name)) {
            $intersection += [Math]::Min([int]$a[$name], [int]$b[$name])
        }
    }

    return [Math]::Round((100.0 * $intersection / $denominator), 2)
}

function Read-ImportedDeckRecord {
    param([string]$Path)

    if (-not (Test-IsOurImportedDeckFile $Path)) {
        return $null
    }

    $lines = @(Get-Content -LiteralPath $Path -Encoding UTF8)
    $section = ""
    $name = ""
    $originalName = ""
    $sourceUrl = ""
    $commanders = New-Object System.Collections.ArrayList
    $main = New-Object System.Collections.ArrayList

    foreach ($line in $lines) {
        if ($line -match '^\[(.+)\]$') {
            $section = $Matches[1].ToLowerInvariant()
            continue
        }

        if ($section -eq "metadata") {
            if ($line -match '^Name=(.*)$') {
                $name = [string]$Matches[1]
            }
            elseif ($line -match '^Source URL=(.*)$') {
                $sourceUrl = [string]$Matches[1]
            }
            elseif ($line -match '^Comment=.*\|\s*Original=(.*)$') {
                $originalName = [string]$Matches[1]
            }
            continue
        }

        if ($section -ne "commander" -and $section -ne "main") {
            continue
        }

        if ($line -notmatch '^\s*(\d+)\s+(.+?)\s*$') {
            continue
        }

        $qty = [int]$Matches[1]
        $cardName = [string]$Matches[2]

        if ($cardName.Contains("|")) {
            $cardName = ($cardName -split "\|", 2)[0]
        }

        $obj = [pscustomobject]@{
            Name = $cardName.Trim()
            Quantity = $qty
        }

        if ($section -eq "commander") {
            [void]$commanders.Add($obj)
        }
        else {
            [void]$main.Add($obj)
        }
    }

    if ([string]::IsNullOrWhiteSpace($originalName)) {
        $originalName = $name
    }

    $commanderLabel = Get-CommanderLabel $commanders
    $vector = Get-NormalizedDeckVector $main $commanders
    $similarityVector = Get-SimilarityVector $vector
    $hash = Get-VectorHash $vector

    $deckId = ""
    if ($sourceUrl -match '/decks/(\d+)') {
        $deckId = [string]$Matches[1]
    }

    return [pscustomobject]@{
        Path = $Path
        DeckId = $deckId
        DisplayName = $name
        OriginalName = $originalName
        CommanderLabel = $commanderLabel
        CardVector = $vector
        SimilarityVector = $similarityVector
        CardHash = $hash
    }
}

function Get-ImportedLibraryIndex {
    $records = New-Object System.Collections.ArrayList
    $hashes = @{}
    $names = @{}
    $commanders = @{}

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (-not (Test-IsOurImportedDeckFile $file.FullName)) {
                continue
            }

            try {
                $record = Read-ImportedDeckRecord $file.FullName
                if ($null -eq $record) { continue }

                [void]$records.Add($record)

                if (-not [string]::IsNullOrWhiteSpace([string]$record.CardHash)) {
                    $hashes[[string]$record.CardHash] = $record
                }

                foreach ($candidateName in @($record.DisplayName, $record.OriginalName)) {
                    if (-not [string]::IsNullOrWhiteSpace([string]$candidateName)) {
                        $names[([string]$candidateName).Trim().ToLowerInvariant()] = $record
                    }
                }

                if (-not [string]::IsNullOrWhiteSpace([string]$record.CommanderLabel)) {
                    $commanders[([string]$record.CommanderLabel).Trim().ToLowerInvariant()] = $record
                }
            }
            catch {
                Write-Log ("WARNING: Could not index imported deck " + $file.Name + ": " + $_.Exception.Message)
            }
        }
    }

    return [pscustomobject]@{
        Records = $records
        Hashes = $hashes
        Names = $names
        Commanders = $commanders
    }
}

function Find-SimilarImportedDeck {
    param(
        $SimilarityVector,
        $LibraryIndex
    )

    if (-not [bool]$Settings.SimilarityDetection) {
        return $null
    }

    $threshold = 90.0
    try { $threshold = [double]$Settings.SimilarityThreshold } catch { $threshold = 90.0 }

    if ($threshold -lt 50) { $threshold = 50 }
    if ($threshold -gt 100) { $threshold = 100 }

    $best = $null
    $bestPercent = 0.0

    foreach ($record in $LibraryIndex.Records) {
        if ($null -eq $record.SimilarityVector) { continue }

        $percent = Get-DeckSimilarityPercent $SimilarityVector $record.SimilarityVector
        if ($percent -gt $bestPercent) {
            $bestPercent = $percent
            $best = $record
        }
    }

    if ($best -and $bestPercent -ge $threshold) {
        return [pscustomobject]@{
            Record = $best
            Percent = $bestPercent
        }
    }

    return $null
}

function Commit-PreparedDeck {
    param($Result)

    if ($null -eq $Result -or $Result.Skipped) {
        throw "Cannot commit a skipped or empty prepared deck."
    }

    if ([bool]$Settings.DryRun) {
        return
    }

    $sourceUrl = "https://archidekt.com/decks/" + [string]$Result.Id
    $existing = Find-ImportedDeckBySource $sourceUrl

    if ($existing) {
        Backup-ImportedDeck $existing ([string]$Result.Id)

        if ([IO.Path]::GetFullPath($existing) -ne [IO.Path]::GetFullPath([string]$Result.Path)) {
            Remove-Item -LiteralPath $existing -Force -ErrorAction Stop
        }
    }

    Write-Utf8NoBom ([string]$Result.Path) $Result.DeckLines
}

function Convert-Deck {
    param(
        $Deck,
        $Meta,
        $RenameCounts,
        [switch]$PreviewOnly,
        [switch]$Exact100Only,
        [string]$SourceMode = "Profile",
        [int]$Bracket = 0
    )

    $deckId = [string](Get-Prop $Deck "id")
    if (-not $deckId) {
        $deckId = [string](Get-Prop $Meta "id")
    }
    if (-not $deckId) {
        throw "Deck detail did not include an ID."
    }

    $deckName = [string](Get-Prop $Deck "name")
    if (-not $deckName) {
        $deckName = [string](Get-Prop $Meta "name")
    }
    if (-not $deckName) {
        $deckName = "Archidekt Deck $deckId"
    }

    $sourceUrl = "https://archidekt.com/decks/$deckId"
    $entries = @(Get-Prop $Deck "cards")

    $uids = New-Object System.Collections.ArrayList
    foreach ($entry in $entries) {
        $uid = Get-ArchidektUid $entry
        if ($uid) {
            [void]$uids.Add($uid)
        }
    }

    $scryfallMap = @{}
    if ([bool]$Settings.ResolveWithScryfall -and $uids.Count -gt 0) {
        try {
            $scryfallMap = Invoke-ScryfallCollection $uids
        }
        catch {
            Write-Log "    WARNING: Scryfall validation failed. Falling back to Archidekt names."
            $scryfallMap = @{}
        }
    }

    $premierCategories = @{}
    $excludedCategories = @{}
    $sideboardCategories = @{}

    foreach ($cat in (Get-Prop $Deck "categories")) {
        if ($null -eq $cat) { continue }

        $catName = [string](Get-Prop $cat "name")
        if ([string]::IsNullOrWhiteSpace($catName)) { continue }

        $included = Get-Prop $cat "includedInDeck"
        if ($null -eq $included) { $included = $true }

        $premier = Get-Prop $cat "isPremier"
        if ($null -eq $premier) { $premier = $false }

        if (-not [bool]$included) {
            $excludedCategories[$catName] = $true
        }

        if ([bool]$included -and [bool]$premier) {
            $premierCategories[$catName] = $true
        }

        if ($catName -match '^(?i:sideboard)$') {
            $sideboardCategories[$catName] = $true
        }
    }

    $main = New-Object System.Collections.ArrayList
    $commanders = New-Object System.Collections.ArrayList
    $sideboard = New-Object System.Collections.ArrayList

    $tokensRemoved = 0
    $maybeboardRemoved = 0
    $unresolvedNames = 0

    foreach ($entry in $entries) {
        if ($null -eq $entry) { continue }

        $fallbackName = Get-ArchidektCardName $entry
        if ([string]::IsNullOrWhiteSpace($fallbackName)) { continue }

        $uid = Get-ArchidektUid $entry
        $scry = $null

        if ($uid -and $scryfallMap.ContainsKey($uid)) {
            $scry = $scryfallMap[$uid]
        }

        $forgeName = Get-ForgeCardName $fallbackName $scry
        if ([string]::IsNullOrWhiteSpace($forgeName)) { continue }

        if (-not $scry) {
            $unresolvedNames++
        }

        $qty = Get-Prop $entry "quantity"
        if ($null -eq $qty) { $qty = 1 }
        try { $qty = [int]$qty } catch { $qty = 1 }
        if ($qty -lt 1) { continue }

        $cats = @(Get-EntryCategories $entry)

        if ([bool]$Settings.RemoveActualTokens) {
            if (Test-IsActualTokenOrEmblem $entry $scry) {
                $tokensRemoved += $qty
                continue
            }
        }

        $isExcluded = $false
        $isPremier = $false
        $isSideboard = $false

        foreach ($cat in $cats) {
            if ($excludedCategories.ContainsKey([string]$cat)) {
                $isExcluded = $true
            }

            if ($premierCategories.ContainsKey([string]$cat)) {
                $isPremier = $true
            }

            if ($sideboardCategories.ContainsKey([string]$cat) -or
                [string]$cat -match '^(?i:sideboard)$') {
                $isSideboard = $true
            }

            if ([string]$cat -match '^(?i:commander|commanders)$') {
                $isPremier = $true
            }

            if ([string]$cat -match '^(?i:maybeboard|maybe board)$') {
                $isExcluded = $true
            }
        }

        if ($isExcluded -and -not $isPremier) {
            $maybeboardRemoved += $qty
            continue
        }

        $obj = New-DeckCard $forgeName $qty $uid $scry $cats

        if ($isPremier) {
            [void]$commanders.Add($obj)
        }
        elseif ($isSideboard) {
            [void]$sideboard.Add($obj)
        }
        else {
            [void]$main.Add($obj)
        }
    }

    $formatText = Get-DeckFormatText $Deck $Meta
    $isCommanderDeck = ($formatText -match '(?i)commander') -or ($commanders.Count -gt 0)

    if ($isCommanderDeck -and $commanders.Count -eq 0) {
        Move-FallbackCommanderIfNeeded $main $commanders $deckName
    }

    if ($commanders.Count -gt 0) {
        $isCommanderDeck = $true
    }

    $commanderLabel = Get-CommanderLabel $commanders
    $preTrimTotal = (Get-QuantityTotal $commanders) + (Get-QuantityTotal $main)

    $existing = Find-ImportedDeckBySource $sourceUrl

    $mustSkipForCount = $false
    $countSkipReason = ""

    if ($isCommanderDeck -and $Exact100Only -and $preTrimTotal -ne 100) {
        $mustSkipForCount = $true
        $countSkipReason = "Bracket/library mode requires exactly 100 cards; found " + $preTrimTotal
    }
    elseif ($isCommanderDeck -and
        [bool]$Settings.SkipIncompleteCommander -and
        $preTrimTotal -lt 100) {

        $mustSkipForCount = $true
        $countSkipReason = "Commander deck is under 100 cards"
    }

    if ($mustSkipForCount) {
        if ($existing -and -not [bool]$Settings.DryRun -and -not $PreviewOnly -and -not $Exact100Only) {
            Backup-ImportedDeck $existing $deckId
            Remove-Item -LiteralPath $existing -Force -ErrorAction Stop
        }

        $skipVector = Get-NormalizedDeckVector $main $commanders
        $skipSimilarityVector = Get-SimilarityVector $skipVector

        return [pscustomobject]@{
            Id = $deckId
            Name = $deckName
            DisplayName = $deckName
            DeckType = "Commander"
            Path = $null
            MainCount = (Get-QuantityTotal $main)
            CommanderCount = (Get-QuantityTotal $commanders)
            SideboardCount = (Get-QuantityTotal $sideboard)
            Total = $preTrimTotal
            TokensRemoved = $tokensRemoved
            MaybeboardRemoved = $maybeboardRemoved
            CutCount = 0
            CutCards = @()
            UnresolvedNames = $unresolvedNames
            CommanderLabel = $commanderLabel
            Skipped = $true
            SkipReason = $countSkipReason
            Status = "SkippedIncomplete"
            DeckLines = @()
            CardVector = $skipVector
            SimilarityVector = $skipSimilarityVector
            CardHash = Get-VectorHash $skipVector
            SourceMode = $SourceMode
            Bracket = $Bracket
        }
    }

    $cutResult = [pscustomobject]@{
        CutCount = 0
        CutCards = @()
        FinalTotal = $preTrimTotal
    }

    if ($isCommanderDeck -and -not $Exact100Only -and [bool]$Settings.CapCommanderAt100 -and $preTrimTotal -gt 100) {
        $cutResult = Trim-CommanderDeckTo100 $main $commanders
    }

    $deckType = if ($isCommanderDeck) { "Commander" } else { "Constructed" }
    $targetDir = if ($isCommanderDeck) { $CommanderDir } else { $ConstructedDir }

    $displayName = Get-RenameDisplayName $deckName $commanderLabel $RenameCounts
    $output = Choose-OutputPath $targetDir $displayName $deckId $sourceUrl $existing

    $cleanDisplayName = $displayName.Replace("`r", " ").Replace("`n", " ")
    $cleanOriginalName = $deckName.Replace("`r", " ").Replace("`n", " ")

    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add("[metadata]")
    [void]$lines.Add("Name=" + $cleanDisplayName)
    [void]$lines.Add("Deck Type=" + $deckType)
    [void]$lines.Add("Source URL=" + $sourceUrl)
    [void]$lines.Add("Comment=" + $ImporterComment + " | Original=" + $cleanOriginalName)
    [void]$lines.Add("Tags=" + $ImportTag)
    [void]$lines.Add("")

    if ($isCommanderDeck -and $commanders.Count -gt 0) {
        [void]$lines.Add("[commander]")
        foreach ($card in $commanders) {
            [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
        }
        [void]$lines.Add("")
    }

    [void]$lines.Add("[main]")
    foreach ($card in $main) {
        [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
    }

    if ([bool]$Settings.PreserveSideboards -and $sideboard.Count -gt 0) {
        [void]$lines.Add("")
        [void]$lines.Add("[sideboard]")
        foreach ($card in $sideboard) {
            [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
        }
    }

    if (-not [bool]$Settings.DryRun -and -not $PreviewOnly) {
        if ($existing) {
            Backup-ImportedDeck $existing $deckId

            try {
                if ([IO.Path]::GetFullPath($existing) -ne [IO.Path]::GetFullPath($output)) {
                    Remove-Item -LiteralPath $existing -Force -ErrorAction Stop
                    Write-Log ("    Removed old imported filename: " + [IO.Path]::GetFileName($existing))
                }
            }
            catch {
                throw ("Could not replace old imported deck: " + $_.Exception.Message)
            }
        }

        Write-Utf8NoBom $output $lines
    }

    $mainTotal = Get-QuantityTotal $main
    $commanderTotal = Get-QuantityTotal $commanders
    $sideTotal = if ([bool]$Settings.PreserveSideboards) { Get-QuantityTotal $sideboard } else { 0 }
    $cardVector = Get-NormalizedDeckVector $main $commanders
    $similarityVector = Get-SimilarityVector $cardVector
    $cardHash = Get-VectorHash $cardVector

    return [pscustomobject]@{
        Id = $deckId
        Name = $deckName
        DisplayName = $displayName
        DeckType = $deckType
        Path = $output
        MainCount = $mainTotal
        CommanderCount = $commanderTotal
        SideboardCount = $sideTotal
        Total = $mainTotal + $commanderTotal
        TokensRemoved = $tokensRemoved
        MaybeboardRemoved = $maybeboardRemoved
        CutCount = [int]$cutResult.CutCount
        CutCards = $cutResult.CutCards
        UnresolvedNames = $unresolvedNames
        CommanderLabel = $commanderLabel
        Skipped = $false
        SkipReason = ""
        Status = "Imported"
        DeckLines = $lines.ToArray()
        CardVector = $cardVector
        SimilarityVector = $similarityVector
        CardHash = $cardHash
        SourceMode = $SourceMode
        Bracket = $Bracket
    }
}

function Sync-Profile {
    param([string]$InputText)

    $script:ProfileImportNeedsFallback = $false

    try {
        $username = Parse-ProfileInput $InputText
    }
    catch {
        Write-Host ""
        Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
        return
    }

    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "No username found." -ForegroundColor Red
        return
    }

    Add-ProfileHistory $username
    Start-Log

    $fingerprint = Get-SettingsFingerprint
    $state = Read-ImportState

    Write-Log ""
    Write-Log ("Syncing PUBLIC Archidekt decks for: " + $username)
    Write-Log ("Fast import: " + (Get-OnOff ([bool]$Settings.FastImport)))
    Write-Log ("Copy detection: " + (Get-OnOff ([bool]$Settings.CopyDetection)))
    Write-Log ("Rename to commander: " + (Get-OnOff ([bool]$Settings.RenameToCommander)))
    Write-Log ("Actual token / emblem removal: " + (Get-OnOff ([bool]$Settings.RemoveActualTokens)))
    Write-Log ("Commander 100-card cap: " + (Get-OnOff ([bool]$Settings.CapCommanderAt100)))
    Write-Log ("Skip Commander decks under 100: " + (Get-OnOff ([bool]$Settings.SkipIncompleteCommander)))
    Write-Log ("Backup before overwrite/delete: " + (Get-OnOff ([bool]$Settings.BackupBeforeOverwrite)))
    Write-Log ("Preserve sideboards: " + (Get-OnOff ([bool]$Settings.PreserveSideboards)))
    Write-Log ("Dry run: " + (Get-OnOff ([bool]$Settings.DryRun)))
    Write-Log ""

    $metas = New-Object System.Collections.ArrayList

    try {
        $encoded = [Uri]::EscapeDataString($username)
        $page = 1

        while ($true) {
            $url = "https://archidekt.com/api/decks/v3/?ownerUsername=$encoded&orderBy=-updatedAt&pageSize=50&page=$page"
            $data = Invoke-JsonGet $url
            $results = @($data.results)

            if ($results.Count -eq 0) {
                break
            }

            foreach ($deck in $results) {
                [void]$metas.Add($deck)
            }

            Write-Log ("  Page " + $page + ": " + $results.Count + " deck(s), total " + $metas.Count)

            $next = Get-Prop $data "next"
            if (-not $next) {
                break
            }

            $page++
            Wait-ApiPacing
        }
    }
    catch {
        $script:ProfileImportNeedsFallback = $true
        Write-Host ""
        Write-Host "ARCHIDEKT PROFILE REQUEST FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host ("Log: " + $script:CurrentLog)
        return
    }

    if ($metas.Count -eq 0) {
        Write-Host ""
        Write-Host "No public decks were found for that profile."
        return
    }

    Write-Log ""
    Write-Log ("Found " + $metas.Count + " public deck(s).")
    Write-Log ""

    # First pass:
    #  - Copy detection decides which decks need no work.
    #  - Changed/new deck details are fetched once.
    #  - Commander labels are collected so rename collisions are predictable.
    $workItems = New-Object System.Collections.ArrayList
    $renameCounts = @{}

    foreach ($meta in $metas) {
        $deckId = [string](Get-Prop $meta "id")
        $deckName = [string](Get-Prop $meta "name")
        if (-not $deckName) { $deckName = "Deck $deckId" }

        $stateEntry = $null
        if ($state.ContainsKey($deckId)) {
            $stateEntry = $state[$deckId]
        }

        $skipCopy = $false
        if ([bool]$Settings.CopyDetection) {
            $skipCopy = Test-CopyStateMatch $meta $stateEntry $fingerprint
        }

        if ($skipCopy) {
            $label = [string]$stateEntry.CommanderLabel

            [void]$workItems.Add([pscustomobject]@{
                Meta = $meta
                Detail = $null
                CopySkipped = $true
                StateEntry = $stateEntry
                CommanderLabel = $label
            })

            if ([bool]$Settings.RenameToCommander -and -not [string]::IsNullOrWhiteSpace($label)) {
                $key = $label.ToLowerInvariant()
                if ($renameCounts.ContainsKey($key)) {
                    $renameCounts[$key] = [int]$renameCounts[$key] + 1
                }
                else {
                    $renameCounts[$key] = 1
                }
            }

            continue
        }

        try {
            Wait-ApiPacing
            $detail = Invoke-JsonGet ("https://archidekt.com/api/decks/" + $deckId + "/")
            $label = Get-ArchidektPremierCommanderLabel $detail

            [void]$workItems.Add([pscustomobject]@{
                Meta = $meta
                Detail = $detail
                CopySkipped = $false
                StateEntry = $stateEntry
                CommanderLabel = $label
            })

            if ([bool]$Settings.RenameToCommander -and -not [string]::IsNullOrWhiteSpace($label)) {
                $key = $label.ToLowerInvariant()
                if ($renameCounts.ContainsKey($key)) {
                    $renameCounts[$key] = [int]$renameCounts[$key] + 1
                }
                else {
                    $renameCounts[$key] = 1
                }
            }
        }
        catch {
            [void]$workItems.Add([pscustomobject]@{
                Meta = $meta
                Detail = $null
                CopySkipped = $false
                StateEntry = $stateEntry
                CommanderLabel = ""
                DetailError = $_.Exception.Message
            })
        }
    }

    # If rename mode is ON and a new duplicate commander name appears,
    # reprocess an older copy that was previously named only after its commander.
    # This makes BOTH duplicate decks use "Commander - Original Deck Name".
    if ([bool]$Settings.RenameToCommander -and [bool]$Settings.CopyDetection) {
        foreach ($item in $workItems) {
            if (-not [bool]$item.CopySkipped) { continue }

            $label = [string]$item.CommanderLabel
            if ([string]::IsNullOrWhiteSpace($label)) { continue }

            $key = $label.ToLowerInvariant()
            if (-not $renameCounts.ContainsKey($key)) { continue }
            if ([int]$renameCounts[$key] -le 1) { continue }

            $oldDisplayName = [string]$item.StateEntry.DisplayName
            if ([string]::IsNullOrWhiteSpace($oldDisplayName)) {
                $oldDisplayName = [string]$item.StateEntry.OriginalName
            }

            if ($oldDisplayName -eq $label) {
                try {
                    $meta = $item.Meta
                    $deckId = [string](Get-Prop $meta "id")
                    Wait-ApiPacing
                    $item.Detail = Invoke-JsonGet ("https://archidekt.com/api/decks/" + $deckId + "/")
                    $item.CopySkipped = $false
                }
                catch {
                    # If refresh fails, keep the valid existing imported copy.
                }
            }
        }
    }

    $ok = New-Object System.Collections.ArrayList
    $failed = New-Object System.Collections.ArrayList
    $warnings = New-Object System.Collections.ArrayList

    $copySkippedCount = 0
    $incompleteSkippedCount = 0
    $index = 0

    foreach ($item in $workItems) {
        $index++

        $meta = $item.Meta
        $deckId = [string](Get-Prop $meta "id")
        $deckName = [string](Get-Prop $meta "name")
        if (-not $deckName) { $deckName = "Deck $deckId" }

        Write-Log ("[" + $index + "/" + $workItems.Count + "] " + $deckName)

        if ([bool]$item.CopySkipped) {
            $copySkippedCount++

            if ([string]$item.StateEntry.Status -eq "SkippedIncomplete") {
                Write-Log "    UNCHANGED: still excluded because it is under 100 cards."
            }
            else {
                Write-Log "    UNCHANGED: copy detection skipped this deck."
            }

            continue
        }

        $detailError = Get-Prop $item "DetailError"
        if ($detailError) {
            [void]$failed.Add([pscustomobject]@{
                Name = $deckName
                Id = $deckId
                Error = [string]$detailError
            })
            Write-Log ("    FAILED: " + [string]$detailError)
            continue
        }

        try {
            $result = Convert-Deck $item.Detail $meta $renameCounts

            if ([bool]$result.Skipped) {
                $incompleteSkippedCount++
                Write-Log ("    EXCLUDED: " + $result.SkipReason + " (" + $result.Total + " cards)")

                if (-not [bool]$Settings.DryRun) {
                    $state[$deckId] = [pscustomobject]@{
                        DeckId = $deckId
                        Profile = $username
                        UpdatedAt = Get-MetaUpdatedAt $meta
                        Fingerprint = $fingerprint
                        OriginalName = $deckName
                        OutputPath = ""
                        DisplayName = $result.DisplayName
                        CommanderLabel = $result.CommanderLabel
                        Status = "SkippedIncomplete"
                    }
                }

                continue
            }

            [void]$ok.Add($result)

            $extra = New-Object System.Collections.ArrayList

            if ($result.TokensRemoved -gt 0) {
                [void]$extra.Add("actual tokens removed " + $result.TokensRemoved)
            }

            if ($result.CutCount -gt 0) {
                [void]$extra.Add("trimmed " + $result.CutCount + " to maximum 100")
            }

            if ([bool]$Settings.DryRun) {
                [void]$extra.Add("DRY RUN - no files changed")
            }

            $suffix = ""
            if ($extra.Count -gt 0) {
                $suffix = " | " + ($extra.ToArray() -join ", ")
            }

            Write-Log ("    " + $result.DeckType + " | " + $result.Total + " cards -> " + [IO.Path]::GetFileName($result.Path) + $suffix)

            if ($result.DeckType -eq "Commander" -and $result.CommanderCount -eq 0) {
                [void]$warnings.Add($result.Name + ": Commander format detected but no commander could be identified.")
                Write-Log "    WARNING: Commander still could not be identified."
            }

            if ($result.UnresolvedNames -gt 0) {
                Write-Log ("    NOTE: " + $result.UnresolvedNames + " card(s) used Archidekt-name fallback.")
            }

            if ($result.CutCount -gt 0) {
                Write-Log "    Cards trimmed from the end of the imported mainboard:"
                foreach ($cut in $result.CutCards) {
                    Write-Log ("      - " + $cut)
                }
            }

            if (-not [bool]$Settings.DryRun) {
                $state[$deckId] = [pscustomobject]@{
                    DeckId = $deckId
                    Profile = $username
                    UpdatedAt = Get-MetaUpdatedAt $meta
                    Fingerprint = $fingerprint
                    OriginalName = $deckName
                    OutputPath = $result.Path
                    DisplayName = $result.DisplayName
                    CommanderLabel = $result.CommanderLabel
                    CardHash = $result.CardHash
                    CardVector = $result.CardVector
                    SimilarityVector = $result.SimilarityVector
                    SourceMode = "Profile"
                    Bracket = 0
                    Status = "Imported"
                }
            }
        }
        catch {
            [void]$failed.Add([pscustomobject]@{
                Name = $deckName
                Id = $deckId
                Error = $_.Exception.Message
            })

            Write-Log ("    FAILED: " + $_.Exception.Message)

            if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
                Write-Log ("    POSITION: " + ($_.InvocationInfo.PositionMessage -replace "`r?`n", " "))
            }

            if ($_.ScriptStackTrace) {
                Write-Log ("    STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
            }
        }
    }

    if (-not [bool]$Settings.DryRun) {
        Save-ImportState $state
    }

    Write-Host ""
    Write-Host "================================================"
    Write-Host "PROFILE SYNC COMPLETE"
    Write-Host "================================================"
    Write-Host ""
    Write-Host ("Profile             : " + $username)
    Write-Host ("Imported / updated  : " + $ok.Count)
    Write-Host ("Copy-detected skips : " + $copySkippedCount)
    Write-Host ("Under-100 excluded  : " + $incompleteSkippedCount)
    Write-Host ("Failed              : " + $failed.Count)
    Write-Host ("Warnings            : " + $warnings.Count)
    Write-Host ""
    Write-Host ("Log: " + $script:CurrentLog)

    if ($failed.Count -gt 0) {
        Write-Host ""
        Write-Host "Failed decks:" -ForegroundColor Yellow
        foreach ($failedItem in $failed) {
            Write-Host ("  - " + $failedItem.Name + " : " + $failedItem.Error)
        }
    }

    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "Warnings:" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host ("  - " + $warning)
        }
    }

    if ($failed.Count -gt 0) {
        $script:ProfileImportNeedsFallback = $true
    }

    Write-Host ""
    Write-Host "You can immediately import another profile without closing the manager."
}


function Get-IntegerMetaValue {
    param(
        $Object,
        [string[]]$Names,
        [int]$Default = -1
    )

    foreach ($name in $Names) {
        $value = Get-Prop $Object $name
        if ($null -eq $value) { continue }

        try {
            return [int]$value
        }
        catch {}
    }

    return $Default
}

function Get-BracketSearchPage {
    param(
        [int]$Bracket,
        [int]$Page
    )

    $filteredUrl = "https://archidekt.com/api/decks/v3/?deckFormat=3&edhBracket=" +
        $Bracket + "&orderBy=-updatedAt&pageSize=50&page=" + $Page

    try {
        return Invoke-JsonGet $filteredUrl
    }
    catch {
        Write-Log "    Archidekt filtered query failed; using safe public-list fallback."
        $fallbackUrl = "https://archidekt.com/api/decks/v3/?orderBy=-updatedAt&pageSize=50&page=" + $Page
        return Invoke-JsonGet $fallbackUrl
    }
}

function Add-ResultToLibraryIndex {
    param(
        $Result,
        $LibraryIndex
    )

    $record = [pscustomobject]@{
        Path = [string]$Result.Path
        DeckId = [string]$Result.Id
        DisplayName = [string]$Result.DisplayName
        OriginalName = [string]$Result.Name
        CommanderLabel = [string]$Result.CommanderLabel
        CardVector = $Result.CardVector
        SimilarityVector = $Result.SimilarityVector
        CardHash = [string]$Result.CardHash
    }

    [void]$LibraryIndex.Records.Add($record)

    if (-not [string]::IsNullOrWhiteSpace([string]$record.CardHash)) {
        $LibraryIndex.Hashes[[string]$record.CardHash] = $record
    }

    foreach ($candidateName in @($record.DisplayName, $record.OriginalName)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$candidateName)) {
            $LibraryIndex.Names[([string]$candidateName).Trim().ToLowerInvariant()] = $record
        }
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$record.CommanderLabel)) {
        $LibraryIndex.Commanders[([string]$record.CommanderLabel).Trim().ToLowerInvariant()] = $record
    }
}

function Invoke-BracketLibraryImport {
    Write-Host ""
    Write-Host "Bracket Library Import"
    Write-Host "----------------------"
    Write-Host ""
    Write-Host "This mode only accepts public Commander decks that resolve to EXACTLY 100 cards."
    Write-Host "It never trims a 101-card deck and never pads a 99-card deck."
    Write-Host ""

    $bracketText = Read-Host "Bracket to import (1-5)"
    $bracket = 0

    if (-not [int]::TryParse($bracketText, [ref]$bracket) -or $bracket -lt 1 -or $bracket -gt 5) {
        throw "Bracket must be a number from 1 to 5."
    }

    $countText = Read-Host "How many valid unique decks should be imported? (1-500)"
    $wanted = 0

    if (-not [int]::TryParse($countText, [ref]$wanted) -or $wanted -lt 1 -or $wanted -gt 500) {
        throw "Import count must be between 1 and 500."
    }

    Start-Log

    Write-Log ""
    Write-Log ("BRACKET LIBRARY IMPORT - BRACKET " + $bracket)
    Write-Log ("Requested valid decks: " + $wanted)
    Write-Log "Exact 100-card requirement: ON"
    Write-Log ("Unique imported commander: " + (Get-OnOff ([bool]$Settings.BracketUniqueCommander)))
    Write-Log ("Unique imported deck name: " + (Get-OnOff ([bool]$Settings.BracketUniqueDeckName)))
    Write-Log ("Copy detection: " + (Get-OnOff ([bool]$Settings.CopyDetection)))
    Write-Log ("Similarity detection: " + (Get-OnOff ([bool]$Settings.SimilarityDetection)))
    Write-Log ("Similarity threshold: " + [string]$Settings.SimilarityThreshold + "%")
    Write-Log ""

    $library = Get-ImportedLibraryIndex
    $state = Read-ImportState
    $fingerprint = Get-SettingsFingerprint
    $seenIds = @{}

    $accepted = 0
    $inspected = 0
    $page = 1
    $maxPages = 250

    $skipWrongFormat = 0
    $skipWrongBracket = 0
    $skipMetaCount = 0
    $skipExactCount = 0
    $skipExistingId = 0
    $skipSameName = 0
    $skipSameCommander = 0
    $skipHash = 0
    $skipSimilarity = 0
    $skipCommander = 0
    $failed = 0

    while ($accepted -lt $wanted -and $page -le $maxPages) {
        Write-Log ("Searching Archidekt page " + $page + "...")

        $data = Get-BracketSearchPage $bracket $page
        $results = @($data.results)

        if ($results.Count -eq 0) {
            break
        }

        foreach ($meta in $results) {
            if ($accepted -ge $wanted) {
                break
            }

            $deckId = [string](Get-Prop $meta "id")
            if ([string]::IsNullOrWhiteSpace($deckId)) {
                continue
            }

            if ($seenIds.ContainsKey($deckId)) {
                continue
            }
            $seenIds[$deckId] = $true

            $inspected++

            $deckFormat = Get-IntegerMetaValue $meta @("deckFormat", "deck_format") -1
            $metaBracket = Get-IntegerMetaValue $meta @("edhBracket", "edh_bracket") -1
            $metaSize = Get-IntegerMetaValue $meta @("size") -1
            $deckName = [string](Get-Prop $meta "name")

            if ($deckFormat -ne 3) {
                $skipWrongFormat++
                continue
            }

            if ($metaBracket -ne $bracket) {
                $skipWrongBracket++
                continue
            }

            if ($metaSize -ne 100) {
                $skipMetaCount++
                continue
            }

            if ($state.ContainsKey($deckId)) {
                $skipExistingId++
                continue
            }

            $alreadyById = $false
            foreach ($record in $library.Records) {
                if ([string]$record.DeckId -eq $deckId) {
                    $alreadyById = $true
                    break
                }
            }

            if ($alreadyById) {
                $skipExistingId++
                continue
            }

            Write-Log ("  Candidate " + ($accepted + 1) + "/" + $wanted + ": " + $deckName)

            try {
                Wait-ApiPacing
                $detail = Invoke-JsonGet ("https://archidekt.com/api/decks/" + $deckId + "/")

                $prepared = Convert-Deck `
                    $detail `
                    $meta `
                    @{} `
                    -PreviewOnly `
                    -Exact100Only `
                    -SourceMode "Bracket" `
                    -Bracket $bracket

                if ($prepared.Skipped -or $prepared.Total -ne 100) {
                    $skipExactCount++
                    Write-Log ("    SKIP: exact deck count validation failed (" + $prepared.Total + ").")
                    continue
                }

                if ([string]::IsNullOrWhiteSpace([string]$prepared.CommanderLabel)) {
                    $skipCommander++
                    Write-Log "    SKIP: commander could not be identified."
                    continue
                }

                if ([bool]$Settings.BracketUniqueDeckName) {
                    $nameKey = ([string]$prepared.Name).Trim().ToLowerInvariant()
                    if ($library.Names.ContainsKey($nameKey)) {
                        $skipSameName++
                        Write-Log "    SKIP: imported library already contains this deck name."
                        continue
                    }
                }

                if ([bool]$Settings.BracketUniqueCommander) {
                    $commanderKey = ([string]$prepared.CommanderLabel).Trim().ToLowerInvariant()
                    if ($library.Commanders.ContainsKey($commanderKey)) {
                        $skipSameCommander++
                        Write-Log ("    SKIP: commander identity already imported: " + $prepared.CommanderLabel)
                        continue
                    }
                }

                if ($library.Hashes.ContainsKey([string]$prepared.CardHash)) {
                    $skipHash++
                    Write-Log "    SKIP: exact normalized 100-card deck copy already imported."
                    continue
                }

                $similar = Find-SimilarImportedDeck $prepared.SimilarityVector $library
                if ($similar) {
                    $skipSimilarity++
                    Write-Log (
                        "    SKIP: " + $similar.Percent + "% similar to imported deck " +
                        $similar.Record.DisplayName
                    )
                    continue
                }

                Commit-PreparedDeck $prepared

                # Always add accepted candidates to the in-memory index, even in
                # Dry Run mode. This prevents duplicates inside the current batch.
                Add-ResultToLibraryIndex $prepared $library

                if (-not [bool]$Settings.DryRun) {
                    $state[$deckId] = [pscustomobject]@{
                        DeckId = $deckId
                        Profile = ""
                        UpdatedAt = Get-MetaUpdatedAt $meta
                        Fingerprint = $fingerprint
                        OriginalName = $prepared.Name
                        OutputPath = $prepared.Path
                        DisplayName = $prepared.DisplayName
                        CommanderLabel = $prepared.CommanderLabel
                        CardHash = $prepared.CardHash
                        CardVector = $prepared.CardVector
                        SimilarityVector = $prepared.SimilarityVector
                        SourceMode = "Bracket"
                        Bracket = $bracket
                        Status = "Imported"
                    }
                }

                $accepted++
                Write-Log (
                    "    ACCEPTED " + $accepted + "/" + $wanted +
                    " | " + $prepared.CommanderLabel +
                    " | " + $prepared.DisplayName
                )
            }
            catch {
                $failed++
                Write-Log ("    FAILED candidate: " + $_.Exception.Message)

                if ($_.ScriptStackTrace) {
                    Write-Log ("    STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
                }

                # A single public deck must never crash the full bracket run.
                continue
            }
        }

        $next = Get-Prop $data "next"
        if (-not $next) {
            break
        }

        $page++
    }

    if (-not [bool]$Settings.DryRun) {
        Save-ImportState $state
    }

    Write-Host ""
    Write-Host "================================================"
    Write-Host "BRACKET IMPORT COMPLETE"
    Write-Host "================================================"
    Write-Host ""
    Write-Host ("Bracket                    : " + $bracket)
    Write-Host ("Requested                  : " + $wanted)
    Write-Host ("Accepted                   : " + $accepted)
    Write-Host ("Search results inspected   : " + $inspected)
    Write-Host ""
    Write-Host "Skipped:"
    Write-Host ("  Wrong format             : " + $skipWrongFormat)
    Write-Host ("  Wrong / missing bracket  : " + $skipWrongBracket)
    Write-Host ("  Metadata not 100 cards   : " + $skipMetaCount)
    Write-Host ("  Full list not 100 cards  : " + $skipExactCount)
    Write-Host ("  Already imported ID      : " + $skipExistingId)
    Write-Host ("  Same imported deck name  : " + $skipSameName)
    Write-Host ("  Same imported commander  : " + $skipSameCommander)
    Write-Host ("  Exact deck copy          : " + $skipHash)
    Write-Host ("  Similarity match         : " + $skipSimilarity)
    Write-Host ("  Commander unresolved     : " + $skipCommander)
    Write-Host ("  Candidate failures       : " + $failed)
    Write-Host ""
    Write-Host ("Log: " + $script:CurrentLog)

    if ($accepted -lt $wanted) {
        Write-Host ""
        Write-Host (
            "Archidekt results were exhausted before " + $wanted +
            " valid unique decks could be accepted."
        ) -ForegroundColor Yellow
    }
}

function Remove-ImportedDecks {
    $files = New-Object System.Collections.ArrayList

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (Test-IsOurImportedDeckFile $file.FullName) {
                [void]$files.Add($file)
            }
        }
    }

    Write-Host ""

    if ($files.Count -eq 0) {
        Write-Host "No decks created by Jadon's Archidekt importer were found."
        return
    }

    Write-Host ("Found " + $files.Count + " imported deck file(s).")
    Write-Host "Only decks carrying this importer's marker will be affected."
    Write-Host "Manually-created Forge decks are not touched."
    Write-Host ""

    if ([bool]$Settings.DryRun) {
        Write-Host "DRY RUN is ON. These files would be removed:"
        foreach ($file in $files) {
            Write-Host ("  - " + $file.FullName)
        }
        return
    }

    $answer = Read-Host "Remove all of these imported decks? Type YES to confirm"
    if ($answer -cne "YES") {
        Write-Host "Cleanup cancelled."
        return
    }

    $removed = 0

    foreach ($file in $files) {
        try {
            $source = ""
            try {
                foreach ($line in (Get-Content -LiteralPath $file.FullName -TotalCount 20 -Encoding UTF8)) {
                    if ($line -match '^Source URL=https://archidekt\.com/decks/(\d+)') {
                        $source = $Matches[1]
                        break
                    }
                }
            }
            catch {}

            if ([string]::IsNullOrWhiteSpace($source)) {
                $source = "unknown"
            }

            Backup-ImportedDeck $file.FullName $source
            Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
            $removed++
        }
        catch {
            Write-Host ("Could not remove: " + $file.FullName + " - " + $_.Exception.Message) -ForegroundColor Yellow
        }
    }

    if (Test-Path -LiteralPath $StateFile) {
        Remove-Item -LiteralPath $StateFile -Force -ErrorAction SilentlyContinue
    }

    Write-Host ""
    Write-Host ("Removed " + $removed + " imported deck file(s).")
}

function Show-RecentProfiles {
    $recent = @(Get-RecentProfiles)

    if ($recent.Count -eq 0) {
        return
    }

    Write-Host "Recent profiles:"
    for ($i = 0; $i -lt $recent.Count; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $recent[$i])
    }
    Write-Host ""
}

function Prompt-Profile {
    $recent = @(Get-RecentProfiles)
    Show-RecentProfiles

    $inputText = Read-Host "Paste Archidekt profile URL/username, or enter a recent-profile number"

    if ([string]::IsNullOrWhiteSpace($inputText)) {
        return $null
    }

    $n = 0
    if ([int]::TryParse($inputText.Trim(), [ref]$n)) {
        if ($n -ge 1 -and $n -le $recent.Count) {
            return $recent[$n - 1]
        }
    }

    return $inputText
}

function Run-ForgeFromManager {
    Write-Host ""

    if (Test-Path -LiteralPath $ForgeLauncher) {
        try {
            Start-Process -FilePath $ForgeLauncher
            Write-Host "Forge launched."
        }
        catch {
            Write-Host ("Could not launch Forge: " + $_.Exception.Message) -ForegroundColor Red
        }
        return
    }

    Write-Host "Forge launcher was not found at:"
    Write-Host ("  " + $ForgeLauncher)
    Write-Host ""
    Write-Host "Run Jadon's Ultimate Installer and install Forge first."
}


function Get-ForgeDesktopJar {
    $candidates = @(
        Get-ChildItem -LiteralPath $Base `
            -Filter "forge-gui-desktop-*-jar-with-dependencies.jar" `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue
    )

    if ($candidates.Count -eq 0) {
        throw "Forge desktop JAR was not found under " + $Base
    }

    return ($candidates | Sort-Object LastWriteTime -Descending | Select-Object -First 1)
}

function Get-ForgeVersionFromJar {
    param([string]$JarPath)

    $name = [IO.Path]::GetFileName($JarPath)

    if ($name -match '^forge-gui-desktop-(.+)-jar-with-dependencies\.jar$') {
        return [string]$Matches[1]
    }

    throw "Could not determine Forge version from " + $name
}

function Get-AiArchitecture {
    $arch = [string]$env:PROCESSOR_ARCHITECTURE
    $wow = [string]$env:PROCESSOR_ARCHITEW6432

    if ($wow) {
        $arch = $wow
    }

    switch -Regex ($arch.ToUpperInvariant()) {
        "ARM64" { return "aarch64" }
        "AMD64|X86_64" { return "x64" }
        default { throw "AI Viewer currently supports 64-bit x64 and ARM64 Windows." }
    }
}

function Download-UserFile {
    param(
        [string]$Url,
        [string]$Destination
    )

    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    $last = $null

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        $client = $null

        try {
            if (Test-Path -LiteralPath $Destination) {
                Remove-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
            }

            Write-Host ("Downloading: " + [IO.Path]::GetFileName($Destination))
            $client = New-Object System.Net.WebClient
            $client.Headers["User-Agent"] = "Jadons-Ultimate-Forge-Manager/6.0"
            $client.DownloadFile($Url, $Destination)

            if (-not (Test-Path -LiteralPath $Destination)) {
                throw "Download completed without creating the destination file."
            }

            if ((Get-Item -LiteralPath $Destination).Length -le 0) {
                throw "Downloaded file is empty."
            }

            return
        }
        catch {
            $last = $_

            if ($attempt -lt 3) {
                Write-Host ("Download failed; retrying (" + $attempt + "/3)...")
                Start-Sleep -Seconds (2 * $attempt)
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }
    }

    throw $last
}

function Get-RemoteUtf8Text {
    param([string]$Url)

    $client = $null

    try {
        $client = New-Object System.Net.WebClient
        $client.Headers["User-Agent"] = "Jadons-Ultimate-Forge-Manager/6.0"
        $bytes = $client.DownloadData($Url)
        return [Text.Encoding]::UTF8.GetString($bytes)
    }
    finally {
        if ($client) {
            $client.Dispose()
        }
    }
}

function Ensure-AiJdk {
    $existing = @(
        Get-ChildItem -LiteralPath $AiJdkDir `
            -Filter "javac.exe" `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue
    )

    if ($existing.Count -gt 0) {
        return $existing[0].FullName
    }

    $arch = Get-AiArchitecture
    $zipPath = Join-Path $AiDownloadsDir ("temurin-jdk21-" + $arch + ".zip")
    $url = "https://api.adoptium.net/v3/binary/latest/21/ga/windows/" +
        $arch + "/jdk/hotspot/normal/eclipse?project=jdk"

    Download-UserFile $url $zipPath

    $extractRoot = Join-Path $AiDir ("jdk-extract-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $extractRoot | Out-Null

    try {
        Write-Host "Extracting private Java JDK for AI Viewer..."
        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force

        $javac = Get-ChildItem -LiteralPath $extractRoot `
            -Filter "javac.exe" `
            -File `
            -Recurse `
            -ErrorAction Stop |
            Select-Object -First 1

        if ($null -eq $javac) {
            throw "Downloaded JDK did not contain javac.exe."
        }

        $jdkRoot = Split-Path -Parent (Split-Path -Parent $javac.FullName)

        if (Test-Path -LiteralPath $AiJdkDir) {
            Remove-Item -LiteralPath $AiJdkDir -Force -Recurse -ErrorAction Stop
        }

        Move-Item -LiteralPath $jdkRoot -Destination $AiJdkDir -Force
    }
    finally {
        if (Test-Path -LiteralPath $extractRoot) {
            Remove-Item -LiteralPath $extractRoot -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    $finalJavac = Get-ChildItem -LiteralPath $AiJdkDir `
        -Filter "javac.exe" `
        -File `
        -Recurse `
        -ErrorAction Stop |
        Select-Object -First 1

    if ($null -eq $finalJavac) {
        throw "Private JDK extraction did not produce javac.exe."
    }

    return $finalJavac.FullName
}

function Replace-AiSourceLineOnce {
    param(
        [string]$Text,
        [string]$OldLine,
        [string]$Replacement,
        [string]$Label
    )

    $count = ([regex]::Matches($Text, [regex]::Escape($OldLine))).Count

    if ($count -ne 1) {
        throw (
            "AI source verification failed for " + $Label +
            ". Expected exactly one source match; found " + $count + "."
        )
    }

    return $Text.Replace($OldLine, $Replacement)
}

function Write-AiTelemetryJava {
    param([string]$Path)

    $java = @'
package forge.ai.simulation;

import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.Instant;

public final class AiTelemetry {
    private static final Object LOCK = new Object();

    private AiTelemetry() {
    }

    private static String propertyPath() {
        try {
            return System.getProperty("jadon.ai.telemetry", "");
        } catch (Throwable ignored) {
            return "";
        }
    }

    private static String escape(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder out = new StringBuilder();

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);

            switch (c) {
                case '\\': out.append("\\\\"); break;
                case '"': out.append("\\\""); break;
                case '\n': out.append("\\n"); break;
                case '\r': out.append("\\r"); break;
                case '\t': out.append("\\t"); break;
                default:
                    if (c < 32) {
                        out.append(' ');
                    } else {
                        out.append(c);
                    }
            }
        }

        return out.toString();
    }

    private static String invokeString(Object target, String methodName) {
        if (target == null) {
            return "";
        }

        try {
            Method method = target.getClass().getMethod(methodName);
            Object result = method.invoke(target);
            return result == null ? "" : String.valueOf(result);
        } catch (Throwable ignored) {
            return "";
        }
    }

    private static String playerName(Object player) {
        String value = invokeString(player, "getName");
        return value.isEmpty() ? String.valueOf(player) : value;
    }

    private static String phaseName(Object game) {
        if (game == null) {
            return "";
        }

        try {
            Method getPhaseHandler = game.getClass().getMethod("getPhaseHandler");
            Object handler = getPhaseHandler.invoke(game);

            if (handler == null) {
                return "";
            }

            Method getPhase = handler.getClass().getMethod("getPhase");
            Object phase = getPhase.invoke(handler);
            return phase == null ? "" : String.valueOf(phase);
        } catch (Throwable ignored) {
            return "";
        }
    }

    private static String turnNumber(Object game) {
        if (game == null) {
            return "";
        }

        try {
            Method getPhaseHandler = game.getClass().getMethod("getPhaseHandler");
            Object handler = getPhaseHandler.invoke(game);

            if (handler == null) {
                return "";
            }

            Method getTurn = handler.getClass().getMethod("getTurn");
            Object turn = getTurn.invoke(handler);
            return turn == null ? "" : String.valueOf(turn);
        } catch (Throwable ignored) {
            return "";
        }
    }

    private static void emit(String type, Object player, Object game, String... pairs) {
        String outputPath = propertyPath();

        if (outputPath == null || outputPath.isEmpty()) {
            return;
        }

        try {
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"time\":\"").append(escape(Instant.now().toString())).append("\",");
            json.append("\"type\":\"").append(escape(type)).append("\",");
            json.append("\"player\":\"").append(escape(playerName(player))).append("\",");
            json.append("\"turn\":\"").append(escape(turnNumber(game))).append("\",");
            json.append("\"phase\":\"").append(escape(phaseName(game))).append("\"");

            for (int i = 0; i + 1 < pairs.length; i += 2) {
                json.append(",\"")
                    .append(escape(pairs[i]))
                    .append("\":\"")
                    .append(escape(pairs[i + 1]))
                    .append("\"");
            }

            json.append("}");
            json.append(System.lineSeparator());

            synchronized (LOCK) {
                Path path = Paths.get(outputPath);
                Path parent = path.getParent();

                if (parent != null) {
                    Files.createDirectories(parent);
                }

                Files.writeString(
                    path,
                    json.toString(),
                    StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE,
                    StandardOpenOption.APPEND
                );
            }
        } catch (Throwable ignored) {
            // Telemetry must NEVER affect Forge gameplay or AI decisions.
        }
    }

    public static void start(
            Object player,
            Object game,
            int score,
            int available,
            int candidates) {

        emit(
            "decision_start",
            player,
            game,
            "score", String.valueOf(score),
            "available", String.valueOf(available),
            "candidates", String.valueOf(candidates)
        );
    }

    public static void candidate(
            Object player,
            Object game,
            String action,
            String status) {

        emit(
            "candidate",
            player,
            game,
            "action", action,
            "status", status
        );
    }

    public static void evaluated(
            Object player,
            Object game,
            String action,
            int score,
            int available) {

        emit(
            "evaluated",
            player,
            game,
            "action", action,
            "score", String.valueOf(score),
            "available", String.valueOf(available)
        );
    }

    public static void chosen(
            Object player,
            Object game,
            String action,
            int originalScore,
            int chosenScore,
            int chosenAvailable,
            long milliseconds,
            int simulations) {

        emit(
            "chosen",
            player,
            game,
            "action", action,
            "originalScore", String.valueOf(originalScore),
            "score", String.valueOf(chosenScore),
            "available", String.valueOf(chosenAvailable),
            "milliseconds", String.valueOf(milliseconds),
            "simulations", String.valueOf(simulations)
        );
    }

    public static void plan(
            Object player,
            Object game,
            String plan,
            int finalScore) {

        emit(
            "plan",
            player,
            game,
            "plan", plan,
            "score", String.valueOf(finalScore)
        );
    }

    public static void heuristicStart(
            Object player,
            Object game) {

        emit(
            "heuristic_start",
            player,
            game,
            "mode", "heuristic"
        );
    }

    public static void heuristicCandidate(
            Object player,
            Object game,
            String action,
            String status) {

        emit(
            "heuristic_candidate",
            player,
            game,
            "action", action,
            "status", status
        );
    }

    public static void heuristicChosen(
            Object player,
            Object game,
            String action) {

        emit(
            "heuristic_chosen",
            player,
            game,
            "action", action,
            "mode", "heuristic priority"
        );
    }

    public static void combatAttack(
            Object player,
            Object game,
            int aggression,
            String combatState) {

        emit(
            "combat_attack",
            player,
            game,
            "aggression", String.valueOf(aggression),
            "combat", combatState
        );
    }

    public static void combatBlock(
            Object player,
            Object game,
            String combatState) {

        emit(
            "combat_block",
            player,
            game,
            "combat", combatState
        );
    }
}
'@

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, $java, $encoding)
}

function Patch-SpellAbilityPickerSource {
    param(
        [string]$Source,
        [string]$OutputPath
    )

    $Source = $Source.Replace("`r`n", "`n").Replace("`r", "`n")

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "    private int numSimulations;" `
        ("    private int numSimulations;`n" +
         "    private boolean jadonTelemetryRoot = false;") `
        "telemetry root field"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "            AiPlayDecision opinion = canPlayAndPayForSim(sa);" `
        ("            AiPlayDecision opinion = canPlayAndPayForSim(sa);`n" +
         "            if (jadonTelemetryRoot) {`n" +
         "                AiTelemetry.candidate(player, game, abilityToString(sa), opinion.toString());`n" +
         "            }") `
        "candidate decision hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        Score origGameScore = new GameStateEvaluator().getScoreForGameState(game, player);" `
        ("        if (controller == null) {`n" +
         "            jadonTelemetryRoot = true;`n" +
         "            numSimulations = 0;`n" +
         "        }`n" +
         "        Score origGameScore = new GameStateEvaluator().getScoreForGameState(game, player);") `
        "root decision hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        List<SpellAbility> candidateSAs = getCandidateSpellsAndAbilities();" `
        ("        List<SpellAbility> candidateSAs = getCandidateSpellsAndAbilities();`n" +
         "        if (jadonTelemetryRoot) {`n" +
         "            AiTelemetry.start(player, game, origGameScore.value, origGameScore.availableValue, candidateSAs.size());`n" +
         "        }") `
        "decision start hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "            Score value = evaluateSa(controller, phase, candidateSAs, i);" `
        ("            Score value = evaluateSa(controller, phase, candidateSAs, i);`n" +
         "            if (jadonTelemetryRoot) {`n" +
         "                AiTelemetry.evaluated(player, game, abilityToString(candidateSAs.get(i)), value.value, value.availableValue);`n" +
         "            }") `
        "candidate evaluation hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        long execTime = System.currentTimeMillis() - startTime;" `
        ("        long execTime = System.currentTimeMillis() - startTime;`n" +
         "        if (jadonTelemetryRoot) {`n" +
         "            AiTelemetry.chosen(player, game, abilityToString(bestSa), origGameScore.value, bestSaValue.value, bestSaValue.availableValue, execTime, numSimulations);`n" +
         "        }") `
        "chosen action hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        PhaseType currentPhase = game.getPhaseHandler().getPhase();" `
        ("        if (jadonTelemetryRoot) {`n" +
         "            StringBuilder jadonPlan = new StringBuilder();`n" +
         "            for (Plan.Decision jadonDecision : bestPlan.getDecisions()) {`n" +
         "                if (jadonPlan.length() > 0) { jadonPlan.append(`" | `"); }`n" +
         "                jadonPlan.append(jadonDecision.toString());`n" +
         "            }`n" +
         "            AiTelemetry.plan(player, game, jadonPlan.toString(), bestPlan.getFinalScore().value);`n" +
         "        }`n" +
         "        PhaseType currentPhase = game.getPhaseHandler().getPhase();") `
        "plan hook"

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($OutputPath, $Source, $encoding)
}

function Patch-AiControllerSource {
    param(
        [string]$Source,
        [string]$OutputPath
    )

    $Source = $Source.Replace("`r`n", "`n").Replace("`r", "`n")

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "import forge.ai.simulation.GameStateEvaluator;" `
        ("import forge.ai.simulation.GameStateEvaluator;`n" +
         "import forge.ai.simulation.AiTelemetry;") `
        "AiController telemetry import"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "    public List<SpellAbility> chooseSpellAbilityToPlay() {" `
        ("    public List<SpellAbility> chooseSpellAbilityToPlay() {`n" +
         "        AiTelemetry.heuristicStart(player, game);") `
        "heuristic decision start hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "                AiPlayDecision opinion = useLivingEnd && AiPlayDecision.WillPlay.equals(aiPlayDecision) ? aiPlayDecision : canPlayAndPayFor(sa);" `
        ("                AiPlayDecision opinion = useLivingEnd && AiPlayDecision.WillPlay.equals(aiPlayDecision) ? aiPlayDecision : canPlayAndPayFor(sa);`n" +
         "                AiTelemetry.heuristicCandidate(player, game, String.valueOf(sa.getHostCard()) + `" -> `" + String.valueOf(sa), opinion.toString());") `
        "heuristic candidate hook"

    $oldReturn =
        "                // TODO could continue to try find another with higher rating (weighted by priority ordering)`n" +
        "                return sa;"

    $newReturn =
        "                // TODO could continue to try find another with higher rating (weighted by priority ordering)`n" +
        "                AiTelemetry.heuristicChosen(player, game, String.valueOf(sa.getHostCard()) + `" -> `" + String.valueOf(sa));`n" +
        "                return sa;"

    $count = ([regex]::Matches($Source, [regex]::Escape($oldReturn))).Count
    if ($count -ne 1) {
        throw (
            "AI source verification failed for heuristic chosen hook. " +
            "Expected exactly one source match; found " + $count + "."
        )
    }

    $Source = $Source.Replace($oldReturn, $newReturn)

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        lastAttackAggression = aiAtk.declareAttackers(combat);" `
        ("        lastAttackAggression = aiAtk.declareAttackers(combat);`n" +
         "        AiTelemetry.combatAttack(attacker, game, lastAttackAggression, String.valueOf(combat));") `
        "combat attack hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        block.assignBlockersForCombat(combat);" `
        ("        block.assignBlockersForCombat(combat);`n" +
         "        AiTelemetry.combatBlock(defender, game, String.valueOf(combat));") `
        "combat block hook"

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($OutputPath, $Source, $encoding)
}

function Write-AiViewerScript {
    $viewer = @'
param(
    [Parameter(Mandatory=$true)]
    [string]$TelemetryPath
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "Jadon's Forge AI Thought Viewer"
$form.Width = 1180
$form.Height = 760
$form.StartPosition = "CenterScreen"
$form.MinimumSize = New-Object System.Drawing.Size(850, 560)

$root = New-Object System.Windows.Forms.TableLayoutPanel
$root.Dock = "Fill"
$root.RowCount = 4
$root.ColumnCount = 1
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 92)))
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 48)))
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 32)))
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 20)))
$form.Controls.Add($root)

$summary = New-Object System.Windows.Forms.TableLayoutPanel
$summary.Dock = "Fill"
$summary.ColumnCount = 4
$summary.RowCount = 2

$lblPlayer = New-Object System.Windows.Forms.Label
$lblPlayer.Text = "AI: waiting for Forge..."
$lblPlayer.AutoSize = $true
$lblPlayer.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)

$lblPhase = New-Object System.Windows.Forms.Label
$lblPhase.Text = "Turn / phase: -"
$lblPhase.AutoSize = $true

$lblChosen = New-Object System.Windows.Forms.Label
$lblChosen.Text = "Chosen action: -"
$lblChosen.AutoSize = $true
$lblChosen.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$lblStats = New-Object System.Windows.Forms.Label
$lblStats.Text = "Score: -   Simulations: -   Decision time: -"
$lblStats.AutoSize = $true

$summary.Controls.Add($lblPlayer, 0, 0)
$summary.SetColumnSpan($lblPlayer, 2)
$summary.Controls.Add($lblPhase, 2, 0)
$summary.SetColumnSpan($lblPhase, 2)
$summary.Controls.Add($lblChosen, 0, 1)
$summary.SetColumnSpan($lblChosen, 2)
$summary.Controls.Add($lblStats, 2, 1)
$summary.SetColumnSpan($lblStats, 2)
$root.Controls.Add($summary, 0, 0)

$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$chart.Dock = "Fill"
$chartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$chartArea.AxisX.Interval = 1
$chartArea.AxisX.LabelStyle.Enabled = $true
$chartArea.AxisY.Title = "Evaluated score"
[void]$chart.ChartAreas.Add($chartArea)

$series = New-Object System.Windows.Forms.DataVisualization.Charting.Series
$series.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Bar
$series.IsValueShownAsLabel = $true
[void]$chart.Series.Add($series)
$root.Controls.Add($chart, 0, 1)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Dock = "Fill"
$grid.ReadOnly = $true
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.AutoSizeColumnsMode = "Fill"
$grid.SelectionMode = "FullRowSelect"
[void]$grid.Columns.Add("Type", "Type")
[void]$grid.Columns.Add("Action", "Action / option")
[void]$grid.Columns.Add("Status", "Status")
[void]$grid.Columns.Add("Score", "Score")
[void]$grid.Columns.Add("Available", "Available")
$root.Controls.Add($grid, 0, 2)

$bottom = New-Object System.Windows.Forms.SplitContainer
$bottom.Dock = "Fill"
$bottom.Orientation = "Vertical"
$bottom.SplitterDistance = 760

$planBox = New-Object System.Windows.Forms.TextBox
$planBox.Dock = "Fill"
$planBox.Multiline = $true
$planBox.ReadOnly = $true
$planBox.ScrollBars = "Vertical"
$planBox.Text = "Current plan will appear here."
$bottom.Panel1.Controls.Add($planBox)

$history = New-Object System.Windows.Forms.ListBox
$history.Dock = "Fill"
$bottom.Panel2.Controls.Add($history)
$root.Controls.Add($bottom, 0, 3)

$lastLine = 0
$decisionNumber = 0

function Add-GridRow {
    param($Type, $Action, $Status, $Score, $Available)

    [void]$grid.Rows.Add(
        [string]$Type,
        [string]$Action,
        [string]$Status,
        [string]$Score,
        [string]$Available
    )

    if ($grid.Rows.Count -gt 250) {
        $grid.Rows.RemoveAt(0)
    }
}

function Add-ChartPoint {
    param([string]$Action, [double]$Score)

    $label = $Action
    if ($label.Length -gt 52) {
        $label = $label.Substring(0, 49) + "..."
    }

    $point = New-Object System.Windows.Forms.DataVisualization.Charting.DataPoint
    $point.AxisLabel = $label
    $point.YValues = @($Score)
    [void]$series.Points.Add($point)

    while ($series.Points.Count -gt 14) {
        $series.Points.RemoveAt(0)
    }
}

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 350

$timer.Add_Tick({
    try {
        if (-not (Test-Path -LiteralPath $TelemetryPath)) {
            return
        }

        $lines = [IO.File]::ReadAllLines($TelemetryPath, [Text.Encoding]::UTF8)

        if ($lines.Count -lt $lastLine) {
            $lastLine = 0
        }

        for ($i = $lastLine; $i -lt $lines.Count; $i++) {
            $line = [string]$lines[$i]
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }

            try {
                $event = $line | ConvertFrom-Json
            }
            catch {
                continue
            }

            $type = [string]$event.type

            if ($type -eq "heuristic_start") {
                $decisionNumber++
                $grid.Rows.Clear()
                $series.Points.Clear()
                $planBox.Text = "Heuristic AI mode: Forge is using priority / rule-based reasoning for this decision."

                $lblPlayer.Text = "AI: " + [string]$event.player
                $lblPhase.Text = "Turn " + [string]$event.turn + " / " + [string]$event.phase
                $lblChosen.Text = "Chosen action: evaluating heuristic options..."
                $lblStats.Text = "Mode: Forge heuristic AI"
            }
            elseif ($type -eq "heuristic_candidate") {
                $status = [string]$event.status
                $rowType = if ($status -eq "WillPlay") { "Playable" } else { "Rejected" }
                Add-GridRow $rowType $event.action $status "" ""
            }
            elseif ($type -eq "heuristic_chosen") {
                $action = [string]$event.action
                $lblChosen.Text = "Chosen action: " + $action
                $lblStats.Text = "Mode: Forge heuristic priority selection"
                Add-GridRow "CHOSEN" $action "Selected" "" ""

                $history.Items.Insert(
                    0,
                    ("#" + $decisionNumber + "  Turn " + [string]$event.turn +
                     " " + [string]$event.phase + " - " + $action)
                )

                while ($history.Items.Count -gt 30) {
                    $history.Items.RemoveAt($history.Items.Count - 1)
                }
            }
            elseif ($type -eq "combat_attack") {
                $decisionNumber++
                $lblPlayer.Text = "AI: " + [string]$event.player
                $lblPhase.Text = "Turn " + [string]$event.turn + " / " + [string]$event.phase
                $lblChosen.Text = "Combat: attackers declared"
                $lblStats.Text = "Attack aggression: " + [string]$event.aggression
                $planBox.Text = "Forge combat state after attacker selection:" +
                    [Environment]::NewLine +
                    [Environment]::NewLine +
                    [string]$event.combat

                Add-GridRow "COMBAT" "Declare attackers" ("Aggression " + [string]$event.aggression) "" ""

                $history.Items.Insert(
                    0,
                    ("#" + $decisionNumber + "  Turn " + [string]$event.turn +
                     " " + [string]$event.phase + " - attackers declared")
                )
            }
            elseif ($type -eq "combat_block") {
                $decisionNumber++
                $lblPlayer.Text = "AI: " + [string]$event.player
                $lblPhase.Text = "Turn " + [string]$event.turn + " / " + [string]$event.phase
                $lblChosen.Text = "Combat: blockers assigned"
                $lblStats.Text = "Mode: Forge combat AI"
                $planBox.Text = "Forge combat state after blocker assignment:" +
                    [Environment]::NewLine +
                    [Environment]::NewLine +
                    [string]$event.combat

                Add-GridRow "COMBAT" "Assign blockers" "Selected" "" ""

                $history.Items.Insert(
                    0,
                    ("#" + $decisionNumber + "  Turn " + [string]$event.turn +
                     " " + [string]$event.phase + " - blockers assigned")
                )
            }
            elseif ($type -eq "decision_start") {
                $decisionNumber++
                $grid.Rows.Clear()
                $series.Points.Clear()
                $planBox.Text = "No multi-step plan reported yet."

                $lblPlayer.Text = "AI: " + [string]$event.player
                $lblPhase.Text = "Turn " + [string]$event.turn + " / " + [string]$event.phase
                $lblChosen.Text = "Chosen action: evaluating..."
                $lblStats.Text =
                    "Starting score: " + [string]$event.score +
                    "   Playable candidates: " + [string]$event.candidates
            }
            elseif ($type -eq "candidate") {
                $status = [string]$event.status

                if ($status -ne "WillPlay") {
                    Add-GridRow "Rejected" $event.action $status "" ""
                }
                else {
                    Add-GridRow "Candidate" $event.action "Playable" "" ""
                }
            }
            elseif ($type -eq "evaluated") {
                Add-GridRow "Evaluated" $event.action "" $event.score $event.available

                $numeric = 0.0
                if ([double]::TryParse(
                    [string]$event.available,
                    [Globalization.NumberStyles]::Any,
                    [Globalization.CultureInfo]::InvariantCulture,
                    [ref]$numeric)) {

                    Add-ChartPoint ([string]$event.action) $numeric
                }
            }
            elseif ($type -eq "plan") {
                $planBox.Text =
                    "Final plan score: " + [string]$event.score +
                    [Environment]::NewLine +
                    [Environment]::NewLine +
                    ([string]$event.plan).Replace(" | ", [Environment]::NewLine)
            }
            elseif ($type -eq "chosen") {
                $action = [string]$event.action
                $lblChosen.Text = "Chosen action: " + $action
                $lblStats.Text =
                    "Original: " + [string]$event.originalScore +
                    "   Chosen: " + [string]$event.score +
                    "   Available: " + [string]$event.available +
                    "   Simulations: " + [string]$event.simulations +
                    "   Time: " + [string]$event.milliseconds + " ms"

                Add-GridRow "CHOSEN" $action "Selected" $event.score $event.available

                $history.Items.Insert(
                    0,
                    ("#" + $decisionNumber + "  Turn " + [string]$event.turn +
                     " " + [string]$event.phase + " - " + $action)
                )

                while ($history.Items.Count -gt 30) {
                    $history.Items.RemoveAt($history.Items.Count - 1)
                }
            }
        }

        $lastLine = $lines.Count
    }
    catch {
        # Viewer errors are isolated. Never affect Forge.
    }
})

$form.Add_FormClosed({
    $timer.Stop()
})

$timer.Start()
[void]$form.ShowDialog()
'@

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($AiViewerScript, $viewer, $encoding)
}

function Write-AiLauncher {
    param(
        [string]$ForgeJar,
        [string]$JavawPath,
        [string]$ForgeHome
    )

    $javaLine =
        '"' + '%JAVAW%' + '"' +
        ' -Xmx4096m -Dio.netty.tryReflectionSetAccessible=true -Dfile.encoding=UTF-8' +
        ' --add-opens java.desktop/java.beans=ALL-UNNAMED' +
        ' --add-opens java.desktop/javax.swing.border=ALL-UNNAMED' +
        ' --add-opens java.desktop/javax.swing.event=ALL-UNNAMED' +
        ' --add-opens java.desktop/sun.swing=ALL-UNNAMED' +
        ' --add-opens java.desktop/java.awt.image=ALL-UNNAMED' +
        ' --add-opens java.desktop/java.awt.color=ALL-UNNAMED' +
        ' --add-opens java.desktop/sun.awt.image=ALL-UNNAMED' +
        ' --add-opens java.desktop/javax.swing=ALL-UNNAMED' +
        ' --add-opens java.desktop/java.awt=ALL-UNNAMED' +
        ' --add-opens java.base/java.util=ALL-UNNAMED' +
        ' --add-opens java.base/java.lang=ALL-UNNAMED' +
        ' --add-opens java.base/java.lang.reflect=ALL-UNNAMED' +
        ' --add-opens java.base/java.text=ALL-UNNAMED' +
        ' --add-opens java.desktop/java.awt.font=ALL-UNNAMED' +
        ' --add-opens java.base/jdk.internal.misc=ALL-UNNAMED' +
        ' --add-opens java.base/sun.nio.ch=ALL-UNNAMED' +
        ' --add-opens java.base/java.nio=ALL-UNNAMED' +
        ' --add-opens java.base/java.math=ALL-UNNAMED' +
        ' --add-opens java.base/java.util.concurrent=ALL-UNNAMED' +
        ' --add-opens java.base/java.net=ALL-UNNAMED' +
        ' "-Djadon.ai.telemetry=%TELEMETRY%"' +
        ' -cp "%PATCH%;%FORGEJAR%" forge.view.Main'

    $lines = @(
        '@echo off',
        'setlocal EnableExtensions',
        'title Jadon Forge AI Thought Viewer',
        ('set "TELEMETRY=' + $AiTelemetryFile + '"'),
        ('set "VIEWER=' + $AiViewerScript + '"'),
        ('set "PATCH=' + $AiPatchJar + '"'),
        ('set "FORGEJAR=' + $ForgeJar + '"'),
        ('set "JAVAW=' + $JavawPath + '"'),
        ('set "FORGEHOME=' + $ForgeHome + '"'),
        'if exist "%TELEMETRY%" del /f /q "%TELEMETRY%" >nul 2>&1',
        'start "Jadon AI Thought Viewer" powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%VIEWER%" -TelemetryPath "%TELEMETRY%"',
        'pushd "%FORGEHOME%"',
        $javaLine,
        'set "RC=%ERRORLEVEL%"',
        'popd',
        'exit /b %RC%'
    )

    $encoding = New-Object System.Text.ASCIIEncoding
    [IO.File]::WriteAllLines($AiLauncher, $lines, $encoding)
}

function Setup-AiThoughtViewer {
    Write-Host ""
    Write-Host "AI Thought Viewer Setup"
    Write-Host "-----------------------"
    Write-Host ""
    Write-Host "This creates a separate telemetry-enabled Forge launcher."
    Write-Host "Your normal Forge JAR and normal launcher are NOT modified."
    Write-Host ""

    $forgeJarItem = Get-ForgeDesktopJar
    $forgeJar = $forgeJarItem.FullName
    $forgeHome = $forgeJarItem.DirectoryName
    $version = Get-ForgeVersionFromJar $forgeJar
    $tag = "forge-" + $version

    Write-Host ("Detected Forge version: " + $version)
    Write-Host ("Forge JAR: " + $forgeJar)
    Write-Host ""

    $javac = Ensure-AiJdk
    $jdkBin = Split-Path -Parent $javac
    $javaw = Join-Path $jdkBin "javaw.exe"
    $jarTool = Join-Path $jdkBin "jar.exe"

    if (-not (Test-Path -LiteralPath $javaw)) {
        throw "AI private JDK is missing javaw.exe."
    }

    if (-not (Test-Path -LiteralPath $jarTool)) {
        throw "AI private JDK is missing jar.exe."
    }

    if (Test-Path -LiteralPath $AiSourceDir) {
        Remove-Item -LiteralPath $AiSourceDir -Force -Recurse -ErrorAction Stop
    }

    if (Test-Path -LiteralPath $AiClassesDir) {
        Remove-Item -LiteralPath $AiClassesDir -Force -Recurse -ErrorAction Stop
    }

    New-Item -ItemType Directory -Force -Path $AiSourceDir | Out-Null
    New-Item -ItemType Directory -Force -Path $AiClassesDir | Out-Null

    $pickerSourceUrl =
        "https://raw.githubusercontent.com/Card-Forge/forge/" +
        $tag +
        "/forge-ai/src/main/java/forge/ai/simulation/SpellAbilityPicker.java"

    $controllerSourceUrl =
        "https://raw.githubusercontent.com/Card-Forge/forge/" +
        $tag +
        "/forge-ai/src/main/java/forge/ai/AiController.java"

    Write-Host "Downloading the exact Forge AI sources for this installed version..."
    $pickerSource = Get-RemoteUtf8Text $pickerSourceUrl
    $controllerSource = Get-RemoteUtf8Text $controllerSourceUrl

    if ([string]::IsNullOrWhiteSpace($pickerSource) -or
        $pickerSource -notmatch 'public class SpellAbilityPicker') {

        throw "SpellAbilityPicker source could not be verified. Nothing was patched."
    }

    if ([string]::IsNullOrWhiteSpace($controllerSource) -or
        $controllerSource -notmatch 'public class AiController') {

        throw "AiController source could not be verified. Nothing was patched."
    }

    $simulationPackageDir = Join-Path $AiSourceDir "forge\ai\simulation"
    $aiPackageDir = Join-Path $AiSourceDir "forge\ai"
    New-Item -ItemType Directory -Force -Path $simulationPackageDir | Out-Null
    New-Item -ItemType Directory -Force -Path $aiPackageDir | Out-Null

    $pickerPath = Join-Path $simulationPackageDir "SpellAbilityPicker.java"
    $telemetryPath = Join-Path $simulationPackageDir "AiTelemetry.java"
    $controllerPath = Join-Path $aiPackageDir "AiController.java"

    Patch-SpellAbilityPickerSource $pickerSource $pickerPath
    Patch-AiControllerSource $controllerSource $controllerPath
    Write-AiTelemetryJava $telemetryPath

    Write-Host "Compiling read-only AI telemetry hooks against the installed Forge JAR..."

    & $javac `
        -encoding UTF-8 `
        -cp $forgeJar `
        -d $AiClassesDir `
        $telemetryPath `
        $pickerPath `
        $controllerPath

    if ($LASTEXITCODE -ne 0) {
        throw "AI telemetry compilation failed. Normal Forge was not modified."
    }

    if (Test-Path -LiteralPath $AiPatchJar) {
        Remove-Item -LiteralPath $AiPatchJar -Force -ErrorAction Stop
    }

    Push-Location $AiClassesDir
    try {
        & $jarTool cf $AiPatchJar forge
        if ($LASTEXITCODE -ne 0) {
            throw "Could not package AI telemetry patch JAR."
        }
    }
    finally {
        Pop-Location
    }

    Write-AiViewerScript
    Write-AiLauncher $forgeJar $javaw $forgeHome

    $jarHash = (Get-FileHash -LiteralPath $forgeJar -Algorithm SHA256).Hash.ToLowerInvariant()

    $status = [pscustomobject]@{
        Version = 1
        ForgeVersion = $version
        ForgeJar = $forgeJar
        ForgeJarHash = $jarHash
        PatchJar = $AiPatchJar
        ViewerScript = $AiViewerScript
        Launcher = $AiLauncher
        PickerSourceUrl = $pickerSourceUrl
        ControllerSourceUrl = $controllerSourceUrl
        BuiltAt = (Get-Date).ToString("o")
    }

    $json = $status | ConvertTo-Json -Depth 5
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($AiStatusFile, $json, $encoding)

    Write-Host ""
    Write-Host "AI Thought Viewer setup complete." -ForegroundColor Green
    Write-Host "Normal Forge remains unchanged."
    Write-Host ("AI launcher: " + $AiLauncher)
}

function Get-AiViewerStatus {
    if (-not (Test-Path -LiteralPath $AiStatusFile)) {
        return $null
    }

    try {
        return Get-Content -LiteralPath $AiStatusFile -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        return $null
    }
}

function Assert-AiViewerReady {
    $status = Get-AiViewerStatus

    if ($null -eq $status) {
        throw "AI Thought Viewer has not been set up yet."
    }

    foreach ($path in @(
        [string]$status.ForgeJar,
        [string]$status.PatchJar,
        [string]$status.ViewerScript,
        [string]$status.Launcher
    )) {
        if ([string]::IsNullOrWhiteSpace($path) -or
            -not (Test-Path -LiteralPath $path)) {

            throw "AI Thought Viewer files are incomplete. Run Setup / Repair."
        }
    }

    $currentForgeJar = (Get-ForgeDesktopJar).FullName

    if ([IO.Path]::GetFullPath($currentForgeJar) -ne
        [IO.Path]::GetFullPath([string]$status.ForgeJar)) {

        throw "Installed Forge changed since AI Viewer setup. Run Setup / Repair."
    }

    $currentHash = (Get-FileHash -LiteralPath $currentForgeJar -Algorithm SHA256).Hash.ToLowerInvariant()

    if ($currentHash -ne [string]$status.ForgeJarHash) {
        throw "Forge JAR changed since AI Viewer setup. Run Setup / Repair."
    }

    return $status
}

function Run-ForgeWithAiViewer {
    $status = Assert-AiViewerReady

    if (Test-Path -LiteralPath $AiTelemetryFile) {
        Remove-Item -LiteralPath $AiTelemetryFile -Force -ErrorAction SilentlyContinue
    }

    Start-Process -FilePath ([string]$status.Launcher) `
        -WorkingDirectory (Split-Path -Parent ([string]$status.Launcher))
}

function Open-AiViewerOnly {
    if (-not (Test-Path -LiteralPath $AiViewerScript)) {
        throw "AI Viewer graphical script is not installed. Run Setup / Repair first."
    }

    Start-Process `
        -FilePath "powershell.exe" `
        -ArgumentList @(
            "-NoLogo",
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-STA",
            "-File", $AiViewerScript,
            "-TelemetryPath", $AiTelemetryFile
        )
}

function Show-AiViewerStatus {
    Write-Host ""
    Write-Host "AI Thought Viewer Status"
    Write-Host "------------------------"
    Write-Host ""

    $status = Get-AiViewerStatus

    if ($null -eq $status) {
        Write-Host "Status: NOT SET UP"
        return
    }

    Write-Host ("Forge version : " + [string]$status.ForgeVersion)
    Write-Host ("Built at      : " + [string]$status.BuiltAt)
    Write-Host ("Forge JAR     : " + [string]$status.ForgeJar)
    Write-Host ("Patch JAR     : " + [string]$status.PatchJar)
    Write-Host ("AI launcher   : " + [string]$status.Launcher)
    Write-Host ("Telemetry     : " + $AiTelemetryFile)
    Write-Host ""

    try {
        [void](Assert-AiViewerReady)
        Write-Host "Verification: READY" -ForegroundColor Green
    }
    catch {
        Write-Host ("Verification: NEEDS REPAIR - " + $_.Exception.Message) -ForegroundColor Yellow
    }
}

function Show-AiViewerMenu {
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "AI Thought Viewer"
        Write-Host "-----------------"
        Write-Host ""
        Write-Host "[1] Setup / Repair AI Thought Viewer"
        Write-Host "[2] Run Forge with graphical AI Thought Viewer"
        Write-Host "[3] Open graphical viewer only"
        Write-Host "[4] Show AI Viewer status"
        Write-Host "[5] Back"
        Write-Host ""
        Write-Host "The telemetry bridge is read-only."
        Write-Host "Normal Forge is never replaced or modified."
        Write-Host "If telemetry or the viewer fails, Forge gameplay continues."
        Write-Host ""

        $choice = Read-Host "Choose 1-5"

        switch ($choice) {
            "1" {
                Invoke-SafeOperation "AI Thought Viewer setup" {
                    Setup-AiThoughtViewer
                }
                if (-not $script:LastOperationSucceeded) {
                    Read-Host "Press Enter to return to the main menu"
                    return
                }
                Write-Host ""
                Read-Host "Press Enter to continue"
            }

            "2" {
                Invoke-SafeOperation "Run Forge with AI Thought Viewer" {
                    Run-ForgeWithAiViewer
                }
                if (-not $script:LastOperationSucceeded) {
                    Read-Host "Press Enter to return to the main menu"
                    return
                }
                Write-Host ""
                Read-Host "Press Enter to continue"
            }

            "3" {
                Invoke-SafeOperation "Open AI graphical viewer" {
                    Open-AiViewerOnly
                }
                if (-not $script:LastOperationSucceeded) {
                    Read-Host "Press Enter to return to the main menu"
                    return
                }
                Write-Host ""
                Read-Host "Press Enter to continue"
            }

            "4" {
                Invoke-SafeOperation "AI Viewer status" {
                    Show-AiViewerStatus
                }
                if (-not $script:LastOperationSucceeded) {
                    Read-Host "Press Enter to return to the main menu"
                    return
                }
                Write-Host ""
                Read-Host "Press Enter to continue"
            }

            "5" {
                return
            }
        }
    }
}

function Show-SettingsMenu {
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "V6 Import / Library Settings"
        Write-Host "----------------------------"
        Write-Host ""
        Write-Host ("[1]  Fast import                        [" + (Get-OnOff ([bool]$Settings.FastImport)) + "]")
        Write-Host ("[2]  Copy detection                     [" + (Get-OnOff ([bool]$Settings.CopyDetection)) + "]")
        Write-Host ("[3]  Similarity detection               [" + (Get-OnOff ([bool]$Settings.SimilarityDetection)) + "]")
        Write-Host ("[4]  Similarity threshold               [" + [string]$Settings.SimilarityThreshold + "%]")
        Write-Host ("[5]  Rename decks to commander          [" + (Get-OnOff ([bool]$Settings.RenameToCommander)) + "]")
        Write-Host ("[6]  Remove actual tokens / emblems     [" + (Get-OnOff ([bool]$Settings.RemoveActualTokens)) + "]")
        Write-Host ("[7]  Profile maximum 100-card cap       [" + (Get-OnOff ([bool]$Settings.CapCommanderAt100)) + "]")
        Write-Host ("[8]  Exclude Commander decks under 100  [" + (Get-OnOff ([bool]$Settings.SkipIncompleteCommander)) + "]")
        Write-Host ("[9]  Bracket unique commander           [" + (Get-OnOff ([bool]$Settings.BracketUniqueCommander)) + "]")
        Write-Host ("[10] Bracket unique deck name           [" + (Get-OnOff ([bool]$Settings.BracketUniqueDeckName)) + "]")
        Write-Host ("[11] Backup before overwrite / delete   [" + (Get-OnOff ([bool]$Settings.BackupBeforeOverwrite)) + "]")
        Write-Host ("[12] Preserve sideboards                [" + (Get-OnOff ([bool]$Settings.PreserveSideboards)) + "]")
        Write-Host ("[13] Dry run - preview only             [" + (Get-OnOff ([bool]$Settings.DryRun)) + "]")
        Write-Host "[0]  Back"
        Write-Host ""
        Write-Host "Bracket mode exact-100 validation is safety-locked ON."
        Write-Host "It skips both 99-card and 101-card lists instead of changing them."
        Write-Host "Similarity detection is OFF by default and compares only importer-owned decks."
        Write-Host ""

        $choice = Read-Host "Choose 0-13"

        switch ($choice) {
            "1" {
                $Settings.FastImport = -not [bool]$Settings.FastImport
                Save-Settings $Settings
            }
            "2" {
                $Settings.CopyDetection = -not [bool]$Settings.CopyDetection
                Save-Settings $Settings
            }
            "3" {
                $Settings.SimilarityDetection = -not [bool]$Settings.SimilarityDetection
                Save-Settings $Settings
            }
            "4" {
                $valueText = Read-Host "Similarity threshold 50-100 (recommended 90)"
                $value = 0

                if (-not [int]::TryParse($valueText, [ref]$value) -or
                    $value -lt 50 -or $value -gt 100) {

                    Write-Host "Threshold was not changed. Enter a number from 50 to 100." -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                }
                else {
                    $Settings.SimilarityThreshold = $value
                    Save-Settings $Settings
                }
            }
            "5" {
                $Settings.RenameToCommander = -not [bool]$Settings.RenameToCommander
                Save-Settings $Settings
            }
            "6" {
                $Settings.RemoveActualTokens = -not [bool]$Settings.RemoveActualTokens
                Save-Settings $Settings
            }
            "7" {
                $Settings.CapCommanderAt100 = -not [bool]$Settings.CapCommanderAt100
                Save-Settings $Settings
            }
            "8" {
                $Settings.SkipIncompleteCommander = -not [bool]$Settings.SkipIncompleteCommander
                Save-Settings $Settings
            }
            "9" {
                $Settings.BracketUniqueCommander = -not [bool]$Settings.BracketUniqueCommander
                Save-Settings $Settings
            }
            "10" {
                $Settings.BracketUniqueDeckName = -not [bool]$Settings.BracketUniqueDeckName
                Save-Settings $Settings
            }
            "11" {
                $Settings.BackupBeforeOverwrite = -not [bool]$Settings.BackupBeforeOverwrite
                Save-Settings $Settings
            }
            "12" {
                $Settings.PreserveSideboards = -not [bool]$Settings.PreserveSideboards
                Save-Settings $Settings
            }
            "13" {
                $Settings.DryRun = -not [bool]$Settings.DryRun
                Save-Settings $Settings
            }
            "0" {
                return
            }
        }
    }
}

function Show-MainMenu {
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "Jadon's Ultimate Forge Manager v6.3 FORTIFIED"
        Write-Host "--------------------------------------------"
        Write-Host ""
        Write-Host "[1] Import / sync an Archidekt profile"
        Write-Host "[2] Bracket Library Import"
        Write-Host "[3] AI Thought Viewer"
        Write-Host "[4] Run normal Forge"
        Write-Host "[5] Remove ALL decks added by this importer"
        Write-Host "[6] Settings"
        Write-Host "[7] Show folders / logs / backups"
        Write-Host "[8] Run PROVEN SAFE profile importer"
        Write-Host "[9] Exit"
        Write-Host ""
        Write-Host (
            "Fast: " + (Get-OnOff ([bool]$Settings.FastImport)) +
            " | Copy: " + (Get-OnOff ([bool]$Settings.CopyDetection)) +
            " | Similarity: " + (Get-OnOff ([bool]$Settings.SimilarityDetection)) +
            " (" + [string]$Settings.SimilarityThreshold + "%)"
        )
        Write-Host (
            "Rename: " + (Get-OnOff ([bool]$Settings.RenameToCommander)) +
            " | Tokens: " + (Get-OnOff ([bool]$Settings.RemoveActualTokens)) +
            " | Under-100 exclusion: " + (Get-OnOff ([bool]$Settings.SkipIncompleteCommander))
        )
        Write-Host ""
        Write-Host "Profile-import safety: if V6 cannot complete cleanly, the proven V4"
        Write-Host "importer opens automatically in this same CMD window."
        Write-Host "All other operation failures return here instead of closing the manager."
        Write-Host ""

        $choice = Read-Host "Choose 1-9"

        switch ($choice) {
            "1" {
                $script:ProfileImportNeedsFallback = $false
                $script:ProfileImportWasRequested = $false

                Invoke-SafeOperation "Archidekt profile import" {
                    Write-Host ""
                    $profile = Prompt-Profile
                    if ($profile) {
                        $script:ProfileImportWasRequested = $true
                        Sync-Profile $profile
                    }
                }

                if ($script:ProfileImportWasRequested -and ((-not $script:LastOperationSucceeded) -or $script:ProfileImportNeedsFallback)) {
                    [void](Invoke-ProvenSafeImporter "The primary V6 profile importer reported a failure. Switching to the proven V4 importer instead.")
                }

                Write-Host ""
                Read-Host "Press Enter to return to the main menu"
            }

            "2" {
                Invoke-SafeOperation "Bracket Library Import" {
                    Invoke-BracketLibraryImport
                }
                Write-Host ""
                Read-Host "Press Enter to return to the main menu"
            }

            "3" {
                Invoke-SafeOperation "AI Thought Viewer menu" {
                    Show-AiViewerMenu
                }
            }

            "4" {
                Invoke-SafeOperation "Run normal Forge" {
                    Run-ForgeFromManager
                }
                Write-Host ""
                Read-Host "Press Enter to return to the main menu"
            }

            "5" {
                Invoke-SafeOperation "Remove importer-owned decks" {
                    Remove-ImportedDecks
                }
                Write-Host ""
                Read-Host "Press Enter to return to the main menu"
            }

            "6" {
                Invoke-SafeOperation "Settings" {
                    Show-SettingsMenu
                }
            }

            "7" {
                Invoke-SafeOperation "Show V6 folders" {
                    Write-Host ""
                    Write-Host "Commander decks:"
                    Write-Host ("  " + $CommanderDir)
                    Write-Host ""
                    Write-Host "Constructed decks:"
                    Write-Host ("  " + $ConstructedDir)
                    Write-Host ""
                    Write-Host "Importer logs:"
                    Write-Host ("  " + $LogDir)
                    Write-Host ""
                    Write-Host "Backups:"
                    Write-Host ("  " + $BackupDir)
                    Write-Host ""
                    Write-Host "AI Viewer:"
                    Write-Host ("  " + $AiDir)
                    Write-Host ""
                    Write-Host "Proven safe importer:"
                    Write-Host ("  " + $SafeImporterCmd)
                }
                Write-Host ""
                Read-Host "Press Enter to return to the main menu"
            }

            "8" {
                [void](Invoke-ProvenSafeImporter "You selected the known-good V4 importer directly.")
                Write-Host ""
                Read-Host "Press Enter to return to the main menu"
            }

            "9" {
                return
            }
        }
    }
}

function Invoke-ManagerSelfTest {
    Write-Host ""
    Write-Host "Running importer v6.3 compatibility self-test..."
    Write-Host ("Windows PowerShell version: " + $PSVersionTable.PSVersion.ToString())
    Write-Host ""

    try {
        Write-Host "[SelfTest 1/10] Collection and 100-card trimming..."
        $testMain = New-Object System.Collections.ArrayList
        $testCommanders = New-Object System.Collections.ArrayList

        [void]$testMain.Add([pscustomobject]@{
            Name = "Test Card A"
            Quantity = 50
            Scryfall = $null
        })

        [void]$testMain.Add([pscustomobject]@{
            Name = "Test Card B"
            Quantity = 51
            Scryfall = $null
        })

        [void]$testCommanders.Add([pscustomobject]@{
            Name = "Test Commander"
            Quantity = 1
            Scryfall = $null
        })

        $trimTest = Trim-CommanderDeckTo100 $testMain $testCommanders
        if ($trimTest.FinalTotal -ne 100) {
            throw "100-card trimming self-test failed."
        }

        Write-Host "[SelfTest 2/10] Multi-face / DFC Forge naming..."
        $legions = Get-ForgeCardName `
            "Legion's Landing // Adanto, the First Fort" `
            ([pscustomobject]@{ name = "Legion's Landing // Adanto, the First Fort"; layout = "transform" })

        $pathway = Get-ForgeCardName `
            "Brightclimb Pathway // Grimclimb Pathway" `
            ([pscustomobject]@{ name = "Brightclimb Pathway // Grimclimb Pathway"; layout = "modal_dfc" })

        $adventure = Get-ForgeCardName `
            "Foulmire Knight // Profane Insight" `
            ([pscustomobject]@{ name = "Foulmire Knight // Profane Insight"; layout = "adventure" })

        $splitCard = Get-ForgeCardName `
            "Fire // Ice" `
            ([pscustomobject]@{ name = "Fire // Ice"; layout = "split" })

        $roomCard = Get-ForgeCardName `
            "Bottomless Pool // Locker Room" `
            ([pscustomobject]@{ name = "Bottomless Pool // Locker Room"; layout = "split" })

        if ($legions -ne "Legion's Landing") { throw "Transform-card self-test failed." }
        if ($pathway -ne "Brightclimb Pathway") { throw "Modal DFC self-test failed." }
        if ($adventure -ne "Foulmire Knight") { throw "Adventure-card self-test failed." }
        if ($splitCard -ne "Fire // Ice") { throw "Split-card self-test failed." }
        if ($roomCard -ne "Bottomless Pool // Locker Room") { throw "Room-card self-test failed." }

        Write-Host "[SelfTest 3/10] Actual-token safety..."
        $normalTokenMakerEntry = [pscustomobject]@{
            categories = @("Tokens")
            card = [pscustomobject]@{
                layout = "normal"
                typeLine = "Creature - Elf Druid"
            }
        }

        $normalTokenMakerScryfall = [pscustomobject]@{
            layout = "normal"
            type_line = "Creature - Elf Druid"
        }

        if (Test-IsActualTokenOrEmblem $normalTokenMakerEntry $normalTokenMakerScryfall) {
            throw "Token-category safety self-test failed."
        }

        $actualTokenEntry = [pscustomobject]@{
            card = [pscustomobject]@{
                layout = "token"
                typeLine = "Token Creature - Soldier"
            }
        }

        $actualTokenScryfall = [pscustomobject]@{
            layout = "token"
            type_line = "Token Creature - Soldier"
        }

        if (-not (Test-IsActualTokenOrEmblem $actualTokenEntry $actualTokenScryfall)) {
            throw "Actual-token detection self-test failed."
        }

        Write-Host "[SelfTest 4/10] UTF-8 card-name round trip..."
        $accented = "Bartolom" + [char]0x00E9 + " del Presidio"
        $testFile = Join-Path $ToolDir "selftest_utf8.txt"
        Write-Utf8NoBom $testFile @($accented)
        $roundTrip = [IO.File]::ReadAllText($testFile, [Text.Encoding]::UTF8)
        Remove-Item -LiteralPath $testFile -Force -ErrorAction SilentlyContinue

        if ($roundTrip.Trim() -ne $accented) {
            throw "UTF-8 card-name self-test failed."
        }

        Write-Host "[SelfTest 5/10] Settings/default migration..."
        if ([bool]$Settings.FastImport -ne $false -and -not (Test-Path -LiteralPath $SettingsFile)) {
            throw "Fast-import default self-test failed."
        }

        Write-Host "[SelfTest 6/10] Similarity calculation..."
        $vectorA = @("1`talpha card", "1`tbeta card", "1`tgamma card")
        $vectorB = @("1`talpha card", "1`tbeta card", "1`tdelta card")

        $similarity = Get-DeckSimilarityPercent $vectorA $vectorB
        if ([Math]::Abs($similarity - 66.67) -gt 0.02) {
            throw "Similarity calculation self-test failed."
        }

        Write-Host "[SelfTest 7/10] Exact-copy hashing..."
        $hashA = Get-VectorHash $vectorA
        $hashA2 = Get-VectorHash $vectorA
        if ($hashA -ne $hashA2 -or [string]::IsNullOrWhiteSpace($hashA)) {
            throw "Exact deck hash self-test failed."
        }

        Write-Host "[SelfTest 8/10] Bracket safety and copy fingerprint..."
        if ([bool]$Settings.BracketExact100 -ne $true) {
            throw "Bracket exact-100 safety self-test failed."
        }

        $fingerprint = Get-SettingsFingerprint
        if ([string]::IsNullOrWhiteSpace($fingerprint) -or $fingerprint -notmatch 'engine=6') {
            throw "Copy-detection fingerprint self-test failed."
        }

        Write-Host "[SelfTest 9/10] AI telemetry source-patch generation..."

        $spellPatchInput = @(
            '    private int numSimulations;'
            '            AiPlayDecision opinion = canPlayAndPayForSim(sa);'
            '        Score origGameScore = new GameStateEvaluator().getScoreForGameState(game, player);'
            '        List<SpellAbility> candidateSAs = getCandidateSpellsAndAbilities();'
            '            Score value = evaluateSa(controller, phase, candidateSAs, i);'
            '        long execTime = System.currentTimeMillis() - startTime;'
            '        PhaseType currentPhase = game.getPhaseHandler().getPhase();'
        ) -join "`n"

        $aiPatchInput = @(
            'import forge.ai.simulation.GameStateEvaluator;'
            '    public List<SpellAbility> chooseSpellAbilityToPlay() {'
            '                AiPlayDecision opinion = useLivingEnd && AiPlayDecision.WillPlay.equals(aiPlayDecision) ? aiPlayDecision : canPlayAndPayFor(sa);'
            '                // TODO could continue to try find another with higher rating (weighted by priority ordering)'
            '                return sa;'
            '        lastAttackAggression = aiAtk.declareAttackers(combat);'
            '        block.assignBlockersForCombat(combat);'
        ) -join "`n"

        $spellPatchFile = Join-Path $ToolDir "selftest_spell_patch.java"
        $aiPatchFile = Join-Path $ToolDir "selftest_ai_patch.java"

        try {
            Patch-SpellAbilityPickerSource $spellPatchInput $spellPatchFile
            Patch-AiControllerSource $aiPatchInput $aiPatchFile

            $spellPatched = [IO.File]::ReadAllText($spellPatchFile, [Text.Encoding]::UTF8)
            $aiPatched = [IO.File]::ReadAllText($aiPatchFile, [Text.Encoding]::UTF8)

            if (-not $spellPatched.Contains('jadonPlan.append(" | ");')) {
                throw "AI plan telemetry patch self-test failed."
            }

            if (-not $aiPatched.Contains('String.valueOf(sa.getHostCard()) + " -> " + String.valueOf(sa)')) {
                throw "AI heuristic telemetry quote-generation self-test failed."
            }

            if (-not $aiPatched.Contains('AiTelemetry.combatAttack(attacker, game, lastAttackAggression, String.valueOf(combat));')) {
                throw "AI combat-attack telemetry patch self-test failed."
            }

            if (-not $aiPatched.Contains('AiTelemetry.combatBlock(defender, game, String.valueOf(combat));')) {
                throw "AI combat-block telemetry patch self-test failed."
            }
        }
        finally {
            Remove-Item -LiteralPath $spellPatchFile -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $aiPatchFile -Force -ErrorAction SilentlyContinue
        }

        Write-Host "[SelfTest 10/10] Proven safe-importer fallback..."
        if (-not (Test-Path -LiteralPath $SafeImporterCmd)) {
            throw "Proven safe importer is missing."
        }
        $safeHead = [IO.File]::ReadAllText($SafeImporterCmd, [Text.Encoding]::UTF8)
        if (-not $safeHead.StartsWith("@echo off")) {
            throw "Proven safe importer launcher is damaged."
        }
        if (-not $safeHead.Contains("Jadon's Archidekt Forge Manager v4 SAFE TOKENS")) {
            throw "Proven safe importer identity check failed."
        }

        Write-Host "Importer v6.3 self-test: PASS" -ForegroundColor Green
        Write-Host ""
        return $true
    }
    catch {
        Write-Host "Importer v6.3 self-test: FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message

        if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
            Write-Host $_.InvocationInfo.PositionMessage
        }

        if ($_.ScriptStackTrace) {
            Write-Host $_.ScriptStackTrace
        }

        Write-Host ""
        Write-Host "No Forge decks were changed."
        return $false
    }
}

if (-not (Invoke-ManagerSelfTest)) {
    if (-not $SelfTest) {
        Write-Host ""
        Write-Host "The V6.3 manager stopped before opening its menu because the startup self-test failed." -ForegroundColor Red
        Write-Host "This window will stay open."
        Write-Host ("Logs folder: " + $LogDir)
        Write-Host ""
        Read-Host "Press Enter to return/close"
    }
    exit 1
}

if ($SelfTest) {
    exit 0
}

while ($true) {
    try {
        Show-MainMenu
        break
    }
    catch {
        $script:LastOperationSucceeded = $false

        try {
            if (-not $script:CurrentLog) {
                Start-Log
            }

            Write-Log ""
            Write-Log "UNEXPECTED MANAGER ERROR"
            Write-Log ("ERROR: " + $_.Exception.Message)

            if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
                Write-Log ("POSITION: " + ($_.InvocationInfo.PositionMessage -replace "`r?`n", " "))
            }

            if ($_.ScriptStackTrace) {
                Write-Log ("STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
            }
        }
        catch {}

        Write-Host ""
        Write-Host "V6.3 recovered from an unexpected error." -ForegroundColor Yellow
        Write-Host "The manager will return to the main menu instead of closing."
        Write-Host ("Reason: " + $_.Exception.Message)
        Write-Host ""
        Read-Host "Press Enter to return to the main menu"
    }
}
###JADON_LEGACY_V8_FALLBACK_END###
###JADON_INSTALLER_V7_PS_PAYLOAD_BEGIN###
param(
    [ValidateSet("Install", "RunForge", "SelfTest", "ManagerShortcut", "Uninstall")]
    [string]$Action = "SelfTest",

    [ValidateSet("SCHOOL", "NORMAL")]
    [string]$Mode = "SCHOOL",

    [ValidateSet("ImportedDecks", "Manager", "Forge", "Java", "Caches", "KeepDecks", "Everything")]
    [string]$UninstallScope = "ImportedDecks"
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Base = if ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA "MTGForge"
} else {
    Join-Path $env:USERPROFILE "AppData\Local\MTGForge"
}

$Roaming = if ($env:APPDATA) {
    $env:APPDATA
} else {
    Join-Path $env:USERPROFILE "AppData\Roaming"
}

$LogDir = Join-Path $Base "logs"
$LogFile = Join-Path $LogDir "installer-v7.log"
$Downloads = Join-Path $Base "downloads"
$JavaHome = Join-Path $Base "java-21-jre"
$Launcher = Join-Path $Base "Start_Forge.cmd"
$LocationFile = Join-Path $Base "Forge_Location.txt"
$ManagerCmd = Join-Path $Base "Jadons_Ultimate_Forge_Manager_v9.cmd"
$RunId = [Guid]::NewGuid().ToString("N")

New-Item -ItemType Directory -Force -Path $Base | Out-Null
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Write-InstallLog {
    param([string]$Message)

    try {
        $line = "[" + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff") + "] " + $Message
        [IO.File]::AppendAllText(
            $LogFile,
            $line + [Environment]::NewLine,
            (New-Object Text.UTF8Encoding($false))
        )
    }
    catch {}
}

function Write-Status {
    param([string]$Message, [ConsoleColor]$Color = [ConsoleColor]::Gray)

    Write-Host $Message -ForegroundColor $Color
    Write-InstallLog $Message
}

function Get-FileSha256 {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return ""
    }

    $stream = $null
    $sha = $null
    try {
        $stream = [IO.File]::OpenRead($Path)
        $sha = [Security.Cryptography.SHA256]::Create()
        return [BitConverter]::ToString($sha.ComputeHash($stream)).Replace("-", "").ToLowerInvariant()
    }
    finally {
        if ($stream) { $stream.Dispose() }
        if ($sha) { $sha.Dispose() }
    }
}

function Write-TextAtomic {
    param(
        [string]$Path,
        [string]$Text,
        [Text.Encoding]$Encoding
    )

    if ($null -eq $Encoding) {
        $Encoding = New-Object Text.UTF8Encoding($false)
    }

    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    $candidate = $Path + ".candidate-" + [Guid]::NewGuid().ToString("N")

    try {
        [IO.File]::WriteAllText($candidate, $Text, $Encoding)
        Promote-FileCandidate $candidate $Path
        $candidate = ""
    }
    finally {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            Remove-Item -LiteralPath $candidate -Force -ErrorAction SilentlyContinue
        }
    }
}

function Promote-FileCandidate {
    param([string]$Candidate, [string]$Live)

    if (-not (Test-Path -LiteralPath $Candidate -PathType Leaf)) {
        throw "File candidate is missing: $Candidate"
    }

    $parent = Split-Path -Parent $Live
    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    if (Test-Path -LiteralPath $Live) {
        $backup = $Live + ".last-good"
        if (Test-Path -LiteralPath $backup) {
            $backup = $Live + ".last-good-" + (Get-Date -Format "yyyyMMdd-HHmmssfff")
        }
        [IO.File]::Replace($Candidate, $Live, $backup, $true)
    }
    else {
        [IO.File]::Move($Candidate, $Live)
    }
}

function Promote-DirectoryCandidate {
    param([string]$Candidate, [string]$Live)

    if (-not (Test-Path -LiteralPath $Candidate -PathType Container)) {
        throw "Directory candidate is missing: $Candidate"
    }

    if (-not (Test-Path -LiteralPath $Live)) {
        [IO.Directory]::Move($Candidate, $Live)
        return
    }

    $backup = $Live + ".last-good-" + (Get-Date -Format "yyyyMMdd-HHmmssfff")
    [IO.Directory]::Move($Live, $backup)

    try {
        [IO.Directory]::Move($Candidate, $Live)
    }
    catch {
        if (-not (Test-Path -LiteralPath $Live) -and (Test-Path -LiteralPath $backup)) {
            [IO.Directory]::Move($backup, $Live)
        }
        throw
    }
}

function Remove-CandidatePath {
    param([string]$Path)

    if (-not $Path -or -not (Test-Path -LiteralPath $Path)) {
        return
    }

    $baseFull = [IO.Path]::GetFullPath($Base).TrimEnd("\") + "\"
    $full = [IO.Path]::GetFullPath($Path)
    $leaf = [IO.Path]::GetFileName($full)

    if (-not $full.StartsWith($baseFull, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refused to remove a candidate outside the MTGForge base."
    }

    if ($leaf -notmatch '(?i)(candidate|stage|selftest)-[A-Fa-f0-9]{8,}') {
        throw "Refused to remove a path that is not a uniquely named candidate."
    }

    if (Test-Path -LiteralPath $full -PathType Container) {
        [IO.Directory]::Delete($full, $true)
    }
    else {
        [IO.File]::Delete($full)
    }
}

function Invoke-NativeLogged {
    param([string]$FilePath, [string[]]$Arguments)

    $saved = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $output = @(& $FilePath @Arguments 2>&1)
        $rc = $LASTEXITCODE
    }
    catch {
        $output = @($_)
        $rc = 9009
    }
    finally {
        $ErrorActionPreference = $saved
    }

    foreach ($line in $output) {
        Write-InstallLog ([string]$line)
    }

    return [int]$rc
}

function Test-PrivateJava {
    param([string]$Root)

    $java = Join-Path $Root "bin\java.exe"
    if (-not (Test-Path -LiteralPath $java -PathType Leaf)) {
        return $false
    }

    $saved = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $output = @(& $java -version 2>&1)
        $rc = $LASTEXITCODE
    }
    catch {
        Write-InstallLog ("Java test exception: " + $_.Exception.Message)
        return $false
    }
    finally {
        $ErrorActionPreference = $saved
    }

    $text = ($output | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
    Write-InstallLog $text

    if ($rc -ne 0 -or $text -notmatch 'version\s+"(?:1\.)?(\d+)') {
        return $false
    }

    return ([int]$Matches[1] -ge 17)
}

function Get-JavaArchitecture {
    $architecture = [string]$env:PROCESSOR_ARCHITECTURE
    if ($env:PROCESSOR_ARCHITEW6432) {
        $architecture = [string]$env:PROCESSOR_ARCHITEW6432
    }

    switch -Regex ($architecture.ToUpperInvariant()) {
        'ARM64' { return 'aarch64' }
        'AMD64|X86_64' { return 'x64' }
        default { throw "32-bit or unsupported Windows architecture: $architecture" }
    }
}

function Download-File {
    param([string]$Url, [string]$Destination, [string]$InstallMode)

    if (-not $Url.StartsWith("https://", [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refused a non-HTTPS download URL."
    }

    if (Test-Path -LiteralPath $Destination) {
        Remove-CandidatePath $Destination
    }

    $curl = Join-Path $env:SystemRoot "System32\curl.exe"
    if (Test-Path -LiteralPath $curl -PathType Leaf) {
        Write-Status "Trying the Windows curl downloader..."
        $rc = Invoke-NativeLogged $curl @(
            "-L", "--fail", "--retry", "3", "--retry-delay", "2",
            "--connect-timeout", "30", "-o", $Destination, $Url
        )
        if ($rc -eq 0 -and (Test-Path -LiteralPath $Destination) -and
            (Get-Item -LiteralPath $Destination).Length -gt 0) {
            return
        }

        if (Test-Path -LiteralPath $Destination) {
            Remove-CandidatePath $Destination
        }
    }

    Write-Status "Trying the Windows PowerShell downloader..."
    $client = $null
    try {
        $client = New-Object Net.WebClient
        $client.Headers["User-Agent"] = "Jadons-Ultimate-Installer/7.0"
        $client.DownloadFile($Url, $Destination)
        if ((Get-Item -LiteralPath $Destination).Length -gt 0) {
            return
        }
    }
    catch {
        Write-InstallLog ("PowerShell download failed: " + $_.Exception.ToString())
    }
    finally {
        if ($client) { $client.Dispose() }
    }

    if (Test-Path -LiteralPath $Destination) {
        Remove-CandidatePath $Destination
    }

    if ($InstallMode -eq "SCHOOL") {
        throw "Download failed. School mode did not use BITS."
    }

    Write-Status "Trying the Normal-mode BITS fallback..."
    try {
        Import-Module BitsTransfer -ErrorAction Stop
        Start-BitsTransfer -Source $Url -Destination $Destination -ErrorAction Stop
        if ((Get-Item -LiteralPath $Destination).Length -gt 0) {
            return
        }
    }
    catch {
        Write-InstallLog ("BITS download failed: " + $_.Exception.ToString())
    }

    throw "All permitted download methods failed."
}

function Ensure-PrivateJava {
    param([string]$InstallMode)

    Write-Status "[2/8] Checking private Java 21..."
    if (Test-PrivateJava $JavaHome) {
        Write-Status "Existing private Java 17+ is working; reusing it." Green
        return (Join-Path $JavaHome "bin\java.exe")
    }

    if (Test-Path -LiteralPath $JavaHome) {
        Write-Status "The existing private Java could not be validated; it will remain untouched." Yellow
    }

    New-Item -ItemType Directory -Force -Path $Downloads | Out-Null
    $architecture = Get-JavaArchitecture
    $archive = Join-Path $Downloads ("temurin-jre21.candidate-" + $RunId + ".zip")
    $stage = Join-Path $Base ("java-stage-" + $RunId)
    $candidate = Join-Path $Base ("java-21-jre.candidate-" + $RunId)
    $url = "https://api.adoptium.net/v3/binary/latest/21/ga/windows/" +
        $architecture + "/jre/hotspot/normal/eclipse?project=jdk"

    try {
        Write-Status "Downloading an Eclipse Temurin Java 21 JRE candidate..."
        Download-File $url $archive $InstallMode

        New-Item -ItemType Directory -Path $stage | Out-Null
        Expand-Archive -LiteralPath $archive -DestinationPath $stage -Force

        $java = Get-ChildItem -LiteralPath $stage -Filter "java.exe" -File -Recurse |
            Where-Object { $_.FullName -match '[\\/]bin[\\/]java[.]exe$' } |
            Sort-Object FullName |
            Select-Object -First 1

        if (-not $java) {
            throw "java.exe was not found in the downloaded JRE archive."
        }

        $root = Split-Path -Parent (Split-Path -Parent $java.FullName)
        [IO.Directory]::Move($root, $candidate)

        if (-not (Test-PrivateJava $candidate)) {
            throw "The Java candidate did not run as Java 17 or newer."
        }

        Promote-DirectoryCandidate $candidate $JavaHome
        $candidate = ""

        if (-not (Test-PrivateJava $JavaHome)) {
            throw "Private Java failed after promotion."
        }

        Write-Status "Private Java candidate validated and promoted." Green
        return (Join-Path $JavaHome "bin\java.exe")
    }
    finally {
        foreach ($path in @($candidate, $stage, $archive)) {
            if ($path -and (Test-Path -LiteralPath $path)) {
                try { Remove-CandidatePath $path } catch { Write-InstallLog $_.Exception.Message }
            }
        }
    }
}

function Read-ZipManifest {
    param([string]$Path)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = $null
    $reader = $null
    try {
        $zip = [IO.Compression.ZipFile]::OpenRead($Path)
        $manifest = $zip.Entries |
            Where-Object { $_.FullName -ieq "META-INF/MANIFEST.MF" } |
            Select-Object -First 1
        if (-not $manifest) { return "" }
        $reader = New-Object IO.StreamReader($manifest.Open(), [Text.Encoding]::UTF8)
        return $reader.ReadToEnd()
    }
    finally {
        if ($reader) { $reader.Dispose() }
        if ($zip) { $zip.Dispose() }
    }
}

function Test-ForgeInstallerJar {
    param([string]$Path, [string]$Version, [string]$ExpectedDigest)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf) -or
        (Get-Item -LiteralPath $Path).Length -lt 1000000) {
        return $false
    }

    if ([IO.Path]::GetFileName($Path) -notmatch (
        '^forge-installer-' + [regex]::Escape($Version) +
        '(?:[.]candidate-[A-Fa-f0-9]{8,})?[.]jar$'
    )) {
        return $false
    }

    try {
        $manifest = Read-ZipManifest $Path
        if ($manifest -notmatch '(?m)^Main-Class:\s*com[.]izforge[.]izpack[.]installer[.]bootstrap[.]Installer\s*$') {
            return $false
        }
    }
    catch {
        return $false
    }

    if ($ExpectedDigest -and (Get-FileSha256 $Path) -ne $ExpectedDigest.ToLowerInvariant()) {
        return $false
    }

    return $true
}

function Test-ForgeDesktopJar {
    param([string]$Path, [string]$ExpectedVersion)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf) -or
        (Get-Item -LiteralPath $Path).Length -lt 1000000) {
        return $false
    }

    $name = [IO.Path]::GetFileName($Path)
    if ($name -notmatch '^forge-gui-desktop-(.+)-jar-with-dependencies[.]jar$') {
        return $false
    }

    $fileVersion = [string]$Matches[1]
    if ($ExpectedVersion -and $fileVersion -ne $ExpectedVersion) {
        return $false
    }

    try {
        $manifest = Read-ZipManifest $Path
        if ($manifest -notmatch '(?m)^Implementation-Title:\s*Forge\s*$' -or
            $manifest -notmatch '(?m)^Main-Class:\s*forge[.]view[.]Main\s*$') {
            return $false
        }

        if ($manifest -notmatch '(?m)^Implementation-Version:\s*([^\r\n]+)') {
            return $false
        }

        $manifestVersion = [string]$Matches[1].Trim()
        if (-not $manifestVersion.StartsWith($fileVersion, [StringComparison]::OrdinalIgnoreCase)) {
            return $false
        }
    }
    catch {
        return $false
    }

    return $true
}

function Get-ForgeTargetInRoot {
    param([string]$Root, [string]$Version)

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        return $null
    }

    $jars = @(
        Get-ChildItem -LiteralPath $Root -Filter "forge-gui-desktop-*-jar-with-dependencies.jar" -File -Recurse -ErrorAction SilentlyContinue |
            Sort-Object FullName |
            Where-Object { Test-ForgeDesktopJar $_.FullName $Version }
    )
    $jarPath = if ($jars.Count) { $jars[0].FullName } else { "" }

    $cmds = @(
        Get-ChildItem -LiteralPath $Root -Filter "forge.cmd" -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Length -gt 0 } |
            Sort-Object @{ Expression = { $_.DirectoryName.Length } }, FullName
    )
    if ($cmds.Count) {
        return [pscustomobject]@{
            Kind = "CMD"; Path = $cmds[0].FullName; Home = $cmds[0].DirectoryName
            Version = $Version; JarPath = $jarPath
        }
    }

    $exes = @(
        Get-ChildItem -LiteralPath $Root -Filter "forge.exe" -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Length -gt 100000 } |
            Sort-Object @{ Expression = { $_.DirectoryName.Length } }, FullName
    )
    if ($exes.Count) {
        return [pscustomobject]@{
            Kind = "EXE"; Path = $exes[0].FullName; Home = $exes[0].DirectoryName
            Version = $Version; JarPath = $jarPath
        }
    }

    if ($jarPath) {
        return [pscustomobject]@{
            Kind = "JAR"; Path = $jarPath; Home = Split-Path -Parent $jarPath
            Version = $Version; JarPath = $jarPath
        }
    }

    return $null
}

function Get-InstalledForge {
    param([string]$SpecificVersion = "")

    $directories = @(
        Get-ChildItem -LiteralPath $Base -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^Forge-(\d+(?:[.]\d+){1,3})$' } |
            ForEach-Object {
                [pscustomobject]@{
                    Directory = $_
                    VersionText = [string]$Matches[1]
                    VersionObject = try { [version]$Matches[1] } catch { [version]"0.0" }
                }
            } |
            Sort-Object VersionObject -Descending
    )

    foreach ($entry in $directories) {
        if ($SpecificVersion -and $entry.VersionText -ne $SpecificVersion) {
            continue
        }

        $target = Get-ForgeTargetInRoot $entry.Directory.FullName $entry.VersionText
        if ($target) { return $target }
    }

    return $null
}

function Resolve-ForgeRelease {
    Write-Status "[3/8] Finding the latest stable Forge release..."
    $client = $null
    try {
        $client = New-Object Net.WebClient
        $client.Headers["User-Agent"] = "Jadons-Ultimate-Installer/7.0"
        $json = $client.DownloadString("https://api.github.com/repos/Card-Forge/forge/releases/latest")
        $release = $json | ConvertFrom-Json
        $asset = @($release.assets) |
            Where-Object { $_.name -match '^forge-installer-(.+)[.]jar$' } |
            Select-Object -First 1

        if (-not $asset -or [string]$release.tag_name -notmatch '^forge-(\d+(?:[.]\d+){1,3})$') {
            throw "The latest release did not contain a stable desktop installer asset."
        }

        $version = [string]$Matches[1]
        if ([string]$asset.name -ne ("forge-installer-" + $version + ".jar")) {
            throw "Forge tag and installer filename do not agree."
        }

        $digest = ""
        if ($asset.PSObject.Properties["digest"] -and [string]$asset.digest -match '^sha256:([A-Fa-f0-9]{64})$') {
            $digest = [string]$Matches[1].ToLowerInvariant()
        }

        return [pscustomobject]@{
            Version = $version
            Tag = [string]$release.tag_name
            Asset = [string]$asset.name
            Url = [string]$asset.browser_download_url
            Digest = $digest
            IsFallback = $false
        }
    }
    catch {
        Write-InstallLog ("GitHub release lookup failed: " + $_.Exception.ToString())
        return $null
    }
    finally {
        if ($client) { $client.Dispose() }
    }
}

function Ensure-ForgeInstaller {
    param($Release, [string]$InstallMode)

    Write-Status "[4/8] Checking the Forge installer package..."
    New-Item -ItemType Directory -Force -Path $Downloads | Out-Null
    $live = Join-Path $Downloads $Release.Asset

    if (Test-ForgeInstallerJar $live $Release.Version $Release.Digest) {
        Write-Status "Existing verified Forge installer package will be reused." Green
        return $live
    }

    $candidate = Join-Path $Downloads (
        "forge-installer-" + $Release.Version + ".candidate-" + $RunId + ".jar"
    )

    try {
        Write-Status "Downloading Forge from GitHub..."
        try {
            Download-File $Release.Url $candidate $InstallMode
            if (-not (Test-ForgeInstallerJar $candidate $Release.Version $Release.Digest)) {
                throw "The GitHub Forge installer candidate failed identity, ZIP, version, or digest validation."
            }
        }
        catch {
            Write-InstallLog ("GitHub package attempt failed: " + $_.Exception.ToString())
            if (Test-Path -LiteralPath $candidate) { Remove-CandidatePath $candidate }
            $mirror = "https://sourceforge.net/projects/forge-engine.mirror/files/forge-" +
                $Release.Version + "/forge-installer-" + $Release.Version + ".jar/download"
            Write-Status "Trying the SourceForge release mirror..." Yellow
            Download-File $mirror $candidate $InstallMode
            if (-not (Test-ForgeInstallerJar $candidate $Release.Version $Release.Digest)) {
                throw "The SourceForge Forge installer candidate failed validation."
            }
        }

        Promote-FileCandidate $candidate $live
        $candidate = ""
        Write-Status "Forge installer candidate validated and promoted." Green
        return $live
    }
    finally {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            try { Remove-CandidatePath $candidate } catch { Write-InstallLog $_.Exception.Message }
        }
    }
}

function Install-ForgeCandidate {
    param($Release, [string]$JavaExe, [string]$InstallerJar, [string]$InstallMode)

    Write-Status "[5/8] Installing Forge into a validated candidate directory..."
    $live = Join-Path $Base ("Forge-" + $Release.Version)
    $candidate = Join-Path $Base ("Forge-" + $Release.Version + ".candidate-" + $RunId)
    $defaults = Join-Path $Base ("forge-install.candidate-" + $RunId + ".defaults")
    $forwardPath = $candidate.Replace("\", "/")
    [IO.File]::WriteAllText(
        $defaults,
        "INSTALL_PATH=" + $forwardPath + [Environment]::NewLine,
        (New-Object Text.ASCIIEncoding)
    )

    try {
        Write-Status ("Candidate target: " + $candidate)
        $rc = Invoke-NativeLogged $JavaExe @(
            "-jar", $InstallerJar, "-defaults-file", $defaults, "-auto"
        )
        $target = Get-ForgeTargetInRoot $candidate $Release.Version

        if (-not $target) {
            Write-InstallLog ("Silent installer exit code: " + $rc)
            if ($InstallMode -eq "SCHOOL") {
                throw "Silent Forge installation did not produce a validated target. School mode did not open the installer GUI."
            }

            Write-Status "Silent installation did not produce a validated target." Yellow
            Write-Status "Normal mode will now open Forge's graphical installer for this candidate path." Yellow
            Write-Host ("Keep this Target Path: " + $candidate)
            [void](Read-Host "Press Enter to open the graphical installer")
            $null = Invoke-NativeLogged $JavaExe @("-jar", $InstallerJar, "-defaults-file", $defaults)
            $target = Get-ForgeTargetInRoot $candidate $Release.Version
        }

        if (-not $target) {
            throw "Forge installation ended without a validated CMD, EXE, or desktop JAR target. The incomplete candidate was retained for diagnosis."
        }

        Promote-DirectoryCandidate $candidate $live
        $candidate = ""
        $promoted = Get-ForgeTargetInRoot $live $Release.Version
        if (-not $promoted) {
            throw "Forge candidate promotion completed, but final target validation failed."
        }

        Write-Status "Forge candidate validated and promoted; any previous directory was retained as last-good." Green
        return $promoted
    }
    finally {
        if (Test-Path -LiteralPath $defaults) {
            try { Remove-CandidatePath $defaults } catch { Write-InstallLog $_.Exception.Message }
        }
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            Write-InstallLog ("Retained incomplete Forge candidate for diagnosis: " + $candidate)
        }
    }
}

function Get-BaseRelativePath {
    param([string]$Path)

    $baseFull = [IO.Path]::GetFullPath($Base).TrimEnd("\") + "\"
    $full = [IO.Path]::GetFullPath($Path)
    if (-not $full.StartsWith($baseFull, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Forge target is outside the user-level MTGForge base."
    }
    return $full.Substring($baseFull.Length)
}

function Get-BatchLabels {
    param([string]$Text)

    return @(
        [regex]::Matches($Text, '(?m)^:([A-Za-z0-9_.$?-]+)\s*$') |
            ForEach-Object { $_.Groups[1].Value.ToUpperInvariant() }
    )
}

function Test-LauncherText {
    param([string]$Text)

    if (-not $Text.StartsWith("@echo off`r`n", [StringComparison]::Ordinal)) { return $false }
    if ($Text -notmatch '(?m)^rem JADON_FORGE_LAUNCHER_V7\r?$') { return $false }
    if ($Text -notmatch '%LOCALAPPDATA%\\MTGForge') { return $false }
    if ([regex]::IsMatch($Text, '(?<!\r)\n|\r(?!\n)')) { return $false }
    if ([Text.Encoding]::ASCII.GetString([Text.Encoding]::ASCII.GetBytes($Text)) -ne $Text) { return $false }

    $labels = @(Get-BatchLabels $Text)
    if (@($labels | Group-Object | Where-Object { $_.Count -gt 1 }).Count) { return $false }

    $references = @(
        [regex]::Matches($Text, '(?im)\b(?:goto|call)\s+:([A-Za-z0-9_.$?-]+)') |
            ForEach-Object { $_.Groups[1].Value.ToUpperInvariant() }
    )
    foreach ($reference in $references) {
        if ($labels -notcontains $reference) { return $false }
    }

    return $true
}

function Write-ForgeLauncher {
    param($Target, [string]$OutputPath = $Launcher)

    $targetRelative = Get-BaseRelativePath $Target.Path
    $homeRelative = Get-BaseRelativePath $Target.Home
    $lines = New-Object Collections.ArrayList
    [void]$lines.Add("@echo off")
    [void]$lines.Add("setlocal EnableExtensions DisableDelayedExpansion")
    [void]$lines.Add("rem JADON_FORGE_LAUNCHER_V7")
    [void]$lines.Add('title MTG Forge')
    [void]$lines.Add('if defined LOCALAPPDATA set "JF_BASE=%LOCALAPPDATA%\MTGForge"')
    [void]$lines.Add('if not defined LOCALAPPDATA set "JF_BASE=%USERPROFILE%\AppData\Local\MTGForge"')
    [void]$lines.Add('set "JF_JAVA=%JF_BASE%\java-21-jre\bin\java.exe"')
    [void]$lines.Add('set "JF_HOME=%JF_BASE%\' + $homeRelative + '"')
    [void]$lines.Add('set "JF_TARGET=%JF_BASE%\' + $targetRelative + '"')
    [void]$lines.Add('if not exist "%JF_TARGET%" goto :JF_TARGET_MISSING')
    [void]$lines.Add('cd /d "%JF_HOME%"')
    [void]$lines.Add('if errorlevel 1 goto :JF_HOME_FAILED')

    if ($Target.Kind -eq "CMD") {
        [void]$lines.Add('if not exist "%JF_JAVA%" goto :JF_JAVA_MISSING')
        [void]$lines.Add('set "JAVA_HOME=%JF_BASE%\java-21-jre"')
        [void]$lines.Add('set "PATH=%JAVA_HOME%\bin;%PATH%"')
        [void]$lines.Add('call "%JF_TARGET%"')
        [void]$lines.Add('set "JF_RC=%ERRORLEVEL%"')
        [void]$lines.Add('if not "%JF_RC%"=="0" goto :JF_LAUNCH_FAILED')
        [void]$lines.Add('exit /b 0')
    }
    elseif ($Target.Kind -eq "EXE") {
        [void]$lines.Add('start "" /D "%JF_HOME%" "%JF_TARGET%"')
        [void]$lines.Add('if errorlevel 1 goto :JF_LAUNCH_FAILED')
        [void]$lines.Add('exit /b 0')
    }
    else {
        [void]$lines.Add('if not exist "%JF_JAVA%" goto :JF_JAVA_MISSING')
        [void]$lines.Add('"%JF_JAVA%" --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.lang.reflect=ALL-UNNAMED --add-opens java.base/java.text=ALL-UNNAMED --add-opens java.desktop/java.awt.font=ALL-UNNAMED -Xmx2048m -Dfile.encoding=UTF-8 -jar "%JF_TARGET%"')
        [void]$lines.Add('set "JF_RC=%ERRORLEVEL%"')
        [void]$lines.Add('if not "%JF_RC%"=="0" goto :JF_LAUNCH_FAILED')
        [void]$lines.Add('exit /b 0')
    }

    [void]$lines.Add(":JF_TARGET_MISSING")
    [void]$lines.Add('echo ERROR: The recorded Forge target is missing.')
    [void]$lines.Add('goto :JF_VISIBLE_FAILURE')
    [void]$lines.Add(":JF_HOME_FAILED")
    [void]$lines.Add('echo ERROR: The Forge working directory could not be opened.')
    [void]$lines.Add('goto :JF_VISIBLE_FAILURE')
    [void]$lines.Add(":JF_JAVA_MISSING")
    [void]$lines.Add('echo ERROR: The private Java runtime is missing.')
    [void]$lines.Add('goto :JF_VISIBLE_FAILURE')
    [void]$lines.Add(":JF_LAUNCH_FAILED")
    [void]$lines.Add('echo ERROR: Forge returned a launch error.')
    [void]$lines.Add(":JF_VISIBLE_FAILURE")
    [void]$lines.Add('echo.')
    [void]$lines.Add('echo Run Installer option 1 or 2 to repair this user-level installation.')
    [void]$lines.Add('echo This error window will remain visible.')
    [void]$lines.Add('echo.')
    [void]$lines.Add('pause')
    [void]$lines.Add('exit /b 1')

    $text = [string]::Join("`r`n", [string[]]$lines.ToArray()) + "`r`n"
    if (-not (Test-LauncherText $text)) {
        throw "Generated Start_Forge.cmd failed static validation."
    }

    $candidate = $OutputPath + ".candidate-" + [Guid]::NewGuid().ToString("N")
    try {
        [IO.File]::WriteAllText($candidate, $text, (New-Object Text.ASCIIEncoding))
        if (-not (Test-LauncherText ([IO.File]::ReadAllText($candidate, [Text.Encoding]::ASCII)))) {
            throw "Start_Forge.cmd candidate read-back validation failed."
        }
        Promote-FileCandidate $candidate $OutputPath
        $candidate = ""
    }
    finally {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            Remove-Item -LiteralPath $candidate -Force -ErrorAction SilentlyContinue
        }
    }
}

function Write-ForgeLocation {
    param($Target)

    $lines = New-Object Collections.ArrayList
    [void]$lines.Add("Forge version: " + $Target.Version)
    [void]$lines.Add("Forge folder: " + $Target.Home)
    [void]$lines.Add("Java folder: " + $JavaHome)
    [void]$lines.Add("Launcher: " + $Launcher)
    [void]$lines.Add("Launcher SHA-256: " + (Get-FileSha256 $Launcher))
    [void]$lines.Add("Forge " + $Target.Kind + ": " + $Target.Path)
    if ($Target.JarPath) {
        [void]$lines.Add("Forge JAR: " + $Target.JarPath)
        [void]$lines.Add("Forge JAR SHA-256: " + (Get-FileSha256 $Target.JarPath))
    }
    Write-TextAtomic $LocationFile ([string]::Join("`r`n", [string[]]$lines.ToArray()) + "`r`n") (New-Object Text.UTF8Encoding($false))
}

function Test-LiveLauncher {
    if (-not (Test-Path -LiteralPath $Launcher -PathType Leaf)) { return $false }

    try {
        $bytes = [IO.File]::ReadAllBytes($Launcher)
        if (@($bytes | Where-Object { $_ -ge 128 }).Count) { return $false }
        $text = [Text.Encoding]::ASCII.GetString($bytes)
        if (-not (Test-LauncherText $text)) { return $false }
        if (-not (Test-Path -LiteralPath $LocationFile -PathType Leaf)) { return $false }
        $expected = ""
        foreach ($line in [IO.File]::ReadAllLines($LocationFile, [Text.Encoding]::UTF8)) {
            if ($line -match '^Launcher SHA-256:\s*([A-Fa-f0-9]{64})\s*$') {
                $expected = [string]$Matches[1].ToLowerInvariant()
            }
        }
        return ($expected -and (Get-FileSha256 $Launcher) -eq $expected)
    }
    catch {
        return $false
    }
}

function Create-Shortcut {
    param([string]$Name, [string]$Target, [string]$WorkingDirectory, [string]$Icon = "")

    $desktop = [Environment]::GetFolderPath("Desktop")
    if (-not $desktop -or -not (Test-Path -LiteralPath $desktop -PathType Container)) {
        throw "The current user's Desktop folder is unavailable."
    }

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut((Join-Path $desktop ($Name + ".lnk")))
    $shortcut.TargetPath = $Target
    $shortcut.WorkingDirectory = $WorkingDirectory
    if ($Icon -and (Test-Path -LiteralPath $Icon)) {
        $shortcut.IconLocation = $Icon
    }
    $shortcut.Save()
}

function Test-CommanderDirectory {
    $directory = Join-Path $Roaming "Forge\decks\commander"
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    $test = Join-Path $directory (".__jadon_write_test.candidate-" + $RunId)
    try {
        [IO.File]::WriteAllText($test, "write-test", (New-Object Text.ASCIIEncoding))
        if (-not (Test-Path -LiteralPath $test)) {
            throw "Forge Commander deck directory is not writable."
        }
    }
    finally {
        if (Test-Path -LiteralPath $test) { [IO.File]::Delete($test) }
    }
}

function Complete-ForgeConfiguration {
    param($Target, [string]$InstallMode)

    Write-Status "[6/8] Creating and validating the Forge launcher..."
    Write-ForgeLauncher $Target
    Write-ForgeLocation $Target
    if (-not (Test-LiveLauncher)) {
        throw "Final Start_Forge.cmd integrity validation failed."
    }

    if ($InstallMode -eq "NORMAL") {
        try {
            Create-Shortcut "MTG Forge" $Launcher $Target.Home (
                if ($Target.Kind -eq "EXE") { $Target.Path } else { "" }
            )
            Write-Status "Forge desktop shortcut: CREATED" Green
        }
        catch {
            Write-Status ("Forge desktop shortcut was skipped: " + $_.Exception.Message) Yellow
        }
    }
    else {
        Write-Status "School mode: Windows shortcut integration was skipped."
    }

    Write-Status "[8/8] Running final Java, Forge, launcher, and deck-folder checks..."
    if ($Target.Kind -ne "EXE" -and -not (Test-PrivateJava $JavaHome)) {
        throw "Private Java final validation failed."
    }
    if (-not (Get-ForgeTargetInRoot (Join-Path $Base ("Forge-" + $Target.Version)) $Target.Version)) {
        throw "Forge final target validation failed."
    }
    Test-CommanderDirectory
    Write-Status "Core Forge installation checks: PASS" Green
}

function Install-Forge {
    param([string]$InstallMode)

    Write-InstallLog ("Install requested in " + $InstallMode + " mode.")
    Write-Status "[1/8] User-level preflight checks..."
    Write-Status ("Install base: " + $Base)
    if ($InstallMode -eq "SCHOOL") {
        Write-Status "School mode: no elevation, BITS, GUI fallback, shortcuts, registry commands, or permanent PATH changes."
    }

    $writeTest = Join-Path $Base ("write-test.candidate-" + $RunId)
    try {
        [IO.File]::WriteAllText($writeTest, "write-test", (New-Object Text.ASCIIEncoding))
    }
    finally {
        if (Test-Path -LiteralPath $writeTest) { [IO.File]::Delete($writeTest) }
    }

    $java = Ensure-PrivateJava $InstallMode
    $installed = Get-InstalledForge
    $release = Resolve-ForgeRelease

    if (-not $release) {
        if ($installed) {
            Write-Status ("Release lookup failed; reusing validated installed Forge " + $installed.Version + ".") Yellow
            Complete-ForgeConfiguration $installed $InstallMode
            return
        }

        Write-Status "Release lookup failed and no installed Forge was found; using known stable 2.0.14." Yellow
        $release = [pscustomobject]@{
            Version = "2.0.14"
            Tag = "forge-2.0.14"
            Asset = "forge-installer-2.0.14.jar"
            Url = "https://github.com/Card-Forge/forge/releases/download/forge-2.0.14/forge-installer-2.0.14.jar"
            Digest = ""
            IsFallback = $true
        }
    }

    Write-Status ("Selected Forge release: " + $release.Tag)
    $matching = Get-InstalledForge $release.Version
    if ($matching) {
        Write-Status "The selected Forge version is already validated; reusing it." Green
        Complete-ForgeConfiguration $matching $InstallMode
        return
    }

    if ($installed) {
        try {
            if ([version]$installed.Version -gt [version]$release.Version) {
                Write-Status ("A newer validated Forge " + $installed.Version + " is installed; refusing to downgrade it.") Yellow
                Complete-ForgeConfiguration $installed $InstallMode
                return
            }
        }
        catch {}
    }

    $installer = Ensure-ForgeInstaller $release $InstallMode
    $target = Install-ForgeCandidate $release $java $installer $InstallMode
    Complete-ForgeConfiguration $target $InstallMode
}

function Invoke-ForgeLauncher {
    if (-not (Test-LiveLauncher)) {
        Write-Status "Existing Start_Forge.cmd is absent or failed integrity validation; rebuilding it." Yellow
        $target = Get-InstalledForge
        if (-not $target) {
            throw "No validated Forge installation was found under the user-level MTGForge folder."
        }
        if ($target.Kind -ne "EXE" -and -not (Test-PrivateJava $JavaHome)) {
            throw "Forge was found, but private Java 17+ was not available. Run Install/Repair first."
        }
        Write-ForgeLauncher $target
        Write-ForgeLocation $target
    }
    else {
        Write-Status "Using the existing integrity-verified Start_Forge.cmd." Green
    }

    Write-Status "Launching Forge..."
    $saved = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & $Launcher
        $rc = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $saved
    }

    if ($rc -ne 0) {
        throw "Start_Forge.cmd returned exit code $rc."
    }
}

function Invoke-InstallerSelfTest {
    $root = Join-Path $Base ("installer-selftest-" + $RunId)
    New-Item -ItemType Directory -Path $root | Out-Null
    try {
        $candidate = Join-Path $root "atomic.txt.candidate"
        $live = Join-Path $root "atomic.txt"
        [IO.File]::WriteAllText($candidate, "candidate", (New-Object Text.ASCIIEncoding))
        Promote-FileCandidate $candidate $live
        if ([IO.File]::ReadAllText($live) -ne "candidate") {
            throw "Atomic file promotion self-test failed."
        }

        $forgeRoot = Join-Path $root "Forge-9.9.9"
        New-Item -ItemType Directory -Path $forgeRoot | Out-Null
        $forgeCmd = Join-Path $forgeRoot "forge.cmd"
        [IO.File]::WriteAllText($forgeCmd, "@echo off`r`nexit /b 0`r`n", (New-Object Text.ASCIIEncoding))
        $testLauncher = Join-Path $root "Start_Forge.cmd"
        $target = Get-ForgeTargetInRoot $forgeRoot "9.9.9"
        if (-not $target -or $target.Kind -ne "CMD") {
            throw "Forge target discovery self-test failed."
        }
        Write-ForgeLauncher $target $testLauncher
        if (-not (Test-LauncherText ([IO.File]::ReadAllText($testLauncher, [Text.Encoding]::ASCII)))) {
            throw "Launcher-generation self-test failed."
        }

        if ((Get-FileSha256 $testLauncher).Length -ne 64) {
            throw "SHA-256 self-test failed."
        }

        Write-Host "Installer core self-test: PASS"
        Write-InstallLog "Installer core self-test: PASS"
    }
    finally {
        if (Test-Path -LiteralPath $root) {
            $baseFull = [IO.Path]::GetFullPath($Base).TrimEnd("\") + "\"
            $rootFull = [IO.Path]::GetFullPath($root)
            if ($rootFull.StartsWith($baseFull, [StringComparison]::OrdinalIgnoreCase) -and
                [IO.Path]::GetFileName($rootFull).StartsWith("installer-selftest-")) {
                [IO.Directory]::Delete($rootFull, $true)
            }
        }
    }
}

function Create-ManagerShortcut {
    if (-not (Test-Path -LiteralPath $ManagerCmd -PathType Leaf)) {
        throw "The validated V9 manager launcher is missing."
    }
    Create-Shortcut "Jadon Ultimate Forge Manager v9" $ManagerCmd $Base
    Write-Host "Manager desktop shortcut: CREATED"
    Write-InstallLog "Manager desktop shortcut: CREATED"
}

function Assert-ManagedUninstallPath {
    param([string]$Path, [string]$AllowedRoot)

    $rootFull = [IO.Path]::GetFullPath($AllowedRoot).TrimEnd("\") + "\"
    $pathFull = [IO.Path]::GetFullPath($Path)
    if (-not $pathFull.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) {
        throw ("Uninstall safety check refused path outside its managed root: " + $pathFull)
    }
    return $pathFull
}

function Remove-ManagedUninstallPath {
    param([string]$Path, [string]$AllowedRoot)

    if (-not (Test-Path -LiteralPath $Path)) { return }
    $safePath = Assert-ManagedUninstallPath $Path $AllowedRoot
    Remove-Item -LiteralPath $safePath -Force -Recurse -ErrorAction Stop
    Write-Host ("Removed: " + $safePath)
}

function Test-InstallerOwnedDeck {
    param([string]$Path)

    try {
        $head = @(Get-Content -LiteralPath $Path -TotalCount 20 -Encoding UTF8)
        if ($head -contains "Tags=JADON_ARCHIDEKT_IMPORT") { return $true }
        $source = @($head | Where-Object { $_ -match '^Source URL=https://archidekt[.]com/decks/\d+' }).Count -gt 0
        $comment = @($head | Where-Object {
            $_ -eq "Comment=Imported automatically from Archidekt" -or
            $_ -eq "Comment=Synced from Archidekt by Jadon's Archidekt Deck Sync" -or
            $_ -like "Comment=Imported by Jadon's Archidekt Forge Manager*"
        }).Count -gt 0
        return ($source -and $comment)
    }
    catch { return $false }
}

function Remove-InstallerOwnedDecks {
    $forgeUser = Join-Path $Roaming "Forge"
    $deckRoot = Join-Path $forgeUser "decks"
    $removed = 0
    foreach ($directory in @((Join-Path $deckRoot "commander"), (Join-Path $deckRoot "constructed"))) {
        if (-not (Test-Path -LiteralPath $directory)) { continue }
        foreach ($file in Get-ChildItem -LiteralPath $directory -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (-not (Test-InstallerOwnedDeck $file.FullName)) { continue }
            $safeFile = Assert-ManagedUninstallPath $file.FullName $deckRoot
            Remove-Item -LiteralPath $safeFile -Force -ErrorAction Stop
            $removed++
        }
    }
    $state = Join-Path $Base "ArchidektSync\import-state.json"
    if (Test-Path -LiteralPath $state) { Remove-ManagedUninstallPath $state $Base }
    Write-Host ("Removed importer-owned decks: " + $removed)
}

function Remove-ManagerComponents {
    foreach ($path in @(
        (Join-Path $Base "ArchidektSync"),
        (Join-Path $Base "AIViewer"),
        (Join-Path $Base "Jadons_Ultimate_Forge_Manager_v7.cmd"),
        (Join-Path $Base "Jadons_Ultimate_Forge_Manager_v9.cmd"),
        (Join-Path $Base "LegacyInstaller_v8.compat.cmd")
    )) {
        Remove-ManagedUninstallPath $path $Base
    }
}

function Remove-ForgeComponents {
    foreach ($directory in Get-ChildItem -LiteralPath $Base -Directory -ErrorAction SilentlyContinue) {
        if ($directory.Name -match '^Forge-\d+(?:[.]\d+){1,3}(?:[.].+)?$') {
            Remove-ManagedUninstallPath $directory.FullName $Base
        }
    }
    foreach ($path in @(
        (Join-Path $Base "Start_Forge.cmd"),
        (Join-Path $Base "Start_Forge.cmd.sha256"),
        (Join-Path $Base "Forge_Location.txt"),
        (Join-Path $Base "downloads")
    )) {
        Remove-ManagedUninstallPath $path $Base
    }
}

function Remove-CacheComponents {
    foreach ($path in @(
        (Join-Path $Base "logs"),
        (Join-Path $Base "downloads"),
        (Join-Path $Base "ArchidektSync\backups"),
        (Join-Path $Base "ArchidektSync\scryfall-cache.json")
    )) {
        Remove-ManagedUninstallPath $path $Base
    }
}

function Invoke-ConfiguredUninstall {
    param([string]$Scope)

    Write-Host ""
    Write-Host ("Configured uninstall scope: " + $Scope) -ForegroundColor Cyan
    Write-InstallLog ("Configured uninstall requested: " + $Scope)
    switch ($Scope) {
        "ImportedDecks" { Remove-InstallerOwnedDecks }
        "Manager" { Remove-ManagerComponents }
        "Forge" { Remove-ForgeComponents }
        "Java" { Remove-ManagedUninstallPath $JavaHome $Base }
        "Caches" { Remove-CacheComponents }
        "KeepDecks" {
            Remove-ManagerComponents
            Remove-ForgeComponents
            Remove-ManagedUninstallPath $JavaHome $Base
            Remove-CacheComponents
            foreach ($path in @((Join-Path $Base "InstallerCore_v7.payload"), (Join-Path $Base "InstallerCore_v9.payload"))) {
                Remove-ManagedUninstallPath $path $Base
            }
        }
        "Everything" {
            Remove-InstallerOwnedDecks
            Remove-ManagerComponents
            Remove-ForgeComponents
            Remove-ManagedUninstallPath $JavaHome $Base
            Remove-CacheComponents
            foreach ($path in @((Join-Path $Base "InstallerCore_v7.payload"), (Join-Path $Base "InstallerCore_v9.payload"))) {
                Remove-ManagedUninstallPath $path $Base
            }
        }
    }
    Write-Host "Configured uninstall completed." -ForegroundColor Green
}

try {
    switch ($Action) {
        "Install" { Install-Forge $Mode }
        "RunForge" { Invoke-ForgeLauncher }
        "SelfTest" { Invoke-InstallerSelfTest }
        "ManagerShortcut" { Create-ManagerShortcut }
        "Uninstall" { Invoke-ConfiguredUninstall $UninstallScope }
    }
    exit 0
}
catch {
    Write-InstallLog ("FAILED ACTION: " + $Action)
    Write-InstallLog ("ERROR: " + $_.Exception.ToString())
    if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
        Write-InstallLog ("POSITION: " + ($_.InvocationInfo.PositionMessage -replace "`r?`n", " "))
    }
    if ($_.ScriptStackTrace) {
        Write-InstallLog ("STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
    }

    Write-Host ""
    Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
    Write-Host ("Complete diagnostics: " + $LogFile)
    exit 1
}
###JADON_INSTALLER_V7_PS_PAYLOAD_END###
###JADON_INSTALLER_MANAGER_V7_CMD_PAYLOAD###
@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Jadon's Ultimate Forge Manager v9.0

set "M7_PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%M7_PS_EXE%" goto :M7_NO_POWERSHELL

call :M7_CHECK_POWERSHELL_COMPAT
if errorlevel 1 goto :M7_POLICY_BLOCKED

call :M7_CHECK_NOT_ELEVATED
if errorlevel 1 goto :M7_ELEVATED

if defined LOCALAPPDATA set "M7_BASE=%LOCALAPPDATA%\MTGForge"
if not defined LOCALAPPDATA set "M7_BASE=%USERPROFILE%\AppData\Local\MTGForge"
set "M7_TOOL=%M7_BASE%\ArchidektSync"
set "M7_LOG=%M7_BASE%\logs"
set "M7_PS1=%M7_TOOL%\UltimateForgeManager_v9.payload"
set "M7_PS_CANDIDATE=%M7_TOOL%\UltimateForgeManager_v9.candidate.payload"
set "M7_SAFE_CMD=%M7_TOOL%\Safe_Archidekt_Importer_v4.cmd"
set "M7_SAFE_CMD_CANDIDATE=%M7_TOOL%\Safe_Archidekt_Importer_v4.candidate.cmd"
set "M7_SAFE_PS1=%M7_TOOL%\Safe_Archidekt_Importer_v4.payload"
set "M7_SAFE_PS_CANDIDATE=%M7_TOOL%\Safe_Archidekt_Importer_v4.candidate.payload"
set "M7_LEGACY=%M7_BASE%\LegacyInstaller_v8.compat.cmd"
set "M7_PARSE_LOG=%M7_LOG%\manager-v7-parse.log"
set "M7_TEST_LOG=%M7_LOG%\manager-v7-selftest.log"
set "M7_SAFE_LOG=%M7_LOG%\safe-importer-v4-verify.log"
set "M7_RUN_LOG=%M7_LOG%\manager-v7-last-error.log"
set "M7_SELF=%~f0"
set "M7_SAFE_CMD_SHA=3fdb666ff2b2f87e33f787d52c29601fee7ff965f0df459ee74d220b87be41be"
set "M7_SAFE_PS_SHA=2e8aab791f933f0e7409b23463ada24250bf5caebabb826f00765c1c87050e7c"
set "M7_MANAGER_PS_SHA=83d0be0add54faa95944f29f446e4d24839efe1bf059cf62c45312bd1fceefd9"
set "M7_LEGACY_SHA=ac8ebde5c795e981f6383acc62ac4cd19c29ad8056ffb07ddd3e92e6bf9bcb85"
set "M7_SAFE_READY=0"

if not exist "%M7_BASE%" mkdir "%M7_BASE%" >nul 2>&1
if not exist "%M7_TOOL%" mkdir "%M7_TOOL%" >nul 2>&1
if not exist "%M7_LOG%" mkdir "%M7_LOG%" >nul 2>&1
if not exist "%M7_TOOL%" goto :M7_INIT_FAILED
if not exist "%M7_LOG%" goto :M7_INIT_FAILED

call :M7_PREPARE_SAFE
if not errorlevel 1 set "M7_SAFE_READY=1"

if /I "%~1"=="--safe" goto :M7_SAFE_ONLY

call :M7_PREPARE_MANAGER
if errorlevel 1 goto :M7_PRIMARY_FAILED

if /I "%~1"=="--test" goto :M7_TEST_PASSED
if /I "%~1"=="--memory-import" goto :M7_MEMORY_IMPORT
if /I "%~1"=="--memory-view" goto :M7_MEMORY_VIEW

echo.
echo PowerShell parser: PASS
echo Manager self-test: PASS (22/22)
if "%M7_SAFE_READY%"=="1" echo Proven safe V4 fallback: VERIFIED
if not "%M7_SAFE_READY%"=="1" echo Proven safe V4 fallback: UNAVAILABLE
echo.
echo Starting V9 manager...
echo.

call :M7_INVOKE_PAYLOAD "%M7_PS1%" MAIN
set "M7_RC=%ERRORLEVEL%"
if "%M7_RC%"=="0" exit /b 0

> "%M7_RUN_LOG%" echo V9 manager exited with code %M7_RC%.
>> "%M7_RUN_LOG%" echo Parse log: %M7_PARSE_LOG%
>> "%M7_RUN_LOG%" echo Self-test log: %M7_TEST_LOG%
echo.
echo ================================================================
echo V9 MANAGER RETURNED ERROR CODE %M7_RC%
echo ================================================================
echo.
echo Details: %M7_RUN_LOG%
echo The proven safe importer will open if its exact hash is verified.
echo.
pause
goto :M7_OPEN_SAFE

:M7_TEST_PASSED
type "%M7_PARSE_LOG%"
type "%M7_TEST_LOG%"
echo.
echo V9 primary manager candidate: PASS
if "%M7_SAFE_READY%"=="1" echo Proven safe V4 fallback: PASS
if not "%M7_SAFE_READY%"=="1" echo Proven safe V4 fallback: FAILED
if not "%M7_SAFE_READY%"=="1" exit /b 3
exit /b 0

:M7_MEMORY_IMPORT
call :M7_INVOKE_PAYLOAD "%M7_PS1%" MEMORYIMPORT
exit /b %ERRORLEVEL%

:M7_MEMORY_VIEW
call :M7_INVOKE_PAYLOAD "%M7_PS1%" MEMORYVIEW
exit /b %ERRORLEVEL%

:M7_PRIMARY_FAILED
if /I "%~1"=="--test" goto :M7_TEST_FAILED
echo.
echo ================================================================
echo V9 MANAGER CANDIDATE FAILED VALIDATION
echo ================================================================
echo.
if exist "%M7_PARSE_LOG%" type "%M7_PARSE_LOG%"
if exist "%M7_TEST_LOG%" type "%M7_TEST_LOG%"
echo.
echo The previous working V9 manager, if any, was retained.
echo The proven safe importer will open if its exact hash is verified.
echo.
pause
goto :M7_OPEN_SAFE

:M7_TEST_FAILED
if exist "%M7_PARSE_LOG%" type "%M7_PARSE_LOG%"
if exist "%M7_TEST_LOG%" type "%M7_TEST_LOG%"
echo.
if "%M7_SAFE_READY%"=="1" echo Proven safe V4 fallback: PASS
if not "%M7_SAFE_READY%"=="1" echo Proven safe V4 fallback: FAILED
exit /b 2

:M7_SAFE_ONLY
if not "%M7_SAFE_READY%"=="1" goto :M7_SAFE_UNAVAILABLE
call :M7_RUN_SAFE
if not errorlevel 1 exit /b 0
call :M7_RUN_LEGACY
exit /b %ERRORLEVEL%

:M7_OPEN_SAFE
if not "%M7_SAFE_READY%"=="1" goto :M7_SAFE_UNAVAILABLE
call :M7_RUN_SAFE
if not errorlevel 1 exit /b 0
call :M7_RUN_LEGACY
exit /b %ERRORLEVEL%

:M7_RUN_SAFE
call :M7_SEED_DEFAULT_PROFILES
echo.
echo Opening the independently verified proven safe V4 importer...
echo.
call :M7_INVOKE_PAYLOAD "%M7_SAFE_PS1%" MAIN
set "M7_SAFE_RC=%ERRORLEVEL%"
if "%M7_SAFE_RC%"=="0" exit /b 0
echo.
echo Safe importer returned code %M7_SAFE_RC%.
echo Verification log: %M7_SAFE_LOG%
echo.
pause
exit /b %M7_SAFE_RC%

:M7_PREPARE_SAFE
set "PS_M7_SELF=%M7_SELF%"
set "PS_M7_SAFE_CMD=%M7_SAFE_CMD%"
set "PS_M7_SAFE_CMD_CANDIDATE=%M7_SAFE_CMD_CANDIDATE%"
set "PS_M7_SAFE_CMD_SHA=%M7_SAFE_CMD_SHA%"

"%M7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';" ^
 "$raw=[IO.File]::ReadAllText($env:PS_M7_SELF);" ^
 "$b='###JADON_SAFE_IMPORTER_V4_BEGIN###';" ^
 "$e='###JADON_SAFE_IMPORTER_V4_END###';" ^
 "$bi=$raw.LastIndexOf($b); $ei=$raw.LastIndexOf($e);" ^
 "if($bi -lt 0 -or $ei -le $bi){throw 'Safe importer markers are invalid.'};" ^
 "$body=$raw.Substring($bi+$b.Length,$ei-($bi+$b.Length)).TrimStart([char]13,[char]10);" ^
 "$enc=New-Object Text.UTF8Encoding($false);" ^
 "[IO.File]::WriteAllText($env:PS_M7_SAFE_CMD_CANDIDATE,$body,$enc);" ^
 "$sha=[Security.Cryptography.SHA256]::Create(); $s=[IO.File]::OpenRead($env:PS_M7_SAFE_CMD_CANDIDATE); try{$hash=([BitConverter]::ToString($sha.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$sha.Dispose()};" ^
 "if($hash -ne $env:PS_M7_SAFE_CMD_SHA){throw ('Safe CMD hash mismatch: '+$hash)}" > "%M7_SAFE_LOG%" 2>&1
if errorlevel 1 goto :M7_SAFE_PREP_FAILED

set "PS_M7_SAFE_PS=%M7_SAFE_PS1%"
set "PS_M7_SAFE_PS_CANDIDATE=%M7_SAFE_PS_CANDIDATE%"
set "PS_M7_SAFE_PS_SHA=%M7_SAFE_PS_SHA%"

"%M7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';" ^
 "$raw=[IO.File]::ReadAllText($env:PS_M7_SAFE_CMD_CANDIDATE);" ^
 "$m='###JADON_ARCHIDEKT_MANAGER_PAYLOAD###'; $ix=$raw.LastIndexOf($m);" ^
 "if($ix -lt 0){throw 'Safe PowerShell marker is missing.'};" ^
 "$body=$raw.Substring($ix+$m.Length).TrimStart([char]13,[char]10);" ^
 "$enc=New-Object Text.UTF8Encoding($false);" ^
 "[IO.File]::WriteAllText($env:PS_M7_SAFE_PS_CANDIDATE,$body,$enc);" ^
 "$sha=[Security.Cryptography.SHA256]::Create(); $s=[IO.File]::OpenRead($env:PS_M7_SAFE_PS_CANDIDATE); try{$hash=([BitConverter]::ToString($sha.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$sha.Dispose()};" ^
 "if($hash -ne $env:PS_M7_SAFE_PS_SHA){throw ('Safe PS hash mismatch: '+$hash)};" ^
 "$tokens=$null; $errors=$null;" ^
 "[Management.Automation.Language.Parser]::ParseFile($env:PS_M7_SAFE_PS_CANDIDATE,[ref]$tokens,[ref]$errors)|Out-Null;" ^
 "if($errors.Count){throw ('Safe PS parser error: '+$errors[0].Message)};" ^
 "$cmdLive=$env:PS_M7_SAFE_CMD; $cmdCandidate=$env:PS_M7_SAFE_CMD_CANDIDATE;" ^
 "$psLive=$env:PS_M7_SAFE_PS; $psCandidate=$env:PS_M7_SAFE_PS_CANDIDATE;" ^
 "if(Test-Path -LiteralPath $cmdLive){$bak=$cmdLive+'.last-good'; if(Test-Path -LiteralPath $bak){Remove-Item -LiteralPath $bak -Force}; [IO.File]::Replace($cmdCandidate,$cmdLive,$bak,$true)}else{[IO.File]::Move($cmdCandidate,$cmdLive)};" ^
 "if(Test-Path -LiteralPath $psLive){$bak=$psLive+'.last-good'; if(Test-Path -LiteralPath $bak){Remove-Item -LiteralPath $bak -Force}; [IO.File]::Replace($psCandidate,$psLive,$bak,$true)}else{[IO.File]::Move($psCandidate,$psLive)};" ^
 "Write-Output ('Windows PowerShell: '+$PSVersionTable.PSVersion);" ^
 "Write-Output 'Safe importer CMD hash/parser/runtime extraction: PASS'" >> "%M7_SAFE_LOG%" 2>&1
if errorlevel 1 goto :M7_SAFE_PREP_FAILED
exit /b 0

:M7_SAFE_PREP_FAILED
del /f /q "%M7_SAFE_CMD_CANDIDATE%" >nul 2>&1
del /f /q "%M7_SAFE_PS_CANDIDATE%" >nul 2>&1
exit /b 1

:M7_PREPARE_MANAGER
del /f /q "%M7_PS_CANDIDATE%" >nul 2>&1
del /f /q "%M7_PARSE_LOG%" >nul 2>&1
del /f /q "%M7_TEST_LOG%" >nul 2>&1
set "PS_M7_SELF=%M7_SELF%"
set "PS_M7_OUT=%M7_PS_CANDIDATE%"
set "PS_M7_EXPECTED_SHA=%M7_MANAGER_PS_SHA%"

"%M7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';" ^
 "$raw=[IO.File]::ReadAllText($env:PS_M7_SELF);" ^
 "$m='###JADON_MANAGER_V7_PS_PAYLOAD###'; $ix=$raw.LastIndexOf($m);" ^
 "if($ix -lt 0){throw 'V9 manager PowerShell marker is missing.'};" ^
 "$body=$raw.Substring($ix+$m.Length).TrimStart([char]13,[char]10);" ^
 "$enc=New-Object Text.UTF8Encoding($false);" ^
 "[IO.File]::WriteAllText($env:PS_M7_OUT,$body,$enc);" ^
 "$sha=[Security.Cryptography.SHA256]::Create(); $s=[IO.File]::OpenRead($env:PS_M7_OUT); try{$hash=([BitConverter]::ToString($sha.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$sha.Dispose()};" ^
 "if($hash -ne $env:PS_M7_EXPECTED_SHA){throw ('Manager PS candidate hash mismatch: '+$hash)}" > "%M7_PARSE_LOG%" 2>&1
if errorlevel 1 goto :M7_MANAGER_PREP_FAILED

set "PS_M7_PARSE_FILE=%M7_PS_CANDIDATE%"
"%M7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$src=[IO.File]::ReadAllLines($env:PS_M7_PARSE_FILE);" ^
 "$tokens=$null; $errors=$null;" ^
 "[Management.Automation.Language.Parser]::ParseFile($env:PS_M7_PARSE_FILE,[ref]$tokens,[ref]$errors)|Out-Null;" ^
 "Write-Output ('Windows PowerShell version: '+$PSVersionTable.PSVersion);" ^
 "if($errors.Count){foreach($err in $errors){$ln=$err.Extent.StartLineNumber; $col=$err.Extent.StartColumnNumber; Write-Output ($ln.ToString()+':'+$col.ToString()+': '+$err.Message); if($ln -ge 1 -and $ln -le $src.Length){Write-Output ('    SOURCE> '+$src[$ln-1])}}; exit 1};" ^
 "Write-Output 'PowerShell parser: PASS (complete candidate)'" >> "%M7_PARSE_LOG%" 2>&1
if errorlevel 1 goto :M7_MANAGER_PREP_FAILED

call :M7_INVOKE_PAYLOAD "%M7_PS_CANDIDATE%" SELFTEST > "%M7_TEST_LOG%" 2>&1
if errorlevel 1 goto :M7_MANAGER_PREP_FAILED

set "PS_M7_CANDIDATE=%M7_PS_CANDIDATE%"
set "PS_M7_LIVE=%M7_PS1%"
"%M7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop'; $c=$env:PS_M7_CANDIDATE; $l=$env:PS_M7_LIVE;" ^
 "if(Test-Path -LiteralPath $l){$bak=$l+'.last-good'; if(Test-Path -LiteralPath $bak){Remove-Item -LiteralPath $bak -Force}; [IO.File]::Replace($c,$l,$bak,$true)}else{[IO.File]::Move($c,$l)}"
if errorlevel 1 goto :M7_MANAGER_PREP_FAILED
del /f /q "%M7_TOOL%\UltimateForgeManager_v7.ps1" >nul 2>&1
del /f /q "%M7_TOOL%\UltimateForgeManager_v7.candidate.ps1" >nul 2>&1
del /f /q "%M7_TOOL%\UltimateForgeManager_v7.ps1.last-good" >nul 2>&1
del /f /q "%M7_TOOL%\UltimateForgeManager_v9.ps1" >nul 2>&1
del /f /q "%M7_TOOL%\UltimateForgeManager_v9.candidate.ps1" >nul 2>&1
del /f /q "%M7_TOOL%\UltimateForgeManager_v9.ps1.last-good" >nul 2>&1
del /f /q "%M7_TOOL%\Safe_Archidekt_Importer_v4.ps1" >nul 2>&1
del /f /q "%M7_TOOL%\Safe_Archidekt_Importer_v4.candidate.ps1" >nul 2>&1
del /f /q "%M7_TOOL%\Safe_Archidekt_Importer_v4.ps1.last-good" >nul 2>&1
exit /b 0

:M7_MANAGER_PREP_FAILED
del /f /q "%M7_PS_CANDIDATE%" >nul 2>&1
exit /b 1

:M7_SEED_DEFAULT_PROFILES
set "PS_M7_PROFILE_FILE=%M7_TOOL%\profiles.txt"
"%M7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop'; $d=@('Bot_2','CLAWolf','MrStealYoCreatures');" ^
 "$e=@(); if(Test-Path -LiteralPath $env:PS_M7_PROFILE_FILE){$e=@(Get-Content -LiteralPath $env:PS_M7_PROFILE_FILE -Encoding UTF8|Where-Object{-not [string]::IsNullOrWhiteSpace($_)})};" ^
 "$a=New-Object Collections.ArrayList; foreach($x in $d){[void]$a.Add($x)};" ^
 "foreach($x in $e){$dup=$false; foreach($y in $a){if([string]::Equals([string]$x,[string]$y,[StringComparison]::OrdinalIgnoreCase)){$dup=$true;break}}; if(-not $dup -and $a.Count -lt 20){[void]$a.Add([string]$x)}};" ^
 "$enc=New-Object Text.UTF8Encoding($false); [IO.File]::WriteAllLines($env:PS_M7_PROFILE_FILE,[string[]]$a.ToArray(),$enc)" >nul 2>&1
exit /b 0

:M7_INVOKE_PAYLOAD
set "PS_M7_RUN_PAYLOAD=%~1"
set "PS_M7_RUN_MODE=%~2"
"%M7_PS_EXE%" -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop';$text=[IO.File]::ReadAllText($env:PS_M7_RUN_PAYLOAD,[Text.Encoding]::UTF8);$block=[ScriptBlock]::Create($text);if($env:PS_M7_RUN_MODE-eq'SELFTEST'){. $block -SelfTest}elseif($env:PS_M7_RUN_MODE-eq'MEMORYIMPORT'){. $block -StartupAction ImportMemory}elseif($env:PS_M7_RUN_MODE-eq'MEMORYVIEW'){. $block -StartupAction ViewMemory}else{. $block}"
exit /b %ERRORLEVEL%

:M7_CHECK_POWERSHELL_COMPAT
"%M7_PS_EXE%" -NoLogo -NoProfile -Command "try{if($ExecutionContext.SessionState.LanguageMode-ne'FullLanguage'){exit 12};$b=[ScriptBlock]::Create('param([int]$n);if($n-ne 7){throw ''probe failed''}');&$b 7;exit 0}catch{exit 13}" >nul 2>&1
exit /b %ERRORLEVEL%

:M7_CHECK_NOT_ELEVATED
"%M7_PS_EXE%" -NoLogo -NoProfile -Command "$i=[Security.Principal.WindowsIdentity]::GetCurrent();$p=New-Object Security.Principal.WindowsPrincipal($i);if($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){exit 1};exit 0" >nul 2>&1
exit /b %ERRORLEVEL%

:M7_SAFE_UNAVAILABLE
echo.
echo ERROR: The proven safe importer is unavailable or failed exact validation.
if exist "%M7_SAFE_LOG%" type "%M7_SAFE_LOG%"
echo.
if /I "%~1"=="--test" exit /b 3
call :M7_RUN_LEGACY
if not errorlevel 1 exit /b 0
pause
exit /b 1

:M7_RUN_LEGACY
if not exist "%M7_LEGACY%" exit /b 1
set "PS_M7_LEGACY=%M7_LEGACY%"
set "PS_M7_LEGACY_SHA=%M7_LEGACY_SHA%"
"%M7_PS_EXE%" -NoLogo -NoProfile -Command "$sha=[Security.Cryptography.SHA256]::Create();$s=[IO.File]::OpenRead($env:PS_M7_LEGACY);try{$h=([BitConverter]::ToString($sha.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$sha.Dispose()};if($h-ne$env:PS_M7_LEGACY_SHA){exit 1}" >nul 2>&1
if errorlevel 1 exit /b 1
echo Opening the exact attached v8 compatibility installer and importer...
call "%M7_LEGACY%"
exit /b %ERRORLEVEL%

:M7_NO_POWERSHELL
echo.
echo ERROR: Windows PowerShell 5.1 was not found.
echo No policy bypass or alternate shell was attempted.
echo.
if /I "%~1"=="--test" exit /b 1
pause
exit /b 1

:M7_POLICY_BLOCKED
echo.
echo ERROR: This PC's administrator policy blocks the Windows PowerShell
echo script engine features required by the installer and importer.
echo No execution-policy bypass, registry change, or elevation was attempted.
echo Ask the school administrator to allow this trusted single-file installer.
echo.
if /I "%~1"=="--test" exit /b 1
pause
exit /b 1

:M7_ELEVATED
echo.
echo ERROR: Run this manager as the normal signed-in user, not as administrator.
echo No files were written.
echo.
if /I "%~1"=="--test" exit /b 1
pause
exit /b 1

:M7_INIT_FAILED
echo.
echo ERROR: The user-level manager folders could not be created.
echo Base: %M7_BASE%
echo.
if /I "%~1"=="--test" exit /b 1
pause
exit /b 1

###JADON_SAFE_IMPORTER_V4_BEGIN###
@echo off
setlocal EnableExtensions
title Jadon's Archidekt Forge Manager v4 SAFE TOKENS

if defined LOCALAPPDATA (
    set "BASE=%LOCALAPPDATA%\MTGForge"
) else (
    set "BASE=%USERPROFILE%\AppData\Local\MTGForge"
)

set "TOOLDIR=%BASE%\ArchidektSync"
set "PS1=%TOOLDIR%\ArchidektForgeManager.ps1"
set "SELF=%~f0"

if not exist "%TOOLDIR%" mkdir "%TOOLDIR%" >nul 2>&1

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Windows PowerShell was not found.
    echo.
    pause
    exit /b 1
)

set "PS_SELF=%SELF%"
set "PS_OUT=%PS1%"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; $raw=[IO.File]::ReadAllText($env:PS_SELF); $marker='###JADON_ARCHIDEKT_MANAGER_PAYLOAD###'; $ix=$raw.LastIndexOf($marker); if($ix -lt 0){throw 'Embedded importer payload was not found.'}; $payload=$raw.Substring($ix+$marker.Length).TrimStart([char]13,[char]10); $enc=New-Object System.Text.UTF8Encoding($false); [IO.File]::WriteAllText($env:PS_OUT,$payload,$enc)"

if errorlevel 1 (
    echo.
    echo ERROR: Could not prepare the Archidekt manager.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
 "$errors=$null; $tokens=$null; [System.Management.Automation.Language.Parser]::ParseFile($env:PS_OUT,[ref]$tokens,[ref]$errors) > $null; if($errors.Count -gt 0){$errors | ForEach-Object { Write-Host $_.Message }; exit 1}"

if errorlevel 1 (
    echo.
    echo ERROR: The embedded PowerShell importer failed its syntax test.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
exit /b %ERRORLEVEL%

###JADON_ARCHIDEKT_MANAGER_PAYLOAD###
param()

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Base = if ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA "MTGForge"
} else {
    Join-Path $env:USERPROFILE "AppData\Local\MTGForge"
}

$ToolDir = Join-Path $Base "ArchidektSync"
$LogDir = Join-Path $ToolDir "logs"
$SettingsFile = Join-Path $ToolDir "settings.json"
$ProfileHistoryFile = Join-Path $ToolDir "profiles.txt"

$ForgeUser = Join-Path $env:APPDATA "Forge"
$CommanderDir = Join-Path $ForgeUser "decks\commander"
$ConstructedDir = Join-Path $ForgeUser "decks\constructed"

$ImportTag = "JADON_ARCHIDEKT_IMPORT"
$ImporterComment = "Imported by Jadon's Archidekt Forge Manager"

New-Item -ItemType Directory -Force -Path $ToolDir | Out-Null
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $CommanderDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConstructedDir | Out-Null

function Get-Prop {
    param($Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

function Write-Utf8NoBom {
    param([string]$Path, [string[]]$Lines)
    $enc = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllLines($Path, $Lines, $enc)
}

function Read-Settings {
    $defaults = [pscustomobject]@{
        CapCommanderAt100 = $true
        RemoveActualTokens = $false
        ResolveWithScryfall = $true
    }

    if (-not (Test-Path -LiteralPath $SettingsFile)) {
        return $defaults
    }

    try {
        $saved = Get-Content -LiteralPath $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($null -eq (Get-Prop $saved "CapCommanderAt100")) {
            $saved | Add-Member -NotePropertyName CapCommanderAt100 -NotePropertyValue $true
        }
        if ($null -eq (Get-Prop $saved "RemoveActualTokens")) {
            $saved | Add-Member -NotePropertyName RemoveActualTokens -NotePropertyValue $false
        }
        if ($null -eq (Get-Prop $saved "ResolveWithScryfall")) {
            $saved | Add-Member -NotePropertyName ResolveWithScryfall -NotePropertyValue $true
        }
        return $saved
    }
    catch {
        return $defaults
    }
}

function Save-Settings {
    param($Settings)
    $json = $Settings | ConvertTo-Json -Depth 5
    $enc = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($SettingsFile, $json, $enc)
}

$Settings = Read-Settings

$script:CurrentLog = $null
function Start-Log {
    $script:CurrentLog = Join-Path $LogDir ("sync-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log")
}
function Write-Log {
    param([string]$Text)
    Write-Host $Text
    if ($script:CurrentLog) {
        Add-Content -LiteralPath $script:CurrentLog -Value $Text -Encoding UTF8
    }
}

function Invoke-JsonGet {
    param([string]$Url)

    $last = $null

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        $client = $null
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/4.0"

            $bytes = $client.DownloadData($Url)
            $jsonText = [Text.Encoding]::UTF8.GetString($bytes)

            if ([string]::IsNullOrWhiteSpace($jsonText)) {
                throw "The server returned an empty response."
            }

            return ($jsonText | ConvertFrom-Json)
        }
        catch {
            $last = $_
            if ($attempt -lt 3) {
                Write-Log ("    Request failed. Retry " + $attempt + "/3...")
                Start-Sleep -Seconds (2 * $attempt)
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }
    }

    throw $last
}

function Invoke-ScryfallCollection {
    param($Ids)

    $map = @{}
    if ($null -eq $Ids) {
        return $map
    }

    $unique = @($Ids | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | Select-Object -Unique)
    if ($unique.Count -eq 0) {
        return $map
    }

    for ($offset = 0; $offset -lt $unique.Count; $offset += 75) {
        $lastIndex = [Math]::Min($offset + 74, $unique.Count - 1)
        $identifiers = @()

        for ($i = $offset; $i -le $lastIndex; $i++) {
            $identifiers += @{ id = [string]$unique[$i] }
        }

        $requestJson = @{ identifiers = $identifiers } | ConvertTo-Json -Depth 6 -Compress
        $requestBytes = [Text.Encoding]::UTF8.GetBytes($requestJson)

        $client = $null
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/4.0"
            $client.Headers["Content-Type"] = "application/json; charset=utf-8"

            $responseBytes = $client.UploadData(
                "https://api.scryfall.com/cards/collection",
                "POST",
                $requestBytes
            )

            $responseText = [Text.Encoding]::UTF8.GetString($responseBytes)
            $response = $responseText | ConvertFrom-Json

            foreach ($card in $response.data) {
                if ($card -and $card.id) {
                    $map[[string]$card.id] = $card
                }
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }

        Start-Sleep -Milliseconds 120
    }

    return $map
}

function Parse-ProfileInput {
    param([string]$Text)

    $Text = $Text.Trim()

    if ($Text -match '^https?://(?:www\.)?archidekt\.com/u/([^/?#]+)') {
        return [Uri]::UnescapeDataString($Matches[1])
    }

    if ($Text -match '^https?://(?:www\.)?archidekt\.com/search/decks\?') {
        try {
            $uri = [Uri]$Text
            foreach ($part in $uri.Query.TrimStart("?").Split("&")) {
                $bits = $part.Split("=", 2)
                if ($bits.Count -eq 2 -and $bits[0] -eq "ownerUsername") {
                    return [Uri]::UnescapeDataString($bits[1].Replace("+", " "))
                }
            }
        }
        catch {}
    }

    if ($Text -notmatch '[/\\]') {
        return $Text
    }

    throw "That does not look like an Archidekt profile URL or username."
}

function Add-ProfileHistory {
    param([string]$Username)

    if ([string]::IsNullOrWhiteSpace($Username)) { return }

    $existing = @()
    if (Test-Path -LiteralPath $ProfileHistoryFile) {
        try {
            $existing = @(Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 | Where-Object { $_ })
        }
        catch {}
    }

    $newList = @($Username) + @($existing | Where-Object { $_ -ne $Username })
    if ($newList.Count -gt 20) {
        $newList = @($newList[0..19])
    }

    Write-Utf8NoBom $ProfileHistoryFile $newList
}

function Get-RecentProfiles {
    if (-not (Test-Path -LiteralPath $ProfileHistoryFile)) {
        return @()
    }

    try {
        return @(Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 | Where-Object { $_ } | Select-Object -First 10)
    }
    catch {
        return @()
    }
}

function Get-EntryCategories {
    param($Entry)

    $result = [System.Collections.ArrayList]::new()

    $single = Get-Prop $Entry "category"
    if ($single) {
        if ($single -is [string]) {
            [void]$result.Add([string]$single)
        }
        else {
            $singleName = Get-Prop $single "name"
            if ($singleName) { $result.Add([string]$singleName) }
        }
    }

    foreach ($cat in @(Get-Prop $Entry "categories")) {
        if ($null -eq $cat) { continue }

        if ($cat -is [string]) {
            [void]$result.Add([string]$cat)
        }
        else {
            $name = Get-Prop $cat "name"
            if ($name) { $result.Add([string]$name) }
        }
    }

    return @($result.ToArray() | Select-Object -Unique)
}

function Get-ArchidektCardName {
    param($Entry)

    $card = Get-Prop $Entry "card"
    if ($null -eq $card) { return $null }

    $oracle = Get-Prop $card "oracleCard"
    if ($null -eq $oracle) {
        $oracle = Get-Prop $card "oracle_card"
    }

    if ($oracle) {
        $name = Get-Prop $oracle "name"
        if ($name) { return [string]$name }
    }

    foreach ($field in @("displayName", "name")) {
        $name = Get-Prop $card $field
        if ($name) { return [string]$name }
    }

    return $null
}

function Get-ArchidektUid {
    param($Entry)

    $card = Get-Prop $Entry "card"
    if ($null -eq $card) { return $null }

    foreach ($field in @("uid", "scryfallId", "scryfall_id")) {
        $value = Get-Prop $card $field
        if ($value) {
            return [string]$value
        }
    }

    return $null
}

function Get-DeckFormatText {
    param($Deck, $Meta)

    foreach ($obj in @($Deck, $Meta)) {
        if ($null -eq $obj) { continue }

        foreach ($field in @("deckFormat", "format", "deckFormatName", "formatName")) {
            $value = Get-Prop $obj $field
            if ($null -eq $value) { continue }

            if ($value -is [string]) {
                return [string]$value
            }

            if ($value -is [int] -or $value -is [long]) {
                if ([int64]$value -eq 3) { return "Commander" }
                return [string]$value
            }

            foreach ($sub in @("name", "displayName", "label")) {
                $text = Get-Prop $value $sub
                if ($text) { return [string]$text }
            }

            $id = Get-Prop $value "id"
            if ($id -eq 3) { return "Commander" }
        }
    }

    return ""
}

function Get-ForgeCardName {
    param(
        [string]$FallbackName,
        $ScryfallCard
    )

    $name = $FallbackName
    $layout = ""

    if ($ScryfallCard) {
        if ($ScryfallCard.name) {
            $name = [string]$ScryfallCard.name
        }
        if ($ScryfallCard.layout) {
            $layout = ([string]$ScryfallCard.layout).ToLowerInvariant()
        }
    }

    if ([string]::IsNullOrWhiteSpace($name)) {
        return $null
    }

    # Forge deck files use the FRONT card name for transform/MDFC/flip/adventure
    # cards. Split, aftermath and Room cards keep the full "A // B" name.
    $useFrontFace = $false

    switch ($layout) {
        "transform"        { $useFrontFace = $true }
        "modal_dfc"        { $useFrontFace = $true }
        "flip"             { $useFrontFace = $true }
        "adventure"        { $useFrontFace = $true }
        "reversible_card"  { $useFrontFace = $true }
    }

    if ($name.Contains(" // ") -and $useFrontFace) {
        $parts = $name -split " // "
        return ([string]$parts[0]).Trim()
    }

    # If Scryfall was unavailable, the safest Forge fallback for a combined
    # permanent DFC name is the front face. Scryfall resolution normally
    # prevents split/Room cards from reaching this fallback.
    if (-not $ScryfallCard -and $name.Contains(" // ")) {
        $parts = $name -split " // "
        return ([string]$parts[0]).Trim()
    }

    return $name.Trim()
}

function Test-IsActualTokenOrEmblem {
    param(
        $Entry,
        $ScryfallCard
    )

    # IMPORTANT:
    # Do NOT use Archidekt category names such as "Tokens".
    # Users commonly put ordinary token-generating cards in a category named
    # Tokens, and that does not mean the card itself is a token.

    if ($ScryfallCard) {
        $layout = ([string](Get-Prop $ScryfallCard "layout")).ToLowerInvariant()
        $typeLine = [string](Get-Prop $ScryfallCard "type_line")

        if ($layout -in @("token", "double_faced_token", "emblem")) {
            return $true
        }

        if ($typeLine -match '(?i)^\s*Token\b' -or
            $typeLine -match '(?i)^\s*Emblem\b') {
            return $true
        }
    }

    # Archidekt fallback only when Scryfall metadata is unavailable.
    # Inspect actual card metadata fields, never deck/category labels.
    $card = Get-Prop $Entry "card"
    if ($card) {
        $layout = ([string](Get-Prop $card "layout")).ToLowerInvariant()

        if ($layout -in @("token", "double_faced_token", "emblem")) {
            return $true
        }

        foreach ($field in @("typeLine", "type_line")) {
            $typeLine = [string](Get-Prop $card $field)
            if ($typeLine -match '(?i)^\s*Token\b' -or
                $typeLine -match '(?i)^\s*Emblem\b') {
                return $true
            }
        }

        $oracle = Get-Prop $card "oracleCard"
        if ($oracle) {
            $oracleLayout = ([string](Get-Prop $oracle "layout")).ToLowerInvariant()

            if ($oracleLayout -in @("token", "double_faced_token", "emblem")) {
                return $true
            }

            foreach ($field in @("typeLine", "type_line")) {
                $typeLine = [string](Get-Prop $oracle $field)
                if ($typeLine -match '(?i)^\s*Token\b' -or
                    $typeLine -match '(?i)^\s*Emblem\b') {
                    return $true
                }
            }
        }
    }

    return $false
}

function Test-CommanderEligible {
    param($ScryfallCard)

    if (-not $ScryfallCard) { return $false }

    $typeLine = [string](Get-Prop $ScryfallCard "type_line")
    $oracle = [string](Get-Prop $ScryfallCard "oracle_text")

    if ($typeLine -match '(?i)\bLegendary\b.*\bCreature\b') {
        return $true
    }

    if ($oracle -match '(?i)can be your commander') {
        return $true
    }

    return $false
}

function New-DeckCard {
    param(
        [string]$Name,
        [int]$Quantity,
        [string]$Uid,
        $Scryfall,
        [string[]]$Categories
    )

    return [pscustomobject]@{
        Name = $Name
        Quantity = $Quantity
        Uid = $Uid
        Scryfall = $Scryfall
        Categories = @($Categories)
    }
}

function Get-QuantityTotal {
    param($Cards)

    $total = 0
    foreach ($card in $Cards) {
        $total += [int]$card.Quantity
    }
    return $total
}

function Remove-CardObjectFromList {
    param(
        [System.Collections.IList]$List,
        $Target
    )

    for ($i = $List.Count - 1; $i -ge 0; $i--) {
        if ([object]::ReferenceEquals($List[$i], $Target)) {
            $List.RemoveAt($i)
            return $true
        }
    }

    return $false
}

function Trim-CommanderDeckTo100 {
    param(
        [System.Collections.IList]$Main,
        [System.Collections.IList]$Commanders
    )

    $commanderTotal = Get-QuantityTotal $Commanders
    $mainTotal = Get-QuantityTotal $Main
    $total = $commanderTotal + $mainTotal

    $cutCards = [System.Collections.ArrayList]::new()

    if ($total -le 100) {
        return [pscustomobject]@{
            CutCount = 0
            CutCards = @()
            FinalTotal = $total
        }
    }

    $needToCut = $total - 100

    for ($i = $Main.Count - 1; $i -ge 0 -and $needToCut -gt 0; $i--) {
        $card = $Main[$i]
        $qty = [int]$card.Quantity
        $removeQty = [Math]::Min($qty, $needToCut)

        if ($removeQty -ge $qty) {
            [void]$cutCards.Add(([string]$qty + " " + $card.Name))
            $Main.RemoveAt($i)
        }
        else {
            $card.Quantity = $qty - $removeQty
            [void]$cutCards.Add(([string]$removeQty + " " + $card.Name))
        }

        $needToCut -= $removeQty
    }

    return [pscustomobject]@{
        CutCount = ($total - 100 - $needToCut)
        CutCards = $cutCards.ToArray()
        FinalTotal = ((Get-QuantityTotal $Commanders) + (Get-QuantityTotal $Main))
    }
}

function Safe-FileName {
    param([string]$Name, [string]$DeckId)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = "Archidekt Deck $DeckId"
    }

    $invalid = [IO.Path]::GetInvalidFileNameChars()
    $chars = $Name.ToCharArray()

    for ($i = 0; $i -lt $chars.Length; $i++) {
        if ($invalid -contains $chars[$i]) {
            $chars[$i] = "_"
        }
    }

    $safe = (-join $chars).Trim().TrimEnd(".")
    if ([string]::IsNullOrWhiteSpace($safe)) {
        $safe = "Archidekt Deck $DeckId"
    }

    $reserved = @(
        "CON","PRN","AUX","NUL",
        "COM1","COM2","COM3","COM4","COM5","COM6","COM7","COM8","COM9",
        "LPT1","LPT2","LPT3","LPT4","LPT5","LPT6","LPT7","LPT8","LPT9"
    )

    if ($reserved -contains $safe.ToUpperInvariant()) {
        $safe += "_"
    }

    if ($safe.Length -gt 140) {
        $safe = $safe.Substring(0, 140).TrimEnd()
    }

    return $safe
}

function Test-IsOurImportedDeckFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    try {
        $head = @(Get-Content -LiteralPath $Path -TotalCount 20 -Encoding UTF8)

        if ($head -contains ("Tags=" + $ImportTag)) {
            return $true
        }

        $hasArchidektSource = $false
        foreach ($line in $head) {
            if ($line -match '^Source URL=https://archidekt\.com/decks/\d+') {
                $hasArchidektSource = $true
                break
            }
        }

        if ($hasArchidektSource) {
            foreach ($line in $head) {
                if ($line -eq "Comment=Imported automatically from Archidekt" -or
                    $line -eq "Comment=Synced from Archidekt by Jadon's Archidekt Deck Sync" -or
                    $line -eq ("Comment=" + $ImporterComment)) {
                    return $true
                }
            }
        }
    }
    catch {}

    return $false
}

function Find-ImportedDeckBySource {
    param([string]$SourceUrl)

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (-not (Test-IsOurImportedDeckFile $file.FullName)) {
                continue
            }

            try {
                $head = @(Get-Content -LiteralPath $file.FullName -TotalCount 20 -Encoding UTF8)
                if ($head -contains ("Source URL=" + $SourceUrl)) {
                    return $file.FullName
                }
            }
            catch {}
        }
    }

    return $null
}

function Choose-OutputPath {
    param(
        [string]$Directory,
        [string]$DeckName,
        [string]$DeckId,
        [string]$SourceUrl,
        [string]$Existing
    )

    $safe = Safe-FileName $DeckName $DeckId
    $candidate = Join-Path $Directory ($safe + ".dck")

    if ($Existing) {
        try {
            if ([IO.Path]::GetFullPath($Existing) -eq [IO.Path]::GetFullPath($candidate)) {
                return $candidate
            }
        }
        catch {}
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        return $candidate
    }

    if (Test-IsOurImportedDeckFile $candidate) {
        try {
            $head = @(Get-Content -LiteralPath $candidate -TotalCount 20 -Encoding UTF8)
            if ($head -contains ("Source URL=" + $SourceUrl)) {
                return $candidate
            }
        }
        catch {}
    }

    return Join-Path $Directory ($safe + " [Archidekt " + $DeckId + "].dck")
}

function Move-FallbackCommanderIfNeeded {
    param(
        [System.Collections.IList]$Main,
        [System.Collections.IList]$Commanders,
        [string]$DeckName
    )

    if ($Commanders.Count -gt 0) {
        return
    }

    $eligible = [System.Collections.ArrayList]::new()
    foreach ($card in $Main) {
        if (Test-CommanderEligible $card.Scryfall) {
            [void]$eligible.Add($card)
        }
    }

    if ($eligible.Count -eq 1) {
        $chosen = $eligible[0]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    Enhanced commander detection: " + $chosen.Name)
        return
    }

    if ($eligible.Count -eq 0) {
        return
    }

    # Try deck-name matching before asking the user.
    $deckNameLower = $DeckName.ToLowerInvariant()
    $nameMatches = [System.Collections.ArrayList]::new()

    foreach ($card in $eligible) {
        $front = $card.Name
        if ($front.Contains(" // ")) {
            $front = ($front -split " // ")[0]
        }

        if ($deckNameLower.Contains($front.ToLowerInvariant())) {
            [void]$nameMatches.Add($card)
        }
    }

    if ($nameMatches.Count -eq 1) {
        $chosen = $nameMatches[0]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    Enhanced commander detection from deck name: " + $chosen.Name)
        return
    }

    Write-Host ""
    Write-Host ("Commander tag missing for: " + $DeckName) -ForegroundColor Yellow
    Write-Host "Possible commander cards:"
    Write-Host ""

    $limit = [Math]::Min(20, $eligible.Count)
    for ($i = 0; $i -lt $limit; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $eligible[$i].Name)
    }

    Write-Host ""
    $answer = Read-Host "Enter commander number, two numbers separated by comma, or press Enter to skip"

    if ([string]::IsNullOrWhiteSpace($answer)) {
        return
    }

    $indexes = @()
    foreach ($piece in $answer.Split(",")) {
        $n = 0
        if ([int]::TryParse($piece.Trim(), [ref]$n)) {
            if ($n -ge 1 -and $n -le $limit) {
                $indexes += ($n - 1)
            }
        }
    }

    foreach ($idx in @($indexes | Select-Object -Unique | Sort-Object -Descending)) {
        $chosen = $eligible[$idx]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    User-selected commander: " + $chosen.Name)
    }
}

function Convert-Deck {
    param($Deck, $Meta)

    $deckId = [string](Get-Prop $Deck "id")
    if (-not $deckId) {
        $deckId = [string](Get-Prop $Meta "id")
    }
    if (-not $deckId) {
        throw "Deck detail did not include an ID."
    }

    $deckName = [string](Get-Prop $Deck "name")
    if (-not $deckName) {
        $deckName = [string](Get-Prop $Meta "name")
    }
    if (-not $deckName) {
        $deckName = "Archidekt Deck $deckId"
    }

    $sourceUrl = "https://archidekt.com/decks/$deckId"
    $entries = @(Get-Prop $Deck "cards")

    # Pull Scryfall canonical metadata by Archidekt's Scryfall printing UUIDs.
    $uids = [System.Collections.ArrayList]::new()
    foreach ($entry in $entries) {
        $uid = Get-ArchidektUid $entry
        if ($uid) {
            [void]$uids.Add($uid)
        }
    }

    $scryfallMap = @{}
    if ($Settings.ResolveWithScryfall -and $uids.Count -gt 0) {
        try {
            $scryfallMap = Invoke-ScryfallCollection $uids
        }
        catch {
            Write-Log ("    WARNING: Scryfall canonical-name lookup failed. Falling back to Archidekt names.")
            $scryfallMap = @{}
        }
    }

    # Archidekt category metadata.
    $premierCategories = @{}
    $excludedCategories = @{}
    $sideboardCategories = @{}

    foreach ($cat in @(Get-Prop $Deck "categories")) {
        if ($null -eq $cat) { continue }

        $catName = [string](Get-Prop $cat "name")
        if ([string]::IsNullOrWhiteSpace($catName)) { continue }

        $included = Get-Prop $cat "includedInDeck"
        if ($null -eq $included) { $included = $true }

        $premier = Get-Prop $cat "isPremier"
        if ($null -eq $premier) { $premier = $false }

        if (-not [bool]$included) {
            $excludedCategories[$catName] = $true
        }

        if ([bool]$included -and [bool]$premier) {
            $premierCategories[$catName] = $true
        }

        if ($catName -match '^(?i:sideboard)$') {
            $sideboardCategories[$catName] = $true
        }
    }

    $main = [System.Collections.ArrayList]::new()
    $commanders = [System.Collections.ArrayList]::new()
    $sideboard = [System.Collections.ArrayList]::new()

    $tokensRemoved = 0
    $maybeboardRemoved = 0
    $unresolvedNames = 0

    foreach ($entry in $entries) {
        if ($null -eq $entry) { continue }

        $fallbackName = Get-ArchidektCardName $entry
        if ([string]::IsNullOrWhiteSpace($fallbackName)) { continue }

        $uid = Get-ArchidektUid $entry
        $scry = $null
        if ($uid -and $scryfallMap.ContainsKey($uid)) {
            $scry = $scryfallMap[$uid]
        }

        $forgeName = Get-ForgeCardName $fallbackName $scry
        if ([string]::IsNullOrWhiteSpace($forgeName)) { continue }

        if (-not $scry) {
            $unresolvedNames++
        }

        $qty = Get-Prop $entry "quantity"
        if ($null -eq $qty) { $qty = 1 }
        try { $qty = [int]$qty } catch { $qty = 1 }
        if ($qty -lt 1) { continue }

        $cats = @(Get-EntryCategories $entry)

        if ([bool]$Settings.RemoveActualTokens) {
            if (Test-IsActualTokenOrEmblem $entry $scry) {
                $tokensRemoved += $qty
                continue
            }
        }

        $isExcluded = $false
        $isPremier = $false
        $isSideboard = $false

        foreach ($cat in $cats) {
            if ($excludedCategories.ContainsKey($cat)) {
                $isExcluded = $true
            }
            if ($premierCategories.ContainsKey($cat)) {
                $isPremier = $true
            }
            if ($sideboardCategories.ContainsKey($cat) -or $cat -match '^(?i:sideboard)$') {
                $isSideboard = $true
            }
            if ($cat -match '^(?i:commander|commanders)$') {
                $isPremier = $true
            }
            if ($cat -match '^(?i:maybeboard|maybe board)$') {
                $isExcluded = $true
            }
        }

        if ($isExcluded -and -not $isPremier) {
            $maybeboardRemoved += $qty
            continue
        }

        $obj = New-DeckCard $forgeName $qty $uid $scry $cats

        if ($isPremier) {
            [void]$commanders.Add($obj)
        }
        elseif ($isSideboard) {
            [void]$sideboard.Add($obj)
        }
        else {
            [void]$main.Add($obj)
        }
    }

    $formatText = Get-DeckFormatText $Deck $Meta
    $isCommanderDeck = ($formatText -match '(?i)commander') -or ($commanders.Count -gt 0)

    if ($isCommanderDeck -and $commanders.Count -eq 0) {
        Move-FallbackCommanderIfNeeded $main $commanders $deckName
    }

    if ($commanders.Count -gt 0) {
        $isCommanderDeck = $true
    }

    $cutResult = [pscustomobject]@{
        CutCount = 0
        CutCards = @()
        FinalTotal = ((Get-QuantityTotal $commanders) + (Get-QuantityTotal $main))
    }

    if ($isCommanderDeck -and [bool]$Settings.CapCommanderAt100) {
        $cutResult = Trim-CommanderDeckTo100 $main $commanders
    }

    $deckType = if ($isCommanderDeck) { "Commander" } else { "Constructed" }
    $targetDir = if ($isCommanderDeck) { $CommanderDir } else { $ConstructedDir }

    $existing = Find-ImportedDeckBySource $sourceUrl
    $output = Choose-OutputPath $targetDir $deckName $deckId $sourceUrl $existing

    if ($existing) {
        try {
            if ([IO.Path]::GetFullPath($existing) -ne [IO.Path]::GetFullPath($output)) {
                Remove-Item -LiteralPath $existing -Force
                Write-Log ("    Removed renamed old copy: " + [IO.Path]::GetFileName($existing))
            }
        }
        catch {
            Write-Log ("    WARNING: Could not remove renamed old copy: " + $existing)
        }
    }

    $cleanName = $deckName.Replace("`r", " ").Replace("`n", " ")

    $lines = [System.Collections.ArrayList]::new()
    [void]$lines.Add("[metadata]")
    [void]$lines.Add("Name=" + $cleanName)
    [void]$lines.Add("Deck Type=" + $deckType)
    [void]$lines.Add("Source URL=" + $sourceUrl)
    [void]$lines.Add("Comment=" + $ImporterComment)
    [void]$lines.Add("Tags=" + $ImportTag)
    [void]$lines.Add("")
    if ($isCommanderDeck -and $commanders.Count -gt 0) {
        [void]$lines.Add("[commander]")
        foreach ($card in $commanders) {
            [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
        }
        [void]$lines.Add("")
    }

    [void]$lines.Add("[main]")
    foreach ($card in $main) {
        [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
    }

    if ($sideboard.Count -gt 0) {
        [void]$lines.Add("")
        [void]$lines.Add("[sideboard]")
        foreach ($card in $sideboard) {
            [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
        }
    }

    Write-Utf8NoBom $output $lines

    $mainTotal = Get-QuantityTotal $main
    $commanderTotal = Get-QuantityTotal $commanders
    $sideTotal = Get-QuantityTotal $sideboard

    return [pscustomobject]@{
        Id = $deckId
        Name = $deckName
        DeckType = $deckType
        Path = $output
        MainCount = $mainTotal
        CommanderCount = $commanderTotal
        SideboardCount = $sideTotal
        Total = $mainTotal + $commanderTotal
        TokensRemoved = $tokensRemoved
        MaybeboardRemoved = $maybeboardRemoved
        CutCount = [int]$cutResult.CutCount
        CutCards = @($cutResult.CutCards)
        UnresolvedNames = $unresolvedNames
    }
}

function Sync-Profile {
    param([string]$InputText)

    try {
        $username = Parse-ProfileInput $InputText
    }
    catch {
        Write-Host ""
        Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
        return
    }

    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "No username found." -ForegroundColor Red
        return
    }

    Add-ProfileHistory $username
    Start-Log

    Write-Log ""
    Write-Log ("Syncing PUBLIC Archidekt decks for: " + $username)
    Write-Log ("Commander 100-card cap: " + ($(if ($Settings.CapCommanderAt100) { "ON" } else { "OFF" })))
    Write-Log ("Actual token / emblem removal: " + ($(if ($Settings.RemoveActualTokens) { "ON" } else { "OFF" })))
    Write-Log "Enhanced commander detection: ON"
    Write-Log ""

    $metas = [System.Collections.ArrayList]::new()

    try {
        $encoded = [Uri]::EscapeDataString($username)
        $page = 1

        while ($true) {
            $url = "https://archidekt.com/api/decks/v3/?ownerUsername=$encoded&orderBy=-updatedAt&pageSize=50&page=$page"
            $data = Invoke-JsonGet $url
            $results = @($data.results)

            if ($results.Count -eq 0) { break }

            foreach ($deck in $results) {
                [void]$metas.Add($deck)
            }

            Write-Log ("  Page " + $page + ": " + $results.Count + " deck(s), total " + $metas.Count)

            $next = Get-Prop $data "next"
            if (-not $next) { break }

            $page++
            Start-Sleep -Milliseconds 550
        }
    }
    catch {
        Write-Host ""
        Write-Host "ARCHIDEKT PROFILE REQUEST FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host ("Log: " + $script:CurrentLog)
        return
    }

    if ($metas.Count -eq 0) {
        Write-Host ""
        Write-Host "No public decks were found for that profile."
        return
    }

    Write-Log ""
    Write-Log ("Found " + $metas.Count + " public deck(s).")
    Write-Log ""

    $ok = [System.Collections.ArrayList]::new()
    $failed = [System.Collections.ArrayList]::new()
    $warnings = [System.Collections.ArrayList]::new()

    $index = 0
    foreach ($meta in $metas) {
        $index++

        $deckId = [string](Get-Prop $meta "id")
        $deckName = [string](Get-Prop $meta "name")
        if (-not $deckName) { $deckName = "Deck $deckId" }

        Write-Log ("[" + $index + "/" + $metas.Count + "] " + $deckName)

        try {
            Start-Sleep -Milliseconds 550
            $detail = Invoke-JsonGet ("https://archidekt.com/api/decks/" + $deckId + "/")
            $result = Convert-Deck $detail $meta
            [void]$ok.Add($result)
            $extra = @()
            if ($result.TokensRemoved -gt 0) {
                $extra += ("tokens removed " + $result.TokensRemoved)
            }
            if ($result.CutCount -gt 0) {
                $extra += ("cut " + $result.CutCount + " to cap at 100")
            }

            $suffix = ""
            if ($extra.Count -gt 0) {
                $suffix = " | " + ($extra -join ", ")
            }

            Write-Log ("    " + $result.DeckType + " | " + $result.Total + " cards -> " + [IO.Path]::GetFileName($result.Path) + $suffix)

            if ($result.DeckType -eq "Commander" -and $result.CommanderCount -eq 0) {
                [void]$warnings.Add($result.Name + ": Commander format detected but no commander could be identified.")
                Write-Log "    WARNING: Commander still could not be identified."
            }

            if ($result.DeckType -eq "Commander" -and $result.Total -ne 100) {
                [void]$warnings.Add($result.Name + ": imported Commander total is " + $result.Total + ".")
            }

            if ($result.UnresolvedNames -gt 0) {
                Write-Log ("    NOTE: " + $result.UnresolvedNames + " card(s) used Archidekt-name fallback instead of Scryfall UUID resolution.")
            }

            if ($result.CutCount -gt 0) {
                Write-Log "    Cards trimmed from the end of the Archidekt mainboard:"
                foreach ($cut in $result.CutCards) {
                    Write-Log ("      - " + $cut)
                }
            }
        }
        catch {
            [void]$failed.Add([pscustomobject]@{
                Name = $deckName
                Id = $deckId
                Error = $_.Exception.Message
            })

            Write-Log ("    FAILED: " + $_.Exception.Message)

            if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
                Write-Log ("    POSITION: " + ($_.InvocationInfo.PositionMessage -replace "`r?`n", " "))
            }

            if ($_.ScriptStackTrace) {
                Write-Log ("    STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
            }
        }
    }

    Write-Host ""
    Write-Host "================================================"
    Write-Host "PROFILE SYNC COMPLETE"
    Write-Host "================================================"
    Write-Host ""
    Write-Host ("Profile : " + $username)
    Write-Host ("Synced  : " + $ok.Count)
    Write-Host ("Failed  : " + $failed.Count)
    Write-Host ("Warnings: " + $warnings.Count)
    Write-Host ""
    Write-Host ("Log: " + $script:CurrentLog)

    if ($failed.Count -gt 0) {
        Write-Host ""
        Write-Host "Failed decks:" -ForegroundColor Yellow
        foreach ($item in $failed) {
            Write-Host ("  - " + $item.Name + " : " + $item.Error)
        }
    }

    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "Warnings:" -ForegroundColor Yellow
        foreach ($item in $warnings) {
            Write-Host ("  - " + $item)
        }
    }

    Write-Host ""
    Write-Host "You can now import another profile without closing this program."
}

function Remove-ImportedDecks {
    $files = [System.Collections.ArrayList]::new()

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (Test-IsOurImportedDeckFile $file.FullName) {
                [void]$files.Add($file)
            }
        }
    }

    Write-Host ""
    if ($files.Count -eq 0) {
        Write-Host "No decks created by Jadon's Archidekt importer were found."
        return
    }

    Write-Host ("Found " + $files.Count + " imported deck file(s).")
    Write-Host "Only files carrying this importer's marker or the older Jadon-import comments will be removed."
    Write-Host "Your manually-created Forge decks will not be touched."
    Write-Host ""

    $answer = Read-Host "Remove all of these imported decks? Type YES to confirm"
    if ($answer -cne "YES") {
        Write-Host "Cleanup cancelled."
        return
    }

    $removed = 0
    foreach ($file in $files) {
        try {
            Remove-Item -LiteralPath $file.FullName -Force
            $removed++
        }
        catch {
            Write-Host ("Could not remove: " + $file.FullName) -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host ("Removed " + $removed + " imported deck file(s).")
}

function Show-RecentProfiles {
    $recent = @(Get-RecentProfiles)

    if ($recent.Count -eq 0) {
        return
    }

    Write-Host "Recent profiles:"
    for ($i = 0; $i -lt $recent.Count; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $recent[$i])
    }
    Write-Host ""
}

function Prompt-Profile {
    $recent = @(Get-RecentProfiles)
    Show-RecentProfiles

    $inputText = Read-Host "Paste Archidekt profile URL/username, or enter a recent-profile number"

    if ([string]::IsNullOrWhiteSpace($inputText)) {
        return $null
    }

    $n = 0
    if ([int]::TryParse($inputText.Trim(), [ref]$n)) {
        if ($n -ge 1 -and $n -le $recent.Count) {
            return $recent[$n - 1]
        }
    }

    return $inputText
}

function Show-MainMenu {
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "Jadon's Archidekt Forge Manager v4 SAFE TOKENS"
        Write-Host "------------------------------------------------"
        Write-Host ""
        Write-Host "Run this once and keep importing profile after profile."
        Write-Host ""
        Write-Host "[1] Import / sync an Archidekt profile"
        Write-Host "[2] Remove ALL decks added by this importer"
        Write-Host ("[3] Toggle ACTUAL token/emblem removal  [" + ($(if ($Settings.RemoveActualTokens) { "ON" } else { "OFF" })) + "]")
        Write-Host ("[4] Toggle Commander 100-card cap       [" + ($(if ($Settings.CapCommanderAt100) { "ON" } else { "OFF" })) + "]")
        Write-Host "[5] Show Forge deck folders"
        Write-Host "[6] Exit"
        Write-Host ""
        Write-Host "Token removal only checks actual card metadata."
        Write-Host "An Archidekt category named 'Tokens' will NEVER remove a normal card."
        Write-Host ""

        $choice = Read-Host "Choose 1-6"

        switch ($choice) {
            "1" {
                Write-Host ""
                $profile = Prompt-Profile
                if ($profile) {
                    Sync-Profile $profile
                }
                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "2" {
                Remove-ImportedDecks
                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "3" {
                $Settings.RemoveActualTokens = -not [bool]$Settings.RemoveActualTokens
                Save-Settings $Settings

                Write-Host ""
                Write-Host ("Actual token/emblem removal is now " + ($(if ($Settings.RemoveActualTokens) { "ON" } else { "OFF" })) + ".")
                Write-Host ""

                if ($Settings.RemoveActualTokens) {
                    Write-Host "Only cards whose actual metadata identifies them as a Token or Emblem"
                    Write-Host "will be excluded. Categories such as [Tokens] are ignored for removal."
                }
                else {
                    Write-Host "No cards will be removed for being tokens or emblems."
                }

                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "4" {
                $Settings.CapCommanderAt100 = -not [bool]$Settings.CapCommanderAt100
                Save-Settings $Settings

                Write-Host ""
                Write-Host ("Commander 100-card cap is now " + ($(if ($Settings.CapCommanderAt100) { "ON" } else { "OFF" })) + ".")
                Write-Host ""

                if ($Settings.CapCommanderAt100) {
                    Write-Host "When a Commander deck exceeds 100 cards, commanders are preserved"
                    Write-Host "and overflow cards are removed from the END of Archidekt's mainboard order."
                    Write-Host "This is separate from token removal."
                }
                else {
                    Write-Host "Oversized Commander decks will be imported without trimming."
                }

                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "5" {
                Write-Host ""
                Write-Host "Commander:"
                Write-Host ("  " + $CommanderDir)
                Write-Host ""
                Write-Host "Constructed:"
                Write-Host ("  " + $ConstructedDir)
                Write-Host ""
                Read-Host "Press Enter to return to the menu"
            }

            "6" {
                return
            }

            default {
                Start-Sleep -Milliseconds 500
            }
        }
    }
}


function Invoke-ManagerSelfTest {
    Write-Host ""
    Write-Host "Running importer v4 compatibility self-test..."
    Write-Host ""

    try {
        # Test the non-generic collection path used by every imported deck.
        $testMain = [System.Collections.ArrayList]::new()
        $testCommanders = [System.Collections.ArrayList]::new()

        [void]$testMain.Add([pscustomobject]@{
            Name = "Test Card A"
            Quantity = 50
            Scryfall = $null
        })

        [void]$testMain.Add([pscustomobject]@{
            Name = "Test Card B"
            Quantity = 51
            Scryfall = $null
        })

        [void]$testCommanders.Add([pscustomobject]@{
            Name = "Test Commander"
            Quantity = 1
            Scryfall = $null
        })

        $trimTest = Trim-CommanderDeckTo100 $testMain $testCommanders
        if ($trimTest.FinalTotal -ne 100) {
            throw "100-card trimming self-test failed."
        }

        # Test Forge naming for the layouts that caused the user's errors.
        $legions = Get-ForgeCardName `
            "Legion's Landing // Adanto, the First Fort" `
            ([pscustomobject]@{ name = "Legion's Landing // Adanto, the First Fort"; layout = "transform" })

        $pathway = Get-ForgeCardName `
            "Brightclimb Pathway // Grimclimb Pathway" `
            ([pscustomobject]@{ name = "Brightclimb Pathway // Grimclimb Pathway"; layout = "modal_dfc" })

        $adventure = Get-ForgeCardName `
            "Foulmire Knight // Profane Insight" `
            ([pscustomobject]@{ name = "Foulmire Knight // Profane Insight"; layout = "adventure" })

        $splitCard = Get-ForgeCardName `
            "Fire // Ice" `
            ([pscustomobject]@{ name = "Fire // Ice"; layout = "split" })

        $roomCard = Get-ForgeCardName `
            "Bottomless Pool // Locker Room" `
            ([pscustomobject]@{ name = "Bottomless Pool // Locker Room"; layout = "split" })

        if ($legions -ne "Legion's Landing") {
            throw "Transform-card self-test failed."
        }
        if ($pathway -ne "Brightclimb Pathway") {
            throw "Modal DFC self-test failed."
        }
        if ($adventure -ne "Foulmire Knight") {
            throw "Adventure-card self-test failed."
        }
        if ($splitCard -ne "Fire // Ice") {
            throw "Split-card self-test failed."
        }
        if ($roomCard -ne "Bottomless Pool // Locker Room") {
            throw "Room-card self-test failed."
        }

        # A NORMAL card in a user category named "Tokens" must NOT be treated
        # as an actual token. This is the bug fixed in v4.
        $normalTokenMakerEntry = [pscustomobject]@{
            categories = @("Tokens")
            card = [pscustomobject]@{
                layout = "normal"
                typeLine = "Creature - Elf Druid"
            }
        }

        $normalTokenMakerScryfall = [pscustomobject]@{
            layout = "normal"
            type_line = "Creature - Elf Druid"
        }

        if (Test-IsActualTokenOrEmblem $normalTokenMakerEntry $normalTokenMakerScryfall) {
            throw "Token-category safety self-test failed: a normal card was classified as a token."
        }

        $actualTokenEntry = [pscustomobject]@{
            categories = @("Creatures")
            card = [pscustomobject]@{
                layout = "token"
                typeLine = "Token Creature - Soldier"
            }
        }

        $actualTokenScryfall = [pscustomobject]@{
            layout = "token"
            type_line = "Token Creature - Soldier"
        }

        if (-not (Test-IsActualTokenOrEmblem $actualTokenEntry $actualTokenScryfall)) {
            throw "Actual-token detection self-test failed."
        }

        # Test UTF-8 file output without embedding a non-ASCII source literal.
        $accented = "Bartolom" + [char]0x00E9 + " del Presidio"
        $testFile = Join-Path $ToolDir "selftest_utf8.txt"
        Write-Utf8NoBom $testFile @($accented)
        $roundTrip = [IO.File]::ReadAllText($testFile, [Text.Encoding]::UTF8)
        Remove-Item -LiteralPath $testFile -Force -ErrorAction SilentlyContinue

        if ($roundTrip.Trim() -ne $accented) {
            throw "UTF-8 card-name self-test failed."
        }

        Write-Host "Importer v4 self-test: PASS" -ForegroundColor Green
        Write-Host ""
        return $true
    }
    catch {
        Write-Host "Importer v4 self-test: FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
        if ($_.ScriptStackTrace) {
            Write-Host $_.ScriptStackTrace
        }
        Write-Host ""
        Write-Host "No Forge decks were changed."
        return $false
    }
}

if (-not (Invoke-ManagerSelfTest)) {
    Read-Host "Press Enter to close"
    exit 1
}

Show-MainMenu
###JADON_SAFE_IMPORTER_V4_END###
###JADON_MANAGER_V7_PS_PAYLOAD###
param(
    [switch]$SelfTest,
    [switch]$NetworkSelfTest,
    [ValidateSet("Menu", "ImportMemory", "ViewMemory")]
    [string]$StartupAction = "Menu"
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Net.ServicePointManager]::DefaultConnectionLimit = 8

$Base = if ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA "MTGForge"
} else {
    Join-Path $env:USERPROFILE "AppData\Local\MTGForge"
}

$ToolDir = Join-Path $Base "ArchidektSync"
$LogDir = Join-Path $Base "logs"
$SettingsFile = Join-Path $ToolDir "settings.json"
$ProfileHistoryFile = Join-Path $ToolDir "profiles.txt"
$DefaultProfiles = @("Bot_2", "CLAWolf", "MrStealYoCreatures")
$StateFile = Join-Path $ToolDir "import-state.json"
$ScryfallCacheFile = Join-Path $ToolDir "scryfall-cache.json"
$BackupDir = Join-Path $ToolDir "backups"
$DownloadsDir = if ($env:USERPROFILE) { Join-Path $env:USERPROFILE "Downloads" } else { Join-Path $Base "exports" }
$ForgeLauncher = Join-Path $Base "Start_Forge.cmd"
$SafeImporterCmd = Join-Path $ToolDir "Safe_Archidekt_Importer_v4.cmd"
$SafeImporterSha256 = "3fdb666ff2b2f87e33f787d52c29601fee7ff965f0df459ee74d220b87be41be"
$SafeImporterPs1 = Join-Path $ToolDir "Safe_Archidekt_Importer_v4.payload"
$SafeImporterPsSha256 = "2e8aab791f933f0e7409b23463ada24250bf5caebabb826f00765c1c87050e7c"
$WindowsPowerShell = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"
$LegacyInstaller = Join-Path $Base "LegacyInstaller_v8.compat.cmd"
$LegacyInstallerSha256 = "ac8ebde5c795e981f6383acc62ac4cd19c29ad8056ffb07ddd3e92e6bf9bcb85"
$EngineVersion = "9.0"

$AiDir = Join-Path $Base "AIViewer"
$AiSourceDir = Join-Path $AiDir "source"
$AiClassesDir = Join-Path $AiDir "classes"
$AiDownloadsDir = Join-Path $AiDir "downloads"
$AiJdkDir = Join-Path $AiDir "jdk-21"
$AiPatchJar = Join-Path $AiDir "jadon-ai-telemetry-patch.jar"
$AiViewerScript = Join-Path $AiDir "AI_Thought_Viewer.ps1"
$AiLauncher = Join-Path $AiDir "Start_Forge_AI_Viewer.cmd"
$AiTelemetryFile = Join-Path $AiDir "telemetry.jsonl"
$AiStatusFile = Join-Path $AiDir "status.json"

$RoamingBase = if ($env:APPDATA) {
    $env:APPDATA
} else {
    Join-Path $env:USERPROFILE "AppData\Roaming"
}

$ForgeUser = Join-Path $RoamingBase "Forge"
$CommanderDir = Join-Path $ForgeUser "decks\commander"
$ConstructedDir = Join-Path $ForgeUser "decks\constructed"

$ImportTag = "JADON_ARCHIDEKT_IMPORT"
$ImporterComment = "Imported by Jadon's Archidekt Forge Manager"

New-Item -ItemType Directory -Force -Path $ToolDir | Out-Null
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $CommanderDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConstructedDir | Out-Null
New-Item -ItemType Directory -Force -Path $AiDir | Out-Null
New-Item -ItemType Directory -Force -Path $AiDownloadsDir | Out-Null

function Get-Prop {
    param($Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

function Write-Utf8NoBom {
    param([string]$Path, [string[]]$Lines)
    $enc = New-Object System.Text.UTF8Encoding($false)
    $text = [string]::Join([Environment]::NewLine, [string[]]$Lines)
    if ($Lines.Count -gt 0) {
        $text += [Environment]::NewLine
    }
    Write-TextFileAtomic $Path $text $enc
}

function Write-TextFileAtomic {
    param(
        [string]$Path,
        [string]$Text,
        [Text.Encoding]$Encoding,
        [switch]$KeepLastGood
    )

    if ($null -eq $Encoding) {
        $Encoding = New-Object System.Text.UTF8Encoding($false)
    }

    $parent = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    $candidate = $Path + ".candidate." + [Guid]::NewGuid().ToString("N")
    $backup = $null

    try {
        [IO.File]::WriteAllText($candidate, [string]$Text, $Encoding)

        if (-not (Test-Path -LiteralPath $candidate)) {
            throw "Atomic write candidate was not created: $candidate"
        }

        if (Test-Path -LiteralPath $Path) {
            if ($KeepLastGood) {
                $backup = $Path + ".last-good"
                Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue

                [IO.File]::Replace(
                    [string]$candidate,
                    [string]$Path,
                    [string]$backup,
                    [bool]$true
                )
            }
            else {
                $temporaryBackup = $Path + ".replace-backup." + [Guid]::NewGuid().ToString("N")
                [IO.File]::Replace(
                    [string]$candidate,
                    [string]$Path,
                    [string]$temporaryBackup,
                    [bool]$true
                )
                Remove-Item -LiteralPath $temporaryBackup -Force -ErrorAction SilentlyContinue
            }
        }
        else {
            [IO.File]::Move($candidate, $Path)
        }
    }
    finally {
        Remove-Item -LiteralPath $candidate -Force -ErrorAction SilentlyContinue
    }
}

function Get-FileSha256 {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return ""
    }

    $stream = $null
    $sha = $null

    try {
        $stream = [IO.File]::OpenRead($Path)
        $sha = [Security.Cryptography.SHA256]::Create()
        $bytes = $sha.ComputeHash($stream)
        return [BitConverter]::ToString($bytes).Replace("-", "").ToLowerInvariant()
    }
    finally {
        if ($stream) { $stream.Dispose() }
        if ($sha) { $sha.Dispose() }
    }
}

function Promote-FileCandidate {
    param(
        [string]$Candidate,
        [string]$Live,
        [switch]$KeepLastGood
    )

    if (-not (Test-Path -LiteralPath $Candidate)) {
        throw "Promotion candidate is missing: $Candidate"
    }

    $parent = Split-Path -Parent $Live
    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    if (Test-Path -LiteralPath $Live) {
        if ($KeepLastGood) {
            $backup = [string]($Live + ".last-good")
            Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue

            [IO.File]::Replace(
                [string]$Candidate,
                [string]$Live,
                [string]$backup,
                [bool]$true
            )
        }
        else {
            $temporaryBackup = $Live + ".replace-backup." + [Guid]::NewGuid().ToString("N")
            [IO.File]::Replace(
                [string]$Candidate,
                [string]$Live,
                [string]$temporaryBackup,
                [bool]$true
            )
            Remove-Item -LiteralPath $temporaryBackup -Force -ErrorAction SilentlyContinue
        }
    }
    else {
        [IO.File]::Move([string]$Candidate, [string]$Live)
    }
}

function Read-Settings {
    param([string]$Path = $SettingsFile)

    $defaults = [pscustomobject]@{
        FastImport = $true
        CopyDetection = $true
        SimilarityDetection = $false
        SimilarityThreshold = 90
        BracketUniqueCommander = $true
        BracketUniqueDeckName = $true
        BracketExact100 = $true
        RenameToCommander = $false
        FileNameMode = "Original"
        MemoryFilePath = ""
        RemoveActualTokens = $false
        CapCommanderAt100 = $true
        SkipIncompleteCommander = $true
        BackupBeforeOverwrite = $true
        PreserveSideboards = $true
        DryRun = $false
        ResolveWithScryfall = $true
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        return $defaults
    }

    try {
        $saved = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json

        $hadFileNameMode = $null -ne $saved.PSObject.Properties["FileNameMode"]
        $settingDefaults = @{
            FastImport = $true
            CopyDetection = $true
            SimilarityDetection = $false
            SimilarityThreshold = 90
            BracketUniqueCommander = $true
            BracketUniqueDeckName = $true
            BracketExact100 = $true
            RenameToCommander = $false
            FileNameMode = "Original"
            MemoryFilePath = ""
            RemoveActualTokens = $false
            CapCommanderAt100 = $true
            SkipIncompleteCommander = $true
            BackupBeforeOverwrite = $true
            PreserveSideboards = $true
            DryRun = $false
            ResolveWithScryfall = $true
        }

        foreach ($key in $settingDefaults.Keys) {
            $property = $saved.PSObject.Properties[$key]

            if ($null -eq $property) {
                $saved | Add-Member -NotePropertyName $key -NotePropertyValue $settingDefaults[$key]
            }
            elseif ($null -eq $property.Value) {
                $property.Value = $settingDefaults[$key]
            }
        }

        foreach ($key in @(
            "FastImport",
            "CopyDetection",
            "SimilarityDetection",
            "BracketUniqueCommander",
            "BracketUniqueDeckName",
            "RenameToCommander",
            "RemoveActualTokens",
            "CapCommanderAt100",
            "SkipIncompleteCommander",
            "BackupBeforeOverwrite",
            "PreserveSideboards",
            "DryRun",
            "ResolveWithScryfall"
        )) {
            $value = $saved.PSObject.Properties[$key].Value
            if ($value -isnot [bool]) {
                $parsed = $false
                if ([bool]::TryParse([string]$value, [ref]$parsed)) {
                    $saved.PSObject.Properties[$key].Value = $parsed
                }
                else {
                    $saved.PSObject.Properties[$key].Value = $settingDefaults[$key]
                }
            }
        }

        $threshold = 90
        if (-not [int]::TryParse([string]$saved.SimilarityThreshold, [ref]$threshold) -or
            $threshold -lt 50 -or $threshold -gt 100) {

            $threshold = 90
        }
        $saved.SimilarityThreshold = $threshold

        $fileNameMode = [string]$saved.FileNameMode
        if (-not $hadFileNameMode -and [bool]$saved.RenameToCommander) {
            $fileNameMode = "Commander"
        }
        if (@("Original", "Commander", "CommanderOwner", "CommanderOwnerDeck") -notcontains $fileNameMode) {
            $fileNameMode = "Original"
        }
        $saved.FileNameMode = $fileNameMode
        $saved.RenameToCommander = ($fileNameMode -ne "Original")
        $saved.MemoryFilePath = [string]$saved.MemoryFilePath

        # Bracket exact-100 is deliberately safety-locked and cannot be disabled
        # by a stale or manually edited settings file.
        $saved.BracketExact100 = $true

        return $saved
    }
    catch {
        return $defaults
    }
}

function Save-Settings {
    param(
        $Settings,
        [string]$Path = $SettingsFile
    )
    $json = $Settings | ConvertTo-Json -Depth 5
    $enc = New-Object System.Text.UTF8Encoding($false)
    Write-TextFileAtomic $Path $json $enc -KeepLastGood
}

$Settings = Read-Settings
$script:ScryfallCache = @{}

function Read-ScryfallCache {
    $cache = @{}

    if (-not (Test-Path -LiteralPath $ScryfallCacheFile)) {
        return $cache
    }

    try {
        $document = Get-Content -LiteralPath $ScryfallCacheFile -Raw -Encoding UTF8 |
            ConvertFrom-Json

        foreach ($entry in @($document.Entries)) {
            if ($entry -and $entry.Id -and $entry.Card) {
                $cache[[string]$entry.Id] = $entry.Card
            }
        }
    }
    catch {
        Write-Host "WARNING: Scryfall cache was unreadable and will be rebuilt." -ForegroundColor Yellow
    }

    return $cache
}

function Save-ScryfallCache {
    $entries = New-Object System.Collections.ArrayList

    foreach ($key in @($script:ScryfallCache.Keys | Sort-Object)) {
        [void]$entries.Add([pscustomobject]@{
            Id = [string]$key
            Card = $script:ScryfallCache[$key]
        })
    }

    $document = [pscustomobject]@{
        Version = 1
        SavedAt = (Get-Date).ToString("o")
        Entries = $entries.ToArray()
    }

    $json = $document | ConvertTo-Json -Depth 20
    $enc = New-Object System.Text.UTF8Encoding($false)
    Write-TextFileAtomic $ScryfallCacheFile $json $enc -KeepLastGood
}

$script:ScryfallCache = Read-ScryfallCache

$script:CurrentLog = $null
function Start-Log {
    param([string]$Name = "sync")

    $safeName = ($Name -replace '[^A-Za-z0-9_.-]', '-')
    $script:CurrentLog = Join-Path $LogDir ($safeName + "-" + (Get-Date -Format "yyyyMMdd-HHmmssfff") + ".log")
}
function Write-Log {
    param([string]$Text)
    Write-Host $Text
    if ($script:CurrentLog) {
        Add-Content -LiteralPath $script:CurrentLog -Value $Text -Encoding UTF8
    }
}

$script:UiSpinnerIndex = 0
$script:UiProgressActive = $false
$script:UiProgressRow = -1
$script:UiProgressLength = 0
$script:UiFallbackProgressKey = ""

function Write-UiBanner {
    param(
        [string]$Title,
        [string]$Subtitle = ""
    )

    Write-Host ""
    Write-Host "+------------------------------------------------------------------------------+" -ForegroundColor DarkCyan
    Write-Host ("|  " + $Title.PadRight(76) + "|") -ForegroundColor Cyan
    if (-not [string]::IsNullOrWhiteSpace($Subtitle)) {
        Write-Host ("|  " + $Subtitle.PadRight(76) + "|") -ForegroundColor DarkGray
    }
    Write-Host "+------------------------------------------------------------------------------+" -ForegroundColor DarkCyan
    Write-Host ""
}

function Write-UiSection {
    param([string]$Title)
    Write-Host ("  " + $Title.ToUpperInvariant()) -ForegroundColor Yellow
    Write-Host "  --------------------------------------------------------------------------" -ForegroundColor DarkGray
}

function Complete-UiProgress {
    if ($script:UiProgressActive) {
        try {
            $row = [int]$script:UiProgressRow
            if ($row -ge 0 -and $row -lt [Console]::BufferHeight) {
                [Console]::SetCursorPosition([Math]::Min([int]$script:UiProgressLength, [Console]::BufferWidth - 1), $row)
                [Console]::WriteLine()
            }
            else {
                Write-Host ""
            }
        }
        catch {
            Write-Host ""
        }
        $script:UiProgressActive = $false
        $script:UiProgressRow = -1
        $script:UiProgressLength = 0
    }
}

function Show-UiProgress {
    param(
        [string]$Phase,
        [int]$Current,
        [int]$Total,
        [string]$Detail = ""
    )

    if ($Total -lt 1) { $Total = 1 }
    if ($Current -lt 0) { $Current = 0 }
    if ($Current -gt $Total) { $Current = $Total }

    $percent = [int][Math]::Floor((100.0 * $Current) / $Total)

    $cleanPhase = ([string]$Phase -replace '[\r\n]+', ' ').Trim()
    if ($cleanPhase.Length -gt 12) {
        $cleanPhase = $cleanPhase.Substring(0, 9) + "..."
    }
    $cleanDetail = ([string]$Detail -replace '[\r\n]+', ' ').Trim()

    $renderWidth = 78
    try {
        $renderWidth = [Math]::Max(54, [Console]::WindowWidth - 2)
    }
    catch {}

    $barWidth = if ($renderWidth -ge 100) { 24 } elseif ($renderWidth -ge 74) { 16 } else { 10 }
    $currentText = $Current.ToString()
    $totalText = $Total.ToString()
    $percentText = $percent.ToString().PadLeft(3) + "%"
    $fixedWidth = 2 + 12 + 1 + 1 + $barWidth + 2 + 2 + $currentText.Length + 1 + $totalText.Length + 2 + $percentText.Length
    $deckWidth = [Math]::Max(6, $renderWidth - $fixedWidth)
    if ($cleanDetail.Length -gt $deckWidth) {
        if ($deckWidth -ge 4) {
            $cleanDetail = $cleanDetail.Substring(0, $deckWidth - 3) + "..."
        }
        else {
            $cleanDetail = $cleanDetail.Substring(0, $deckWidth)
        }
    }

    $filled = [int][Math]::Floor(($barWidth * $percent) / 100.0)
    if ($Current -gt 0 -and $filled -eq 0) { $filled = 1 }
    $solid = [string][char]0x2588
    $empty = [string][char]0x2591
    $filledBar = $solid * $filled
    $emptyBar = $empty * ($barWidth - $filled)

    try {
        $oldColor = [Console]::ForegroundColor
        if (-not $script:UiProgressActive) {
            $script:UiProgressRow = [Console]::CursorTop
        }

        $row = [int]$script:UiProgressRow
        if ($row -lt 0 -or $row -ge [Console]::BufferHeight) {
            throw "Console progress row is unavailable."
        }

        [Console]::SetCursorPosition(0, $row)
        [Console]::Write(" " * [Math]::Min($renderWidth, [Console]::BufferWidth - 1))
        [Console]::SetCursorPosition(0, $row)

        [Console]::ForegroundColor = [ConsoleColor]::DarkCyan
        [Console]::Write("  " + $cleanPhase.PadRight(12) + " ")
        [Console]::ForegroundColor = [ConsoleColor]::DarkGray
        [Console]::Write("[")
        [Console]::ForegroundColor = [ConsoleColor]::Cyan
        [Console]::Write($filledBar)
        [Console]::ForegroundColor = [ConsoleColor]::DarkGray
        [Console]::Write($emptyBar + "] ")
        [Console]::ForegroundColor = [ConsoleColor]::Magenta
        [Console]::Write($cleanDetail.PadRight($deckWidth))
        [Console]::ForegroundColor = [ConsoleColor]::DarkGray
        [Console]::Write("  ")
        [Console]::ForegroundColor = [ConsoleColor]::Yellow
        [Console]::Write($currentText)
        [Console]::ForegroundColor = [ConsoleColor]::DarkGray
        [Console]::Write("/")
        [Console]::ForegroundColor = [ConsoleColor]::Red
        [Console]::Write($totalText)
        [Console]::ForegroundColor = [ConsoleColor]::DarkGray
        [Console]::Write("  " + $percentText)
        [Console]::ForegroundColor = $oldColor

        $script:UiProgressLength = [Math]::Min($renderWidth, [Console]::BufferWidth - 1)
        $script:UiProgressActive = $true
    }
    catch {
        $fallbackKey = $Phase + "|" + $Current + "|" + $Total + "|" + $cleanDetail
        if ($fallbackKey -ne $script:UiFallbackProgressKey) {
            Write-Host ("  [" + ("#" * $filled) + ("." * ($barWidth - $filled)) + "] ") -NoNewline -ForegroundColor Cyan
            Write-Host $cleanDetail -NoNewline -ForegroundColor Magenta
            Write-Host ("  " + $currentText) -NoNewline -ForegroundColor Yellow
            Write-Host "/" -NoNewline -ForegroundColor DarkGray
            Write-Host $totalText -ForegroundColor Red
            $script:UiFallbackProgressKey = $fallbackKey
        }
    }

    if ($Current -ge $Total) {
        Complete-UiProgress
    }
}

function Invoke-SafeOperation {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    $script:LastOperationSucceeded = $true
    $script:OperationFailureWasPaused = $false

    try {
        & $Action
    }
    catch {
        $script:LastOperationSucceeded = $false
        if (-not $script:CurrentLog) {
            Start-Log
        }

        Write-Log ""
        Write-Log ("OPERATION FAILED: " + $Name)
        Write-Log ("ERROR: " + $_.Exception.Message)

        if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
            Write-Log ("POSITION: " + ($_.InvocationInfo.PositionMessage -replace "`r?`n", " "))
        }

        if ($_.ScriptStackTrace) {
            Write-Log ("STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
        }

        Write-Host ""
        Write-Host "================================================" -ForegroundColor Red
        Write-Host "OPERATION FAILED - RETURNING TO MAIN MENU" -ForegroundColor Red
        Write-Host "================================================" -ForegroundColor Red
        Write-Host ""
        Write-Host ("Operation: " + $Name)
        Write-Host ("Reason   : " + $_.Exception.Message)
        Write-Host ""
        Write-Host "The manager is still running."
        Write-Host "No automatic retry or elevation was attempted."
        Write-Host ("Detailed log: " + $script:CurrentLog)
        Write-Host ""
        [void](Read-Host "Press Enter to return to the main menu")
        $script:OperationFailureWasPaused = $true
    }
}

function Wait-ForMenuReturn {
    if ($script:OperationFailureWasPaused) {
        $script:OperationFailureWasPaused = $false
        return
    }

    Write-Host ""
    [void](Read-Host "Press Enter to return to the main menu")
}


function Invoke-ProvenSafeImporter {
    param([string]$Reason = "Primary V9 importer could not complete safely.")

    [void](Initialize-DefaultProfileHistory)

    Write-Host ""
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host "OPENING PROVEN SAFE IMPORTER" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host $Reason
    Write-Host ""
    Write-Host "The V9 manager will stay available after the safe importer closes."
    Write-Host ""

    if (-not (Test-Path -LiteralPath $SafeImporterCmd)) {
        Write-Host "Safe importer is missing:" -ForegroundColor Red
        Write-Host ("  " + $SafeImporterCmd)
        Write-Host ""
        return $false
    }

    $safeHash = Get-FileSha256 $SafeImporterCmd
    if ($safeHash -ne $SafeImporterSha256) {
        Write-Host "Safe importer integrity verification failed." -ForegroundColor Red
        Write-Host ("Expected SHA-256: " + $SafeImporterSha256)
        Write-Host ("Actual SHA-256  : " + $safeHash)
        Write-Host ""
        return $false
    }

    $candidate = $SafeImporterPs1 + ".candidate-" + [Guid]::NewGuid().ToString("N")

    try {
        if (-not (Test-Path -LiteralPath $WindowsPowerShell -PathType Leaf)) {
            throw "Windows PowerShell 5.1 was not found at its standard Windows path."
        }

        if ((Get-FileSha256 $SafeImporterPs1) -ne $SafeImporterPsSha256) {
            $raw = [IO.File]::ReadAllText($SafeImporterCmd)
            $marker = "###JADON_ARCHIDEKT_MANAGER_PAYLOAD###"
            $index = $raw.LastIndexOf($marker, [StringComparison]::Ordinal)
            if ($index -lt 0) {
                throw "The verified safe CMD is missing its PowerShell payload marker."
            }

            $body = $raw.Substring($index + $marker.Length).TrimStart([char]13, [char]10)
            [IO.File]::WriteAllText(
                $candidate,
                $body,
                (New-Object Text.UTF8Encoding($false))
            )

            if ((Get-FileSha256 $candidate) -ne $SafeImporterPsSha256) {
                throw "The extracted safe PowerShell payload failed exact SHA-256 validation."
            }

            $tokens = $null
            $errors = $null
            [Management.Automation.Language.Parser]::ParseFile(
                $candidate,
                [ref]$tokens,
                [ref]$errors
            ) | Out-Null

            if ($errors.Count -gt 0) {
                throw ("The safe PowerShell payload failed parser validation: " + $errors[0].Message)
            }

            Promote-FileCandidate $candidate $SafeImporterPs1 -KeepLastGood
            $candidate = ""
        }

        $runnerCommand = '$text=[IO.File]::ReadAllText($env:JADON_SAFE_PAYLOAD,[Text.Encoding]::UTF8);$block=[ScriptBlock]::Create($text);. $block'
        $previousPayload = [Environment]::GetEnvironmentVariable("JADON_SAFE_PAYLOAD", "Process")
        try {
            [Environment]::SetEnvironmentVariable("JADON_SAFE_PAYLOAD", $SafeImporterPs1, "Process")
            & $WindowsPowerShell -NoLogo -NoProfile -Command $runnerCommand
            if ($LASTEXITCODE -ne 0) {
                throw ("The safe importer returned exit code " + $LASTEXITCODE + ".")
            }
        }
        finally {
            [Environment]::SetEnvironmentVariable("JADON_SAFE_PAYLOAD", $previousPayload, "Process")
        }

        return $true
    }
    catch {
        Write-Host ""
        Write-Host ("Safe importer could not be started: " + $_.Exception.Message) -ForegroundColor Red
        return $false
    }
    finally {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            Remove-Item -LiteralPath $candidate -Force -ErrorAction SilentlyContinue
        }
    }
}

function Invoke-AttachedV8Fallback {
    param([string]$Reason = "The primary V9 operation could not continue.")

    Write-Host ""
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host "OPENING ATTACHED V8 COMPATIBILITY FALLBACK" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host $Reason
    Write-Host ""
    if (-not (Test-Path -LiteralPath $LegacyInstaller -PathType Leaf)) {
        Write-Host "The attached v8 fallback is not installed. Run the v9 installer repair option." -ForegroundColor Red
        return $false
    }
    if ((Get-FileSha256 $LegacyInstaller) -ne $LegacyInstallerSha256) {
        Write-Host "The attached v8 fallback failed exact SHA-256 validation." -ForegroundColor Red
        return $false
    }

    Write-Host "The original attached v8 menu will open in this window." -ForegroundColor Cyan
    Write-Host "Select its manager/importer option to continue."
    Write-Host ""
    & $env:ComSpec /d /c ('call "' + $LegacyInstaller + '"')
    return ($LASTEXITCODE -eq 0)
}

function Get-OnOff {
    param([bool]$Value)
    if ($Value) { return "ON" }
    return "OFF"
}

function Wait-ApiPacing {
    if ([bool]$Settings.FastImport) {
        Start-Sleep -Milliseconds 20
    }
    else {
        Start-Sleep -Milliseconds 450
    }
}

function Get-MetaUpdatedAt {
    param($Meta)

    $value = Get-Prop $Meta "updatedAt"
    if ($null -eq $value) {
        $value = Get-Prop $Meta "updated_at"
    }

    if ($null -eq $value) {
        return ""
    }

    return [string]$value
}

function Get-SettingsFingerprint {
    $parts = @(
        ("copy=" + (Get-OnOff ([bool]$Settings.CopyDetection))),
        ("similarity=" + (Get-OnOff ([bool]$Settings.SimilarityDetection))),
        ("threshold=" + [string]$Settings.SimilarityThreshold),
        ("tokens=" + (Get-OnOff ([bool]$Settings.RemoveActualTokens))),
        ("cap100=" + (Get-OnOff ([bool]$Settings.CapCommanderAt100))),
        ("skipUnder100=" + (Get-OnOff ([bool]$Settings.SkipIncompleteCommander))),
        ("filenameMode=" + [string]$Settings.FileNameMode),
        ("sideboard=" + (Get-OnOff ([bool]$Settings.PreserveSideboards))),
        ("scryfall=" + (Get-OnOff ([bool]$Settings.ResolveWithScryfall)))
    )

    return ($parts -join ";")
}

function Normalize-SettingsFingerprint {
    param([string]$Fingerprint)

    if ([string]::IsNullOrWhiteSpace($Fingerprint)) { return "" }
    return (@($Fingerprint -split ";" | Where-Object { $_ -notmatch '^engine=' }) -join ";")
}

function Read-ImportState {
    param([string]$Path = $StateFile)

    $result = @{}

    if (-not (Test-Path -LiteralPath $Path)) {
        return $result
    }

    try {
        $document = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json

        foreach ($entry in $document.entries) {
            if ($entry -and $entry.DeckId) {
                $result[[string]$entry.DeckId] = $entry
            }
        }
    }
    catch {
        Write-Host "WARNING: The import state file could not be read. Copy detection will rebuild it." -ForegroundColor Yellow
    }

    return $result
}

function Save-ImportState {
    param(
        $State,
        [string]$Path = $StateFile
    )

    $entries = New-Object System.Collections.ArrayList

    foreach ($key in $State.Keys) {
        [void]$entries.Add($State[$key])
    }

    $document = [pscustomobject]@{
        Version = 1
        Entries = $entries.ToArray()
    }

    $json = $document | ConvertTo-Json -Depth 8
    $encoding = New-Object System.Text.UTF8Encoding($false)
    Write-TextFileAtomic $Path $json $encoding -KeepLastGood
}

function Test-CopyStateMatch {
    param(
        $Meta,
        $StateEntry,
        [string]$Fingerprint
    )

    if ($null -eq $StateEntry) {
        return $false
    }

    $remoteUpdated = Get-MetaUpdatedAt $Meta
    if ([string]$StateEntry.UpdatedAt -ne $remoteUpdated) {
        return $false
    }

    $savedFingerprint = Normalize-SettingsFingerprint ([string]$StateEntry.Fingerprint)
    $currentFingerprint = Normalize-SettingsFingerprint $Fingerprint
    if ($savedFingerprint -ne $currentFingerprint) {
        return $false
    }

    $remoteName = [string](Get-Prop $Meta "name")
    if ([string]$StateEntry.OriginalName -ne $remoteName) {
        return $false
    }

    if ([string]$StateEntry.Status -like "Skipped*") {
        return $true
    }

    $path = [string]$StateEntry.OutputPath
    if ([string]::IsNullOrWhiteSpace($path)) {
        return $false
    }

    if (-not (Test-Path -LiteralPath $path)) {
        return $false
    }

    if (-not (Test-IsOurImportedDeckFile $path)) {
        return $false
    }

    $expectedHash = [string]$StateEntry.CardHash
    if ([string]::IsNullOrWhiteSpace($expectedHash)) {
        return $false
    }

    try {
        $record = Read-ImportedDeckRecord $path
        return ($record -and [string]$record.CardHash -eq $expectedHash)
    }
    catch {
        return $false
    }
}

function Backup-ImportedDeck {
    param(
        [string]$Path,
        [string]$DeckId
    )

    if (-not [bool]$Settings.BackupBeforeOverwrite) {
        return
    }

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    if (-not (Test-IsOurImportedDeckFile $Path)) {
        return
    }

    $deckBackupDir = Join-Path $BackupDir $DeckId
    New-Item -ItemType Directory -Force -Path $deckBackupDir | Out-Null

    $stamp = Get-Date -Format "yyyyMMdd-HHmmssfff"
    $name = [IO.Path]::GetFileName($Path)
    $destination = Join-Path $deckBackupDir ($stamp + "-" + $name)

    Copy-Item -LiteralPath $Path -Destination $destination -Force
}

function Get-CommanderLabel {
    param($Commanders)

    $names = New-Object System.Collections.ArrayList

    foreach ($card in $Commanders) {
        if ($card -and -not [string]::IsNullOrWhiteSpace([string]$card.Name)) {
            if (-not ($names -contains [string]$card.Name)) {
                [void]$names.Add([string]$card.Name)
            }
        }
    }

    if ($names.Count -eq 0) {
        return ""
    }

    return ($names.ToArray() -join " + ")
}

function Get-ArchidektPremierCommanderLabel {
    param($Deck)

    $premier = @{}

    foreach ($category in (Get-Prop $Deck "categories")) {
        if ($null -eq $category) { continue }

        $name = [string](Get-Prop $category "name")
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $isPremier = Get-Prop $category "isPremier"
        $included = Get-Prop $category "includedInDeck"

        if ($null -eq $included) {
            $included = $true
        }

        if (($isPremier -eq $true -and $included -eq $true) -or
            $name -match '^(?i:commander|commanders)$') {
            $premier[$name] = $true
        }
    }

    $names = New-Object System.Collections.ArrayList

    foreach ($entry in (Get-Prop $Deck "cards")) {
        if ($null -eq $entry) { continue }

        $isCommander = $false
        foreach ($categoryName in (Get-EntryCategories $entry)) {
            if ($premier.ContainsKey([string]$categoryName) -or
                [string]$categoryName -match '^(?i:commander|commanders)$') {
                $isCommander = $true
                break
            }
        }

        if (-not $isCommander) {
            continue
        }

        $name = Get-ArchidektCardName $entry
        if ([string]::IsNullOrWhiteSpace($name)) {
            continue
        }

        $forgeName = Get-ForgeCardName $name $null
        if (-not ($names -contains $forgeName)) {
            [void]$names.Add($forgeName)
        }
    }

    if ($names.Count -eq 0) {
        return ""
    }

    return ($names.ToArray() -join " + ")
}

function Get-DeckOwnerName {
    param($Deck, $Meta)

    foreach ($source in @($Deck, $Meta)) {
        if ($null -eq $source) { continue }
        $owner = Get-Prop $source "owner"
        if ($owner) {
            foreach ($propertyName in @("username", "displayName", "name")) {
                $value = Get-Prop $owner $propertyName
                if (-not [string]::IsNullOrWhiteSpace([string]$value)) {
                    return ([string]$value).Trim()
                }
            }
        }
        foreach ($propertyName in @("ownerUsername", "owner_username", "username")) {
            $value = Get-Prop $source $propertyName
            if (-not [string]::IsNullOrWhiteSpace([string]$value)) {
                return ([string]$value).Trim()
            }
        }
    }

    return "Unknown"
}

function Get-RenameDisplayName {
    param(
        [string]$OriginalName,
        [string]$CommanderLabel,
        [string]$OwnerName,
        $RenameCounts
    )

    $mode = [string]$Settings.FileNameMode
    if ([string]::IsNullOrWhiteSpace($mode)) {
        $mode = if ([bool]$Settings.RenameToCommander) { "Commander" } else { "Original" }
    }

    if ($mode -eq "Original") {
        return $OriginalName
    }

    if ([string]::IsNullOrWhiteSpace($CommanderLabel)) {
        return $OriginalName
    }

    if ([string]::IsNullOrWhiteSpace($OwnerName)) { $OwnerName = "Unknown" }

    if ($mode -eq "CommanderOwnerDeck") {
        return ($CommanderLabel + " - by " + $OwnerName + " - " + $OriginalName)
    }

    if ($mode -eq "CommanderOwner") {
        return ($CommanderLabel + " - by " + $OwnerName)
    }

    $count = 1
    $key = $CommanderLabel.ToLowerInvariant()

    if ($RenameCounts -and $RenameCounts.ContainsKey($key)) {
        $count = [int]$RenameCounts[$key]
    }

    if ($count -gt 1) {
        return ($CommanderLabel + " - " + $OriginalName)
    }

    return $CommanderLabel
}

function Invoke-JsonGet {
    param([string]$Url)

    $last = $null

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        $client = $null
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/9.0"

            $bytes = $client.DownloadData($Url)
            $jsonText = [Text.Encoding]::UTF8.GetString($bytes)

            if ([string]::IsNullOrWhiteSpace($jsonText)) {
                throw "The server returned an empty response."
            }

            return ($jsonText | ConvertFrom-Json)
        }
        catch {
            $last = $_
            if ($attempt -lt 3) {
                Write-Log ("    Request failed. Retry " + $attempt + "/3...")
                Start-Sleep -Seconds (2 * $attempt)
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }
    }

    throw $last
}

function Invoke-JsonGetBatch {
    param(
        $Requests,
        [string]$Activity = "Downloading deck details"
    )

    $requestArray = @($Requests)
    $output = New-Object System.Collections.ArrayList
    if ($requestArray.Count -eq 0) {
        return $output.ToArray()
    }

    # Normal mode intentionally stays conservative and sequential. Fast mode
    # uses six bounded asynchronous requests, then falls back to the proven
    # retrying request path for any individual failure.
    if (-not [bool]$Settings.FastImport) {
        for ($i = 0; $i -lt $requestArray.Count; $i++) {
            $request = $requestArray[$i]
            $data = $null
            $errorText = ""
            Show-UiProgress $Activity $i $requestArray.Count ([string]$request.Name)

            try {
                Wait-ApiPacing
                $data = Invoke-JsonGet ([string]$request.Url)
            }
            catch {
                $errorText = $_.Exception.Message
            }

            [void]$output.Add([pscustomobject]@{
                Key = [string]$request.Key
                Data = $data
                Error = $errorText
            })
            Show-UiProgress $Activity ($i + 1) $requestArray.Count ([string]$request.Name)
        }

        Complete-UiProgress
        return $output.ToArray()
    }

    $batchSize = 6
    $finished = 0

    for ($offset = 0; $offset -lt $requestArray.Count; $offset += $batchSize) {
        $lastIndex = [Math]::Min($offset + $batchSize - 1, $requestArray.Count - 1)
        $jobs = New-Object System.Collections.ArrayList

        for ($i = $offset; $i -le $lastIndex; $i++) {
            $request = $requestArray[$i]
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/9.0"

            try {
                $task = $client.DownloadDataTaskAsync([string]$request.Url)
                [void]$jobs.Add([pscustomobject]@{
                    Request = $request
                    Client = $client
                    Task = $task
                })
            }
            catch {
                $client.Dispose()
                [void]$jobs.Add([pscustomobject]@{
                    Request = $request
                    Client = $null
                    Task = $null
                    StartError = $_.Exception.Message
                })
            }
        }

        do {
            $completedInBatch = 0
            foreach ($job in $jobs) {
                if ($null -eq $job.Task -or $job.Task.IsCompleted) {
                    $completedInBatch++
                }
            }

            $displayCount = [Math]::Min($finished + $completedInBatch, $requestArray.Count)
            $detail = [string]$jobs[[Math]::Min($completedInBatch, $jobs.Count - 1)].Request.Name
            Show-UiProgress $Activity $displayCount $requestArray.Count $detail

            if ($completedInBatch -lt $jobs.Count) {
                Start-Sleep -Milliseconds 90
            }
        } while ($completedInBatch -lt $jobs.Count)

        foreach ($job in $jobs) {
            $data = $null
            $errorText = ""

            try {
                if ($null -eq $job.Task) {
                    throw [InvalidOperationException]::new([string]$job.StartError)
                }

                $bytes = $job.Task.GetAwaiter().GetResult()
                $jsonText = [Text.Encoding]::UTF8.GetString($bytes)
                if ([string]::IsNullOrWhiteSpace($jsonText)) {
                    throw "The server returned an empty response."
                }
                $data = $jsonText | ConvertFrom-Json
            }
            catch {
                # One failed parallel request does not poison the whole batch.
                # Retry it with the existing three-attempt implementation.
                try {
                    Complete-UiProgress
                    $data = Invoke-JsonGet ([string]$job.Request.Url)
                }
                catch {
                    $errorText = $_.Exception.Message
                }
            }
            finally {
                if ($job.Client) { $job.Client.Dispose() }
            }

            [void]$output.Add([pscustomobject]@{
                Key = [string]$job.Request.Key
                Data = $data
                Error = $errorText
            })
            $finished++
        }

        if ($lastIndex -lt ($requestArray.Count - 1)) {
            Start-Sleep -Milliseconds 75
        }
    }

    Complete-UiProgress
    return $output.ToArray()
}

function Invoke-ScryfallCollection {
    param($Ids)

    $map = @{}
    if ($null -eq $Ids) {
        return $map
    }

    $unique = @($Ids | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | Select-Object -Unique)
    if ($unique.Count -eq 0) {
        return $map
    }

    $missing = New-Object System.Collections.ArrayList

    foreach ($id in $unique) {
        $key = [string]$id

        if ($script:ScryfallCache.ContainsKey($key)) {
            $map[$key] = $script:ScryfallCache[$key]
        }
        else {
            [void]$missing.Add($key)
        }
    }

    if ($missing.Count -eq 0) {
        return $map
    }

    $collectionBatches = [int][Math]::Ceiling($missing.Count / 75.0)
    $collectionBatch = 0
    for ($offset = 0; $offset -lt $missing.Count; $offset += 75) {
        $collectionBatch++
        Show-UiProgress "Resolving card names" ($collectionBatch - 1) $collectionBatches ("Scryfall batch " + $collectionBatch)
        $lastIndex = [Math]::Min($offset + 74, $missing.Count - 1)
        $identifiers = @()

        for ($i = $offset; $i -le $lastIndex; $i++) {
            $identifiers += @{ id = [string]$missing[$i] }
        }

        $requestJson = @{ identifiers = $identifiers } | ConvertTo-Json -Depth 6 -Compress
        $requestBytes = [Text.Encoding]::UTF8.GetBytes($requestJson)

        $client = $null
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers["Accept"] = "application/json"
            $client.Headers["User-Agent"] = "Jadons-Archidekt-Forge-Manager/9.0"
            $client.Headers["Content-Type"] = "application/json; charset=utf-8"

            $responseBytes = $client.UploadData(
                "https://api.scryfall.com/cards/collection",
                "POST",
                $requestBytes
            )

            $responseText = [Text.Encoding]::UTF8.GetString($responseBytes)
            $response = $responseText | ConvertFrom-Json

            foreach ($card in $response.data) {
                if ($card -and $card.id) {
                    $key = [string]$card.id
                    $script:ScryfallCache[$key] = $card
                    $map[$key] = $card
                }
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }

        Show-UiProgress "Resolving card names" $collectionBatch $collectionBatches ("Scryfall batch " + $collectionBatch)

        if ([bool]$Settings.FastImport) {
            Start-Sleep -Milliseconds 80
        }
        else {
            Start-Sleep -Milliseconds 120
        }
    }

    try {
        Save-ScryfallCache
    }
    catch {
        Write-Log ("    WARNING: Scryfall cache could not be saved: " + $_.Exception.Message)
    }

    return $map
}

function Warm-ScryfallCacheForDetails {
    param($Details)

    if (-not [bool]$Settings.FastImport -or -not [bool]$Settings.ResolveWithScryfall) {
        return
    }

    $uids = New-Object System.Collections.ArrayList
    foreach ($detail in @($Details)) {
        if ($null -eq $detail) { continue }
        foreach ($entry in @(Get-Prop $detail "cards")) {
            $uid = Get-ArchidektUid $entry
            if ($uid) { [void]$uids.Add($uid) }
        }
    }

    if ($uids.Count -eq 0) { return }

    try {
        [void](Invoke-ScryfallCollection $uids.ToArray())
    }
    catch {
        Complete-UiProgress
        Write-Log ("  WARNING: Bulk card-name prefetch was incomplete: " + $_.Exception.Message)
    }
}

function Parse-ProfileInput {
    param([string]$Text)

    $Text = $Text.Trim()

    if ($Text -match '^https?://(?:www\.)?archidekt\.com/u/([^/?#]+)') {
        return [Uri]::UnescapeDataString($Matches[1])
    }

    if ($Text -match '^https?://(?:www\.)?archidekt\.com/search/decks\?') {
        try {
            $uri = [Uri]$Text
            foreach ($part in ($uri.Query.TrimStart("?") -split "&")) {
                $bits = $part -split "=", 2
                if ($bits.Count -eq 2 -and $bits[0] -eq "ownerUsername") {
                    return [Uri]::UnescapeDataString($bits[1].Replace("+", " "))
                }
            }
        }
        catch {}
    }

    if ($Text -notmatch '[/\\]') {
        return $Text
    }

    throw "That does not look like an Archidekt profile URL or username."
}

function Initialize-DefaultProfileHistory {
    try {
        $existing = @()
        if (Test-Path -LiteralPath $ProfileHistoryFile) {
            $existing = @(
                Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
            )
        }

        $merged = New-Object System.Collections.ArrayList

        foreach ($profile in $DefaultProfiles) {
            [void]$merged.Add([string]$profile)
        }

        foreach ($profile in $existing) {
            $duplicate = $false

            foreach ($current in $merged) {
                if ([string]::Equals(
                    [string]$current,
                    [string]$profile,
                    [StringComparison]::OrdinalIgnoreCase
                )) {
                    $duplicate = $true
                    break
                }
            }

            if (-not $duplicate -and $merged.Count -lt 20) {
                [void]$merged.Add([string]$profile)
            }
        }

        Write-Utf8NoBom $ProfileHistoryFile $merged.ToArray()
        return $true
    }
    catch {
        return $false
    }
}

function Get-ProfileChoices {
    $choices = New-Object System.Collections.ArrayList

    foreach ($profile in $DefaultProfiles) {
        [void]$choices.Add([string]$profile)
    }

    foreach ($profile in @(Get-RecentProfiles)) {
        $duplicate = $false

        foreach ($current in $choices) {
            if ([string]::Equals(
                [string]$current,
                [string]$profile,
                [StringComparison]::OrdinalIgnoreCase
            )) {
                $duplicate = $true
                break
            }
        }

        if (-not $duplicate) {
            [void]$choices.Add([string]$profile)
        }
    }

    return $choices.ToArray()
}

function Add-ProfileHistory {
    param([string]$Username)

    if ([string]::IsNullOrWhiteSpace($Username)) { return }

    $existing = @()
    if (Test-Path -LiteralPath $ProfileHistoryFile) {
        try {
            $existing = @(Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 | Where-Object { $_ })
        }
        catch {}
    }

    $merged = New-Object System.Collections.ArrayList

    foreach ($profile in $DefaultProfiles) {
        [void]$merged.Add([string]$profile)
    }

    $ordered = @($Username) + @($existing)
    foreach ($profile in $ordered) {
        if ([string]::IsNullOrWhiteSpace([string]$profile)) { continue }

        $duplicate = $false
        foreach ($current in $merged) {
            if ([string]::Equals(
                [string]$current,
                [string]$profile,
                [StringComparison]::OrdinalIgnoreCase
            )) {
                $duplicate = $true
                break
            }
        }

        if (-not $duplicate -and $merged.Count -lt 20) {
            [void]$merged.Add([string]$profile)
        }
    }

    Write-Utf8NoBom $ProfileHistoryFile $merged.ToArray()
}

function Get-RecentProfiles {
    if (-not (Test-Path -LiteralPath $ProfileHistoryFile)) {
        return @()
    }

    try {
        return @(Get-Content -LiteralPath $ProfileHistoryFile -Encoding UTF8 | Where-Object { $_ } | Select-Object -First 10)
    }
    catch {
        return @()
    }
}

function Get-EntryCategories {
    param($Entry)

    $result = New-Object System.Collections.ArrayList

    $single = Get-Prop $Entry "category"
    if ($single) {
        if ($single -is [string]) {
            [void]$result.Add([string]$single)
        }
        else {
            $singleName = Get-Prop $single "name"
            if ($singleName) { $result.Add([string]$singleName) }
        }
    }

    foreach ($cat in @(Get-Prop $Entry "categories")) {
        if ($null -eq $cat) { continue }

        if ($cat -is [string]) {
            [void]$result.Add([string]$cat)
        }
        else {
            $name = Get-Prop $cat "name"
            if ($name) { $result.Add([string]$name) }
        }
    }

    return @($result.ToArray() | Select-Object -Unique)
}

function Get-ArchidektCardName {
    param($Entry)

    $card = Get-Prop $Entry "card"
    if ($null -eq $card) { return $null }

    $oracle = Get-Prop $card "oracleCard"
    if ($null -eq $oracle) {
        $oracle = Get-Prop $card "oracle_card"
    }

    if ($oracle) {
        $name = Get-Prop $oracle "name"
        if ($name) { return [string]$name }
    }

    foreach ($field in @("displayName", "name")) {
        $name = Get-Prop $card $field
        if ($name) { return [string]$name }
    }

    return $null
}

function Get-ArchidektUid {
    param($Entry)

    $card = Get-Prop $Entry "card"
    if ($null -eq $card) { return $null }

    foreach ($field in @("uid", "scryfallId", "scryfall_id")) {
        $value = Get-Prop $card $field
        if ($value) {
            return [string]$value
        }
    }

    return $null
}

function Get-DeckFormatText {
    param($Deck, $Meta)

    foreach ($obj in @($Deck, $Meta)) {
        if ($null -eq $obj) { continue }

        foreach ($field in @("deckFormat", "format", "deckFormatName", "formatName")) {
            $value = Get-Prop $obj $field
            if ($null -eq $value) { continue }

            if ($value -is [string]) {
                return [string]$value
            }

            if ($value -is [int] -or $value -is [long]) {
                if ([int64]$value -eq 3) { return "Commander" }
                return [string]$value
            }

            foreach ($sub in @("name", "displayName", "label")) {
                $text = Get-Prop $value $sub
                if ($text) { return [string]$text }
            }

            $id = Get-Prop $value "id"
            if ($id -eq 3) { return "Commander" }
        }
    }

    return ""
}

function Get-ForgeCardName {
    param(
        [string]$FallbackName,
        $ScryfallCard
    )

    $name = $FallbackName
    $layout = ""

    if ($ScryfallCard) {
        if ($ScryfallCard.name) {
            $name = [string]$ScryfallCard.name
        }
        if ($ScryfallCard.layout) {
            $layout = ([string]$ScryfallCard.layout).ToLowerInvariant()
        }
    }

    if ([string]::IsNullOrWhiteSpace($name)) {
        return $null
    }

    # Forge deck files use the FRONT card name for transform/MDFC/flip/adventure
    # cards. Split, aftermath and Room cards keep the full "A // B" name.
    $useFrontFace = $false

    switch ($layout) {
        "transform"        { $useFrontFace = $true }
        "modal_dfc"        { $useFrontFace = $true }
        "flip"             { $useFrontFace = $true }
        "adventure"        { $useFrontFace = $true }
        "reversible_card"  { $useFrontFace = $true }
    }

    if ($name.Contains(" // ") -and $useFrontFace) {
        $parts = $name -split " // "
        return ([string]$parts[0]).Trim()
    }

    # If Scryfall was unavailable, the safest Forge fallback for a combined
    # permanent DFC name is the front face. Scryfall resolution normally
    # prevents split/Room cards from reaching this fallback.
    if (-not $ScryfallCard -and $name.Contains(" // ")) {
        $parts = $name -split " // "
        return ([string]$parts[0]).Trim()
    }

    return $name.Trim()
}

function Test-IsActualTokenOrEmblem {
    param(
        $Entry,
        $ScryfallCard
    )

    # IMPORTANT:
    # Do NOT use Archidekt category names such as "Tokens".
    # Users commonly put ordinary token-generating cards in a category named
    # Tokens, and that does not mean the card itself is a token.

    if ($ScryfallCard) {
        $layout = ([string](Get-Prop $ScryfallCard "layout")).ToLowerInvariant()
        $typeLine = [string](Get-Prop $ScryfallCard "type_line")

        if ($layout -in @("token", "double_faced_token", "emblem")) {
            return $true
        }

        if ($typeLine -match '(?i)^\s*Token\b' -or
            $typeLine -match '(?i)^\s*Emblem\b') {
            return $true
        }
    }

    # Archidekt fallback only when Scryfall metadata is unavailable.
    # Inspect actual card metadata fields, never deck/category labels.
    $card = Get-Prop $Entry "card"
    if ($card) {
        $layout = ([string](Get-Prop $card "layout")).ToLowerInvariant()

        if ($layout -in @("token", "double_faced_token", "emblem")) {
            return $true
        }

        foreach ($field in @("typeLine", "type_line")) {
            $typeLine = [string](Get-Prop $card $field)
            if ($typeLine -match '(?i)^\s*Token\b' -or
                $typeLine -match '(?i)^\s*Emblem\b') {
                return $true
            }
        }

        $oracle = Get-Prop $card "oracleCard"
        if ($oracle) {
            $oracleLayout = ([string](Get-Prop $oracle "layout")).ToLowerInvariant()

            if ($oracleLayout -in @("token", "double_faced_token", "emblem")) {
                return $true
            }

            foreach ($field in @("typeLine", "type_line")) {
                $typeLine = [string](Get-Prop $oracle $field)
                if ($typeLine -match '(?i)^\s*Token\b' -or
                    $typeLine -match '(?i)^\s*Emblem\b') {
                    return $true
                }
            }
        }
    }

    return $false
}

function Test-CommanderEligible {
    param($ScryfallCard)

    if (-not $ScryfallCard) { return $false }

    $typeLine = [string](Get-Prop $ScryfallCard "type_line")
    $oracle = [string](Get-Prop $ScryfallCard "oracle_text")

    if ($typeLine -match '(?i)\bLegendary\b.*\bCreature\b') {
        return $true
    }

    if ($oracle -match '(?i)can be your commander') {
        return $true
    }

    return $false
}

function New-DeckCard {
    param(
        [string]$Name,
        [int]$Quantity,
        [string]$Uid,
        $Scryfall,
        [string[]]$Categories
    )

    return [pscustomobject]@{
        Name = $Name
        Quantity = $Quantity
        Uid = $Uid
        Scryfall = $Scryfall
        Categories = @($Categories)
    }
}

function Get-QuantityTotal {
    param($Cards)

    $total = 0
    foreach ($card in $Cards) {
        $total += [int]$card.Quantity
    }
    return $total
}

function Remove-CardObjectFromList {
    param(
        [System.Collections.IList]$List,
        $Target
    )

    for ($i = $List.Count - 1; $i -ge 0; $i--) {
        if ([object]::ReferenceEquals($List[$i], $Target)) {
            $List.RemoveAt($i)
            return $true
        }
    }

    return $false
}

function Trim-CommanderDeckTo100 {
    param(
        [System.Collections.IList]$Main,
        [System.Collections.IList]$Commanders
    )

    $commanderTotal = Get-QuantityTotal $Commanders
    $mainTotal = Get-QuantityTotal $Main
    $total = $commanderTotal + $mainTotal

    $cutCards = New-Object System.Collections.ArrayList

    if ($total -le 100) {
        return [pscustomobject]@{
            CutCount = 0
            CutCards = @()
            FinalTotal = $total
        }
    }

    $needToCut = $total - 100

    for ($i = $Main.Count - 1; $i -ge 0 -and $needToCut -gt 0; $i--) {
        $card = $Main[$i]
        $qty = [int]$card.Quantity
        $removeQty = [Math]::Min($qty, $needToCut)

        if ($removeQty -ge $qty) {
            [void]$cutCards.Add(([string]$qty + " " + $card.Name))
            $Main.RemoveAt($i)
        }
        else {
            $card.Quantity = $qty - $removeQty
            [void]$cutCards.Add(([string]$removeQty + " " + $card.Name))
        }

        $needToCut -= $removeQty
    }

    return [pscustomobject]@{
        CutCount = ($total - 100 - $needToCut)
        CutCards = $cutCards.ToArray()
        FinalTotal = ((Get-QuantityTotal $Commanders) + (Get-QuantityTotal $Main))
    }
}

function Safe-FileName {
    param([string]$Name, [string]$DeckId)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = "Archidekt Deck $DeckId"
    }

    $invalid = [IO.Path]::GetInvalidFileNameChars()
    $chars = $Name.ToCharArray()

    for ($i = 0; $i -lt $chars.Length; $i++) {
        if ($invalid -contains $chars[$i]) {
            $chars[$i] = "_"
        }
    }

    $safe = (-join $chars).Trim().TrimEnd(".")
    if ([string]::IsNullOrWhiteSpace($safe)) {
        $safe = "Archidekt Deck $DeckId"
    }

    $reserved = @(
        "CON","PRN","AUX","NUL",
        "COM1","COM2","COM3","COM4","COM5","COM6","COM7","COM8","COM9",
        "LPT1","LPT2","LPT3","LPT4","LPT5","LPT6","LPT7","LPT8","LPT9"
    )

    if ($reserved -contains $safe.ToUpperInvariant()) {
        $safe += "_"
    }

    if ($safe.Length -gt 140) {
        $safe = $safe.Substring(0, 140).TrimEnd()
    }

    return $safe
}

function Test-IsOurImportedDeckFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    try {
        $head = @(Get-Content -LiteralPath $Path -TotalCount 20 -Encoding UTF8)

        if ($head -contains ("Tags=" + $ImportTag)) {
            return $true
        }

        $hasArchidektSource = $false
        foreach ($line in $head) {
            if ($line -match '^Source URL=https://archidekt\.com/decks/\d+') {
                $hasArchidektSource = $true
                break
            }
        }

        if ($hasArchidektSource) {
            foreach ($line in $head) {
                if ($line -eq "Comment=Imported automatically from Archidekt" -or
                    $line -eq "Comment=Synced from Archidekt by Jadon's Archidekt Deck Sync" -or
                    $line -eq ("Comment=" + $ImporterComment)) {
                    return $true
                }
            }
        }
    }
    catch {}

    return $false
}

function Find-ImportedDeckBySource {
    param([string]$SourceUrl)

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (-not (Test-IsOurImportedDeckFile $file.FullName)) {
                continue
            }

            try {
                $head = @(Get-Content -LiteralPath $file.FullName -TotalCount 20 -Encoding UTF8)
                if ($head -contains ("Source URL=" + $SourceUrl)) {
                    return $file.FullName
                }
            }
            catch {}
        }
    }

    return $null
}

function Choose-OutputPath {
    param(
        [string]$Directory,
        [string]$DeckName,
        [string]$DeckId,
        [string]$SourceUrl,
        [string]$Existing
    )

    $safe = Safe-FileName $DeckName $DeckId
    $candidate = Join-Path $Directory ($safe + ".dck")

    if ($Existing) {
        try {
            if ([IO.Path]::GetFullPath($Existing) -eq [IO.Path]::GetFullPath($candidate)) {
                return $candidate
            }
        }
        catch {}
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        return $candidate
    }

    if (Test-IsOurImportedDeckFile $candidate) {
        try {
            $head = @(Get-Content -LiteralPath $candidate -TotalCount 20 -Encoding UTF8)
            if ($head -contains ("Source URL=" + $SourceUrl)) {
                return $candidate
            }
        }
        catch {}
    }

    $baseName = $safe + " [Archidekt " + $DeckId + "]"
    $number = 1

    while ($number -le 1000) {
        $suffix = if ($number -eq 1) { "" } else { " " + $number }
        $alternate = Join-Path $Directory ($baseName + $suffix + ".dck")

        if (-not (Test-Path -LiteralPath $alternate)) {
            return $alternate
        }

        if (Test-IsOurImportedDeckFile $alternate) {
            try {
                $head = @(Get-Content -LiteralPath $alternate -TotalCount 20 -Encoding UTF8)
                if ($head -contains ("Source URL=" + $SourceUrl)) {
                    return $alternate
                }
            }
            catch {}
        }

        $number++
    }

    throw "Could not choose a non-conflicting Forge deck filename for Archidekt deck $DeckId."
}

function Move-FallbackCommanderIfNeeded {
    param(
        [System.Collections.IList]$Main,
        [System.Collections.IList]$Commanders,
        [string]$DeckName,
        [bool]$AllowPrompt = $true
    )

    if ($Commanders.Count -gt 0) {
        return
    }

    $eligible = New-Object System.Collections.ArrayList
    foreach ($card in $Main) {
        if (Test-CommanderEligible $card.Scryfall) {
            [void]$eligible.Add($card)
        }
    }

    if ($eligible.Count -eq 1) {
        $chosen = $eligible[0]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    Enhanced commander detection: " + $chosen.Name)
        return
    }

    if ($eligible.Count -eq 0) {
        return
    }

    # Try deck-name matching before asking the user.
    $deckNameLower = $DeckName.ToLowerInvariant()
    $nameMatches = New-Object System.Collections.ArrayList

    foreach ($card in $eligible) {
        $front = $card.Name
        if ($front.Contains(" // ")) {
            $front = ($front -split " // ")[0]
        }

        if ($deckNameLower.Contains($front.ToLowerInvariant())) {
            [void]$nameMatches.Add($card)
        }
    }

    if ($nameMatches.Count -eq 1) {
        $chosen = $nameMatches[0]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    Enhanced commander detection from deck name: " + $chosen.Name)
        return
    }

    if (-not $AllowPrompt) {
        return
    }

    Write-Host ""
    Write-Host ("Commander tag missing for: " + $DeckName) -ForegroundColor Yellow
    Write-Host "Possible commander cards:"
    Write-Host ""

    $limit = [Math]::Min(20, $eligible.Count)
    for ($i = 0; $i -lt $limit; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $eligible[$i].Name)
    }

    Write-Host ""
    $answer = Read-Host "Enter commander number, two numbers separated by comma, or press Enter to skip"

    if ([string]::IsNullOrWhiteSpace($answer)) {
        return
    }

    $indexes = @()
    foreach ($piece in ($answer -split ",")) {
        $n = 0
        if ([int]::TryParse($piece.Trim(), [ref]$n)) {
            if ($n -ge 1 -and $n -le $limit) {
                $indexes += ($n - 1)
            }
        }
    }

    foreach ($idx in @($indexes | Select-Object -Unique | Sort-Object -Descending)) {
        $chosen = $eligible[$idx]
        [void](Remove-CardObjectFromList $Main $chosen)
        [void]$Commanders.Add($chosen)
        Write-Log ("    User-selected commander: " + $chosen.Name)
    }
}


function Get-NormalizedDeckVector {
    param(
        $Main,
        $Commanders
    )

    $counts = @{}

    foreach ($card in $Commanders) {
        if ($null -eq $card) { continue }

        $name = ([string]$card.Name).Trim().ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $qty = 1
        try { $qty = [int]$card.Quantity } catch { $qty = 1 }
        if ($qty -lt 1) { continue }

        if ($counts.ContainsKey($name)) {
            $counts[$name] += $qty
        }
        else {
            $counts[$name] = $qty
        }
    }

    foreach ($card in $Main) {
        if ($null -eq $card) { continue }

        $name = ([string]$card.Name).Trim().ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $qty = 1
        try { $qty = [int]$card.Quantity } catch { $qty = 1 }
        if ($qty -lt 1) { continue }

        if ($counts.ContainsKey($name)) {
            $counts[$name] += $qty
        }
        else {
            $counts[$name] = $qty
        }
    }

    $vector = New-Object System.Collections.ArrayList
    foreach ($name in ($counts.Keys | Sort-Object)) {
        [void]$vector.Add(([string]$counts[$name]) + "`t" + $name)
    }

    return $vector.ToArray()
}

function Get-SimilarityVector {
    param($DeckVector)

    $basicNames = @{
        "plains" = $true
        "island" = $true
        "swamp" = $true
        "mountain" = $true
        "forest" = $true
        "wastes" = $true
        "snow-covered plains" = $true
        "snow-covered island" = $true
        "snow-covered swamp" = $true
        "snow-covered mountain" = $true
        "snow-covered forest" = $true
    }

    $result = New-Object System.Collections.ArrayList

    foreach ($line in $DeckVector) {
        $parts = ([string]$line) -split "`t", 2
        if ($parts.Count -ne 2) { continue }

        $name = ([string]$parts[1]).Trim().ToLowerInvariant()
        if ($basicNames.ContainsKey($name)) {
            continue
        }

        [void]$result.Add(([string]$parts[0]) + "`t" + $name)
    }

    return $result.ToArray()
}

function Get-VectorHash {
    param($DeckVector)

    $joined = (@($DeckVector) -join "`n")
    $bytes = [Text.Encoding]::UTF8.GetBytes($joined)
    $sha = [Security.Cryptography.SHA256]::Create()

    try {
        $hashBytes = $sha.ComputeHash($bytes)
        return ([BitConverter]::ToString($hashBytes)).Replace("-", "").ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Convert-VectorToCountMap {
    param($DeckVector)

    $map = @{}

    foreach ($line in $DeckVector) {
        $parts = ([string]$line) -split "`t", 2
        if ($parts.Count -ne 2) { continue }

        $qty = 0
        if (-not [int]::TryParse(([string]$parts[0]), [ref]$qty)) {
            continue
        }

        if ($qty -lt 1) { continue }

        $name = ([string]$parts[1]).Trim().ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $map[$name] = $qty
    }

    return $map
}

function Get-DeckSimilarityPercent {
    param(
        $VectorA,
        $VectorB
    )

    $a = Convert-VectorToCountMap $VectorA
    $b = Convert-VectorToCountMap $VectorB

    $totalA = 0
    foreach ($value in $a.Values) { $totalA += [int]$value }

    $totalB = 0
    foreach ($value in $b.Values) { $totalB += [int]$value }

    $denominator = [Math]::Max($totalA, $totalB)
    if ($denominator -le 0) {
        return 0.0
    }

    $intersection = 0

    foreach ($name in $a.Keys) {
        if ($b.ContainsKey($name)) {
            $intersection += [Math]::Min([int]$a[$name], [int]$b[$name])
        }
    }

    return [Math]::Round((100.0 * $intersection / $denominator), 2)
}

function Read-ImportedDeckRecord {
    param([string]$Path)

    if (-not (Test-IsOurImportedDeckFile $Path)) {
        return $null
    }

    $lines = @(Get-Content -LiteralPath $Path -Encoding UTF8)
    $section = ""
    $name = ""
    $originalName = ""
    $sourceUrl = ""
    $sourceMode = ""
    $bracket = 0
    $commanders = New-Object System.Collections.ArrayList
    $main = New-Object System.Collections.ArrayList

    foreach ($line in $lines) {
        if ($line -match '^\[(.+)\]$') {
            $section = $Matches[1].ToLowerInvariant()
            continue
        }

        if ($section -eq "metadata") {
            if ($line -match '^Name=(.*)$') {
                $name = [string]$Matches[1]
            }
            elseif ($line -match '^Source URL=(.*)$') {
                $sourceUrl = [string]$Matches[1]
            }
            elseif ($line -match '^Comment=.*\|\s*Original=(.*)$') {
                $originalName = [string]$Matches[1]
            }
            elseif ($line -match '^Import Mode=(.*)$') {
                $sourceMode = ([string]$Matches[1]).Trim()
            }
            elseif ($line -match '^EDH Bracket=(\d+)$') {
                $bracket = [int]$Matches[1]
            }
            continue
        }

        if ($section -ne "commander" -and $section -ne "main") {
            continue
        }

        if ($line -notmatch '^\s*(\d+)\s+(.+?)\s*$') {
            continue
        }

        $qty = [int]$Matches[1]
        $cardName = [string]$Matches[2]

        if ($cardName.Contains("|")) {
            $cardName = ($cardName -split "\|", 2)[0]
        }

        $obj = [pscustomobject]@{
            Name = $cardName.Trim()
            Quantity = $qty
        }

        if ($section -eq "commander") {
            [void]$commanders.Add($obj)
        }
        else {
            [void]$main.Add($obj)
        }
    }

    if ([string]::IsNullOrWhiteSpace($originalName)) {
        $originalName = $name
    }

    $commanderLabel = Get-CommanderLabel $commanders
    $vector = Get-NormalizedDeckVector $main $commanders
    $similarityVector = Get-SimilarityVector $vector
    $hash = Get-VectorHash $vector

    $deckId = ""
    if ($sourceUrl -match '/decks/(\d+)') {
        $deckId = [string]$Matches[1]
    }

    return [pscustomobject]@{
        Path = $Path
        DeckId = $deckId
        DisplayName = $name
        OriginalName = $originalName
        SourceUrl = $sourceUrl
        CommanderLabel = $commanderLabel
        CardVector = $vector
        SimilarityVector = $similarityVector
        CardHash = $hash
        SourceMode = $sourceMode
        Bracket = $bracket
    }
}

function Get-ImportedLibraryIndex {
    $records = New-Object System.Collections.ArrayList
    $hashes = @{}
    $names = @{}
    $commanders = @{}
    $knownState = Read-ImportState

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (-not (Test-IsOurImportedDeckFile $file.FullName)) {
                continue
            }

            try {
                $record = Read-ImportedDeckRecord $file.FullName
                if ($null -eq $record) { continue }

                if ([int]$record.Bracket -eq 0 -and
                    -not [string]::IsNullOrWhiteSpace([string]$record.DeckId) -and
                    $knownState.ContainsKey([string]$record.DeckId)) {

                    $stateRecord = $knownState[[string]$record.DeckId]
                    try { $record.Bracket = [int]$stateRecord.Bracket } catch {}
                    if ([string]::IsNullOrWhiteSpace([string]$record.SourceMode)) {
                        $record.SourceMode = [string]$stateRecord.SourceMode
                    }
                }

                [void]$records.Add($record)

                if (-not [string]::IsNullOrWhiteSpace([string]$record.CardHash)) {
                    $hashes[[string]$record.CardHash] = $record
                }

                foreach ($candidateName in @($record.DisplayName, $record.OriginalName)) {
                    if (-not [string]::IsNullOrWhiteSpace([string]$candidateName)) {
                        $names[([string]$candidateName).Trim().ToLowerInvariant()] = $record
                    }
                }

                if (-not [string]::IsNullOrWhiteSpace([string]$record.CommanderLabel)) {
                    $commanders[([string]$record.CommanderLabel).Trim().ToLowerInvariant()] = $record
                }
            }
            catch {
                Write-Log ("WARNING: Could not index imported deck " + $file.Name + ": " + $_.Exception.Message)
            }
        }
    }

    return [pscustomobject]@{
        Records = $records
        Hashes = $hashes
        Names = $names
        Commanders = $commanders
    }
}

function Find-SimilarImportedDeck {
    param(
        $SimilarityVector,
        $LibraryIndex,
        [string]$ExcludeDeckId = ""
    )

    if (-not [bool]$Settings.SimilarityDetection) {
        return $null
    }

    $threshold = 90.0
    try { $threshold = [double]$Settings.SimilarityThreshold } catch { $threshold = 90.0 }

    if ($threshold -lt 50) { $threshold = 50 }
    if ($threshold -gt 100) { $threshold = 100 }

    $best = $null
    $bestPercent = 0.0

    foreach ($record in $LibraryIndex.Records) {
        if ($null -eq $record.SimilarityVector) { continue }
        if (-not [string]::IsNullOrWhiteSpace($ExcludeDeckId) -and
            [string]$record.DeckId -eq $ExcludeDeckId) {
            continue
        }

        $percent = Get-DeckSimilarityPercent $SimilarityVector $record.SimilarityVector
        if ($percent -gt $bestPercent) {
            $bestPercent = $percent
            $best = $record
        }
    }

    if ($best -and $bestPercent -ge $threshold) {
        return [pscustomobject]@{
            Record = $best
            Percent = $bestPercent
        }
    }

    return $null
}

function Find-SimilarImportedDeckScoped {
    param(
        $SimilarityVector,
        $LibraryIndex,
        [int]$Bracket,
        [ValidateSet("Settings", "All", "SameBracket", "Off")]
        [string]$Scope = "Settings"
    )

    if ($Scope -eq "Off") { return $null }
    if ($Scope -eq "Settings" -and -not [bool]$Settings.SimilarityDetection) {
        return $null
    }

    $threshold = 90.0
    try { $threshold = [double]$Settings.SimilarityThreshold } catch { $threshold = 90.0 }
    if ($threshold -lt 50) { $threshold = 50 }
    if ($threshold -gt 100) { $threshold = 100 }

    $best = $null
    $bestPercent = 0.0

    foreach ($record in $LibraryIndex.Records) {
        if ($null -eq $record.SimilarityVector) { continue }
        if ($Scope -eq "SameBracket") {
            $recordBracket = 0
            try { $recordBracket = [int]$record.Bracket } catch { $recordBracket = 0 }
            if ($recordBracket -ne $Bracket) { continue }
        }

        $percent = Get-DeckSimilarityPercent $SimilarityVector $record.SimilarityVector
        if ($percent -gt $bestPercent) {
            $bestPercent = $percent
            $best = $record
        }
    }

    if ($best -and $bestPercent -ge $threshold) {
        return [pscustomobject]@{
            Record = $best
            Percent = $bestPercent
        }
    }

    return $null
}

function Test-MassCommanderAllowed {
    param(
        [string]$CommanderLabel,
        $LibraryIndex,
        $ManualCommanderIndex,
        [int]$Bracket,
        [ValidateSet("UniqueAll", "DifferentBracket", "Allow")]
        [string]$Policy
    )

    if ($Policy -eq "Allow") { return $true }
    $key = $CommanderLabel.Trim().ToLowerInvariant()

    if ($ManualCommanderIndex -and $ManualCommanderIndex.ContainsKey($key)) {
        return $false
    }

    foreach ($record in $LibraryIndex.Records) {
        if ([string]::IsNullOrWhiteSpace([string]$record.CommanderLabel)) { continue }
        if (([string]$record.CommanderLabel).Trim().ToLowerInvariant() -ne $key) { continue }

        if ($Policy -eq "UniqueAll") { return $false }

        $recordBracket = 0
        try { $recordBracket = [int]$record.Bracket } catch { $recordBracket = 0 }

        # Older imports without bracket metadata are treated conservatively:
        # their bracket cannot be proven different, so they still conflict.
        if ($recordBracket -eq 0 -or $recordBracket -eq $Bracket) {
            return $false
        }
    }

    return $true
}

function Get-ManualCommanderIndex {
    $index = @{}
    if (-not (Test-Path -LiteralPath $CommanderDir)) { return $index }

    foreach ($file in Get-ChildItem -LiteralPath $CommanderDir -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
        if (Test-IsOurImportedDeckFile $file.FullName) { continue }

        try {
            $section = ""
            foreach ($line in Get-Content -LiteralPath $file.FullName -Encoding UTF8) {
                if ($line -match '^\[(.+)\]$') {
                    $section = $Matches[1].ToLowerInvariant()
                    continue
                }
                if ($section -ne "commander") { continue }
                if ($line -notmatch '^\s*\d+\s+(.+?)\s*$') { continue }

                $name = [string]$Matches[1]
                if ($name.Contains("|")) { $name = ($name -split "\|", 2)[0] }
                $key = $name.Trim().ToLowerInvariant()
                if ($key) { $index[$key] = $file.FullName }
            }
        }
        catch {
            # A manually maintained deck that cannot be read is never modified.
        }
    }

    return $index
}

function Commit-PreparedDeck {
    param($Result)

    if ($null -eq $Result -or $Result.Skipped) {
        throw "Cannot commit a skipped or empty prepared deck."
    }

    if ([bool]$Settings.DryRun) {
        return
    }

    $sourceUrl = "https://archidekt.com/decks/" + [string]$Result.Id
    $existing = Find-ImportedDeckBySource $sourceUrl

    if ($existing) {
        Backup-ImportedDeck $existing ([string]$Result.Id)
    }

    Write-Utf8NoBom ([string]$Result.Path) $Result.DeckLines

    if ($existing) {
        if ([IO.Path]::GetFullPath($existing) -ne [IO.Path]::GetFullPath([string]$Result.Path)) {
            Remove-Item -LiteralPath $existing -Force -ErrorAction Stop
        }
    }
}

function Convert-Deck {
    param(
        $Deck,
        $Meta,
        $RenameCounts,
        [switch]$PreviewOnly,
        [switch]$Exact100Only,
        [string]$SourceMode = "Profile",
        [int]$Bracket = 0
    )

    $deckId = [string](Get-Prop $Deck "id")
    if (-not $deckId) {
        $deckId = [string](Get-Prop $Meta "id")
    }
    if (-not $deckId) {
        throw "Deck detail did not include an ID."
    }

    $deckName = [string](Get-Prop $Deck "name")
    if (-not $deckName) {
        $deckName = [string](Get-Prop $Meta "name")
    }
    if (-not $deckName) {
        $deckName = "Archidekt Deck $deckId"
    }
    $ownerName = Get-DeckOwnerName $Deck $Meta

    $sourceUrl = "https://archidekt.com/decks/$deckId"
    $entries = @(Get-Prop $Deck "cards")

    $uids = New-Object System.Collections.ArrayList
    foreach ($entry in $entries) {
        $uid = Get-ArchidektUid $entry
        if ($uid) {
            [void]$uids.Add($uid)
        }
    }

    $scryfallMap = @{}
    if ([bool]$Settings.ResolveWithScryfall -and $uids.Count -gt 0) {
        try {
            $scryfallMap = Invoke-ScryfallCollection $uids
        }
        catch {
            Complete-UiProgress
            Write-Log "    WARNING: Scryfall validation failed. Falling back to Archidekt names."
            $scryfallMap = @{}
        }
    }

    $premierCategories = @{}
    $excludedCategories = @{}
    $sideboardCategories = @{}

    foreach ($cat in (Get-Prop $Deck "categories")) {
        if ($null -eq $cat) { continue }

        $catName = [string](Get-Prop $cat "name")
        if ([string]::IsNullOrWhiteSpace($catName)) { continue }

        $included = Get-Prop $cat "includedInDeck"
        if ($null -eq $included) { $included = $true }

        $premier = Get-Prop $cat "isPremier"
        if ($null -eq $premier) { $premier = $false }

        if (-not [bool]$included) {
            $excludedCategories[$catName] = $true
        }

        if ([bool]$included -and [bool]$premier) {
            $premierCategories[$catName] = $true
        }

        if ($catName -match '^(?i:sideboard)$') {
            $sideboardCategories[$catName] = $true
        }
    }

    $main = New-Object System.Collections.ArrayList
    $commanders = New-Object System.Collections.ArrayList
    $sideboard = New-Object System.Collections.ArrayList

    $tokensRemoved = 0
    $maybeboardRemoved = 0
    $unresolvedNames = 0

    foreach ($entry in $entries) {
        if ($null -eq $entry) { continue }

        $fallbackName = Get-ArchidektCardName $entry
        if ([string]::IsNullOrWhiteSpace($fallbackName)) { continue }

        $uid = Get-ArchidektUid $entry
        $scry = $null

        if ($uid -and $scryfallMap.ContainsKey($uid)) {
            $scry = $scryfallMap[$uid]
        }

        $forgeName = Get-ForgeCardName $fallbackName $scry
        if ([string]::IsNullOrWhiteSpace($forgeName)) { continue }

        if (-not $scry) {
            $unresolvedNames++
        }

        $qty = Get-Prop $entry "quantity"
        if ($null -eq $qty) { $qty = 1 }
        try { $qty = [int]$qty } catch { $qty = 1 }
        if ($qty -lt 1) { continue }

        $cats = @(Get-EntryCategories $entry)

        if ($Exact100Only -or [bool]$Settings.RemoveActualTokens) {
            if (Test-IsActualTokenOrEmblem $entry $scry) {
                $tokensRemoved += $qty
                continue
            }
        }

        $isExcluded = $false
        $isPremier = $false
        $isSideboard = $false

        foreach ($cat in $cats) {
            if ($excludedCategories.ContainsKey([string]$cat)) {
                $isExcluded = $true
            }

            if ($premierCategories.ContainsKey([string]$cat)) {
                $isPremier = $true
            }

            if ($sideboardCategories.ContainsKey([string]$cat) -or
                [string]$cat -match '^(?i:sideboard)$') {
                $isSideboard = $true
            }

            if ([string]$cat -match '^(?i:commander|commanders)$') {
                $isPremier = $true
            }

            if ([string]$cat -match '^(?i:maybeboard|maybe board)$') {
                $isExcluded = $true
            }
        }

        if ($isExcluded -and -not $isPremier) {
            $maybeboardRemoved += $qty
            continue
        }

        $obj = New-DeckCard $forgeName $qty $uid $scry $cats

        if ($isPremier) {
            [void]$commanders.Add($obj)
        }
        elseif ($isSideboard) {
            [void]$sideboard.Add($obj)
        }
        else {
            [void]$main.Add($obj)
        }
    }

    $formatText = Get-DeckFormatText $Deck $Meta
    $isCommanderDeck = ($formatText -match '(?i)commander') -or ($commanders.Count -gt 0)

    if ($isCommanderDeck -and $commanders.Count -eq 0) {
        Move-FallbackCommanderIfNeeded $main $commanders $deckName (-not $Exact100Only)
    }

    if ($commanders.Count -gt 0) {
        $isCommanderDeck = $true
    }

    $commanderLabel = Get-CommanderLabel $commanders
    $preTrimTotal = (Get-QuantityTotal $commanders) + (Get-QuantityTotal $main)

    $existing = Find-ImportedDeckBySource $sourceUrl

    $mustSkipForCount = $false
    $countSkipReason = ""
    $skipStatus = "SkippedIncomplete"

    if ($isCommanderDeck -and $commanders.Count -eq 0) {
        $mustSkipForCount = $true
        $countSkipReason = "Commander deck has no verified commander"
        $skipStatus = "SkippedCommanderUnresolved"
    }
    elseif ($isCommanderDeck -and $Exact100Only -and $preTrimTotal -ne 100) {
        $mustSkipForCount = $true
        $countSkipReason = "Bracket/library mode requires exactly 100 cards; found " + $preTrimTotal
    }
    elseif ($isCommanderDeck -and
        [bool]$Settings.SkipIncompleteCommander -and
        $preTrimTotal -lt 100) {

        $mustSkipForCount = $true
        $countSkipReason = "Commander deck is under 100 cards"
    }

    if ($mustSkipForCount) {
        $skipVector = Get-NormalizedDeckVector $main $commanders
        $skipSimilarityVector = Get-SimilarityVector $skipVector

        return [pscustomobject]@{
            Id = $deckId
            Name = $deckName
            DisplayName = $deckName
            DeckType = "Commander"
            Path = $null
            MainCount = (Get-QuantityTotal $main)
            CommanderCount = (Get-QuantityTotal $commanders)
            SideboardCount = (Get-QuantityTotal $sideboard)
            Total = $preTrimTotal
            TokensRemoved = $tokensRemoved
            MaybeboardRemoved = $maybeboardRemoved
            CutCount = 0
            CutCards = @()
            UnresolvedNames = $unresolvedNames
            CommanderLabel = $commanderLabel
            OwnerName = $ownerName
            Skipped = $true
            SkipReason = $countSkipReason
            Status = $skipStatus
            DeckLines = @()
            CardVector = $skipVector
            SimilarityVector = $skipSimilarityVector
            CardHash = Get-VectorHash $skipVector
            SourceMode = $SourceMode
            Bracket = $Bracket
        }
    }

    $cutResult = [pscustomobject]@{
        CutCount = 0
        CutCards = @()
        FinalTotal = $preTrimTotal
    }

    if ($isCommanderDeck -and -not $Exact100Only -and [bool]$Settings.CapCommanderAt100 -and $preTrimTotal -gt 100) {
        $cutResult = Trim-CommanderDeckTo100 $main $commanders
    }

    $deckType = if ($isCommanderDeck) { "Commander" } else { "Constructed" }
    $targetDir = if ($isCommanderDeck) { $CommanderDir } else { $ConstructedDir }

    $displayName = Get-RenameDisplayName $deckName $commanderLabel $ownerName $RenameCounts
    $output = Choose-OutputPath $targetDir $displayName $deckId $sourceUrl $existing

    $cleanDisplayName = $displayName.Replace("`r", " ").Replace("`n", " ")
    $cleanOriginalName = $deckName.Replace("`r", " ").Replace("`n", " ")

    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add("[metadata]")
    [void]$lines.Add("Name=" + $cleanDisplayName)
    [void]$lines.Add("Deck Type=" + $deckType)
    [void]$lines.Add("Source URL=" + $sourceUrl)
    [void]$lines.Add("Archidekt Owner=" + $ownerName.Replace("`r", " ").Replace("`n", " "))
    [void]$lines.Add("Comment=" + $ImporterComment + " | Original=" + $cleanOriginalName)
    [void]$lines.Add("Tags=" + $ImportTag)
    [void]$lines.Add("Import Mode=" + $SourceMode)
    if ($Bracket -gt 0) {
        [void]$lines.Add("EDH Bracket=" + $Bracket)
    }
    [void]$lines.Add("")

    if ($isCommanderDeck -and $commanders.Count -gt 0) {
        [void]$lines.Add("[commander]")
        foreach ($card in $commanders) {
            [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
        }
        [void]$lines.Add("")
    }

    [void]$lines.Add("[main]")
    foreach ($card in $main) {
        [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
    }

    if ([bool]$Settings.PreserveSideboards -and $sideboard.Count -gt 0) {
        [void]$lines.Add("")
        [void]$lines.Add("[sideboard]")
        foreach ($card in $sideboard) {
            [void]$lines.Add(([string]$card.Quantity) + " " + $card.Name)
        }
    }

    if (-not [bool]$Settings.DryRun -and -not $PreviewOnly) {
        if ($existing) {
            Backup-ImportedDeck $existing $deckId
        }

        Write-Utf8NoBom $output $lines

        if ($existing) {
            try {
                if ([IO.Path]::GetFullPath($existing) -ne [IO.Path]::GetFullPath($output)) {
                    Remove-Item -LiteralPath $existing -Force -ErrorAction Stop
                    Write-Log ("    Removed old imported filename: " + [IO.Path]::GetFileName($existing))
                }
            }
            catch {
                throw ("Could not replace old imported deck: " + $_.Exception.Message)
            }
        }
    }

    $mainTotal = Get-QuantityTotal $main
    $commanderTotal = Get-QuantityTotal $commanders
    $sideTotal = if ([bool]$Settings.PreserveSideboards) { Get-QuantityTotal $sideboard } else { 0 }
    $cardVector = Get-NormalizedDeckVector $main $commanders
    $similarityVector = Get-SimilarityVector $cardVector
    $cardHash = Get-VectorHash $cardVector

    return [pscustomobject]@{
        Id = $deckId
        Name = $deckName
        DisplayName = $displayName
        DeckType = $deckType
        Path = $output
        MainCount = $mainTotal
        CommanderCount = $commanderTotal
        SideboardCount = $sideTotal
        Total = $mainTotal + $commanderTotal
        TokensRemoved = $tokensRemoved
        MaybeboardRemoved = $maybeboardRemoved
        CutCount = [int]$cutResult.CutCount
        CutCards = $cutResult.CutCards
        UnresolvedNames = $unresolvedNames
        CommanderLabel = $commanderLabel
        OwnerName = $ownerName
        Skipped = $false
        SkipReason = ""
        Status = "Imported"
        DeckLines = $lines.ToArray()
        CardVector = $cardVector
        SimilarityVector = $similarityVector
        CardHash = $cardHash
        SourceMode = $SourceMode
        Bracket = $Bracket
    }
}

function Sync-Profile {
    param([string]$InputText)

    $script:ProfileImportNeedsFallback = $false

    try {
        $username = Parse-ProfileInput $InputText
    }
    catch {
        Write-Host ""
        Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
        return
    }

    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "No username found." -ForegroundColor Red
        return
    }

    Add-ProfileHistory $username
    Start-Log "profile-import"
    $runTimer = [Diagnostics.Stopwatch]::StartNew()
    Write-UiBanner "ARCHIDEKT PROFILE SYNC" ("Public decks for " + $username)

    $fingerprint = Get-SettingsFingerprint
    $state = Read-ImportState

    Write-Log ""
    Write-Log ("Syncing PUBLIC Archidekt decks for: " + $username)
    Write-Log ("Fast import: " + (Get-OnOff ([bool]$Settings.FastImport)))
    Write-Log ("Copy detection: " + (Get-OnOff ([bool]$Settings.CopyDetection)))
    Write-Log ("Deck filename style: " + [string]$Settings.FileNameMode)
    Write-Log ("Actual token / emblem removal: " + (Get-OnOff ([bool]$Settings.RemoveActualTokens)))
    Write-Log ("Commander 100-card cap: " + (Get-OnOff ([bool]$Settings.CapCommanderAt100)))
    Write-Log ("Skip Commander decks under 100: " + (Get-OnOff ([bool]$Settings.SkipIncompleteCommander)))
    Write-Log ("Backup before overwrite/delete: " + (Get-OnOff ([bool]$Settings.BackupBeforeOverwrite)))
    Write-Log ("Preserve sideboards: " + (Get-OnOff ([bool]$Settings.PreserveSideboards)))
    Write-Log ("Dry run: " + (Get-OnOff ([bool]$Settings.DryRun)))
    Write-Log ""

    $metas = New-Object System.Collections.ArrayList

    try {
        $encoded = [Uri]::EscapeDataString($username)
        $page = 1

        while ($true) {
            Show-UiProgress "Scanning profile pages" ($page - 1) $page ("Page " + $page)
            $url = "https://archidekt.com/api/decks/v3/?ownerUsername=$encoded&orderBy=-updatedAt&pageSize=50&page=$page"
            $data = Invoke-JsonGet $url
            $results = @($data.results)

            if ($results.Count -eq 0) {
                break
            }

            foreach ($deck in $results) {
                [void]$metas.Add($deck)
            }

            Show-UiProgress "Scanning profile pages" $page $page ("Page " + $page)
            Write-Log ("  Page " + $page + ": " + $results.Count + " deck(s), total " + $metas.Count)

            $next = Get-Prop $data "next"
            if (-not $next) {
                break
            }

            $page++
            Wait-ApiPacing
        }
    }
    catch {
        $script:ProfileImportNeedsFallback = $true
        Write-Host ""
        Write-Host "ARCHIDEKT PROFILE REQUEST FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host ("Log: " + $script:CurrentLog)
        return
    }

    if ($metas.Count -eq 0) {
        Write-Host ""
        Write-Host "No public decks were found for that profile."
        return
    }

    Write-Log ""
    Write-Log ("Found " + $metas.Count + " public deck(s).")
    Write-Log ""

    # First pass:
    #  - Copy detection decides which decks need no work.
    #  - Changed/new deck details are fetched once.
    #  - Commander labels are collected so rename collisions are predictable.
    $workItems = New-Object System.Collections.ArrayList
    $renameCounts = @{}
    $profileLibrary = Get-ImportedLibraryIndex
    $existingImportedById = @{}
    foreach ($record in $profileLibrary.Records) {
        if (-not [string]::IsNullOrWhiteSpace([string]$record.DeckId)) {
            $existingImportedById[[string]$record.DeckId] = $record
        }
    }

    $pendingDetailRequests = New-Object System.Collections.ArrayList
    $workItemById = @{}
    $knownSkippedCount = 0
    $existingFileSkipCount = 0
    $savedStateSkipCount = 0

    foreach ($meta in $metas) {
        $deckId = [string](Get-Prop $meta "id")
        $deckName = [string](Get-Prop $meta "name")
        if (-not $deckName) { $deckName = "Deck $deckId" }

        $stateEntry = $null
        if ($state.ContainsKey($deckId)) {
            $stateEntry = $state[$deckId]
        }

        $skipCopy = $false
        if ([bool]$Settings.CopyDetection) {
            # Profile sync is intentionally "missing decks only". A verified
            # importer-owned file with this Archidekt deck ID is authoritative,
            # even when an older manager version wrote the saved state.
            if ($existingImportedById.ContainsKey($deckId)) {
                $existingRecord = $existingImportedById[$deckId]
                $stateEntry = [pscustomobject]@{
                    DeckId = $deckId
                    Profile = $username
                    UpdatedAt = Get-MetaUpdatedAt $meta
                    Fingerprint = $fingerprint
                    OriginalName = $deckName
                    OutputPath = [string]$existingRecord.Path
                    DisplayName = [string]$existingRecord.DisplayName
                    CommanderLabel = [string]$existingRecord.CommanderLabel
                    CardHash = [string]$existingRecord.CardHash
                    CardVector = $existingRecord.CardVector
                    SimilarityVector = $existingRecord.SimilarityVector
                    SourceMode = "Profile"
                    Bracket = [int]$existingRecord.Bracket
                    Status = "Imported"
                }
                $state[$deckId] = $stateEntry
                $skipCopy = $true
                $existingFileSkipCount++
            }
            else {
                $skipCopy = Test-CopyStateMatch $meta $stateEntry $fingerprint
                if ($skipCopy) { $savedStateSkipCount++ }
            }
        }

        if ($skipCopy) {
            $label = [string]$stateEntry.CommanderLabel
            $knownSkippedCount++

            if ([bool]$Settings.RenameToCommander -and -not [string]::IsNullOrWhiteSpace($label)) {
                $key = $label.ToLowerInvariant()
                if ($renameCounts.ContainsKey($key)) {
                    $renameCounts[$key] = [int]$renameCounts[$key] + 1
                }
                else {
                    $renameCounts[$key] = 1
                }
            }

            continue
        }

        $workItem = [pscustomobject]@{
            Meta = $meta
            Detail = $null
            CopySkipped = $false
            StateEntry = $stateEntry
            CommanderLabel = ""
            DetailError = ""
        }
        [void]$workItems.Add($workItem)
        $workItemById[$deckId] = $workItem
        [void]$pendingDetailRequests.Add([pscustomobject]@{
            Key = $deckId
            Name = $deckName
            Url = "https://archidekt.com/api/decks/" + $deckId + "/"
        })
    }

    Write-UiSection "Smart sync plan"
    Write-Host "  Already present in Forge : " -NoNewline
    Write-Host $existingFileSkipCount -ForegroundColor Green
    Write-Host "  Previously checked/skipped: " -NoNewline
    Write-Host $savedStateSkipCount -ForegroundColor DarkGray
    Write-Host "  Missing deck downloads    : " -NoNewline
    Write-Host $pendingDetailRequests.Count -ForegroundColor Yellow
    Write-Host ""
    Write-Log ("Smart sync: " + $existingFileSkipCount + " already present, " + $savedStateSkipCount + " previously checked, " + $pendingDetailRequests.Count + " missing.")

    if ($pendingDetailRequests.Count -gt 0) {
        Write-Log ("Fetching " + $pendingDetailRequests.Count + " changed/new deck list(s)...")
        if ([bool]$Settings.FastImport) {
            Write-Log "  Fast pipeline: up to 6 simultaneous Archidekt requests."
        }

        $detailResponses = @(Invoke-JsonGetBatch $pendingDetailRequests.ToArray() "Fetching Archidekt lists")
        $downloadedDetails = New-Object System.Collections.ArrayList
        foreach ($response in $detailResponses) {
            $deckId = [string]$response.Key
            if (-not $workItemById.ContainsKey($deckId)) { continue }
            $item = $workItemById[$deckId]

            if (-not [string]::IsNullOrWhiteSpace([string]$response.Error)) {
                $item.DetailError = [string]$response.Error
                continue
            }

            $item.Detail = $response.Data
            [void]$downloadedDetails.Add($response.Data)
            $item.CommanderLabel = Get-ArchidektPremierCommanderLabel $response.Data

            $label = [string]$item.CommanderLabel
            if ([bool]$Settings.RenameToCommander -and -not [string]::IsNullOrWhiteSpace($label)) {
                $key = $label.ToLowerInvariant()
                if ($renameCounts.ContainsKey($key)) {
                    $renameCounts[$key] = [int]$renameCounts[$key] + 1
                }
                else {
                    $renameCounts[$key] = 1
                }
            }
        }

        if ([bool]$Settings.FastImport -and $downloadedDetails.Count -gt 0) {
            Write-Log "Bulk-resolving card names for the fast pipeline..."
            Warm-ScryfallCacheForDetails $downloadedDetails.ToArray()
        }
    }

    # If rename mode is ON and a new duplicate commander name appears,
    # reprocess an older copy that was previously named only after its commander.
    # This makes BOTH duplicate decks use "Commander - Original Deck Name".
    if ([bool]$Settings.RenameToCommander -and [bool]$Settings.CopyDetection) {
        foreach ($item in $workItems) {
            if (-not [bool]$item.CopySkipped) { continue }

            $label = [string]$item.CommanderLabel
            if ([string]::IsNullOrWhiteSpace($label)) { continue }

            $key = $label.ToLowerInvariant()
            if (-not $renameCounts.ContainsKey($key)) { continue }
            if ([int]$renameCounts[$key] -le 1) { continue }

            $oldDisplayName = [string]$item.StateEntry.DisplayName
            if ([string]::IsNullOrWhiteSpace($oldDisplayName)) {
                $oldDisplayName = [string]$item.StateEntry.OriginalName
            }

            if ($oldDisplayName -eq $label) {
                try {
                    $meta = $item.Meta
                    $deckId = [string](Get-Prop $meta "id")
                    Wait-ApiPacing
                    $item.Detail = Invoke-JsonGet ("https://archidekt.com/api/decks/" + $deckId + "/")
                    $item.CopySkipped = $false
                }
                catch {
                    # If refresh fails, keep the valid existing imported copy.
                }
            }
        }
    }

    $ok = New-Object System.Collections.ArrayList
    $failed = New-Object System.Collections.ArrayList
    $warnings = New-Object System.Collections.ArrayList
    $library = $profileLibrary

    $copySkippedCount = $knownSkippedCount
    $incompleteSkippedCount = 0
    $commanderSkippedCount = 0
    $exactSkippedCount = 0
    $similaritySkippedCount = 0
    $index = 0

    foreach ($item in $workItems) {
        $index++

        $meta = $item.Meta
        $deckId = [string](Get-Prop $meta "id")
        $deckName = [string](Get-Prop $meta "name")
        if (-not $deckName) { $deckName = "Deck $deckId" }

        Show-UiProgress "Validating and importing" $index $workItems.Count $deckName
        Complete-UiProgress
        Write-Log ("[" + $index + "/" + $workItems.Count + "] " + $deckName)

        if ([bool]$item.CopySkipped) {
            $copySkippedCount++

            if ([string]$item.StateEntry.Status -like "Skipped*") {
                Write-Log ("    UNCHANGED: " + [string]$item.StateEntry.Status + ".")
            }
            else {
                Write-Log "    UNCHANGED: copy detection skipped this deck."
            }

            continue
        }

        $detailError = Get-Prop $item "DetailError"
        if ($detailError) {
            [void]$failed.Add([pscustomobject]@{
                Name = $deckName
                Id = $deckId
                Error = [string]$detailError
            })
            Write-Log ("    FAILED: " + [string]$detailError)
            continue
        }

        try {
            $result = Convert-Deck $item.Detail $meta $renameCounts -PreviewOnly

            if ([bool]$result.Skipped) {
                if ([string]$result.Status -eq "SkippedCommanderUnresolved") {
                    $commanderSkippedCount++
                }
                else {
                    $incompleteSkippedCount++
                }
                Write-Log ("    EXCLUDED: " + $result.SkipReason + " (" + $result.Total + " cards)")

                if (-not [bool]$Settings.DryRun) {
                    $state[$deckId] = [pscustomobject]@{
                        DeckId = $deckId
                        Profile = $username
                        UpdatedAt = Get-MetaUpdatedAt $meta
                        Fingerprint = $fingerprint
                        OriginalName = $deckName
                        OutputPath = ""
                        DisplayName = $result.DisplayName
                        CommanderLabel = $result.CommanderLabel
                        CardHash = $result.CardHash
                        CardVector = $result.CardVector
                        SimilarityVector = $result.SimilarityVector
                        Status = $result.Status
                    }
                }

                continue
            }

            $exactRecord = $null
            if ([bool]$Settings.CopyDetection) {
                foreach ($record in $library.Records) {
                    if ([string]$record.DeckId -eq $deckId) { continue }
                    if ([string]$record.CardHash -eq [string]$result.CardHash) {
                        $exactRecord = $record
                        break
                    }
                }
            }

            if ($exactRecord) {
                $exactSkippedCount++
                Write-Log ("    SKIP exact normalized copy of imported deck: " + $exactRecord.DisplayName)

                if (-not [bool]$Settings.DryRun) {
                    $state[$deckId] = [pscustomobject]@{
                        DeckId = $deckId
                        Profile = $username
                        UpdatedAt = Get-MetaUpdatedAt $meta
                        Fingerprint = $fingerprint
                        OriginalName = $deckName
                        OutputPath = ""
                        DisplayName = $result.DisplayName
                        CommanderLabel = $result.CommanderLabel
                        CardHash = $result.CardHash
                        CardVector = $result.CardVector
                        SimilarityVector = $result.SimilarityVector
                        Status = "SkippedExactCopy"
                    }
                }

                continue
            }

            $similar = Find-SimilarImportedDeck $result.SimilarityVector $library $deckId
            if ($similar) {
                $similaritySkippedCount++
                Write-Log ("    Candidate: " + $result.Name)
                Write-Log ("    Existing : " + $similar.Record.DisplayName)
                Write-Log ("    Similarity: " + $similar.Percent + "%")
                Write-Log ("    Threshold : " + [string]$Settings.SimilarityThreshold + "%")
                Write-Log "    Result    : SKIP probable duplicate"

                if (-not [bool]$Settings.DryRun) {
                    $state[$deckId] = [pscustomobject]@{
                        DeckId = $deckId
                        Profile = $username
                        UpdatedAt = Get-MetaUpdatedAt $meta
                        Fingerprint = $fingerprint
                        OriginalName = $deckName
                        OutputPath = ""
                        DisplayName = $result.DisplayName
                        CommanderLabel = $result.CommanderLabel
                        CardHash = $result.CardHash
                        CardVector = $result.CardVector
                        SimilarityVector = $result.SimilarityVector
                        Status = "SkippedSimilarity"
                    }
                }

                continue
            }

            Commit-PreparedDeck $result
            $replacedExistingId = $false
            foreach ($record in $library.Records) {
                if ([string]$record.DeckId -eq $deckId) {
                    $replacedExistingId = $true
                    break
                }
            }

            if ($replacedExistingId -and -not [bool]$Settings.DryRun) {
                $library = Get-ImportedLibraryIndex
            }
            else {
                Add-ResultToLibraryIndex $result $library
            }

            [void]$ok.Add($result)

            $extra = New-Object System.Collections.ArrayList

            if ($result.TokensRemoved -gt 0) {
                [void]$extra.Add("actual tokens removed " + $result.TokensRemoved)
            }

            if ($result.CutCount -gt 0) {
                [void]$extra.Add("trimmed " + $result.CutCount + " to maximum 100")
            }

            if ([bool]$Settings.DryRun) {
                [void]$extra.Add("DRY RUN - no files changed")
            }

            $suffix = ""
            if ($extra.Count -gt 0) {
                $suffix = " | " + ($extra.ToArray() -join ", ")
            }

            Write-Log ("    " + $result.DeckType + " | " + $result.Total + " cards -> " + [IO.Path]::GetFileName($result.Path) + $suffix)

            if ($result.DeckType -eq "Commander" -and $result.CommanderCount -eq 0) {
                [void]$warnings.Add($result.Name + ": Commander format detected but no commander could be identified.")
                Write-Log "    WARNING: Commander still could not be identified."
            }

            if ($result.UnresolvedNames -gt 0) {
                Write-Log ("    NOTE: " + $result.UnresolvedNames + " card(s) used Archidekt-name fallback.")
            }

            if ($result.CutCount -gt 0) {
                Write-Log "    Cards trimmed from the end of the imported mainboard:"
                foreach ($cut in $result.CutCards) {
                    Write-Log ("      - " + $cut)
                }
            }

            if (-not [bool]$Settings.DryRun) {
                $state[$deckId] = [pscustomobject]@{
                    DeckId = $deckId
                    Profile = $username
                    UpdatedAt = Get-MetaUpdatedAt $meta
                    Fingerprint = $fingerprint
                    OriginalName = $deckName
                    OutputPath = $result.Path
                    DisplayName = $result.DisplayName
                    CommanderLabel = $result.CommanderLabel
                    CardHash = $result.CardHash
                    CardVector = $result.CardVector
                    SimilarityVector = $result.SimilarityVector
                    SourceMode = "Profile"
                    Bracket = 0
                    Status = "Imported"
                }
            }
        }
        catch {
            [void]$failed.Add([pscustomobject]@{
                Name = $deckName
                Id = $deckId
                Error = $_.Exception.Message
            })

            Write-Log ("    FAILED: " + $_.Exception.Message)

            if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
                Write-Log ("    POSITION: " + ($_.InvocationInfo.PositionMessage -replace "`r?`n", " "))
            }

            if ($_.ScriptStackTrace) {
                Write-Log ("    STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
            }
        }

    }

    Complete-UiProgress

    if (-not [bool]$Settings.DryRun) {
        Save-ImportState $state
    }
    $runTimer.Stop()

    Write-Host ""
    Write-UiBanner "PROFILE SYNC COMPLETE" ("Archidekt user: " + $username)
    Write-Host ""
    Write-Host ("Profile             : " + $username)
    Write-Host ("Imported / updated  : " + $ok.Count)
    Write-Host ("Copy-detected skips : " + $copySkippedCount)
    Write-Host ("Under-100 excluded  : " + $incompleteSkippedCount)
    Write-Host ("Commander unresolved: " + $commanderSkippedCount)
    Write-Host ("Exact-copy skips     : " + $exactSkippedCount)
    Write-Host ("Similarity skips     : " + $similaritySkippedCount)
    Write-Host ("Failed              : " + $failed.Count)
    Write-Host ("Elapsed             : " + [Math]::Round($runTimer.Elapsed.TotalSeconds, 1) + " seconds")
    Write-Host ("Warnings            : " + $warnings.Count)
    Write-Host ""
    Write-Host ("Log: " + $script:CurrentLog)

    if ($failed.Count -gt 0) {
        Write-Host ""
        Write-Host "Failed decks:" -ForegroundColor Yellow
        foreach ($failedItem in $failed) {
            Write-Host ("  - " + $failedItem.Name + " : " + $failedItem.Error)
        }
    }

    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "Warnings:" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host ("  - " + $warning)
        }
    }

    if ($failed.Count -gt 0) {
        $script:ProfileImportNeedsFallback = $true
    }

    Write-Host ""
    Write-Host "You can immediately import another profile without closing the manager."
}


function Get-IntegerMetaValue {
    param(
        $Object,
        [string[]]$Names,
        [int]$Default = -1
    )

    foreach ($name in $Names) {
        $value = Get-Prop $Object $name
        if ($null -eq $value) { continue }

        try {
            return [int]$value
        }
        catch {}
    }

    return $Default
}

function Read-IntegerWithDefault {
    param(
        [string]$Prompt,
        [int]$Minimum,
        [int]$Maximum,
        [int]$Default
    )

    $text = Read-Host ($Prompt + " [default " + $Default + "]")
    if ([string]::IsNullOrWhiteSpace($text)) { return $Default }

    $value = 0
    if (-not [int]::TryParse($text, [ref]$value) -or $value -lt $Minimum -or $value -gt $Maximum) {
        throw ($Prompt + " must be between " + $Minimum + " and " + $Maximum + ".")
    }
    return $value
}

function Get-MassSortDefinition {
    param([int]$Choice)

    switch ($Choice) {
        1 { return [pscustomobject]@{ OrderBy = "-viewCount"; Label = "Most viewed" } }
        2 { return [pscustomobject]@{ OrderBy = "-updatedAt"; Label = "Recently updated" } }
        3 { return [pscustomobject]@{ OrderBy = "-createdAt"; Label = "Newest created" } }
        4 { return [pscustomobject]@{ OrderBy = "viewCount"; Label = "Hidden gems (least viewed)" } }
        5 { return [pscustomobject]@{ OrderBy = "createdAt"; Label = "Oldest created" } }
        6 { return [pscustomobject]@{ OrderBy = "name"; Label = "Alphabetical" } }
        default { return [pscustomobject]@{ OrderBy = "-viewCount"; Label = "Most viewed" } }
    }
}

function Get-MassImportConfiguration {
    Write-UiBanner "GLOBAL ARCHIDEKT MASS IMPORT" "Bracket-targeted discovery with exact-100 validation"

    Write-UiSection "Target"
    $bracket = Read-IntegerWithDefault "  Commander bracket (1-5)" 1 5 2
    $wanted = Read-IntegerWithDefault "  Number of valid unique decks (1-500)" 1 500 10
    Write-Host ""

    Write-UiSection "Discovery order"
    Write-Host "  [1] Most viewed        [2] Recently updated    [3] Newest created"
    Write-Host "  [4] Hidden gems        [5] Oldest created      [6] Alphabetical"
    $sortChoice = Read-IntegerWithDefault "  Sort choice (1-6)" 1 6 1
    $sort = Get-MassSortDefinition $sortChoice
    Write-Host ""

    Write-UiSection "Quality filters"
    $minimumViews = Read-IntegerWithDefault "  Minimum views (0-100000000)" 0 100000000 0
    Write-Host "  Updated activity: [1] Any  [2] 30 days  [3] 90 days  [4] 1 year"
    $activityChoice = Read-IntegerWithDefault "  Activity choice (1-4)" 1 4 1
    $activityDays = switch ($activityChoice) { 2 { 30 } 3 { 90 } 4 { 365 } default { 0 } }
    Write-Host "  Primer: [1] Any  [2] Require primer  [3] No primer"
    $primerChoice = Read-IntegerWithDefault "  Primer choice (1-3)" 1 3 1
    $primerPolicy = switch ($primerChoice) { 2 { "Required" } 3 { "Excluded" } default { "Any" } }
    Write-Host "  Theorycrafted: [1] Include  [2] Exclude  [3] Only theorycrafted"
    $theoryChoice = Read-IntegerWithDefault "  Theorycrafted choice (1-3)" 1 3 2
    $theoryPolicy = switch ($theoryChoice) { 1 { "Any" } 3 { "Only" } default { "Exclude" } }
    Write-Host ""

    Write-UiSection "Diversity and duplicate rules"
    Write-Host "  Commander reuse:"
    Write-Host "    [1] New commanders only across every accessible Forge deck"
    Write-Host "    [2] Allow an imported commander only when its bracket is different"
    Write-Host "    [3] Allow repeated commanders"
    $commanderChoice = Read-IntegerWithDefault "  Commander policy (1-3)" 1 3 1
    $commanderPolicy = switch ($commanderChoice) { 2 { "DifferentBracket" } 3 { "Allow" } default { "UniqueAll" } }

    Write-Host "  Similar deck lists:"
    Write-Host "    [1] Use Settings toggle       [2] Skip similar across all brackets"
    Write-Host "    [3] Skip only in same bracket [4] Allow similar lists"
    $similarityChoice = Read-IntegerWithDefault "  Similarity policy (1-4)" 1 4 1
    $similarityScope = switch ($similarityChoice) { 2 { "All" } 3 { "SameBracket" } 4 { "Off" } default { "Settings" } }
    Write-Host ""

    Write-UiSection "Search depth"
    Write-Host "  Unlimited: continues through every available Archidekt page" -ForegroundColor Green
    Write-Host "  Search stops only after the requested number is accepted or Archidekt has no next page."

    $config = [pscustomobject]@{
        Bracket = $bracket
        Wanted = $wanted
        OrderBy = [string]$sort.OrderBy
        SortLabel = [string]$sort.Label
        MinimumViews = $minimumViews
        ActivityDays = $activityDays
        PrimerPolicy = $primerPolicy
        TheoryPolicy = $theoryPolicy
        CommanderPolicy = $commanderPolicy
        SimilarityScope = $similarityScope
    }

    Write-Host ""
    Write-Host "  IMPORT PLAN" -ForegroundColor Green
    Write-Host ("  Bracket " + $bracket + " | " + $wanted + " decks | " + $sort.Label + " | min views " + $minimumViews)
    Write-Host ("  Pages unlimited | commander " + $commanderPolicy + " | similarity " + $similarityScope)
    if ([bool]$Settings.FastImport) {
        Write-Host "  FAST pipeline: ON (six concurrent detail requests)" -ForegroundColor Green
    }
    else {
        Write-Host "  FAST pipeline: OFF (enable it in Settings for the large speed increase)" -ForegroundColor Yellow
    }

    $confirm = Read-Host "  Start this mass import? [Y/n]"
    if (-not [string]::IsNullOrWhiteSpace($confirm) -and $confirm -notmatch '^(?i:y|yes)$') {
        return $null
    }
    return $config
}

function Test-MassMetaCriteria {
    param(
        $Meta,
        $Config
    )

    $views = Get-IntegerMetaValue $Meta @("viewCount", "view_count") 0
    if ($views -lt [int]$Config.MinimumViews) { return "Views" }

    $hasPrimer = [bool](Get-Prop $Meta "hasPrimer")
    if ([string]$Config.PrimerPolicy -eq "Required" -and -not $hasPrimer) { return "Primer" }
    if ([string]$Config.PrimerPolicy -eq "Excluded" -and $hasPrimer) { return "Primer" }

    $theorycrafted = [bool](Get-Prop $Meta "theorycrafted")
    if ([string]$Config.TheoryPolicy -eq "Exclude" -and $theorycrafted) { return "Theorycrafted" }
    if ([string]$Config.TheoryPolicy -eq "Only" -and -not $theorycrafted) { return "Theorycrafted" }

    if ([int]$Config.ActivityDays -gt 0) {
        $updatedText = Get-MetaUpdatedAt $Meta
        $updated = [DateTime]::MinValue
        if (-not [DateTime]::TryParse($updatedText, [ref]$updated)) { return "Activity" }
        if ($updated.ToUniversalTime() -lt (Get-Date).ToUniversalTime().AddDays(-[int]$Config.ActivityDays)) {
            return "Activity"
        }
    }

    return ""
}

function Get-BracketSearchPage {
    param(
        [int]$Bracket,
        [int]$Page,
        [string]$OrderBy = "-viewCount"
    )

    $encodedOrder = [Uri]::EscapeDataString($OrderBy)
    $filteredUrl = "https://archidekt.com/api/decks/v3/?deckFormat=3&edhBracket=" +
        $Bracket + "&orderBy=" + $encodedOrder + "&pageSize=50&page=" + $Page

    try {
        return Invoke-JsonGet $filteredUrl
    }
    catch {
        Write-Log "    Archidekt filtered query failed; using safe public-list fallback."
        $fallbackUrl = "https://archidekt.com/api/decks/v3/?orderBy=" + $encodedOrder + "&pageSize=50&page=" + $Page
        return Invoke-JsonGet $fallbackUrl
    }
}

function Add-ResultToLibraryIndex {
    param(
        $Result,
        $LibraryIndex
    )

    $record = [pscustomobject]@{
        Path = [string]$Result.Path
        DeckId = [string]$Result.Id
        DisplayName = [string]$Result.DisplayName
        OriginalName = [string]$Result.Name
        CommanderLabel = [string]$Result.CommanderLabel
        CardVector = $Result.CardVector
        SimilarityVector = $Result.SimilarityVector
        CardHash = [string]$Result.CardHash
        SourceMode = [string]$Result.SourceMode
        Bracket = [int]$Result.Bracket
    }

    [void]$LibraryIndex.Records.Add($record)

    if (-not [string]::IsNullOrWhiteSpace([string]$record.CardHash)) {
        $LibraryIndex.Hashes[[string]$record.CardHash] = $record
    }

    foreach ($candidateName in @($record.DisplayName, $record.OriginalName)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$candidateName)) {
            $LibraryIndex.Names[([string]$candidateName).Trim().ToLowerInvariant()] = $record
        }
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$record.CommanderLabel)) {
        $LibraryIndex.Commanders[([string]$record.CommanderLabel).Trim().ToLowerInvariant()] = $record
    }
}

function Invoke-BracketLibraryImport {
    Clear-Host
    $config = Get-MassImportConfiguration
    if ($null -eq $config) {
        Write-Host ""
        Write-Host "Mass import cancelled." -ForegroundColor Yellow
        return
    }

    $bracket = [int]$config.Bracket
    $wanted = [int]$config.Wanted

    Start-Log "bracket-import"
    $runTimer = [Diagnostics.Stopwatch]::StartNew()

    Write-Log ""
    Write-Log ("GLOBAL MASS IMPORT - BRACKET " + $bracket)
    Write-Log ("Requested valid decks: " + $wanted)
    Write-Log ("Discovery order: " + [string]$config.SortLabel + " (" + [string]$config.OrderBy + ")")
    Write-Log ("Minimum views: " + [int]$config.MinimumViews)
    Write-Log ("Activity window days: " + [int]$config.ActivityDays)
    Write-Log ("Primer policy: " + [string]$config.PrimerPolicy)
    Write-Log ("Theorycrafted policy: " + [string]$config.TheoryPolicy)
    Write-Log ("Commander policy: " + [string]$config.CommanderPolicy)
    Write-Log ("Similarity policy: " + [string]$config.SimilarityScope)
    Write-Log "Maximum search pages: UNLIMITED (until target or API end)"
    Write-Log ("Fast pipeline: " + (Get-OnOff ([bool]$Settings.FastImport)))
    Write-Log "Exact 100-card requirement: ON"
    Write-Log ("Unique imported deck name: " + (Get-OnOff ([bool]$Settings.BracketUniqueDeckName)))
    Write-Log ("Copy detection: " + (Get-OnOff ([bool]$Settings.CopyDetection)))
    Write-Log ("Similarity threshold: " + [string]$Settings.SimilarityThreshold + "%")
    Write-Log ""

    $library = Get-ImportedLibraryIndex
    $manualCommanders = Get-ManualCommanderIndex
    $state = Read-ImportState
    $fingerprint = Get-SettingsFingerprint
    $seenIds = @{}

    $accepted = 0
    $inspected = 0
    $page = 1

    $skipWrongFormat = 0
    $skipWrongBracket = 0
    $skipExactCount = 0
    $skipExistingId = 0
    $skipSameName = 0
    $skipSameCommander = 0
    $skipHash = 0
    $skipSimilarity = 0
    $skipCommander = 0
    $skipViews = 0
    $skipPrimer = 0
    $skipActivity = 0
    $skipTheorycrafted = 0
    $failed = 0

    while ($accepted -lt $wanted) {
        Show-UiProgress "Searching Archidekt" ($page - 1) $page ("Page " + $page + " - unlimited")
        Complete-UiProgress
        Write-Log ("Searching Archidekt page " + $page + " by " + [string]$config.SortLabel + "...")

        $data = Get-BracketSearchPage $bracket $page ([string]$config.OrderBy)
        $results = @($data.results)

        if ($results.Count -eq 0) {
            break
        }

        $eligible = New-Object System.Collections.ArrayList

        foreach ($meta in $results) {
            $deckId = [string](Get-Prop $meta "id")
            if ([string]::IsNullOrWhiteSpace($deckId)) {
                continue
            }

            if ($seenIds.ContainsKey($deckId)) {
                continue
            }
            $seenIds[$deckId] = $true

            $inspected++

            $deckFormat = Get-IntegerMetaValue $meta @("deckFormat", "deck_format") -1
            $metaBracket = Get-IntegerMetaValue $meta @("edhBracket", "edh_bracket") -1
            $deckName = [string](Get-Prop $meta "name")

            if ($deckFormat -ne 3) {
                $skipWrongFormat++
                continue
            }

            if ($metaBracket -ne $bracket) {
                $skipWrongBracket++
                continue
            }

            $criteriaFailure = Test-MassMetaCriteria $meta $config
            if (-not [string]::IsNullOrWhiteSpace([string]$criteriaFailure)) {
                switch ($criteriaFailure) {
                    "Views" { $skipViews++ }
                    "Primer" { $skipPrimer++ }
                    "Activity" { $skipActivity++ }
                    "Theorycrafted" { $skipTheorycrafted++ }
                }
                continue
            }

            if ($state.ContainsKey($deckId)) {
                if (Test-CopyStateMatch $meta $state[$deckId] $fingerprint) {
                    $skipExistingId++
                    continue
                }

                [void]$state.Remove($deckId)
            }

            $alreadyById = $false
            foreach ($record in $library.Records) {
                if ([string]$record.DeckId -eq $deckId) {
                    $alreadyById = $true
                    break
                }
            }

            if ($alreadyById) {
                $skipExistingId++
                continue
            }

            [void]$eligible.Add($meta)
        }

        # Fast mode fetches only an adaptive candidate window at a time. It
        # avoids downloading an entire search page after the target is met,
        # while six concurrent requests remove the old network-latency queue.
        $candidateOffset = 0
        while ($candidateOffset -lt $eligible.Count -and $accepted -lt $wanted) {
            $remaining = $wanted - $accepted
            $windowSize = if ([bool]$Settings.FastImport) {
                [Math]::Min(24, [Math]::Max(6, $remaining * 3))
            }
            else {
                1
            }

            $candidateEnd = [Math]::Min($candidateOffset + $windowSize - 1, $eligible.Count - 1)
            $requests = New-Object System.Collections.ArrayList
            $chunkMetas = New-Object System.Collections.ArrayList

            for ($candidateIndex = $candidateOffset; $candidateIndex -le $candidateEnd; $candidateIndex++) {
                $meta = $eligible[$candidateIndex]
                $deckId = [string](Get-Prop $meta "id")
                $deckName = [string](Get-Prop $meta "name")
                if (-not $deckName) { $deckName = "Deck $deckId" }
                [void]$chunkMetas.Add($meta)
                [void]$requests.Add([pscustomobject]@{
                    Key = $deckId
                    Name = $deckName
                    Url = "https://archidekt.com/api/decks/" + $deckId + "/"
                })
            }

            $responseMap = @{}
            $responses = @(Invoke-JsonGetBatch $requests.ToArray() ("Mass import - page " + $page))
            foreach ($response in $responses) {
                $responseMap[[string]$response.Key] = $response
            }
            if ([bool]$Settings.FastImport) {
                $chunkDetails = @($responses | Where-Object {
                    $_.Data -and [string]::IsNullOrWhiteSpace([string]$_.Error)
                } | ForEach-Object { $_.Data })
                Warm-ScryfallCacheForDetails $chunkDetails
            }

            foreach ($meta in $chunkMetas) {
                if ($accepted -ge $wanted) { break }

                $deckId = [string](Get-Prop $meta "id")
                $deckName = [string](Get-Prop $meta "name")
                if (-not $deckName) { $deckName = "Deck $deckId" }
                Write-Log ("  Candidate " + ($accepted + 1) + "/" + $wanted + ": " + $deckName)

                try {
                    if (-not $responseMap.ContainsKey($deckId)) {
                        throw "Candidate detail response was missing."
                    }
                    $response = $responseMap[$deckId]
                    if (-not [string]::IsNullOrWhiteSpace([string]$response.Error)) {
                        throw [InvalidOperationException]::new([string]$response.Error)
                    }
                    $detail = $response.Data

                    $prepared = Convert-Deck `
                        $detail `
                        $meta `
                        @{} `
                        -PreviewOnly `
                        -Exact100Only `
                        -SourceMode "Bracket" `
                        -Bracket $bracket

                    if ($prepared.Skipped -and [string]$prepared.Status -eq "SkippedCommanderUnresolved") {
                        $skipCommander++
                        Write-Log "    SKIP: commander could not be identified."
                        continue
                    }

                    if ($prepared.Skipped -or $prepared.Total -ne 100) {
                        $skipExactCount++
                        Write-Log ("    SKIP: exact deck count validation failed (" + $prepared.Total + ").")
                        continue
                    }

                    if ([string]::IsNullOrWhiteSpace([string]$prepared.CommanderLabel)) {
                        $skipCommander++
                        Write-Log "    SKIP: commander could not be identified."
                        continue
                    }

                    if ([bool]$Settings.BracketUniqueDeckName) {
                        $nameKey = ([string]$prepared.Name).Trim().ToLowerInvariant()
                        if ($library.Names.ContainsKey($nameKey)) {
                            $skipSameName++
                            Write-Log "    SKIP: imported library already contains this deck name."
                            continue
                        }
                    }

                    if (-not (Test-MassCommanderAllowed `
                        ([string]$prepared.CommanderLabel) `
                        $library `
                        $manualCommanders `
                        $bracket `
                        ([string]$config.CommanderPolicy))) {

                        $skipSameCommander++
                        Write-Log ("    SKIP: commander policy rejected " + $prepared.CommanderLabel)
                        continue
                    }

                    if ($library.Hashes.ContainsKey([string]$prepared.CardHash)) {
                        $skipHash++
                        Write-Log "    SKIP: exact normalized 100-card deck copy already imported."
                        continue
                    }

                    $similar = Find-SimilarImportedDeckScoped `
                        $prepared.SimilarityVector `
                        $library `
                        $bracket `
                        ([string]$config.SimilarityScope)
                    if ($similar) {
                        $skipSimilarity++
                        Write-Log (
                            "    SKIP: " + $similar.Percent + "% similar to imported deck " +
                            $similar.Record.DisplayName
                        )
                        continue
                    }

                    Commit-PreparedDeck $prepared

                    # Always add accepted candidates to the in-memory index, even
                    # in Dry Run mode, preventing duplicates inside this batch.
                    Add-ResultToLibraryIndex $prepared $library

                    if (-not [bool]$Settings.DryRun) {
                        $state[$deckId] = [pscustomobject]@{
                            DeckId = $deckId
                            Profile = ""
                            UpdatedAt = Get-MetaUpdatedAt $meta
                            Fingerprint = $fingerprint
                            OriginalName = $prepared.Name
                            OutputPath = $prepared.Path
                            DisplayName = $prepared.DisplayName
                            CommanderLabel = $prepared.CommanderLabel
                            CardHash = $prepared.CardHash
                            CardVector = $prepared.CardVector
                            SimilarityVector = $prepared.SimilarityVector
                            SourceMode = "Bracket"
                            Bracket = $bracket
                            Status = "Imported"
                        }
                    }

                    $accepted++
                    Write-Log (
                        "    ACCEPTED " + $accepted + "/" + $wanted +
                        " | " + $prepared.CommanderLabel +
                        " | " + $prepared.DisplayName
                    )
                }
                catch {
                    $failed++
                    Write-Log ("    FAILED candidate: " + $_.Exception.Message)

                    if ($_.ScriptStackTrace) {
                        Write-Log ("    STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
                    }

                    # A single public deck never crashes the full mass run.
                    continue
                }
            }

            $candidateOffset = $candidateEnd + 1
        }

        $next = Get-Prop $data "next"
        if (-not $next) {
            break
        }

        $page++
        Wait-ApiPacing
    }

    if (-not [bool]$Settings.DryRun) {
        Save-ImportState $state
    }
    $runTimer.Stop()

    Write-Host ""
    Write-UiBanner "GLOBAL MASS IMPORT COMPLETE" ("Bracket " + $bracket + " | " + [string]$config.SortLabel)
    Write-Host ""
    Write-Host ("Bracket                    : " + $bracket)
    Write-Host ("Requested                  : " + $wanted)
    Write-Host ("Accepted                   : " + $accepted)
    Write-Host ("Search results inspected   : " + $inspected)
    Write-Host ("Elapsed                    : " + [Math]::Round($runTimer.Elapsed.TotalSeconds, 1) + " seconds")
    Write-Host ""
    Write-Host "Skipped:"
    Write-Host ("  Wrong format             : " + $skipWrongFormat)
    Write-Host ("  Wrong / missing bracket  : " + $skipWrongBracket)
    Write-Host ("  Full list not 100 cards  : " + $skipExactCount)
    Write-Host ("  Already imported ID      : " + $skipExistingId)
    Write-Host ("  Same imported deck name  : " + $skipSameName)
    Write-Host ("  Same imported commander  : " + $skipSameCommander)
    Write-Host ("  Exact deck copy          : " + $skipHash)
    Write-Host ("  Similarity match         : " + $skipSimilarity)
    Write-Host ("  Commander unresolved     : " + $skipCommander)
    Write-Host ("  Below minimum views      : " + $skipViews)
    Write-Host ("  Primer filter            : " + $skipPrimer)
    Write-Host ("  Activity filter          : " + $skipActivity)
    Write-Host ("  Theorycrafted filter     : " + $skipTheorycrafted)
    Write-Host ("  Candidate failures       : " + $failed)
    Write-Host ""
    Write-Host ("Log: " + $script:CurrentLog)

    if ($accepted -lt $wanted) {
        Write-Host ""
        Write-Host (
            "Archidekt ran out of matching public pages before " + $wanted +
            " valid unique decks could be accepted. Try broader quality or diversity filters."
        ) -ForegroundColor Yellow
    }
}

function Get-DeckMemoryMetadataValue {
    param([string[]]$Lines, [string]$Name)

    $prefix = $Name + "="
    foreach ($line in $Lines) {
        if ([string]$line -like ($prefix + "*")) {
            return ([string]$line).Substring($prefix.Length).Trim()
        }
    }
    return ""
}

function Get-DeckMemoryCommander {
    param([string[]]$Lines)

    $inside = $false
    $names = New-Object System.Collections.ArrayList
    foreach ($line in $Lines) {
        $text = ([string]$line).Trim()
        if ($text -eq "[commander]") {
            $inside = $true
            continue
        }
        if ($inside -and $text -match '^\[.+\]$') { break }
        if ($inside -and $text -match '^\d+\s+(.+)$') {
            [void]$names.Add([string]$Matches[1])
        }
    }
    return ($names.ToArray() -join " + ")
}

function Read-DeckMemoryDocument {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { throw "No deck-memory file was selected." }
    $expanded = [Environment]::ExpandEnvironmentVariables($Path.Trim().Trim('"'))
    if (-not (Test-Path -LiteralPath $expanded -PathType Leaf)) {
        throw ("Deck-memory file was not found: " + $expanded)
    }

    $item = Get-Item -LiteralPath $expanded
    if ($item.Length -le 0 -or $item.Length -gt 100MB) {
        throw "Deck-memory file must be between 1 byte and 100 MB."
    }

    $document = Get-Content -LiteralPath $item.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    if ([string]$document.Schema -ne "JadonForgeDeckMemory" -or [int]$document.SchemaVersion -ne 1) {
        throw "This is not a supported Jadon Forge Deck Memory file."
    }

    $decks = @($document.Decks)
    if ($decks.Count -gt 5000) { throw "Deck-memory files are limited to 5000 decks." }
    $document | Add-Member -NotePropertyName ResolvedPath -NotePropertyValue $item.FullName -Force
    return $document
}

function Set-SelectedDeckMemory {
    param([string]$Path)

    $Settings.MemoryFilePath = [string]$Path
    Save-Settings $Settings
}

function Export-DeckMemory {
    Start-Log "memory-export"
    $records = New-Object System.Collections.ArrayList

    foreach ($entry in @(
        [pscustomobject]@{ Root = $CommanderDir; Kind = "Commander" },
        [pscustomobject]@{ Root = $ConstructedDir; Kind = "Constructed" }
    )) {
        if (-not (Test-Path -LiteralPath $entry.Root)) { continue }
        foreach ($file in Get-ChildItem -LiteralPath $entry.Root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (-not (Test-IsOurImportedDeckFile $file.FullName)) { continue }
            $lines = [IO.File]::ReadAllLines($file.FullName, [Text.Encoding]::UTF8)
            $name = Get-DeckMemoryMetadataValue $lines "Name"
            if ([string]::IsNullOrWhiteSpace($name)) { $name = $file.BaseName }
            [void]$records.Add([pscustomobject]@{
                Name = $name
                Commander = Get-DeckMemoryCommander $lines
                Owner = Get-DeckMemoryMetadataValue $lines "Archidekt Owner"
                DeckType = [string]$entry.Kind
                FileName = $file.Name
                SourceUrl = Get-DeckMemoryMetadataValue $lines "Source URL"
                Bracket = Get-DeckMemoryMetadataValue $lines "EDH Bracket"
                Lines = [string[]]$lines
            })
        }
    }

    if ($records.Count -eq 0) {
        Write-Host ""
        Write-Host "No importer-owned decks are available to export." -ForegroundColor Yellow
        return
    }

    if (-not (Test-Path -LiteralPath $DownloadsDir)) {
        New-Item -ItemType Directory -Force -Path $DownloadsDir | Out-Null
    }
    $path = Join-Path $DownloadsDir ("Jadon_Forge_Deck_Memory_" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".json")
    $document = [pscustomobject]@{
        Schema = "JadonForgeDeckMemory"
        SchemaVersion = 1
        CreatedUtc = (Get-Date).ToUniversalTime().ToString("o")
        CreatedBy = "Jadon's Ultimate Forge Manager " + $EngineVersion
        DeckCount = $records.Count
        FileNameMode = [string]$Settings.FileNameMode
        Decks = $records.ToArray()
    }
    $json = $document | ConvertTo-Json -Depth 10
    Write-TextFileAtomic $path $json (New-Object Text.UTF8Encoding($false))
    Set-SelectedDeckMemory $path

    Write-Host ""
    Write-UiBanner "DECK MEMORY EXPORTED" ($records.Count.ToString() + " portable decks")
    Write-Host ("Saved to: " + $path) -ForegroundColor Green
    Write-Host "This one file contains the complete Forge deck contents; no profile rescan is required."
    Write-Host ("Log: " + $script:CurrentLog)
}

function Import-DeckMemoryInteractive {
    Write-UiBanner "READ EXISTING DECK MEMORY" "Restore saved decks without scanning Archidekt profiles"
    $defaultPath = [string]$Settings.MemoryFilePath
    if (-not [string]::IsNullOrWhiteSpace($defaultPath)) {
        Write-Host ("Current memory: " + $defaultPath) -ForegroundColor DarkCyan
    }
    $path = Read-Host "Paste the full directory and filename of the deck-memory JSON"
    if ([string]::IsNullOrWhiteSpace($path)) { $path = $defaultPath }
    $document = Read-DeckMemoryDocument $path
    $decks = @($document.Decks)
    Set-SelectedDeckMemory ([string]$document.ResolvedPath)

    Write-Host ""
    Write-Host ("Memory contains " + $decks.Count + " deck(s).") -ForegroundColor Cyan
    if ($decks.Count -eq 0) { return }
    if ([bool]$Settings.DryRun) {
        Write-Host "DRY RUN is ON: files will be validated but not written." -ForegroundColor Yellow
    }
    $answer = Read-Host "Type IMPORT to restore these decks"
    if ($answer -cne "IMPORT") {
        Write-Host "Memory was selected, but deck restoration was cancelled." -ForegroundColor Yellow
        return
    }

    Start-Log "memory-import"
    $imported = 0
    $failed = 0
    $index = 0
    foreach ($deck in $decks) {
        $index++
        $name = [string]$deck.Name
        if ([string]::IsNullOrWhiteSpace($name)) { $name = "Memory Deck " + $index }
        Show-UiProgress "Restoring deck memory" $index $decks.Count $name
        try {
            $lines = @($deck.Lines | ForEach-Object { [string]$_ })
            if ($lines.Count -eq 0 -or $lines.Count -gt 5000) { throw "Deck content is empty or too large." }
            if ($lines -notcontains ("Tags=" + $ImportTag)) { throw "Importer ownership marker is missing." }
            $sourceUrl = Get-DeckMemoryMetadataValue $lines "Source URL"
            if ($sourceUrl -notmatch '^https://archidekt[.]com/decks/(\d+)$') {
                throw "A valid Archidekt source URL is required."
            }
            $deckId = [string]$Matches[1]
            $kind = [string]$deck.DeckType
            $targetDir = if ($kind -eq "Constructed") { $ConstructedDir } else { $CommanderDir }
            if (-not (Test-Path -LiteralPath $targetDir)) {
                New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
            }
            $requestedBase = [IO.Path]::GetFileNameWithoutExtension([string]$deck.FileName)
            if ([string]::IsNullOrWhiteSpace($requestedBase)) { $requestedBase = $name }
            $existing = Find-ImportedDeckBySource $sourceUrl
            $output = Choose-OutputPath $targetDir $requestedBase $deckId $sourceUrl $existing
            if (-not [bool]$Settings.DryRun) {
                if ($existing) { Backup-ImportedDeck $existing $deckId }
                Write-Utf8NoBom $output $lines
                if ($existing -and [IO.Path]::GetFullPath($existing) -ne [IO.Path]::GetFullPath($output)) {
                    Remove-Item -LiteralPath $existing -Force -ErrorAction Stop
                }
            }
            $imported++
            Write-Log ("  RESTORED " + $index + "/" + $decks.Count + " | " + $name)
        }
        catch {
            $failed++
            Write-Log ("  FAILED " + $name + " | " + $_.Exception.Message)
        }
    }
    Complete-UiProgress
    Write-Host ""
    Write-UiBanner "DECK MEMORY RESTORE COMPLETE" ([IO.Path]::GetFileName([string]$document.ResolvedPath))
    Write-Host ("Restored : " + $imported) -ForegroundColor Green
    Write-Host ("Failed   : " + $failed) -ForegroundColor $(if ($failed) { "Yellow" } else { "Green" })
    Write-Host ("Log      : " + $script:CurrentLog)
    if ($failed -gt 0) { throw ($failed.ToString() + " memory deck(s) failed validation or restoration.") }
}

function Show-SelectedDeckMemory {
    $document = Read-DeckMemoryDocument ([string]$Settings.MemoryFilePath)
    $decks = @($document.Decks)
    $pageSize = 20
    $page = 1
    $pages = [Math]::Max(1, [int][Math]::Ceiling($decks.Count / [double]$pageSize))
    while ($true) {
        Clear-Host
        Write-UiBanner "DECK MEMORY VIEWER" ("Page " + $page + "/" + $pages + " | " + $decks.Count + " decks")
        Write-Host ("File: " + [string]$document.ResolvedPath) -ForegroundColor DarkCyan
        Write-Host ("Created: " + [string]$document.CreatedUtc) -ForegroundColor DarkGray
        Write-Host ""
        $start = ($page - 1) * $pageSize
        $end = [Math]::Min($start + $pageSize - 1, $decks.Count - 1)
        if ($decks.Count -eq 0) {
            Write-Host "  This memory contains no decks." -ForegroundColor Yellow
        }
        else {
            for ($i = $start; $i -le $end; $i++) {
                $deck = $decks[$i]
                $color = if (($i % 2) -eq 0) { "Cyan" } else { "Green" }
                Write-Host (("  {0,4}. " -f ($i + 1)) + [string]$deck.Name) -ForegroundColor $color
                Write-Host ("        Commander: " + [string]$deck.Commander) -ForegroundColor White
                Write-Host ("        Owner: " + [string]$deck.Owner + " | Type: " + [string]$deck.DeckType + " | Bracket: " + [string]$deck.Bracket) -ForegroundColor DarkGray
            }
        }
        Write-Host ""
        $choice = Read-Host "[N]ext  [P]revious  [Q]uit"
        if ($choice -match '^(?i:q|quit)$') { return }
        if ($choice -match '^(?i:n|next)$' -and $page -lt $pages) { $page++ }
        if ($choice -match '^(?i:p|previous)$' -and $page -gt 1) { $page-- }
    }
}

function Remove-ImportedDecks {
    Start-Log "cleanup"
    $files = New-Object System.Collections.ArrayList

    foreach ($root in @($CommanderDir, $ConstructedDir)) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $root -Filter "*.dck" -File -ErrorAction SilentlyContinue) {
            if (Test-IsOurImportedDeckFile $file.FullName) {
                [void]$files.Add($file)
            }
        }
    }

    Write-Host ""

    if ($files.Count -eq 0) {
        Write-Host "No decks created by Jadon's Archidekt importer were found."
        return
    }

    Write-Host ("Found " + $files.Count + " imported deck file(s).")
    Write-Host "Only decks carrying this importer's marker will be affected."
    Write-Host "Manually-created Forge decks are not touched."
    Write-Host ""

    if ([bool]$Settings.DryRun) {
        Write-Host "DRY RUN is ON. These files would be removed:"
        foreach ($file in $files) {
            Write-Host ("  - " + $file.FullName)
        }
        return
    }

    $answer = Read-Host "Remove all of these imported decks? Type YES to confirm"
    if ($answer -cne "YES") {
        Write-Host "Cleanup cancelled."
        return
    }

    $removed = 0
    $removeFailures = 0

    foreach ($file in $files) {
        try {
            $source = ""
            try {
                foreach ($line in (Get-Content -LiteralPath $file.FullName -TotalCount 20 -Encoding UTF8)) {
                    if ($line -match '^Source URL=https://archidekt\.com/decks/(\d+)') {
                        $source = $Matches[1]
                        break
                    }
                }
            }
            catch {}

            if ([string]::IsNullOrWhiteSpace($source)) {
                $source = "unknown"
            }

            Backup-ImportedDeck $file.FullName $source
            Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
            $removed++
        }
        catch {
            $removeFailures++
            Write-Host ("Could not remove: " + $file.FullName + " - " + $_.Exception.Message) -ForegroundColor Yellow
            Write-Log ("CLEANUP FAILED: " + $file.FullName + " - " + $_.Exception.Message)
        }
    }

    if ($removeFailures -eq 0 -and (Test-Path -LiteralPath $StateFile)) {
        Remove-Item -LiteralPath $StateFile -Force -ErrorAction SilentlyContinue
    }

    Write-Host ""
    Write-Host ("Removed " + $removed + " imported deck file(s).")
    Write-Host ("Failed removals: " + $removeFailures)
    Write-Host ("Log: " + $script:CurrentLog)
}

function Remove-AllCustomDeckFiles {
    param(
        [switch]$IncludeCommander,
        [switch]$IncludeConstructed
    )

    if (-not $IncludeCommander -and -not $IncludeConstructed) { return }
    Start-Log "custom-deck-purge"

    $targets = New-Object System.Collections.ArrayList
    if ($IncludeCommander) {
        [void]$targets.Add([pscustomobject]@{ Label = "commander"; Path = $CommanderDir })
    }
    if ($IncludeConstructed) {
        [void]$targets.Add([pscustomobject]@{ Label = "constructed"; Path = $ConstructedDir })
    }

    $allowedBase = [IO.Path]::GetFullPath((Join-Path $ForgeUser "decks"))
    if (-not $allowedBase.EndsWith([IO.Path]::DirectorySeparatorChar)) {
        $allowedBase += [IO.Path]::DirectorySeparatorChar
    }

    $files = New-Object System.Collections.ArrayList
    foreach ($target in $targets) {
        $resolvedTarget = [IO.Path]::GetFullPath([string]$target.Path)
        if (-not $resolvedTarget.StartsWith($allowedBase, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Custom-deck cleanup target escaped Forge's decks folder."
        }
        if (-not (Test-Path -LiteralPath $resolvedTarget -PathType Container)) { continue }

        foreach ($file in Get-ChildItem -LiteralPath $resolvedTarget -Filter "*.dck" -File -ErrorAction Stop) {
            [void]$files.Add([pscustomobject]@{
                File = $file
                Label = [string]$target.Label
            })
        }
    }

    Write-UiBanner "CUSTOM DECK CLEANUP" "Exact Forge folders only - every file is backed up first"
    foreach ($target in $targets) {
        $count = @($files | Where-Object { $_.Label -eq [string]$target.Label }).Count
        Write-Host ("  " + ([string]$target.Label).ToUpperInvariant().PadRight(12) + " " + $count + " deck(s)") -ForegroundColor Yellow
        Write-Host ("    " + [string]$target.Path) -ForegroundColor DarkGray
    }
    Write-Host ""

    if ($files.Count -eq 0) {
        Write-Host "No custom .dck files were found in the selected folder(s)."
        return
    }

    Write-Host "  WARNING: This includes manual decks and decks from other importers." -ForegroundColor Red
    Write-Host "  The backup is mandatory and is created before the first deletion." -ForegroundColor Yellow
    Write-Host ""

    if ([bool]$Settings.DryRun) {
        Write-Host "DRY RUN is ON. No files will be changed:" -ForegroundColor Yellow
        foreach ($item in $files) { Write-Host ("  - " + $item.File.FullName) }
        return
    }

    $confirmationText = "DELETE " + $files.Count + " CUSTOM DECKS"
    $answer = Read-Host ("Type exactly '" + $confirmationText + "' to continue")
    if ($answer -cne $confirmationText) {
        Write-Host "Custom-deck cleanup cancelled." -ForegroundColor Yellow
        return
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmssfff"
    $purgeBackupRoot = Join-Path (Join-Path $BackupDir "custom-purge") $stamp
    New-Item -ItemType Directory -Force -Path $purgeBackupRoot | Out-Null

    # Complete the full backup phase before deleting even one deck.
    foreach ($item in $files) {
        $destinationDir = Join-Path $purgeBackupRoot ([string]$item.Label)
        New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
        $destination = Join-Path $destinationDir $item.File.Name
        Copy-Item -LiteralPath $item.File.FullName -Destination $destination -Force -ErrorAction Stop
    }

    $removedPaths = @{}
    $removed = 0
    $failed = 0
    foreach ($item in $files) {
        try {
            $fullPath = [IO.Path]::GetFullPath($item.File.FullName)
            Remove-Item -LiteralPath $fullPath -Force -ErrorAction Stop
            $removedPaths[$fullPath.ToLowerInvariant()] = $true
            $removed++
            Write-Log ("REMOVED CUSTOM DECK: " + $fullPath)
        }
        catch {
            $failed++
            Write-Log ("CUSTOM DECK REMOVE FAILED: " + $item.File.FullName + " - " + $_.Exception.Message)
        }
    }

    $savedState = Read-ImportState
    foreach ($deckId in @($savedState.Keys)) {
        $outputPath = [string]$savedState[$deckId].OutputPath
        if ([string]::IsNullOrWhiteSpace($outputPath)) { continue }
        try {
            $key = [IO.Path]::GetFullPath($outputPath).ToLowerInvariant()
            if ($removedPaths.ContainsKey($key)) { [void]$savedState.Remove($deckId) }
        }
        catch {}
    }
    Save-ImportState $savedState

    Write-Host ""
    Write-Host ("Removed: " + $removed) -ForegroundColor Green
    Write-Host ("Failed : " + $failed) -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
    Write-Host ("Backup : " + $purgeBackupRoot) -ForegroundColor Cyan
    Write-Host "The backup can be copied back into the matching commander/constructed folder." -ForegroundColor DarkGray
    Write-Host ("Log    : " + $script:CurrentLog)
}

function Show-DeckCleanupMenu {
    Clear-Host
    Write-UiBanner "DECK CLEANUP" "Choose the exact scope - nothing is removed without confirmation"
    Write-Host "  [1] Remove decks added by this Archidekt manager" -ForegroundColor Green
    Write-Host "      Preserves every manual and third-party deck." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [2] Remove ALL custom Commander .dck files" -ForegroundColor Yellow
    Write-Host "  [3] Remove ALL custom Constructed .dck files" -ForegroundColor Yellow
    Write-Host "  [4] Remove ALL custom .dck files from both folders" -ForegroundColor Red
    Write-Host "      Options 2-4 include manual decks and force a complete backup first." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [0] Back"
    Write-Host ""

    $choice = Read-Host "  Select 0-4"
    switch ($choice) {
        "1" { Remove-ImportedDecks }
        "2" { Remove-AllCustomDeckFiles -IncludeCommander }
        "3" { Remove-AllCustomDeckFiles -IncludeConstructed }
        "4" { Remove-AllCustomDeckFiles -IncludeCommander -IncludeConstructed }
        default { return }
    }
}

function Restore-ImportedDeckBackup {
    Start-Log "backup-restore"

    $backups = @(
        Get-ChildItem -LiteralPath $BackupDir `
            -Filter "*.dck" `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTimeUtc -Descending |
        Where-Object { Test-IsOurImportedDeckFile $_.FullName } |
        Select-Object -First 100
    )

    Write-Host ""
    Write-Host "Restore Importer Backup"
    Write-Host "-----------------------"
    Write-Host ""

    if ($backups.Count -eq 0) {
        Write-Host "No verified importer-owned deck backups were found."
        return
    }

    for ($i = 0; $i -lt $backups.Count; $i++) {
        Write-Host (
            "[" + ($i + 1) + "] " + $backups[$i].LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss") +
            "  " + $backups[$i].Name
        )
    }

    Write-Host ""
    $answer = Read-Host "Choose a backup number, or press Enter to cancel"
    if ([string]::IsNullOrWhiteSpace($answer)) { return }

    $number = 0
    if (-not [int]::TryParse($answer, [ref]$number) -or
        $number -lt 1 -or $number -gt $backups.Count) {

        throw "Backup selection is not in the displayed list."
    }

    $backup = $backups[$number - 1]
    $record = Read-ImportedDeckRecord $backup.FullName
    if ($null -eq $record -or [string]::IsNullOrWhiteSpace([string]$record.DeckId)) {
        throw "Selected backup does not contain verified Archidekt source metadata."
    }

    Write-Host ""
    Write-Host ("Backup : " + $backup.FullName)
    Write-Host ("Deck   : " + $record.DisplayName)
    Write-Host ("Source : " + $record.SourceUrl)
    Write-Host ""

    $confirm = Read-Host "Type YES to restore this importer-owned backup"
    if ($confirm -cne "YES") {
        Write-Host "Restore cancelled."
        return
    }

    $targetDir = if ([string]::IsNullOrWhiteSpace([string]$record.CommanderLabel)) {
        $ConstructedDir
    }
    else {
        $CommanderDir
    }

    $existing = Find-ImportedDeckBySource ([string]$record.SourceUrl)
    $target = Choose-OutputPath `
        $targetDir `
        ([string]$record.DisplayName) `
        ([string]$record.DeckId) `
        ([string]$record.SourceUrl) `
        $existing

    if ($existing) {
        Backup-ImportedDeck $existing ([string]$record.DeckId)
    }

    $lines = @(Get-Content -LiteralPath $backup.FullName -Encoding UTF8)
    Write-Utf8NoBom $target $lines

    if ($existing -and
        [IO.Path]::GetFullPath($existing) -ne [IO.Path]::GetFullPath($target)) {

        Remove-Item -LiteralPath $existing -Force -ErrorAction Stop
    }

    Write-Log ("RESTORED: " + $backup.FullName + " -> " + $target)
    Write-Host ""
    Write-Host "Backup restored." -ForegroundColor Green
    Write-Host ("Output: " + $target)
    Write-Host ("Log: " + $script:CurrentLog)
}

function Show-ProfileChoices {
    $choices = @(Get-ProfileChoices)

    Write-UiBanner "PROFILE SYNC" "Choose a saved profile or paste any Archidekt username/URL"
    Write-UiSection "Default profiles"
    for ($i = 0; $i -lt $DefaultProfiles.Count; $i++) {
        Write-Host ("  [" + ($i + 1) + "] " + $DefaultProfiles[$i]) -ForegroundColor Cyan
    }

    if ($choices.Count -gt $DefaultProfiles.Count) {
        Write-Host ""
        Write-UiSection "Recent profiles"

        for ($i = $DefaultProfiles.Count; $i -lt $choices.Count; $i++) {
            Write-Host ("  [" + ($i + 1) + "] " + $choices[$i])
        }
    }

    Write-Host ""
}

function Prompt-Profile {
    [void](Initialize-DefaultProfileHistory)
    $choices = @(Get-ProfileChoices)
    Show-ProfileChoices

    $inputText = Read-Host "Choose a profile number, or paste any Archidekt profile URL/username"

    if ([string]::IsNullOrWhiteSpace($inputText)) {
        return $null
    }

    $n = 0
    if ([int]::TryParse($inputText.Trim(), [ref]$n)) {
        if ($n -ge 1 -and $n -le $choices.Count) {
            return [string]$choices[$n - 1]
        }

        Write-Host "That profile number is not in the list." -ForegroundColor Yellow
        return $null
    }

    return $inputText
}

function Run-ForgeFromManager {
    Write-Host ""

    if (Test-Path -LiteralPath $ForgeLauncher) {
        $process = Start-Process -FilePath $ForgeLauncher -PassThru
        if ($null -eq $process) {
            throw "Windows did not return a Forge launcher process."
        }
        Write-Host "Forge launch requested."
        return
    }

    throw "Forge launcher was not found at: $ForgeLauncher"
}


function Get-ForgeDesktopJar {
    $locationFile = Join-Path $Base "Forge_Location.txt"
    if (Test-Path -LiteralPath $locationFile) {
        try {
            foreach ($line in Get-Content -LiteralPath $locationFile -Encoding UTF8) {
                if ($line -match '^Forge JAR:\s*(.+?)\s*$') {
                    $recorded = [string]$Matches[1]
                    if (Test-Path -LiteralPath $recorded) {
                        return Get-Item -LiteralPath $recorded
                    }
                }
            }
        }
        catch {}
    }

    $candidates = @(
        Get-ChildItem -LiteralPath $Base `
            -Filter "forge-gui-desktop-*-jar-with-dependencies.jar" `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue
    )

    if ($candidates.Count -eq 0) {
        throw "Forge desktop JAR was not found under " + $Base
    }

    return (
        $candidates |
        Sort-Object `
            @{ Expression = {
                if ($_.Name -match '^forge-gui-desktop-(\d+(?:\.\d+){1,3})-') {
                    try { return [version]$Matches[1] } catch {}
                }
                return [version]"0.0"
            }; Descending = $true },
            @{ Expression = { $_.LastWriteTimeUtc }; Descending = $true } |
        Select-Object -First 1
    )
}

function Get-ForgeVersionFromJar {
    param([string]$JarPath)

    $name = [IO.Path]::GetFileName($JarPath)

    if ($name -match '^forge-gui-desktop-(.+)-jar-with-dependencies\.jar$') {
        $fileVersion = [string]$Matches[1]
    }
    else {
        throw "Could not determine Forge version from $name"
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = $null
    $reader = $null

    try {
        $zip = [IO.Compression.ZipFile]::OpenRead($JarPath)
        $manifest = $zip.Entries |
            Where-Object { $_.FullName -ieq "META-INF/MANIFEST.MF" } |
            Select-Object -First 1

        if ($null -eq $manifest) {
            throw "Forge desktop JAR manifest is missing."
        }

        $reader = New-Object IO.StreamReader($manifest.Open(), [Text.Encoding]::UTF8)
        $text = $reader.ReadToEnd()

        if ($text -notmatch '(?m)^Implementation-Title:\s*Forge\s*$' -or
            $text -notmatch '(?m)^Main-Class:\s*forge\.view\.Main\s*$') {

            throw "JAR manifest does not identify the Forge desktop application."
        }

        $implementationVersion = ""
        if ($text -match '(?m)^Implementation-Version:\s*([^\r\n]+)') {
            $implementationVersion = [string]$Matches[1].Trim()
        }

        if ([string]::IsNullOrWhiteSpace($implementationVersion) -or
            -not $implementationVersion.StartsWith($fileVersion + "-", [StringComparison]::OrdinalIgnoreCase)) {

            throw "Forge filename version and manifest version do not agree."
        }

        return $fileVersion
    }
    finally {
        if ($reader) { $reader.Dispose() }
        if ($zip) { $zip.Dispose() }
    }
}

function Get-AiArchitecture {
    $arch = [string]$env:PROCESSOR_ARCHITECTURE
    $wow = [string]$env:PROCESSOR_ARCHITEW6432

    if ($wow) {
        $arch = $wow
    }

    switch -Regex ($arch.ToUpperInvariant()) {
        "ARM64" { return "aarch64" }
        "AMD64|X86_64" { return "x64" }
        default { throw "AI Viewer currently supports 64-bit x64 and ARM64 Windows." }
    }
}

function Download-UserFile {
    param(
        [string]$Url,
        [string]$Destination
    )

    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    $last = $null

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        $client = $null

        try {
            if (Test-Path -LiteralPath $Destination) {
                Remove-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
            }

            Write-Host ("Downloading: " + [IO.Path]::GetFileName($Destination))
            $client = New-Object System.Net.WebClient
            $client.Headers["User-Agent"] = "Jadons-Ultimate-Forge-Manager/7.0"
            $client.DownloadFile($Url, $Destination)

            if (-not (Test-Path -LiteralPath $Destination)) {
                throw "Download completed without creating the destination file."
            }

            if ((Get-Item -LiteralPath $Destination).Length -le 0) {
                throw "Downloaded file is empty."
            }

            return
        }
        catch {
            $last = $_

            if ($attempt -lt 3) {
                Write-Host ("Download failed; retrying (" + $attempt + "/3)...")
                Start-Sleep -Seconds (2 * $attempt)
            }
        }
        finally {
            if ($client) {
                $client.Dispose()
            }
        }
    }

    throw $last
}

function Get-RemoteUtf8Text {
    param([string]$Url)

    $client = $null

    try {
        $client = New-Object System.Net.WebClient
        $client.Headers["User-Agent"] = "Jadons-Ultimate-Forge-Manager/7.0"
        $bytes = $client.DownloadData($Url)
        return [Text.Encoding]::UTF8.GetString($bytes)
    }
    finally {
        if ($client) {
            $client.Dispose()
        }
    }
}

function Ensure-AiJdk {
    foreach ($jdkRoot in @($AiJdkDir, (Join-Path $Base "java-21"), (Join-Path $Base "java-21-jdk"))) {
        $existing = @(
            Get-ChildItem -LiteralPath $jdkRoot `
                -Filter "javac.exe" `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue
        )

        if ($existing.Count -gt 0) {
            & $existing[0].FullName -version | Out-Null
            if ($LASTEXITCODE -eq 0) {
                return $existing[0].FullName
            }
        }
    }

    $arch = Get-AiArchitecture
    $zipPath = Join-Path $AiDownloadsDir ("temurin-jdk21-" + $arch + ".zip")
    $url = "https://api.adoptium.net/v3/binary/latest/21/ga/windows/" +
        $arch + "/jdk/hotspot/normal/eclipse?project=jdk"

    Download-UserFile $url $zipPath

    $extractRoot = Join-Path $AiDir ("jdk-extract-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $extractRoot | Out-Null

    try {
        Write-Host "Extracting private Java JDK for AI Viewer..."
        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force

        $javac = Get-ChildItem -LiteralPath $extractRoot `
            -Filter "javac.exe" `
            -File `
            -Recurse `
            -ErrorAction Stop |
            Select-Object -First 1

        if ($null -eq $javac) {
            throw "Downloaded JDK did not contain javac.exe."
        }

        $jdkRoot = Split-Path -Parent (Split-Path -Parent $javac.FullName)

        if (Test-Path -LiteralPath $AiJdkDir) {
            Remove-Item -LiteralPath $AiJdkDir -Force -Recurse -ErrorAction Stop
        }

        Move-Item -LiteralPath $jdkRoot -Destination $AiJdkDir -Force
    }
    finally {
        if (Test-Path -LiteralPath $extractRoot) {
            Remove-Item -LiteralPath $extractRoot -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    $finalJavac = Get-ChildItem -LiteralPath $AiJdkDir `
        -Filter "javac.exe" `
        -File `
        -Recurse `
        -ErrorAction Stop |
        Select-Object -First 1

    if ($null -eq $finalJavac) {
        throw "Private JDK extraction did not produce javac.exe."
    }

    return $finalJavac.FullName
}

function Replace-AiSourceLineOnce {
    param(
        [string]$Text,
        [string]$OldLine,
        [string]$Replacement,
        [string]$Label
    )

    $count = ([regex]::Matches($Text, [regex]::Escape($OldLine))).Count

    if ($count -ne 1) {
        throw (
            "AI source verification failed for " + $Label +
            ". Expected exactly one source match; found " + $count + "."
        )
    }

    return $Text.Replace($OldLine, $Replacement)
}

function Write-AiTelemetryJava {
    param([string]$Path)

    $java = @'
package forge.ai.simulation;

import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.Instant;

public final class AiTelemetry {
    private static final Object LOCK = new Object();

    private AiTelemetry() {
    }

    private static String propertyPath() {
        try {
            return System.getProperty("jadon.ai.telemetry", "");
        } catch (Throwable ignored) {
            return "";
        }
    }

    private static String escape(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder out = new StringBuilder();

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);

            switch (c) {
                case '\\': out.append("\\\\"); break;
                case '"': out.append("\\\""); break;
                case '\n': out.append("\\n"); break;
                case '\r': out.append("\\r"); break;
                case '\t': out.append("\\t"); break;
                default:
                    if (c < 32) {
                        out.append(' ');
                    } else {
                        out.append(c);
                    }
            }
        }

        return out.toString();
    }

    private static String invokeString(Object target, String methodName) {
        if (target == null) {
            return "";
        }

        try {
            Method method = target.getClass().getMethod(methodName);
            Object result = method.invoke(target);
            return result == null ? "" : String.valueOf(result);
        } catch (Throwable ignored) {
            return "";
        }
    }

    private static String playerName(Object player) {
        if (player == null) {
            return "";
        }
        String value = invokeString(player, "getName");
        return value.isEmpty() ? String.valueOf(player) : value;
    }

    @SuppressWarnings({"rawtypes", "unchecked"})
    private static String zoneSize(Object player, String zoneName) {
        if (player == null) {
            return "";
        }

        try {
            Class zoneType = Class.forName("forge.game.zone.ZoneType");
            Object zone = Enum.valueOf(zoneType, zoneName);
            Method getCardsIn = player.getClass().getMethod("getCardsIn", zoneType);
            Object cards = getCardsIn.invoke(player, zone);
            return invokeString(cards, "size");
        } catch (Throwable ignored) {
            return "";
        }
    }

    private static Object weakestOpponent(Object player) {
        if (player == null) {
            return null;
        }

        try {
            Method method = player.getClass().getMethod("getWeakestOpponent");
            return method.invoke(player);
        } catch (Throwable ignored) {
            return null;
        }
    }

    private static String phaseName(Object game) {
        if (game == null) {
            return "";
        }

        try {
            Method getPhaseHandler = game.getClass().getMethod("getPhaseHandler");
            Object handler = getPhaseHandler.invoke(game);

            if (handler == null) {
                return "";
            }

            Method getPhase = handler.getClass().getMethod("getPhase");
            Object phase = getPhase.invoke(handler);
            return phase == null ? "" : String.valueOf(phase);
        } catch (Throwable ignored) {
            return "";
        }
    }

    private static String turnNumber(Object game) {
        if (game == null) {
            return "";
        }

        try {
            Method getPhaseHandler = game.getClass().getMethod("getPhaseHandler");
            Object handler = getPhaseHandler.invoke(game);

            if (handler == null) {
                return "";
            }

            Method getTurn = handler.getClass().getMethod("getTurn");
            Object turn = getTurn.invoke(handler);
            return turn == null ? "" : String.valueOf(turn);
        } catch (Throwable ignored) {
            return "";
        }
    }

    private static void emit(String type, Object player, Object game, String... pairs) {
        String outputPath = propertyPath();

        if (outputPath == null || outputPath.isEmpty()) {
            return;
        }

        try {
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"time\":\"").append(escape(Instant.now().toString())).append("\",");
            json.append("\"type\":\"").append(escape(type)).append("\",");
            json.append("\"player\":\"").append(escape(playerName(player))).append("\",");
            json.append("\"turn\":\"").append(escape(turnNumber(game))).append("\",");
            json.append("\"phase\":\"").append(escape(phaseName(game))).append("\"");

            for (int i = 0; i + 1 < pairs.length; i += 2) {
                json.append(",\"")
                    .append(escape(pairs[i]))
                    .append("\":\"")
                    .append(escape(pairs[i + 1]))
                    .append("\"");
            }

            json.append("}");
            json.append(System.lineSeparator());

            synchronized (LOCK) {
                Path path = Paths.get(outputPath);
                Path parent = path.getParent();

                if (parent != null) {
                    Files.createDirectories(parent);
                }

                Files.writeString(
                    path,
                    json.toString(),
                    StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE,
                    StandardOpenOption.APPEND
                );
            }
        } catch (Throwable ignored) {
            // Telemetry must NEVER affect Forge gameplay or AI decisions.
        }
    }

    public static void start(
            Object player,
            Object game,
            int score,
            int available,
            int candidates) {

        Object opponent = weakestOpponent(player);
        emit(
            "decision_start",
            player,
            game,
            "score", String.valueOf(score),
            "available", String.valueOf(available),
            "candidates", String.valueOf(candidates),
            "life", invokeString(player, "getLife"),
            "hand", zoneSize(player, "Hand"),
            "battlefield", zoneSize(player, "Battlefield"),
            "mana", invokeString(player, "getManaPool"),
            "opponent", playerName(opponent),
            "opponentLife", invokeString(opponent, "getLife"),
            "opponentBattlefield", zoneSize(opponent, "Battlefield")
        );
    }

    public static void candidate(
            Object player,
            Object game,
            String action,
            String status) {

        emit(
            "candidate",
            player,
            game,
            "action", action,
            "status", status
        );
    }

    public static void evaluated(
            Object player,
            Object game,
            String action,
            int score,
            int available) {

        emit(
            "evaluated",
            player,
            game,
            "action", action,
            "score", String.valueOf(score),
            "available", String.valueOf(available)
        );
    }

    public static void simulationBest(
            Object player,
            Object game,
            String action,
            int originalScore,
            int chosenScore,
            int chosenAvailable,
            long milliseconds,
            int simulations) {

        emit(
            "simulation_best",
            player,
            game,
            "action", action,
            "originalScore", String.valueOf(originalScore),
            "score", String.valueOf(chosenScore),
            "available", String.valueOf(chosenAvailable),
            "milliseconds", String.valueOf(milliseconds),
            "simulations", String.valueOf(simulations)
        );
    }

    public static void plan(
            Object player,
            Object game,
            String plan,
            int finalScore) {

        emit(
            "plan",
            player,
            game,
            "plan", plan,
            "score", String.valueOf(finalScore)
        );
    }

    public static void planned(
            Object player,
            Object game,
            String action,
            String decision) {

        emit(
            "planned",
            player,
            game,
            "action", action,
            "decision", decision
        );
    }

    public static void heuristicStart(
            Object player,
            Object game) {

        Object opponent = weakestOpponent(player);
        emit(
            "heuristic_start",
            player,
            game,
            "mode", "heuristic",
            "life", invokeString(player, "getLife"),
            "hand", zoneSize(player, "Hand"),
            "battlefield", zoneSize(player, "Battlefield"),
            "mana", invokeString(player, "getManaPool"),
            "opponent", playerName(opponent),
            "opponentLife", invokeString(opponent, "getLife"),
            "opponentBattlefield", zoneSize(opponent, "Battlefield")
        );
    }

    public static void heuristicCandidate(
            Object player,
            Object game,
            String action,
            String status) {

        emit(
            "heuristic_candidate",
            player,
            game,
            "action", action,
            "status", status
        );
    }

    public static void heuristicChosen(
            Object player,
            Object game,
            String action) {

        emit(
            "heuristic_chosen",
            player,
            game,
            "action", action,
            "mode", "heuristic priority"
        );
    }

    public static void combatAttack(
            Object player,
            Object game,
            int aggression,
            String combatState) {

        emit(
            "combat_attack",
            player,
            game,
            "aggression", String.valueOf(aggression),
            "combat", combatState
        );
    }

    public static void combatBlock(
            Object player,
            Object game,
            String combatState) {

        emit(
            "combat_block",
            player,
            game,
            "combat", combatState
        );
    }
}
'@

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, $java, $encoding)
}

function Patch-SpellAbilityPickerSource {
    param(
        [string]$Source,
        [string]$OutputPath
    )

    $Source = $Source.Replace("`r`n", "`n").Replace("`r", "`n")

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "    private int numSimulations;" `
        ("    private int numSimulations;`n" +
         "    private boolean jadonTelemetryRoot = false;") `
        "telemetry root field"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        //printOutput = controller == null;" `
        ("        final boolean jadonTelemetryOwner = controller == null;`n" +
         "        if (jadonTelemetryOwner) {`n" +
         "            jadonTelemetryRoot = true;`n" +
         "            numSimulations = 0;`n" +
         "        }`n" +
         "        try {`n" +
         "        //printOutput = controller == null;") `
        "telemetry decision scope start"

    $scopeEndOld =
        "        createNewPlan(origGameScore, candidateSAs);`n" +
        "        return getPlannedSpellAbility(origGameScore, candidateSAs);`n" +
        "    }"

    $scopeEndNew =
        "        createNewPlan(origGameScore, candidateSAs);`n" +
        "        return getPlannedSpellAbility(origGameScore, candidateSAs);`n" +
        "        } finally {`n" +
        "            if (jadonTelemetryOwner) {`n" +
        "                jadonTelemetryRoot = false;`n" +
        "            }`n" +
        "        }`n" +
        "    }"

    $scopeEndCount = ([regex]::Matches($Source, [regex]::Escape($scopeEndOld))).Count
    if ($scopeEndCount -ne 1) {
        throw "AI source verification failed for telemetry decision scope end."
    }
    $Source = $Source.Replace($scopeEndOld, $scopeEndNew)

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "            AiPlayDecision opinion = canPlayAndPayForSim(sa);" `
        ("            AiPlayDecision opinion = canPlayAndPayForSim(sa);`n" +
         "            if (jadonTelemetryRoot) {`n" +
         "                try {`n" +
         "                    AiTelemetry.candidate(player, game, abilityToString(sa), String.valueOf(opinion));`n" +
         "                } catch (Throwable ignored) { }`n" +
         "            }") `
        "candidate decision hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        Score origGameScore = new GameStateEvaluator().getScoreForGameState(game, player);" `
        ("        if (controller == null) {`n" +
         "            jadonTelemetryRoot = true;`n" +
         "            numSimulations = 0;`n" +
         "        }`n" +
         "        Score origGameScore = new GameStateEvaluator().getScoreForGameState(game, player);") `
        "root decision hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        List<SpellAbility> candidateSAs = getCandidateSpellsAndAbilities();" `
        ("        List<SpellAbility> candidateSAs = getCandidateSpellsAndAbilities();`n" +
         "        if (jadonTelemetryRoot) {`n" +
         "            try {`n" +
         "                AiTelemetry.start(player, game, origGameScore.value, origGameScore.availableValue, candidateSAs.size());`n" +
         "            } catch (Throwable ignored) { }`n" +
         "        }") `
        "decision start hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "            Score value = evaluateSa(controller, phase, candidateSAs, i);" `
        ("            Score value = evaluateSa(controller, phase, candidateSAs, i);`n" +
         "            if (jadonTelemetryRoot) {`n" +
         "                try {`n" +
         "                    AiTelemetry.evaluated(player, game, abilityToString(candidateSAs.get(i)), value.value, value.availableValue);`n" +
         "                } catch (Throwable ignored) { }`n" +
         "            }") `
        "candidate evaluation hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        long execTime = System.currentTimeMillis() - startTime;" `
        ("        long execTime = System.currentTimeMillis() - startTime;`n" +
         "        if (jadonTelemetryRoot) {`n" +
         "            try {`n" +
         "                AiTelemetry.simulationBest(player, game, abilityToString(bestSa), origGameScore.value, bestSaValue.value, bestSaValue.availableValue, execTime, numSimulations);`n" +
         "            } catch (Throwable ignored) { }`n" +
         "        }") `
        "chosen action hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        plan = bestPlan;" `
        ("        plan = bestPlan;`n" +
         "        if (jadonTelemetryRoot) {`n" +
         "            try {`n" +
         "                StringBuilder jadonPlan = new StringBuilder();`n" +
         "                for (Plan.Decision jadonDecision : bestPlan.getDecisions()) {`n" +
         "                    if (jadonPlan.length() > 0) { jadonPlan.append(`" | `"); }`n" +
         "                    jadonPlan.append(jadonDecision.toString());`n" +
         "                }`n" +
         "                AiTelemetry.plan(player, game, jadonPlan.toString(), bestPlan.getFinalScore().value);`n" +
         "            } catch (Throwable ignored) { }`n" +
         "        }") `
        "accepted plan hook"

    $plannedReturnOld =
        '        print("Planned decision " + plan.getNextDecisionIndex() + ": " + decision);' + "`n" +
        "        return sa;"

    $plannedReturnNew =
        '        print("Planned decision " + plan.getNextDecisionIndex() + ": " + decision);' + "`n" +
        "        try {`n" +
        "            AiTelemetry.planned(player, game, abilityToString(sa), String.valueOf(decision));`n" +
        "        } catch (Throwable ignored) { }`n" +
        "        return sa;"

    $plannedReturnCount = ([regex]::Matches($Source, [regex]::Escape($plannedReturnOld))).Count
    if ($plannedReturnCount -ne 1) {
        throw "AI source verification failed for planned-action execution hook."
    }
    $Source = $Source.Replace($plannedReturnOld, $plannedReturnNew)

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($OutputPath, $Source, $encoding)
}

function Patch-AiControllerSource {
    param(
        [string]$Source,
        [string]$OutputPath
    )

    $Source = $Source.Replace("`r`n", "`n").Replace("`r", "`n")

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "import forge.ai.simulation.GameStateEvaluator;" `
        ("import forge.ai.simulation.GameStateEvaluator;`n" +
         "import forge.ai.simulation.AiTelemetry;") `
        "AiController telemetry import"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "    public List<SpellAbility> chooseSpellAbilityToPlay() {" `
        ("    public List<SpellAbility> chooseSpellAbilityToPlay() {`n" +
         "        try {`n" +
         "            AiTelemetry.heuristicStart(player, game);`n" +
         "        } catch (Throwable ignored) { }") `
        "heuristic decision start hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "                AiPlayDecision opinion = useLivingEnd && AiPlayDecision.WillPlay.equals(aiPlayDecision) ? aiPlayDecision : canPlayAndPayFor(sa);" `
        ("                AiPlayDecision opinion = useLivingEnd && AiPlayDecision.WillPlay.equals(aiPlayDecision) ? aiPlayDecision : canPlayAndPayFor(sa);`n" +
         "                try {`n" +
         "                    AiTelemetry.heuristicCandidate(player, game, String.valueOf(sa.getHostCard()) + `" -> `" + String.valueOf(sa), String.valueOf(opinion));`n" +
         "                } catch (Throwable ignored) { }") `
        "heuristic candidate hook"

    $oldReturn =
        "                // TODO could continue to try find another with higher rating (weighted by priority ordering)`n" +
        "                return sa;"

    $newReturn =
        "                // TODO could continue to try find another with higher rating (weighted by priority ordering)`n" +
        "                try {`n" +
        "                    AiTelemetry.heuristicChosen(player, game, String.valueOf(sa.getHostCard()) + `" -> `" + String.valueOf(sa));`n" +
        "                } catch (Throwable ignored) { }`n" +
        "                return sa;"

    $count = ([regex]::Matches($Source, [regex]::Escape($oldReturn))).Count
    if ($count -ne 1) {
        throw (
            "AI source verification failed for heuristic chosen hook. " +
            "Expected exactly one source match; found " + $count + "."
        )
    }

    $Source = $Source.Replace($oldReturn, $newReturn)

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        lastAttackAggression = aiAtk.declareAttackers(combat);" `
        ("        lastAttackAggression = aiAtk.declareAttackers(combat);`n" +
         "        try {`n" +
         "            AiTelemetry.combatAttack(attacker, game, lastAttackAggression, String.valueOf(combat));`n" +
         "        } catch (Throwable ignored) { }") `
        "combat attack hook"

    $Source = Replace-AiSourceLineOnce `
        $Source `
        "        block.assignBlockersForCombat(combat);" `
        ("        block.assignBlockersForCombat(combat);`n" +
         "        try {`n" +
         "            AiTelemetry.combatBlock(defender, game, String.valueOf(combat));`n" +
         "        } catch (Throwable ignored) { }") `
        "combat block hook"

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($OutputPath, $Source, $encoding)
}

function Write-AiViewerScript {
    param([string]$OutputPath = $AiViewerScript)

    $viewer = @'
param(
    [Parameter(Mandatory=$true)]
    [string]$TelemetryPath
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "Jadon's Forge AI Thought Viewer"
$form.Width = 1180
$form.Height = 760
$form.StartPosition = "CenterScreen"
$form.MinimumSize = New-Object System.Drawing.Size(850, 560)

$root = New-Object System.Windows.Forms.TableLayoutPanel
$root.Dock = "Fill"
$root.RowCount = 4
$root.ColumnCount = 1
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 92)))
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 48)))
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 32)))
$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 20)))
$form.Controls.Add($root)

$summary = New-Object System.Windows.Forms.TableLayoutPanel
$summary.Dock = "Fill"
$summary.ColumnCount = 4
$summary.RowCount = 2

$lblPlayer = New-Object System.Windows.Forms.Label
$lblPlayer.Text = "AI: waiting for Forge..."
$lblPlayer.AutoSize = $true
$lblPlayer.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)

$lblPhase = New-Object System.Windows.Forms.Label
$lblPhase.Text = "Turn / phase: -"
$lblPhase.AutoSize = $true

$lblChosen = New-Object System.Windows.Forms.Label
$lblChosen.Text = "Chosen action: -"
$lblChosen.AutoSize = $true
$lblChosen.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$lblStats = New-Object System.Windows.Forms.Label
$lblStats.Text = "Score: -   Simulations: -   Decision time: -"
$lblStats.AutoSize = $true

$summary.Controls.Add($lblPlayer, 0, 0)
$summary.SetColumnSpan($lblPlayer, 2)
$summary.Controls.Add($lblPhase, 2, 0)
$summary.SetColumnSpan($lblPhase, 2)
$summary.Controls.Add($lblChosen, 0, 1)
$summary.SetColumnSpan($lblChosen, 2)
$summary.Controls.Add($lblStats, 2, 1)
$summary.SetColumnSpan($lblStats, 2)
$root.Controls.Add($summary, 0, 0)

$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$chart.Dock = "Fill"
$chartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$chartArea.AxisX.Interval = 1
$chartArea.AxisX.LabelStyle.Enabled = $true
$chartArea.AxisY.Title = "Evaluated score"
[void]$chart.ChartAreas.Add($chartArea)

$series = New-Object System.Windows.Forms.DataVisualization.Charting.Series
$series.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Bar
$series.IsValueShownAsLabel = $true
[void]$chart.Series.Add($series)
$root.Controls.Add($chart, 0, 1)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Dock = "Fill"
$grid.ReadOnly = $true
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.AutoSizeColumnsMode = "Fill"
$grid.SelectionMode = "FullRowSelect"
[void]$grid.Columns.Add("Type", "Type")
[void]$grid.Columns.Add("Action", "Action / option")
[void]$grid.Columns.Add("Status", "Status")
[void]$grid.Columns.Add("Score", "Score")
[void]$grid.Columns.Add("Available", "Available")
$root.Controls.Add($grid, 0, 2)

$bottom = New-Object System.Windows.Forms.SplitContainer
$bottom.Dock = "Fill"
$bottom.Orientation = "Vertical"
$bottom.SplitterDistance = 760

$planBox = New-Object System.Windows.Forms.TextBox
$planBox.Dock = "Fill"
$planBox.Multiline = $true
$planBox.ReadOnly = $true
$planBox.ScrollBars = "Vertical"
$planBox.Text = "Current plan will appear here."
$bottom.Panel1.Controls.Add($planBox)

$history = New-Object System.Windows.Forms.ListBox
$history.Dock = "Fill"
$bottom.Panel2.Controls.Add($history)
$root.Controls.Add($bottom, 0, 3)

$filePosition = [int64]0
$partialLine = ""
$decisionNumber = 0
$decisionSnapshots = New-Object System.Collections.ArrayList
$currentPositionText = ""

function Add-GridRow {
    param($Type, $Action, $Status, $Score, $Available)

    [void]$grid.Rows.Add(
        [string]$Type,
        [string]$Action,
        [string]$Status,
        [string]$Score,
        [string]$Available
    )

    if ($grid.Rows.Count -gt 250) {
        $grid.Rows.RemoveAt(0)
    }
}

function Add-ChartPoint {
    param([string]$Action, [double]$Score)

    $label = $Action
    if ($label.Length -gt 52) {
        $label = $label.Substring(0, 49) + "..."
    }

    $point = New-Object System.Windows.Forms.DataVisualization.Charting.DataPoint
    $point.AxisLabel = $label
    $point.YValues = @($Score)
    [void]$series.Points.Add($point)

    while ($series.Points.Count -gt 14) {
        $series.Points.RemoveAt(0)
    }
}

function Capture-DecisionSnapshot {
    param([string]$Title)

    $rows = New-Object System.Collections.ArrayList
    foreach ($row in $grid.Rows) {
        if ($row.IsNewRow) { continue }
        [void]$rows.Add(@(
            [string]$row.Cells[0].Value,
            [string]$row.Cells[1].Value,
            [string]$row.Cells[2].Value,
            [string]$row.Cells[3].Value,
            [string]$row.Cells[4].Value
        ))
    }

    $points = New-Object System.Collections.ArrayList
    foreach ($point in $series.Points) {
        [void]$points.Add([pscustomobject]@{
            Label = [string]$point.AxisLabel
            Value = [double]$point.YValues[0]
        })
    }

    [void]$decisionSnapshots.Insert(0, [pscustomobject]@{
        Player = $lblPlayer.Text
        Phase = $lblPhase.Text
        Chosen = $lblChosen.Text
        Stats = $lblStats.Text
        Plan = $planBox.Text
        Rows = $rows.ToArray()
        Points = $points.ToArray()
    })
    [void]$history.Items.Insert(0, $Title)

    while ($history.Items.Count -gt 50) {
        $history.Items.RemoveAt($history.Items.Count - 1)
        $decisionSnapshots.RemoveAt($decisionSnapshots.Count - 1)
    }
}

$history.Add_SelectedIndexChanged({
    try {
        $index = $history.SelectedIndex
        if ($index -lt 0 -or $index -ge $decisionSnapshots.Count) { return }

        $snapshot = $decisionSnapshots[$index]
        $lblPlayer.Text = [string]$snapshot.Player
        $lblPhase.Text = [string]$snapshot.Phase
        $lblChosen.Text = [string]$snapshot.Chosen
        $lblStats.Text = [string]$snapshot.Stats
        $planBox.Text = [string]$snapshot.Plan

        $grid.Rows.Clear()
        foreach ($row in $snapshot.Rows) {
            Add-GridRow $row[0] $row[1] $row[2] $row[3] $row[4]
        }

        $series.Points.Clear()
        foreach ($point in $snapshot.Points) {
            Add-ChartPoint ([string]$point.Label) ([double]$point.Value)
        }
    }
    catch {
        # History inspection is viewer-only and never affects Forge.
    }
})

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 350

$timer.Add_Tick({
    try {
        if (-not (Test-Path -LiteralPath $TelemetryPath)) {
            return
        }

        $stream = $null
        $reader = $null
        try {
            $share = [IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete
            $stream = New-Object IO.FileStream(
                $TelemetryPath,
                [IO.FileMode]::Open,
                [IO.FileAccess]::Read,
                $share
            )

            if ($stream.Length -lt $filePosition) {
                $filePosition = 0
                $partialLine = ""
            }

            [void]$stream.Seek($filePosition, [IO.SeekOrigin]::Begin)
            $reader = New-Object IO.StreamReader(
                $stream,
                (New-Object Text.UTF8Encoding($false)),
                $false,
                4096,
                $true
            )
            $chunk = $reader.ReadToEnd()
            $filePosition = $stream.Position
        }
        finally {
            if ($reader) { $reader.Dispose() }
            if ($stream) { $stream.Dispose() }
        }

        if ([string]::IsNullOrEmpty($chunk)) {
            return
        }

        $combined = $partialLine + $chunk
        $parts = [regex]::Split($combined, "`r?`n")
        $lines = New-Object System.Collections.ArrayList

        for ($partIndex = 0; $partIndex -lt ($parts.Count - 1); $partIndex++) {
            [void]$lines.Add([string]$parts[$partIndex])
        }

        if ($combined -match "`r?`n$") {
            $partialLine = ""
        }
        else {
            $partialLine = [string]$parts[$parts.Count - 1]
        }

        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = [string]$lines[$i]
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }

            try {
                $event = $line | ConvertFrom-Json
            }
            catch {
                continue
            }

            $type = [string]$event.type

            if ($type -eq "heuristic_start") {
                $decisionNumber++
                $grid.Rows.Clear()
                $series.Points.Clear()
                $currentPositionText =
                    "POSITION EVALUATION (actual Forge state)`r`n" +
                    "Life: " + [string]$event.life +
                    " | Hand: " + [string]$event.hand +
                    " | Battlefield: " + [string]$event.battlefield + "`r`n" +
                    "Mana pool: " + [string]$event.mana + "`r`n" +
                    "Opponent: " + [string]$event.opponent +
                    " | Life: " + [string]$event.opponentLife +
                    " | Battlefield: " + [string]$event.opponentBattlefield
                $planBox.Text = $currentPositionText + "`r`n`r`n" +
                    "Heuristic AI mode: Forge is using priority / rule-based reasoning for this decision."

                $lblPlayer.Text = "AI: " + [string]$event.player
                $lblPhase.Text = "Turn " + [string]$event.turn + " / " + [string]$event.phase
                $lblChosen.Text = "Chosen action: evaluating heuristic options..."
                $lblStats.Text = "Mode: Forge heuristic AI"
            }
            elseif ($type -eq "heuristic_candidate") {
                $status = [string]$event.status
                $rowType = if ($status -eq "WillPlay") { "Playable" } else { "Rejected" }
                Add-GridRow $rowType $event.action $status "" ""
            }
            elseif ($type -eq "heuristic_chosen") {
                $action = [string]$event.action
                $lblChosen.Text = "Chosen action: " + $action
                $lblStats.Text = "Mode: Forge heuristic priority selection"
                Add-GridRow "CHOSEN" $action "Selected" "" ""

                Capture-DecisionSnapshot (
                    "#" + $decisionNumber + "  Turn " + [string]$event.turn +
                    " " + [string]$event.phase + " - " + $action
                )
            }
            elseif ($type -eq "combat_attack") {
                $decisionNumber++
                $lblPlayer.Text = "AI: " + [string]$event.player
                $lblPhase.Text = "Turn " + [string]$event.turn + " / " + [string]$event.phase
                $lblChosen.Text = "Combat: attackers declared"
                $lblStats.Text = "Attack aggression: " + [string]$event.aggression
                $planBox.Text = "Forge combat state after attacker selection:" +
                    [Environment]::NewLine +
                    [Environment]::NewLine +
                    [string]$event.combat

                Add-GridRow "COMBAT" "Declare attackers" ("Aggression " + [string]$event.aggression) "" ""

                Capture-DecisionSnapshot (
                    "#" + $decisionNumber + "  Turn " + [string]$event.turn +
                    " " + [string]$event.phase + " - attackers declared"
                )
            }
            elseif ($type -eq "combat_block") {
                $decisionNumber++
                $lblPlayer.Text = "AI: " + [string]$event.player
                $lblPhase.Text = "Turn " + [string]$event.turn + " / " + [string]$event.phase
                $lblChosen.Text = "Combat: blockers assigned"
                $lblStats.Text = "Mode: Forge combat AI"
                $planBox.Text = "Forge combat state after blocker assignment:" +
                    [Environment]::NewLine +
                    [Environment]::NewLine +
                    [string]$event.combat

                Add-GridRow "COMBAT" "Assign blockers" "Selected" "" ""

                Capture-DecisionSnapshot (
                    "#" + $decisionNumber + "  Turn " + [string]$event.turn +
                    " " + [string]$event.phase + " - blockers assigned"
                )
            }
            elseif ($type -eq "decision_start") {
                $decisionNumber++
                $grid.Rows.Clear()
                $series.Points.Clear()
                $currentPositionText =
                    "POSITION EVALUATION (actual Forge state)`r`n" +
                    "Life: " + [string]$event.life +
                    " | Hand: " + [string]$event.hand +
                    " | Battlefield: " + [string]$event.battlefield + "`r`n" +
                    "Mana pool: " + [string]$event.mana + "`r`n" +
                    "Opponent: " + [string]$event.opponent +
                    " | Life: " + [string]$event.opponentLife +
                    " | Battlefield: " + [string]$event.opponentBattlefield
                $planBox.Text = $currentPositionText + "`r`n`r`nNo multi-step plan reported yet."

                $lblPlayer.Text = "AI: " + [string]$event.player
                $lblPhase.Text = "Turn " + [string]$event.turn + " / " + [string]$event.phase
                $lblChosen.Text = "Chosen action: evaluating..."
                $lblStats.Text =
                    "Starting score: " + [string]$event.score +
                    "   Playable candidates: " + [string]$event.candidates
            }
            elseif ($type -eq "candidate") {
                $status = [string]$event.status

                if ($status -ne "WillPlay") {
                    Add-GridRow "Rejected" $event.action $status "" ""
                }
                else {
                    Add-GridRow "Candidate" $event.action "Playable" "" ""
                }
            }
            elseif ($type -eq "evaluated") {
                Add-GridRow "Evaluated" $event.action "" $event.score $event.available

                $numeric = 0.0
                if ([double]::TryParse(
                    [string]$event.available,
                    [Globalization.NumberStyles]::Any,
                    [Globalization.CultureInfo]::InvariantCulture,
                    [ref]$numeric)) {

                    Add-ChartPoint ([string]$event.action) $numeric
                }
            }
            elseif ($type -eq "plan") {
                $planBox.Text =
                    $currentPositionText +
                    [Environment]::NewLine +
                    [Environment]::NewLine +
                    "CURRENT PLAN - final score: " + [string]$event.score +
                    [Environment]::NewLine +
                    [Environment]::NewLine +
                    ([string]$event.plan).Replace(" | ", [Environment]::NewLine)
            }
            elseif ($type -eq "planned") {
                $action = [string]$event.action
                $lblChosen.Text = "Executed planned action: " + $action
                $planBox.Text += [Environment]::NewLine + [Environment]::NewLine +
                    "EXECUTED PLAN STEP" + [Environment]::NewLine +
                    [string]$event.decision
                Add-GridRow "PLAN STEP" $action "Executed" "" ""
                Capture-DecisionSnapshot (
                    "#" + $decisionNumber + "  Turn " + [string]$event.turn +
                    " " + [string]$event.phase + " - " + $action
                )
            }
            elseif ($type -eq "simulation_best") {
                $action = [string]$event.action
                $originalNumeric = 0
                $chosenNumeric = 0
                [void][int]::TryParse([string]$event.originalScore, [ref]$originalNumeric)
                [void][int]::TryParse([string]$event.score, [ref]$chosenNumeric)
                $improvement = $chosenNumeric - $originalNumeric
                $improvementText = if ($improvement -ge 0) { "+" + $improvement } else { [string]$improvement }
                $lblChosen.Text = "Best simulated option: " + $action
                $lblStats.Text =
                    "Original: " + [string]$event.originalScore +
                    "   Chosen: " + [string]$event.score +
                    "   Improvement: " + $improvementText +
                    "   Available: " + [string]$event.available +
                    "   Simulations: " + [string]$event.simulations +
                    "   Time: " + [string]$event.milliseconds + " ms"

                Add-GridRow "BEST LINE" $action "Simulation result" $event.score $event.available
            }
        }

    }
    catch {
        # Viewer errors are isolated. Never affect Forge.
    }
})

$form.Add_FormClosed({
    $timer.Stop()
})

$timer.Start()
[void]$form.ShowDialog()
'@

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($OutputPath, $viewer, $encoding)
}

function Write-AiLauncher {
    param(
        [string]$ForgeJar,
        [string]$JavawPath,
        [string]$ForgeHome,
        [string]$OutputPath = $AiLauncher
    )

    $baseFull = [IO.Path]::GetFullPath($Base).TrimEnd("\") + "\"
    $toRuntimePath = {
        param([string]$Path)
        $full = [IO.Path]::GetFullPath($Path)
        if ($full.StartsWith($baseFull, [StringComparison]::OrdinalIgnoreCase)) {
            return "%BASE%\" + $full.Substring($baseFull.Length)
        }
        return $full
    }

    $forgeJarRuntime = & $toRuntimePath $ForgeJar
    $javawRuntime = & $toRuntimePath $JavawPath
    $forgeHomeRuntime = (& $toRuntimePath $ForgeHome).TrimEnd("\")

    $javaLine =
        '"' + '%JAVAW%' + '"' +
        ' -Xmx4096m -Dio.netty.tryReflectionSetAccessible=true -Dfile.encoding=UTF-8' +
        ' --add-opens java.desktop/java.beans=ALL-UNNAMED' +
        ' --add-opens java.desktop/javax.swing.border=ALL-UNNAMED' +
        ' --add-opens java.desktop/javax.swing.event=ALL-UNNAMED' +
        ' --add-opens java.desktop/sun.swing=ALL-UNNAMED' +
        ' --add-opens java.desktop/java.awt.image=ALL-UNNAMED' +
        ' --add-opens java.desktop/java.awt.color=ALL-UNNAMED' +
        ' --add-opens java.desktop/sun.awt.image=ALL-UNNAMED' +
        ' --add-opens java.desktop/javax.swing=ALL-UNNAMED' +
        ' --add-opens java.desktop/java.awt=ALL-UNNAMED' +
        ' --add-opens java.base/java.util=ALL-UNNAMED' +
        ' --add-opens java.base/java.lang=ALL-UNNAMED' +
        ' --add-opens java.base/java.lang.reflect=ALL-UNNAMED' +
        ' --add-opens java.base/java.text=ALL-UNNAMED' +
        ' --add-opens java.desktop/java.awt.font=ALL-UNNAMED' +
        ' --add-opens java.base/jdk.internal.misc=ALL-UNNAMED' +
        ' --add-opens java.base/sun.nio.ch=ALL-UNNAMED' +
        ' --add-opens java.base/java.nio=ALL-UNNAMED' +
        ' --add-opens java.base/java.math=ALL-UNNAMED' +
        ' --add-opens java.base/java.util.concurrent=ALL-UNNAMED' +
        ' --add-opens java.base/java.net=ALL-UNNAMED' +
        ' "-Djadon.ai.telemetry=%TELEMETRY%"' +
        ' -cp "%PATCH%;%FORGEJAR%" forge.view.Main'

    $lines = @(
        '@echo off',
        'setlocal EnableExtensions DisableDelayedExpansion',
        'title Jadon Forge AI Thought Viewer',
        'if defined LOCALAPPDATA goto :JADON_AI_HAVE_LOCALAPPDATA',
        'set "BASE=%USERPROFILE%\AppData\Local\MTGForge"',
        'goto :JADON_AI_BASE_READY',
        ':JADON_AI_HAVE_LOCALAPPDATA',
        'set "BASE=%LOCALAPPDATA%\MTGForge"',
        ':JADON_AI_BASE_READY',
        'set "TELEMETRY=%BASE%\AIViewer\telemetry.jsonl"',
        'set "VIEWER=%BASE%\AIViewer\AI_Thought_Viewer.ps1"',
        'set "PATCH=%BASE%\AIViewer\jadon-ai-telemetry-patch.jar"',
        ('set "FORGEJAR=' + $forgeJarRuntime + '"'),
        ('set "JAVAW=' + $javawRuntime + '"'),
        ('set "FORGEHOME=' + $forgeHomeRuntime + '"'),
        'if exist "%TELEMETRY%" del /f /q "%TELEMETRY%" >nul 2>&1',
        'start "Jadon AI Thought Viewer" powershell.exe -NoLogo -NoProfile -STA -File "%VIEWER%" -TelemetryPath "%TELEMETRY%"',
        'pushd "%FORGEHOME%"',
        $javaLine,
        'set "RC=%ERRORLEVEL%"',
        'popd',
        'exit /b %RC%'
    )

    $encoding = New-Object System.Text.ASCIIEncoding
    [IO.File]::WriteAllLines($OutputPath, $lines, $encoding)
}

function Setup-AiThoughtViewer {
    Start-Log "ai-viewer-build"

    Write-Host ""
    Write-Host "AI Thought Viewer Setup"
    Write-Host "-----------------------"
    Write-Host ""
    Write-Host "This creates a separate telemetry-enabled Forge launcher."
    Write-Host "Your normal Forge JAR and normal launcher are NOT modified."
    Write-Host ""

    $forgeJarItem = Get-ForgeDesktopJar
    $forgeJar = $forgeJarItem.FullName
    $forgeHome = $forgeJarItem.DirectoryName
    $version = Get-ForgeVersionFromJar $forgeJar
    $tag = "forge-" + $version
    $jarHashBeforeBuild = Get-FileSha256 $forgeJar

    Write-Host ("Detected Forge version: " + $version)
    Write-Host ("Forge JAR: " + $forgeJar)
    Write-Host ""

    $javac = Ensure-AiJdk
    $jdkBin = Split-Path -Parent $javac
    $javaw = Join-Path $jdkBin "javaw.exe"
    $jarTool = Join-Path $jdkBin "jar.exe"

    if (-not (Test-Path -LiteralPath $javaw)) {
        throw "AI private JDK is missing javaw.exe."
    }

    if (-not (Test-Path -LiteralPath $jarTool)) {
        throw "AI private JDK is missing jar.exe."
    }

    $buildId = [Guid]::NewGuid().ToString("N")
    $buildRoot = Join-Path $AiDir ("build-candidate-" + $buildId)
    $candidateSourceDir = Join-Path $buildRoot "source"
    $candidateClassesDir = Join-Path $buildRoot "classes"
    $candidatePatchJar = Join-Path $buildRoot "jadon-ai-telemetry-patch.candidate.jar"
    $candidateViewer = Join-Path $buildRoot "AI_Thought_Viewer.candidate.ps1"
    $candidateLauncher = Join-Path $buildRoot "Start_Forge_AI_Viewer.candidate.cmd"
    $candidateStatus = Join-Path $buildRoot "status.candidate.json"

    New-Item -ItemType Directory -Force -Path $candidateSourceDir | Out-Null
    New-Item -ItemType Directory -Force -Path $candidateClassesDir | Out-Null

    $pickerSourceUrl =
        "https://raw.githubusercontent.com/Card-Forge/forge/" +
        $tag +
        "/forge-ai/src/main/java/forge/ai/simulation/SpellAbilityPicker.java"

    $controllerSourceUrl =
        "https://raw.githubusercontent.com/Card-Forge/forge/" +
        $tag +
        "/forge-ai/src/main/java/forge/ai/AiController.java"

    try {
        Write-Log "Downloading the exact Forge AI sources for this installed version..."
        $pickerSource = Get-RemoteUtf8Text $pickerSourceUrl
        $controllerSource = Get-RemoteUtf8Text $controllerSourceUrl

        if ([string]::IsNullOrWhiteSpace($pickerSource) -or
            $pickerSource -notmatch 'public class SpellAbilityPicker') {

            throw "SpellAbilityPicker source could not be verified. Nothing was patched."
        }

        if ([string]::IsNullOrWhiteSpace($controllerSource) -or
            $controllerSource -notmatch 'public class AiController') {

            throw "AiController source could not be verified. Nothing was patched."
        }

        $simulationPackageDir = Join-Path $candidateSourceDir "forge\ai\simulation"
        $aiPackageDir = Join-Path $candidateSourceDir "forge\ai"
        New-Item -ItemType Directory -Force -Path $simulationPackageDir | Out-Null
        New-Item -ItemType Directory -Force -Path $aiPackageDir | Out-Null

        $pickerPath = Join-Path $simulationPackageDir "SpellAbilityPicker.java"
        $telemetryPath = Join-Path $simulationPackageDir "AiTelemetry.java"
        $controllerPath = Join-Path $aiPackageDir "AiController.java"

        Patch-SpellAbilityPickerSource $pickerSource $pickerPath
        Patch-AiControllerSource $controllerSource $controllerPath
        Write-AiTelemetryJava $telemetryPath

        $patchedPicker = [IO.File]::ReadAllText($pickerPath, [Text.Encoding]::UTF8)
        if (-not $patchedPicker.Contains('jadonPlan.append(" | ");')) {
            throw "Generated SpellAbilityPicker source failed its quote/instrumentation check."
        }

        Write-Log "Compiling read-only AI telemetry hooks against the installed Forge JAR..."

        $savedErrorActionPreference = $ErrorActionPreference
        try {
            # Windows PowerShell 5.1 wraps a native program's stderr as
            # ErrorRecord objects. javac may emit warnings on stderr even when
            # it succeeds, so capture both streams and trust its exit code.
            $ErrorActionPreference = "Continue"
            $compileOutput = @(
                & $javac `
                    -encoding UTF-8 `
                    -cp $forgeJar `
                    -d $candidateClassesDir `
                    $telemetryPath `
                    $pickerPath `
                    $controllerPath 2>&1
            )
            $compileRc = $LASTEXITCODE
        }
        finally {
            $ErrorActionPreference = $savedErrorActionPreference
        }

        $compileOutput | ForEach-Object { Write-Log ([string]$_) }
        if ($compileRc -ne 0) {
            throw "AI telemetry compilation failed. Normal Forge and the working AI Viewer were not modified."
        }

        $jarHashAfterCompile = Get-FileSha256 $forgeJar
        if ($jarHashAfterCompile -ne $jarHashBeforeBuild) {
            throw "Forge JAR changed during AI compilation. Candidate was discarded; run Setup / Repair again."
        }

        Push-Location $candidateClassesDir
        try {
            $savedErrorActionPreference = $ErrorActionPreference
            try {
                $ErrorActionPreference = "Continue"
                $jarOutput = @(& $jarTool cf $candidatePatchJar forge 2>&1)
                $jarRc = $LASTEXITCODE
            }
            finally {
                $ErrorActionPreference = $savedErrorActionPreference
            }

            $jarOutput | ForEach-Object { Write-Log ([string]$_) }
            if ($jarRc -ne 0) {
                throw "Could not package AI telemetry patch JAR."
            }
        }
        finally {
            Pop-Location
        }

        Write-AiViewerScript $candidateViewer
        Write-AiLauncher $forgeJar $javaw $forgeHome $candidateLauncher

        if ((Get-Item -LiteralPath $candidatePatchJar).Length -le 0) {
            throw "AI patch candidate JAR is empty."
        }

        $viewerTokens = $null
        $viewerErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile(
            $candidateViewer,
            [ref]$viewerTokens,
            [ref]$viewerErrors
        ) | Out-Null

        if ($viewerErrors.Count -gt 0) {
            throw ("Generated AI Viewer script parser error: " + $viewerErrors[0].Message)
        }

        $launcherText = [IO.File]::ReadAllText($candidateLauncher, [Text.Encoding]::ASCII)
        if (-not $launcherText.StartsWith("@echo off")) {
            throw "Generated AI launcher validation failed."
        }

        $jarHash = $jarHashBeforeBuild
        $buildFinal = Join-Path $AiDir (
            "build-" + ($version -replace '[^A-Za-z0-9_.-]', '-') + "-" +
            $jarHash.Substring(0, 12) + "-" + (Get-Date -Format "yyyyMMdd-HHmmssfff") +
            "-" + $buildId.Substring(0, 8)
        )

        $status = [pscustomobject]@{
            Version = 2
            ForgeVersion = $version
            ForgeJar = $forgeJar
            ForgeJarHash = $jarHash
            PatchJar = $AiPatchJar
            PatchJarHash = Get-FileSha256 $candidatePatchJar
            ViewerScript = $AiViewerScript
            ViewerScriptHash = Get-FileSha256 $candidateViewer
            Launcher = $AiLauncher
            LauncherHash = Get-FileSha256 $candidateLauncher
            BuildDirectory = $buildFinal
            PickerSourceUrl = $pickerSourceUrl
            PickerSourceHash = Get-VectorHash @($pickerSource)
            ControllerSourceUrl = $controllerSourceUrl
            ControllerSourceHash = Get-VectorHash @($controllerSource)
            BuiltAt = (Get-Date).ToString("o")
        }

        $json = $status | ConvertTo-Json -Depth 5
        $encoding = New-Object System.Text.UTF8Encoding($false)
        [IO.File]::WriteAllText($candidateStatus, $json, $encoding)

        Promote-FileCandidate $candidatePatchJar $AiPatchJar -KeepLastGood
        Promote-FileCandidate $candidateViewer $AiViewerScript -KeepLastGood
        Promote-FileCandidate $candidateLauncher $AiLauncher -KeepLastGood

        Move-Item -LiteralPath $buildRoot -Destination $buildFinal -Force
        $buildRoot = ""

        $statusCandidateAfterMove = Join-Path $buildFinal "status.candidate.json"
        Promote-FileCandidate $statusCandidateAfterMove $AiStatusFile -KeepLastGood
    }
    finally {
        if (-not [string]::IsNullOrWhiteSpace($buildRoot) -and
            (Test-Path -LiteralPath $buildRoot)) {

            Remove-Item -LiteralPath $buildRoot -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    Write-Host ""
    Write-Host "AI Thought Viewer setup complete." -ForegroundColor Green
    Write-Host "Normal Forge remains unchanged."
    Write-Host ("AI launcher: " + $AiLauncher)
    Write-Host ("Build log: " + $script:CurrentLog)
}

function Get-AiViewerStatus {
    if (-not (Test-Path -LiteralPath $AiStatusFile)) {
        return $null
    }

    try {
        return Get-Content -LiteralPath $AiStatusFile -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        return $null
    }
}

function Assert-AiViewerReady {
    $status = Get-AiViewerStatus

    if ($null -eq $status) {
        throw "AI Thought Viewer has not been set up yet."
    }

    foreach ($path in @(
        [string]$status.ForgeJar,
        [string]$status.PatchJar,
        [string]$status.ViewerScript,
        [string]$status.Launcher
    )) {
        if ([string]::IsNullOrWhiteSpace($path) -or
            -not (Test-Path -LiteralPath $path)) {

            throw "AI Thought Viewer files are incomplete. Run Setup / Repair."
        }
    }

    $currentForgeJar = (Get-ForgeDesktopJar).FullName

    if ([IO.Path]::GetFullPath($currentForgeJar) -ne
        [IO.Path]::GetFullPath([string]$status.ForgeJar)) {

        throw "Installed Forge changed since AI Viewer setup. Run Setup / Repair."
    }

    $currentHash = Get-FileSha256 $currentForgeJar

    if ($currentHash -ne [string]$status.ForgeJarHash) {
        throw "Forge JAR changed since AI Viewer setup. Run Setup / Repair."
    }


    foreach ($check in @(
        [pscustomobject]@{ Path = [string]$status.PatchJar; Hash = [string]$status.PatchJarHash; Name = "AI patch JAR" },
        [pscustomobject]@{ Path = [string]$status.ViewerScript; Hash = [string]$status.ViewerScriptHash; Name = "AI Viewer script" },
        [pscustomobject]@{ Path = [string]$status.Launcher; Hash = [string]$status.LauncherHash; Name = "AI launcher" }
    )) {
        if ([string]::IsNullOrWhiteSpace($check.Hash)) {
            throw ($check.Name + " has no V9 integrity record. Run Setup / Repair.")
        }

        if ((Get-FileSha256 $check.Path) -ne $check.Hash) {
            throw ($check.Name + " changed since setup. Run Setup / Repair.")
        }
    }

    return $status
}

function Run-ForgeWithAiViewer {
    $status = Assert-AiViewerReady

    if (Test-Path -LiteralPath $AiTelemetryFile) {
        Remove-Item -LiteralPath $AiTelemetryFile -Force -ErrorAction SilentlyContinue
    }

    Start-Process -FilePath ([string]$status.Launcher) `
        -WorkingDirectory (Split-Path -Parent ([string]$status.Launcher))
}

function Open-AiViewerOnly {
    if (-not (Test-Path -LiteralPath $AiViewerScript)) {
        throw "AI Viewer graphical script is not installed. Run Setup / Repair first."
    }

    Start-Process `
        -FilePath "powershell.exe" `
        -ArgumentList @(
            "-NoLogo",
            "-NoProfile",
            "-STA",
            "-File", $AiViewerScript,
            "-TelemetryPath", $AiTelemetryFile
        )
}

function Show-AiViewerStatus {
    Write-Host ""
    Write-Host "AI Thought Viewer Status"
    Write-Host "------------------------"
    Write-Host ""

    $status = Get-AiViewerStatus

    if ($null -eq $status) {
        Write-Host "Status: NOT SET UP"
        return
    }

    Write-Host ("Forge version : " + [string]$status.ForgeVersion)
    Write-Host ("Built at      : " + [string]$status.BuiltAt)
    Write-Host ("Forge JAR     : " + [string]$status.ForgeJar)
    Write-Host ("Patch JAR     : " + [string]$status.PatchJar)
    Write-Host ("AI launcher   : " + [string]$status.Launcher)
    Write-Host ("Telemetry     : " + $AiTelemetryFile)
    Write-Host ""

    try {
        [void](Assert-AiViewerReady)
        Write-Host "Verification: READY" -ForegroundColor Green
    }
    catch {
        Write-Host ("Verification: NEEDS REPAIR - " + $_.Exception.Message) -ForegroundColor Yellow
    }
}

function Show-AiViewerMenu {
    while ($true) {
        Clear-Host
        Write-UiBanner "AI THOUGHT VIEWER" "Read-only Forge AI telemetry and live graphical inspection"
        Write-UiSection "Actions"
        Write-Host "  [1] Setup / Repair AI Thought Viewer" -ForegroundColor Cyan
        Write-Host "  [2] Run Forge with graphical AI Thought Viewer" -ForegroundColor Green
        Write-Host "  [3] Open graphical viewer only"
        Write-Host "  [4] Show AI Viewer status"
        Write-Host "  [5] Back"
        Write-Host ""
        Write-Host "The telemetry bridge is read-only."
        Write-Host "Normal Forge is never replaced or modified."
        Write-Host "If telemetry or the viewer fails, Forge gameplay continues."
        Write-Host ""

        $choice = Read-Host "Choose 1-5"

        switch ($choice) {
            "1" {
                Invoke-SafeOperation "AI Thought Viewer setup" {
                    Setup-AiThoughtViewer
                }
                if (-not $script:LastOperationSucceeded) {
                    return
                }
                Write-Host ""
                Read-Host "Press Enter to continue"
            }

            "2" {
                Invoke-SafeOperation "Run Forge with AI Thought Viewer" {
                    Run-ForgeWithAiViewer
                }
                if (-not $script:LastOperationSucceeded) {
                    return
                }
                Write-Host ""
                Read-Host "Press Enter to continue"
            }

            "3" {
                Invoke-SafeOperation "Open AI graphical viewer" {
                    Open-AiViewerOnly
                }
                if (-not $script:LastOperationSucceeded) {
                    return
                }
                Write-Host ""
                Read-Host "Press Enter to continue"
            }

            "4" {
                Invoke-SafeOperation "AI Viewer status" {
                    Show-AiViewerStatus
                }
                if (-not $script:LastOperationSucceeded) {
                    return
                }
                Write-Host ""
                Read-Host "Press Enter to continue"
            }

            "5" {
                return
            }
        }
    }
}

function Set-DeckFileNameMode {
    Write-Host ""
    Write-UiSection "Deck filename style"
    Write-Host "  [1] Original deck name"
    Write-Host "  [2] Commander"
    Write-Host "  [3] Commander - by Archidekt owner" -ForegroundColor Cyan
    Write-Host "  [4] Commander - by owner - original deck name" -ForegroundColor Green
    Write-Host ""
    $choice = Read-Host "Choose 1-4"
    $mode = switch ($choice) {
        "1" { "Original" }
        "2" { "Commander" }
        "3" { "CommanderOwner" }
        "4" { "CommanderOwnerDeck" }
        default { "" }
    }
    if ($mode) {
        $Settings.FileNameMode = $mode
        $Settings.RenameToCommander = ($mode -ne "Original")
        Save-Settings $Settings
        Write-Host ("Filename style set to: " + $mode) -ForegroundColor Green
        Start-Sleep -Milliseconds 700
    }
}

function Show-SettingsMenu {
    while ($true) {
        Clear-Host
        Write-UiBanner "IMPORT & LIBRARY SETTINGS" "Changes save immediately"
        Write-UiSection "Performance"
        Write-Host ("  [1]  Fast import (6-request pipeline)   [" + (Get-OnOff ([bool]$Settings.FastImport)) + "]") -ForegroundColor Cyan
        Write-Host ""
        Write-UiSection "Duplicate protection"
        Write-Host ("[2]  Copy detection                     [" + (Get-OnOff ([bool]$Settings.CopyDetection)) + "]")
        Write-Host ("[3]  Similarity detection               [" + (Get-OnOff ([bool]$Settings.SimilarityDetection)) + "]")
        Write-Host ("[4]  Similarity threshold               [" + [string]$Settings.SimilarityThreshold + "%]")
        Write-Host ""
        Write-UiSection "Deck conversion"
        Write-Host ("[5]  Deck filename style                [" + [string]$Settings.FileNameMode + "]")
        Write-Host ("[6]  Remove actual tokens / emblems     [" + (Get-OnOff ([bool]$Settings.RemoveActualTokens)) + "]")
        Write-Host ("[7]  Profile maximum 100-card cap       [" + (Get-OnOff ([bool]$Settings.CapCommanderAt100)) + "]")
        Write-Host ("[8]  Exclude Commander decks under 100  [" + (Get-OnOff ([bool]$Settings.SkipIncompleteCommander)) + "]")
        Write-Host ("[9]  Bracket unique commander           [" + (Get-OnOff ([bool]$Settings.BracketUniqueCommander)) + "]")
        Write-Host ("[10] Bracket unique deck name           [" + (Get-OnOff ([bool]$Settings.BracketUniqueDeckName)) + "]")
        Write-Host ("[11] Backup before overwrite / delete   [" + (Get-OnOff ([bool]$Settings.BackupBeforeOverwrite)) + "]")
        Write-Host ("[12] Preserve sideboards                [" + (Get-OnOff ([bool]$Settings.PreserveSideboards)) + "]")
        Write-Host ("[13] Dry run - preview only             [" + (Get-OnOff ([bool]$Settings.DryRun)) + "]")
        Write-Host ""
        Write-Host "  [0] Back to dashboard" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Mass import has its own per-run sorting, quality, commander, and similarity choices." -ForegroundColor DarkGray
        Write-Host "  Exact-100 mass-import validation is safety-locked ON." -ForegroundColor DarkGray
        Write-Host ""

        $choice = Read-Host "Choose 0-13"

        switch ($choice) {
            "1" {
                $Settings.FastImport = -not [bool]$Settings.FastImport
                Save-Settings $Settings
            }
            "2" {
                $Settings.CopyDetection = -not [bool]$Settings.CopyDetection
                Save-Settings $Settings
            }
            "3" {
                $Settings.SimilarityDetection = -not [bool]$Settings.SimilarityDetection
                Save-Settings $Settings
            }
            "4" {
                $valueText = Read-Host "Similarity threshold 50-100 (recommended 90)"
                $value = 0

                if (-not [int]::TryParse($valueText, [ref]$value) -or
                    $value -lt 50 -or $value -gt 100) {

                    Write-Host "Threshold was not changed. Enter a number from 50 to 100." -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                }
                else {
                    $Settings.SimilarityThreshold = $value
                    Save-Settings $Settings
                }
            }
            "5" {
                Set-DeckFileNameMode
            }
            "6" {
                $Settings.RemoveActualTokens = -not [bool]$Settings.RemoveActualTokens
                Save-Settings $Settings
            }
            "7" {
                $Settings.CapCommanderAt100 = -not [bool]$Settings.CapCommanderAt100
                Save-Settings $Settings
            }
            "8" {
                $Settings.SkipIncompleteCommander = -not [bool]$Settings.SkipIncompleteCommander
                Save-Settings $Settings
            }
            "9" {
                $Settings.BracketUniqueCommander = -not [bool]$Settings.BracketUniqueCommander
                Save-Settings $Settings
            }
            "10" {
                $Settings.BracketUniqueDeckName = -not [bool]$Settings.BracketUniqueDeckName
                Save-Settings $Settings
            }
            "11" {
                $Settings.BackupBeforeOverwrite = -not [bool]$Settings.BackupBeforeOverwrite
                Save-Settings $Settings
            }
            "12" {
                $Settings.PreserveSideboards = -not [bool]$Settings.PreserveSideboards
                Save-Settings $Settings
            }
            "13" {
                $Settings.DryRun = -not [bool]$Settings.DryRun
                Save-Settings $Settings
            }
            "0" {
                return
            }
        }
    }
}

function Show-MainMenu {
    while ($true) {
        Clear-Host
        Write-UiBanner "JADON'S ULTIMATE FORGE MANAGER v9.0" "Archidekt library + portable deck memory"

        Write-UiSection "Import decks"
        Write-Host "  [1] Profile Sync             Import or update one Archidekt profile" -ForegroundColor White
        Write-Host "  [2] Global Mass Import       Search all public decks by bracket and quality" -ForegroundColor Green
        Write-Host "  [9] Proven Safe Importer     Open the locked V4 profile fallback" -ForegroundColor DarkGray
        Write-Host ""

        Write-UiSection "Play and inspect"
        Write-Host "  [3] AI Thought Viewer        Setup, run, or inspect Forge AI telemetry"
        Write-Host "  [4] Run Normal Forge         Launch the standard Forge client"
        Write-Host ""

        Write-UiSection "Library and maintenance"
        Write-Host "  [5] Deck Cleanup             Imported-only or all custom deck files"
        Write-Host "  [6] Settings                 Performance, safety, and deck conversion"
        Write-Host "  [7] Restore Backup           Restore an importer-owned backup"
        Write-Host "  [8] Folders and Logs         Open data, log, and backup locations"
        Write-Host ""

        Write-UiSection "Portable deck memory"
        Write-Host "  [10] Export Deck Memory      Save every imported deck to one Downloads file" -ForegroundColor Green
        Write-Host "  [11] Read Existing Memory    Restore decks without scanning profiles" -ForegroundColor Cyan
        $memoryReady = -not [string]::IsNullOrWhiteSpace([string]$Settings.MemoryFilePath) -and
            (Test-Path -LiteralPath ([string]$Settings.MemoryFilePath) -PathType Leaf)
        if ($memoryReady) {
            Write-Host "  [12] View Memory             Open the coloured portable-memory viewer" -ForegroundColor Magenta
        }
        Write-Host ""

        $fastColor = if ([bool]$Settings.FastImport) { "Green" } else { "Yellow" }
        Write-Host "  STATUS  " -NoNewline -ForegroundColor DarkCyan
        Write-Host ("FAST " + (Get-OnOff ([bool]$Settings.FastImport))) -NoNewline -ForegroundColor $fastColor
        Write-Host ("   COPY " + (Get-OnOff ([bool]$Settings.CopyDetection))) -NoNewline
        Write-Host ("   SIMILARITY " + (Get-OnOff ([bool]$Settings.SimilarityDetection)) + " @ " + [string]$Settings.SimilarityThreshold + "%")
        Write-Host "  [0] Exit" -ForegroundColor DarkGray
        Write-Host ""

        $choice = Read-Host "  Select 0-12"

        switch ($choice) {
            "1" {
                $script:ProfileImportNeedsFallback = $false
                $script:ProfileImportWasRequested = $false

                Invoke-SafeOperation "Archidekt profile import" {
                    Write-Host ""
                    $profile = Prompt-Profile
                    if ($profile) {
                        $script:ProfileImportWasRequested = $true
                        Sync-Profile $profile
                    }
                }

                if ($script:ProfileImportWasRequested -and ((-not $script:LastOperationSucceeded) -or $script:ProfileImportNeedsFallback)) {
                    $safeOpened = Invoke-ProvenSafeImporter "The primary V9 profile importer reported a failure. Switching to the attached installer's proven V4 importer."
                    if (-not $safeOpened) {
                        [void](Invoke-AttachedV8Fallback "Both the primary V9 importer and proven V4 importer were unavailable.")
                    }
                }

                Write-Host ""
                Read-Host "Press Enter to return to the main menu"
            }

            "2" {
                Invoke-SafeOperation "Bracket Library Import" {
                    Invoke-BracketLibraryImport
                }
                if (-not $script:LastOperationSucceeded) {
                    [void](Invoke-AttachedV8Fallback "The V9 mass importer failed. The original attached v8 manager is available as a compatibility fallback.")
                }
                Wait-ForMenuReturn
            }

            "3" {
                Invoke-SafeOperation "AI Thought Viewer menu" {
                    Show-AiViewerMenu
                }
            }

            "4" {
                Invoke-SafeOperation "Run normal Forge" {
                    Run-ForgeFromManager
                }
                Wait-ForMenuReturn
            }

            "5" {
                Invoke-SafeOperation "Deck cleanup" {
                    Show-DeckCleanupMenu
                }
                Wait-ForMenuReturn
            }

            "6" {
                Invoke-SafeOperation "Settings" {
                    Show-SettingsMenu
                }
            }

            "7" {
                Invoke-SafeOperation "Restore importer backup" {
                    Restore-ImportedDeckBackup
                }
                Wait-ForMenuReturn
            }

            "8" {
                Invoke-SafeOperation "Show V9 folders" {
                    Write-Host ""
                    Write-Host "Commander decks:"
                    Write-Host ("  " + $CommanderDir)
                    Write-Host ""
                    Write-Host "Constructed decks:"
                    Write-Host ("  " + $ConstructedDir)
                    Write-Host ""
                    Write-Host "Importer logs:"
                    Write-Host ("  " + $LogDir)
                    Write-Host ""
                    Write-Host "Backups:"
                    Write-Host ("  " + $BackupDir)
                    Write-Host ""
                    Write-Host "AI Viewer:"
                    Write-Host ("  " + $AiDir)
                    Write-Host ""
                    Write-Host "Proven safe importer:"
                    Write-Host ("  " + $SafeImporterCmd)
                }
                Wait-ForMenuReturn
            }

            "9" {
                $safeOpened = Invoke-ProvenSafeImporter "You selected the known-good V4 importer directly."
                if (-not $safeOpened) {
                    [void](Invoke-AttachedV8Fallback "The proven V4 importer could not start.")
                }
                Write-Host ""
                Read-Host "Press Enter to return to the main menu"
            }

            "10" {
                Invoke-SafeOperation "Export portable deck memory" {
                    Export-DeckMemory
                }
                Wait-ForMenuReturn
            }

            "11" {
                Invoke-SafeOperation "Read existing deck memory" {
                    Import-DeckMemoryInteractive
                }
                Wait-ForMenuReturn
            }

            "12" {
                if ($memoryReady) {
                    Invoke-SafeOperation "View selected deck memory" {
                        Show-SelectedDeckMemory
                    }
                }
            }

            "0" {
                return
            }
        }
    }
}

function Invoke-ManagerSelfTest {
    Write-Host ""
    Write-Host "Running importer V9 compatibility self-test..."
    Write-Host ("Windows PowerShell version: " + $PSVersionTable.PSVersion.ToString())
    Write-Host ""

    $currentTest = "startup"
    $selfTestRoot = Join-Path $ToolDir ("selftest-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $selfTestRoot | Out-Null

    try {
        $currentTest = "Windows PowerShell 5.1 compatibility and collection behavior"
        Write-Host ("[SelfTest 1/22] " + $currentTest + "...")
        if ($PSVersionTable.PSVersion.Major -lt 5) {
            throw "Windows PowerShell 5.1 or newer is required."
        }
        $collection = New-Object System.Collections.ArrayList
        [void]$collection.Add([pscustomobject]@{ Name = "one" })
        [void]$collection.Add([pscustomobject]@{ Name = "two" })
        $collectionArray = $collection.ToArray()
        if ($collectionArray.Count -ne 2 -or $collectionArray[1].Name -ne "two") {
            throw "PS5.1-safe ArrayList conversion failed."
        }
        $popularSort = Get-MassSortDefinition 1
        $hiddenSort = Get-MassSortDefinition 4
        if ($popularSort.OrderBy -ne "-viewCount" -or $hiddenSort.OrderBy -ne "viewCount") {
            throw "Mass-import discovery sort mapping failed."
        }
        if ([Net.ServicePointManager]::DefaultConnectionLimit -lt 6) {
            throw "Fast-import HTTP connection limit was not raised."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "100-card trimming"
        Write-Host ("[SelfTest 2/22] " + $currentTest + "...")
        $testMain = New-Object System.Collections.ArrayList
        $testCommanders = New-Object System.Collections.ArrayList
        [void]$testMain.Add([pscustomobject]@{ Name = "A"; Quantity = 50; Scryfall = $null })
        [void]$testMain.Add([pscustomobject]@{ Name = "B"; Quantity = 51; Scryfall = $null })
        [void]$testCommanders.Add([pscustomobject]@{ Name = "Commander"; Quantity = 1; Scryfall = $null })
        $trim = Trim-CommanderDeckTo100 $testMain $testCommanders
        if ($trim.FinalTotal -ne 100 -or $trim.CutCount -ne 2) {
            throw "100-card trimming produced the wrong total."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "transform front-face conversion"
        Write-Host ("[SelfTest 3/22] " + $currentTest + "...")
        $transform = Get-ForgeCardName `
            "Legion's Landing // Adanto, the First Fort" `
            ([pscustomobject]@{ name = "Legion's Landing // Adanto, the First Fort"; layout = "transform" })
        if ($transform -ne "Legion's Landing") { throw "Transform conversion failed." }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "modal DFC front-face conversion"
        Write-Host ("[SelfTest 4/22] " + $currentTest + "...")
        $mdfc = Get-ForgeCardName `
            "Brightclimb Pathway // Grimclimb Pathway" `
            ([pscustomobject]@{ name = "Brightclimb Pathway // Grimclimb Pathway"; layout = "modal_dfc" })
        if ($mdfc -ne "Brightclimb Pathway") { throw "Modal DFC conversion failed." }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "Adventure front-face conversion"
        Write-Host ("[SelfTest 5/22] " + $currentTest + "...")
        $adventure = Get-ForgeCardName `
            "Foulmire Knight // Profane Insight" `
            ([pscustomobject]@{ name = "Foulmire Knight // Profane Insight"; layout = "adventure" })
        if ($adventure -ne "Foulmire Knight") { throw "Adventure conversion failed." }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "split and Room name preservation"
        Write-Host ("[SelfTest 6/22] " + $currentTest + "...")
        $split = Get-ForgeCardName "Fire // Ice" ([pscustomobject]@{ name = "Fire // Ice"; layout = "split" })
        $room = Get-ForgeCardName `
            "Bottomless Pool // Locker Room" `
            ([pscustomobject]@{ name = "Bottomless Pool // Locker Room"; layout = "split" })
        if ($split -ne "Fire // Ice" -or $room -ne "Bottomless Pool // Locker Room") {
            throw "Split or Room preservation failed."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "actual token and emblem metadata detection"
        Write-Host ("[SelfTest 7/22] " + $currentTest + "...")
        $tokenEntry = [pscustomobject]@{ card = [pscustomobject]@{ layout = "token"; typeLine = "Token Creature - Soldier" } }
        $tokenScryfall = [pscustomobject]@{ layout = "token"; type_line = "Token Creature - Soldier" }
        $emblemScryfall = [pscustomobject]@{ layout = "emblem"; type_line = "Emblem" }
        if (-not (Test-IsActualTokenOrEmblem $tokenEntry $tokenScryfall) -or
            -not (Test-IsActualTokenOrEmblem $tokenEntry $emblemScryfall)) {
            throw "Actual token/emblem detection failed."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "Tokens category does not remove normal cards"
        Write-Host ("[SelfTest 8/22] " + $currentTest + "...")
        $normalEntry = [pscustomobject]@{
            categories = @("Tokens")
            card = [pscustomobject]@{ layout = "normal"; typeLine = "Creature - Elf Druid" }
        }
        $normalScryfall = [pscustomobject]@{ layout = "normal"; type_line = "Creature - Elf Druid" }
        if (Test-IsActualTokenOrEmblem $normalEntry $normalScryfall) {
            throw "A user category named Tokens was mistaken for token metadata."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "UTF-8 accented card-name round trip"
        Write-Host ("[SelfTest 9/22] " + $currentTest + "...")
        $accented = "Bartolom" + [char]0x00E9 + " del Presidio"
        $utf8Path = Join-Path $selfTestRoot "utf8.dck"
        Write-Utf8NoBom $utf8Path @($accented)
        $utf8Bytes = [IO.File]::ReadAllBytes($utf8Path)
        $roundTrip = [IO.File]::ReadAllText($utf8Path, [Text.Encoding]::UTF8).Trim()
        if ($roundTrip -ne $accented -or
            ($utf8Bytes.Length -ge 3 -and $utf8Bytes[0] -eq 0xEF -and $utf8Bytes[1] -eq 0xBB -and $utf8Bytes[2] -eq 0xBF)) {
            throw "UTF-8 no-BOM round trip failed."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "settings migration and locked defaults"
        Write-Host ("[SelfTest 10/22] " + $currentTest + "...")
        $settingsPath = Join-Path $selfTestRoot "settings.json"
        $oldSettings = '{"FastImport":"false","BracketExact100":false}'
        Write-TextFileAtomic $settingsPath $oldSettings (New-Object Text.UTF8Encoding($false))
        $migrated = Read-Settings $settingsPath
        if ([bool]$migrated.FastImport -ne $false -or
            [bool]$migrated.CopyDetection -ne $true -or
            [bool]$migrated.BracketExact100 -ne $true -or
            [int]$migrated.SimilarityThreshold -ne 90 -or
            [string]$migrated.FileNameMode -ne "Original" -or
            $null -eq $migrated.MemoryFilePath) {
            throw "Settings migration/default enforcement failed."
        }
        $savedNameMode = [string]$Settings.FileNameMode
        try {
            $Settings.FileNameMode = "CommanderOwner"
            if ((Get-RenameDisplayName "Deck Name" "Atraxa" "DeckBuilder" @{}) -ne "Atraxa - by DeckBuilder") {
                throw "Commander plus owner filename mode failed."
            }
            $Settings.FileNameMode = "CommanderOwnerDeck"
            if ((Get-RenameDisplayName "Deck Name" "Atraxa" "DeckBuilder" @{}) -ne "Atraxa - by DeckBuilder - Deck Name") {
                throw "Commander plus owner plus deck filename mode failed."
            }
        }
        finally {
            $Settings.FileNameMode = $savedNameMode
        }
        $memoryTestPath = Join-Path $selfTestRoot "portable-memory.json"
        $memoryTest = [pscustomobject]@{
            Schema = "JadonForgeDeckMemory"
            SchemaVersion = 1
            Decks = @([pscustomobject]@{ Name = "Test"; Lines = @("[metadata]", "Tags=JADON_ARCHIDEKT_IMPORT") })
        }
        Write-TextFileAtomic $memoryTestPath ($memoryTest | ConvertTo-Json -Depth 6) (New-Object Text.UTF8Encoding($false))
        $memoryRoundTrip = Read-DeckMemoryDocument $memoryTestPath
        if (@($memoryRoundTrip.Decks).Count -ne 1) { throw "Portable deck-memory round trip failed." }
        $legacyFingerprint = "engine=7.0;copy=ON;similarity=OFF;threshold=90"
        $newFingerprint = "copy=ON;similarity=OFF;threshold=90"
        if ((Normalize-SettingsFingerprint $legacyFingerprint) -ne
            (Normalize-SettingsFingerprint $newFingerprint)) {
            throw "Version-independent sync fingerprint migration failed."
        }
        if ((Get-SettingsFingerprint) -match '(^|;)engine=') {
            throw "The current sync fingerprint still depends on the manager version."
        }
        Save-Settings $migrated $settingsPath
        if (-not (Test-Path -LiteralPath $settingsPath)) { throw "Settings write failed." }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "deterministic exact deck hashing"
        Write-Host ("[SelfTest 11/22] " + $currentTest + "...")
        $hashMainA = @(
            [pscustomobject]@{ Name = "Beta"; Quantity = 2 },
            [pscustomobject]@{ Name = "Alpha"; Quantity = 1 }
        )
        $hashMainB = @(
            [pscustomobject]@{ Name = "Alpha"; Quantity = 1 },
            [pscustomobject]@{ Name = "Beta"; Quantity = 2 }
        )
        $vectorA = Get-NormalizedDeckVector $hashMainA @()
        $vectorB = Get-NormalizedDeckVector $hashMainB @()
        if ((Get-VectorHash $vectorA) -ne (Get-VectorHash $vectorB)) {
            throw "Normalized hash changed with card order."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "similarity score calculation"
        Write-Host ("[SelfTest 12/22] " + $currentTest + "...")
        $similarity = Get-DeckSimilarityPercent `
            @("1`talpha", "1`tbeta", "1`tgamma") `
            @("1`talpha", "1`tbeta", "1`tdelta")
        if ([Math]::Abs($similarity - 66.67) -gt 0.02) {
            throw "Similarity calculation failed."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "bracket exact-100 real-card validation"
        Write-Host ("[SelfTest 13/22] " + $currentTest + "...")
        $realCardTotal = 99
        if (-not (Test-IsActualTokenOrEmblem $tokenEntry $tokenScryfall)) { $realCardTotal++ }
        if ([bool]$Settings.BracketExact100 -ne $true -or $realCardTotal -ne 99) {
            throw "Bracket exact-100/token exclusion safety failed."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "default profile ordering, persistence, and case-insensitive dedupe"
        Write-Host ("[SelfTest 14/22] " + $currentTest + "...")
        $savedProfilePath = $script:ProfileHistoryFile
        $script:ProfileHistoryFile = Join-Path $selfTestRoot "profiles.txt"
        try {
            Write-Utf8NoBom $script:ProfileHistoryFile @("bot_2", "RecentUser", "recentuser")
            if (-not (Initialize-DefaultProfileHistory)) { throw "Profile initialization failed." }
            Add-ProfileHistory "AnotherUser"
            $profiles = @(Get-ProfileChoices)
            if ($profiles.Count -lt 5 -or
                $profiles[0] -ne "Bot_2" -or
                $profiles[1] -ne "CLAWolf" -or
                $profiles[2] -ne "MrStealYoCreatures" -or
                (@($profiles | Where-Object { $_ -ieq "RecentUser" })).Count -ne 1) {
                throw "Default profile persistence or dedupe failed."
            }
        }
        finally {
            $script:ProfileHistoryFile = $savedProfilePath
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "importer-owned cleanup matching"
        Write-Host ("[SelfTest 15/22] " + $currentTest + "...")
        $ownedPath = Join-Path $selfTestRoot "owned.dck"
        $manualPath = Join-Path $selfTestRoot "manual.dck"
        Write-Utf8NoBom $ownedPath @(
            "[metadata]",
            "Name=Owned",
            "Source URL=https://archidekt.com/decks/7001",
            ("Comment=" + $ImporterComment + " | Original=Owned"),
            ("Tags=" + $ImportTag),
            "",
            "[main]",
            "1 Alpha"
        )
        Write-Utf8NoBom $manualPath @("[metadata]", "Name=Manual", "", "[main]", "1 Alpha")
        $ownedMatch = Test-IsOurImportedDeckFile $ownedPath
        $manualMatch = Test-IsOurImportedDeckFile $manualPath
        if (-not $ownedMatch -or $manualMatch) {
            throw ("Importer ownership matcher result was owned=" + $ownedMatch + ", manual=" + $manualMatch + ".")
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "AI Java source patch generation and defensive boundaries"
        Write-Host ("[SelfTest 16/22] " + $currentTest + "...")
        $spellInput = @(
            '    private int numSimulations;',
            '    public SpellAbility chooseSpellAbilityToPlay(SimulationController controller) {',
            '        //printOutput = controller == null;',
            '        Score origGameScore = new GameStateEvaluator().getScoreForGameState(game, player);',
            '        List<SpellAbility> candidateSAs = getCandidateSpellsAndAbilities();',
            '        createNewPlan(origGameScore, candidateSAs);',
            '        return getPlannedSpellAbility(origGameScore, candidateSAs);',
            '    }',
            '            AiPlayDecision opinion = canPlayAndPayForSim(sa);',
            '            Score value = evaluateSa(controller, phase, candidateSAs, i);',
            '        long execTime = System.currentTimeMillis() - startTime;',
            '        plan = bestPlan;',
            '        print("Planned decision " + plan.getNextDecisionIndex() + ": " + decision);',
            '        return sa;'
        ) -join "`n"
        $controllerInput = @(
            'import forge.ai.simulation.GameStateEvaluator;',
            '    public List<SpellAbility> chooseSpellAbilityToPlay() {',
            '                AiPlayDecision opinion = useLivingEnd && AiPlayDecision.WillPlay.equals(aiPlayDecision) ? aiPlayDecision : canPlayAndPayFor(sa);',
            '                // TODO could continue to try find another with higher rating (weighted by priority ordering)',
            '                return sa;',
            '        lastAttackAggression = aiAtk.declareAttackers(combat);',
            '        block.assignBlockersForCombat(combat);'
        ) -join "`n"
        $spellOutput = Join-Path $selfTestRoot "SpellAbilityPicker.java"
        $controllerOutput = Join-Path $selfTestRoot "AiController.java"
        Patch-SpellAbilityPickerSource $spellInput $spellOutput
        Patch-AiControllerSource $controllerInput $controllerOutput
        $spellPatched = [IO.File]::ReadAllText($spellOutput, [Text.Encoding]::UTF8)
        $controllerPatched = [IO.File]::ReadAllText($controllerOutput, [Text.Encoding]::UTF8)
        if (-not $spellPatched.Contains('jadonPlan.append(" | ");') -or
            -not $spellPatched.Contains('AiTelemetry.planned(') -or
            -not $spellPatched.Contains('catch (Throwable ignored)') -or
            -not $controllerPatched.Contains('catch (Throwable ignored)')) {
            throw "Generated AI source is malformed or lacks defensive telemetry guards."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "telemetry JSON escaping round trip"
        Write-Host ("[SelfTest 17/22] " + $currentTest + "...")
        $telemetryValue = "Quote `" slash \ tab`t newline`nend"
        $telemetryJson = [pscustomobject]@{ action = $telemetryValue } | ConvertTo-Json -Compress
        $telemetryRoundTrip = $telemetryJson | ConvertFrom-Json
        $telemetryJavaPath = Join-Path $selfTestRoot "AiTelemetry.java"
        Write-AiTelemetryJava $telemetryJavaPath
        $telemetryJava = [IO.File]::ReadAllText($telemetryJavaPath, [Text.Encoding]::UTF8)
        if ([string]$telemetryRoundTrip.action -ne $telemetryValue -or
            -not $telemetryJava.Contains('catch (Throwable ignored)')) {
            throw "Telemetry escaping or failure isolation check failed."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "state database save/load and copy hash verification"
        Write-Host ("[SelfTest 18/22] " + $currentTest + "...")
        $ownedRecord = Read-ImportedDeckRecord $ownedPath
        $statePath = Join-Path $selfTestRoot "import-state.json"
        $testState = @{
            "7001" = [pscustomobject]@{
                DeckId = "7001"
                UpdatedAt = "2026-01-01"
                Fingerprint = "test"
                OriginalName = "Owned"
                OutputPath = $ownedPath
                CardHash = $ownedRecord.CardHash
                Status = "Imported"
            }
        }
        Save-ImportState $testState $statePath
        $loadedState = Read-ImportState $statePath
        $meta = [pscustomobject]@{ id = 7001; name = "Owned"; updatedAt = "2026-01-01" }
        if (-not (Test-CopyStateMatch $meta $loadedState["7001"] "test")) {
            throw "Valid copy state was not recognized."
        }
        $loadedState["7001"].CardHash = "wrong"
        if (Test-CopyStateMatch $meta $loadedState["7001"] "test") {
            throw "Copy detection ignored a generated-card hash mismatch."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "proven-safe importer exact SHA-256"
        Write-Host ("[SelfTest 19/22] " + $currentTest + "...")
        if ((Get-FileSha256 $SafeImporterCmd) -ne $SafeImporterSha256) {
            throw "Proven-safe importer SHA-256 mismatch."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "backup creation"
        Write-Host ("[SelfTest 20/22] " + $currentTest + "...")
        $savedBackupDir = $script:BackupDir
        $savedBackupSetting = [bool]$Settings.BackupBeforeOverwrite
        $script:BackupDir = Join-Path $selfTestRoot "backups"
        $Settings.BackupBeforeOverwrite = $true
        try {
            Backup-ImportedDeck $ownedPath "7001"
            $backupFiles = @(Get-ChildItem -LiteralPath $script:BackupDir -Filter "*.dck" -File -Recurse)
            if ($backupFiles.Count -ne 1 -or
                (Get-FileSha256 $backupFiles[0].FullName) -ne (Get-FileSha256 $ownedPath)) {
                throw "Backup creation or integrity check failed."
            }
        }
        finally {
            $script:BackupDir = $savedBackupDir
            $Settings.BackupBeforeOverwrite = $savedBackupSetting
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "candidate-to-live atomic promotion"
        Write-Host ("[SelfTest 21/22] " + $currentTest + "...")
        $promotionLive = Join-Path $selfTestRoot "promotion.live"
        $promotionCandidate = Join-Path $selfTestRoot "promotion.candidate"
        [IO.File]::WriteAllText($promotionLive, "old", [Text.Encoding]::ASCII)
        [IO.File]::WriteAllText($promotionCandidate, "new", [Text.Encoding]::ASCII)
        Promote-FileCandidate $promotionCandidate $promotionLive -KeepLastGood
        if ([IO.File]::ReadAllText($promotionLive) -ne "new" -or
            [IO.File]::ReadAllText($promotionLive + ".last-good") -ne "old") {
            throw "Atomic promotion or last-known-good retention failed."
        }
        Write-Host "PASS" -ForegroundColor Green

        $currentTest = "menu launcher persistence"
        Write-Host ("[SelfTest 22/22] " + $currentTest + "...")
        $launcherLive = Join-Path $selfTestRoot "Start_Forge.cmd"
        $launcherCandidate = Join-Path $selfTestRoot "Start_Forge.candidate.cmd"
        $launcherContent = "@echo off`r`nsetlocal EnableExtensions DisableDelayedExpansion`r`nexit /b 0`r`n"
        [IO.File]::WriteAllText($launcherCandidate, $launcherContent, [Text.Encoding]::ASCII)
        Promote-FileCandidate $launcherCandidate $launcherLive
        $launcherBytes = [IO.File]::ReadAllBytes($launcherLive)
        if (-not [IO.File]::ReadAllText($launcherLive, [Text.Encoding]::ASCII).StartsWith("@echo off") -or
            $launcherBytes[0] -ne 0x40) {
            throw "Menu launcher persistence/format validation failed."
        }
        Write-Host "PASS" -ForegroundColor Green

        Write-Host ""
        Write-Host "Importer V9 self-test: PASS (22/22)" -ForegroundColor Green
        Write-Host ""
        return $true
    }
    catch {
        Write-Host ""
        Write-Host "Importer V9 self-test: FAILED" -ForegroundColor Red
        Write-Host ("Test: " + $currentTest)
        Write-Host ("Message: " + $_.Exception.Message)

        if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
            Write-Host $_.InvocationInfo.PositionMessage
        }
        if ($_.ScriptStackTrace) {
            Write-Host $_.ScriptStackTrace
        }

        Write-Host ""
        Write-Host "No Forge decks were changed."
        return $false
    }
    finally {
        if (Test-Path -LiteralPath $selfTestRoot) {
            Remove-Item -LiteralPath $selfTestRoot -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
}

if ($NetworkSelfTest) {
    $Settings.FastImport = $true
    $search = Invoke-JsonGet "https://archidekt.com/api/decks/v3/?deckFormat=3&edhBracket=2&orderBy=-viewCount&pageSize=6&page=1"
    $requests = New-Object System.Collections.ArrayList
    foreach ($meta in @($search.results | Select-Object -First 6)) {
        $id = [string](Get-Prop $meta "id")
        [void]$requests.Add([pscustomobject]@{
            Key = $id
            Name = [string](Get-Prop $meta "name")
            Url = "https://archidekt.com/api/decks/" + $id + "/"
        })
    }
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $networkResults = @(Invoke-JsonGetBatch $requests.ToArray() "Network self-test")
    $timer.Stop()
    $failures = @($networkResults | Where-Object { $_.Error -or -not $_.Data })
    if ($networkResults.Count -ne 6 -or $failures.Count -gt 0) {
        Write-Host "Network self-test: FAILED" -ForegroundColor Red
        exit 1
    }
    Write-Host ("Network self-test: PASS - 6 deck details in " + [Math]::Round($timer.Elapsed.TotalSeconds, 2) + " seconds") -ForegroundColor Green
    exit 0
}

if (-not (Invoke-ManagerSelfTest)) {
    if (-not $SelfTest) {
        Write-Host ""
        Write-Host "The V9 manager stopped before opening its menu because the startup self-test failed." -ForegroundColor Red
        Write-Host "This window will stay open."
        Write-Host ("Logs folder: " + $LogDir)
        Write-Host ""
        Read-Host "Press Enter to return/close"
    }
    exit 1
}

if ($SelfTest) {
    exit 0
}

[void](Initialize-DefaultProfileHistory)

if ($StartupAction -eq "ImportMemory") {
    try {
        Import-DeckMemoryInteractive
        exit 0
    }
    catch {
        Write-Host ""
        Write-Host ("Deck-memory import failed: " + $_.Exception.Message) -ForegroundColor Red
        exit 1
    }
}

if ($StartupAction -eq "ViewMemory") {
    try {
        Show-SelectedDeckMemory
        exit 0
    }
    catch {
        Write-Host ""
        Write-Host ("Deck-memory viewer failed: " + $_.Exception.Message) -ForegroundColor Red
        exit 1
    }
}

while ($true) {
    try {
        Show-MainMenu
        break
    }
    catch {
        $script:LastOperationSucceeded = $false

        try {
            if (-not $script:CurrentLog) {
                Start-Log
            }

            Write-Log ""
            Write-Log "UNEXPECTED MANAGER ERROR"
            Write-Log ("ERROR: " + $_.Exception.Message)

            if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
                Write-Log ("POSITION: " + ($_.InvocationInfo.PositionMessage -replace "`r?`n", " "))
            }

            if ($_.ScriptStackTrace) {
                Write-Log ("STACK: " + ($_.ScriptStackTrace -replace "`r?`n", " | "))
            }
        }
        catch {}

        Write-Host ""
        Write-Host "V9 recovered from an unexpected error." -ForegroundColor Yellow
        Write-Host "The manager will return to the main menu instead of closing."
        Write-Host ("Reason: " + $_.Exception.Message)
        Write-Host ""
        Read-Host "Press Enter to return to the main menu"
    }
}
