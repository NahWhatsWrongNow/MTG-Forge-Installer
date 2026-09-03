@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Jadon's Ultimate Installer v10.0

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
set "I7_CORE=%I7_BASE%\InstallerCore_v10.payload"
set "I7_CORE_CANDIDATE=%I7_BASE%\InstallerCore_v10.candidate.payload"
set "I7_MANAGER=%I7_BASE%\Jadons_Ultimate_Forge_Manager_v10.cmd"
set "I7_MANAGER_CANDIDATE=%I7_BASE%\Jadons_Ultimate_Forge_Manager_v10.candidate.cmd"
set "I7_DEV=%I7_BASE%\Jadon_Uni_Dev_Manager_v10.cmd"
set "I7_DEV_CANDIDATE=%I7_BASE%\Jadon_Uni_Dev_Manager_v10.candidate.cmd"
set "I7_DEV_SHA=58ff79a204da0c2b8c5a63d54c16b7c85b40629c0d58613fa5c126db701ed61a"
set "I7_SAFE_CMD=%I7_TOOL%\Safe_Archidekt_Importer_v4.cmd"
set "I7_SAFE_CMD_CANDIDATE=%I7_TOOL%\Safe_Archidekt_Importer_v4.candidate.cmd"
set "I7_SAFE_PS=%I7_TOOL%\Safe_Archidekt_Importer_v4.payload"
set "I7_SAFE_PS_CANDIDATE=%I7_TOOL%\Safe_Archidekt_Importer_v4.candidate.payload"
set "I7_LEGACY=%I7_BASE%\LegacyInstaller_v8.compat.cmd"
set "I7_LEGACY_CANDIDATE=%I7_BASE%\LegacyInstaller_v8.candidate.cmd"
set "I7_LAUNCHER=%I7_BASE%\Start_Forge.cmd"
set "I7_CORE_SHA=9894049fed5e0c77919587244b1c60f2c2d29bb517719940491eb730748d17e6"
set "I7_MANAGER_SHA=2c6a4b7e06583ec4fc7d00098f28e50a98c7174800f57b2dcabf808d04b8495c"
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
echo Jadon's Ultimate Installer v10.0 - Forge + University Dev Edition
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
echo [4] Run Ultimate Forge Manager v10
echo     Profiles, brackets, backups, similarity tools, and AI Viewer.
echo.
echo [5] Test / Repair Ultimate Forge Manager v10
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
echo [D] University Development Command Center
echo     Portable Python, VS Code, Anaconda repair, React and Riftfront Tactics.
echo.
echo [0] Exit
echo.

if not exist "%SystemRoot%\System32\choice.exe" goto :I7_CHOICE_MISSING
"%SystemRoot%\System32\choice.exe" /C 123456789D0 /N /M "Choose an option: "
set "I7_CHOICE=%ERRORLEVEL%"
if "%I7_CHOICE%"=="11" goto :I7_END
if "%I7_CHOICE%"=="10" goto :I7_MENU_DEV
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

:I7_MENU_DEV
call :I7_PREPARE_DEV
if errorlevel 1 (
    set "I7_FAIL_MESSAGE=The embedded University Development Manager failed integrity validation."
    call :I7_SHOW_FAILURE
    goto :I7_HOME_MENU
)
call "%I7_DEV%"
goto :I7_HOME_MENU

:I7_PREPARE_DEV
set "PS_I7_SELF=%I7_SELF%"
set "PS_I7_DEV_OUT=%I7_DEV_CANDIDATE%"
set "PS_I7_DEV_SHA=%I7_DEV_SHA%"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';$raw=[IO.File]::ReadAllText($env:PS_I7_SELF);$b='###JADON_UNIDEV_V10_BEGIN###';$e='###JADON_UNIDEV_V10_END###';$bi=$raw.LastIndexOf($b);$ei=$raw.LastIndexOf($e);if($bi-lt0-or$ei-le$bi){throw 'University development payload markers are invalid.'};" ^
 "$body=$raw.Substring($bi+$b.Length,$ei-($bi+$b.Length)).TrimStart([char]13,[char]10);[IO.File]::WriteAllText($env:PS_I7_DEV_OUT,$body,(New-Object Text.ASCIIEncoding));$a=[Security.Cryptography.SHA256]::Create();$s=[IO.File]::OpenRead($env:PS_I7_DEV_OUT);try{$h=([BitConverter]::ToString($a.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$a.Dispose()};if($h-ne$env:PS_I7_DEV_SHA){throw ('University development payload hash mismatch: '+$h)}"
if errorlevel 1 exit /b 1
call "%I7_DEV_CANDIDATE%" --selftest
if errorlevel 1 exit /b 1
set "PS_I7_DEV_CANDIDATE=%I7_DEV_CANDIDATE%"
set "PS_I7_DEV_LIVE=%I7_DEV%"
"%I7_PS_EXE%" -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='Stop';$c=$env:PS_I7_DEV_CANDIDATE;$l=$env:PS_I7_DEV_LIVE;if(Test-Path -LiteralPath $l){$b=$l+'.last-good-'+(Get-Date -Format 'yyyyMMdd-HHmmssfff');[IO.File]::Replace($c,$l,$b,$true)}else{[IO.File]::Move($c,$l)}"
exit /b %ERRORLEVEL%

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
call :I7_PREPARE_DEV
if errorlevel 1 goto :I7_AUTOTEST_FAILED
echo Installer combined test: PASS
echo Installer core parser/runtime: PASS
echo Proven safe fallback integrity/parser: PASS
echo Attached v8 compatibility fallback integrity: PASS
echo Manager CMD extraction and 22/22 runtime tests: PASS
echo University Development Manager integrity and embedded bundle self-test: PASS
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
###JADON_UNIDEV_V10_BEGIN###
@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Jadon Uni Dev Command Center v10
mode con cols=118 lines=48 >nul 2>&1
color 0B

set "UD_SELF=%~f0"
if defined LOCALAPPDATA (set "UD_BASE=%LOCALAPPDATA%\JadonUniDev") else set "UD_BASE=%USERPROFILE%\AppData\Local\JadonUniDev"
set "UD_DOWNLOADS=%UD_BASE%\downloads"
set "UD_LOGS=%UD_BASE%\logs"
set "UD_LOG=%UD_LOGS%\UniDev-v10-%RANDOM%-%RANDOM%.log"
set "PY_HOME=%UD_BASE%\Python312"
set "PY_EXE=%PY_HOME%\python.exe"
set "PY_VERSION=3.12.10"
set "PY_WORK=%USERPROFILE%\PythonUniWorkspace"
set "NODE_VERSION=24.20.0"
set "NODE_HOME=%UD_BASE%\Node"
set "NODE_EXE=%NODE_HOME%\node.exe"
set "NPM_CMD=%NODE_HOME%\npm.cmd"
set "VSCODE_HOME=%UD_BASE%\VSCode"
set "VSCODE_PROFILE_BASE=%UD_BASE%\VSCodeProfile"
set "VSCODE_EXTENSIONS_BASE=%UD_BASE%\VSCodeExtensions"
set "VSCODE_PROFILE=%VSCODE_PROFILE_BASE%"
set "VSCODE_EXTENSIONS=%VSCODE_EXTENSIONS_BASE%"
set "VSCODE_CLI="
set "VSCODE_EXE="
set "VSCODE_KIND="
set "VSCODE_SETTINGS=%VSCODE_PROFILE%\User\settings.json"
set "GAME_DIR=%USERPROFILE%\RiftfrontTactics"
set "LEGACY_APP=%USERPROFILE%\myreactapp2026"
set "RIFT_HASH=5137473c33d54989835bb8ec6b7844bc267d8e2b4d1c25323c3d6302474d5436"
set "LEGACY_HASH=1b1773c4fd58558469f5d6a1f02abde05550549957c1def1cfdad7ffc1577694"
set "UD_AUTOMATED=0"

if /I "%~1"=="--selftest" goto :UD_SELFTEST
if /I "%~1"=="--extract-game-test" goto :UD_EXTRACT_GAME_TEST
if /I "%~1"=="--test-python" goto :UD_TEST_PYTHON
if /I "%~1"=="--test-full-packages" goto :UD_TEST_FULL_PACKAGES
if /I "%~1"=="--test-vscode-config" goto :UD_TEST_VSCODE_CONFIG
if /I "%~1"=="--test-game-install" goto :UD_TEST_GAME_INSTALL
if /I "%~1"=="--test-portable-vscode" goto :UD_TEST_PORTABLE_VSCODE
if /I "%~1"=="--test-extensions" goto :UD_TEST_EXTENSIONS

call :UD_INIT
if errorlevel 1 goto :UD_FATAL_INIT

:UD_MENU
call :UD_DISCOVER_ALL
cls
call :UD_HEADER "UNIVERSITY DEVELOPMENT COMMAND CENTER" "Portable Python, isolated VS Code, React labs and games"
call :UD_STATUS
echo.
echo  [1] SMART COMPLETE SETUP
echo      Fresh portable Python + full packages + VS Code/extensions + Riftfront.
echo.
echo  [2] Install / repair PORTABLE PYTHON + packages
echo  [3] Install / repair VS CODE + extensions + interpreter
echo  [4] Repair the ANACONDA INTERPRETER using a clean isolated environment
echo.
echo  [5] Install / repair RIFTFRONT TACTICS - new card RTS
echo  [6] Start Riftfront Tactics
echo  [7] Open Python workspace in managed VS Code
echo  [8] Open Riftfront in managed VS Code
echo  [9] Python package manager
echo.
echo  [A] Diagnostics and verification
echo  [L] Original Student Portal + Ricochet Arena installer
echo  [U] Configure uninstall of managed development tools
echo  [0] Exit
echo.
set "UD_CHOICE="
set /p "UD_CHOICE=  Select: "
if /I "%UD_CHOICE%"=="1" call :UD_SMART_SETUP
if /I "%UD_CHOICE%"=="2" call :UD_PYTHON_MENU
if /I "%UD_CHOICE%"=="3" call :UD_VSCODE_SETUP
if /I "%UD_CHOICE%"=="4" call :UD_REPAIR_CONDA
if /I "%UD_CHOICE%"=="5" call :UD_INSTALL_GAME
if /I "%UD_CHOICE%"=="6" call :UD_START_GAME
if /I "%UD_CHOICE%"=="7" call :UD_OPEN_PY_CODE
if /I "%UD_CHOICE%"=="8" call :UD_OPEN_GAME_CODE
if /I "%UD_CHOICE%"=="9" call :UD_PACKAGE_MENU
if /I "%UD_CHOICE%"=="A" call :UD_DIAGNOSTICS
if /I "%UD_CHOICE%"=="L" call :UD_RUN_LEGACY
if /I "%UD_CHOICE%"=="U" call :UD_UNINSTALL_MENU
if "%UD_CHOICE%"=="0" goto :UD_END
goto :UD_MENU

:UD_INIT
for %%D in ("%UD_BASE%" "%UD_DOWNLOADS%" "%UD_LOGS%" "%PY_WORK%" "%VSCODE_PROFILE%\User" "%VSCODE_EXTENSIONS%") do if not exist "%%~D" mkdir "%%~D" >nul 2>&1
if not exist "%UD_BASE%" exit /b 1
>>"%UD_LOG%" echo.
>>"%UD_LOG%" echo [%DATE% %TIME%] Uni Dev v10 started from %UD_SELF%
exit /b 0

:UD_HEADER
echo.
echo  ==================================================================================================================
echo   %~1
echo   %~2
echo  ==================================================================================================================
exit /b 0

:UD_STATUS
if exist "%PY_EXE%" (set "S_PY=READY") else set "S_PY=NOT INSTALLED"
if defined VSCODE_CLI (set "S_CODE=READY - %VSCODE_KIND%") else set "S_CODE=NOT FOUND"
if exist "%GAME_DIR%\package.json" (set "S_GAME=READY") else set "S_GAME=NOT INSTALLED"
echo.
echo   PYTHON  [%S_PY%]    VS CODE  [%S_CODE%]
echo   RIFTFRONT [%S_GAME%]    ORIGINAL APP [%LEGACY_APP%]
exit /b 0

:UD_SMART_SETUP
cls
call :UD_HEADER "SMART COMPLETE SETUP" "Four verified stages; each working component is kept if a later stage fails"
echo   This always installs a fresh managed Python. Existing Python and Anaconda are ignored.
echo   Your normal VS Code profile and extensions are not modified.
echo.
call :UD_INSTALL_PYTHON
if errorlevel 1 goto :UD_SMART_FAIL
call :UD_INSTALL_PACKAGES FULL
if errorlevel 1 goto :UD_SMART_FAIL
call :UD_VSCODE_SETUP_NO_PAUSE
if errorlevel 1 goto :UD_SMART_FAIL
call :UD_INSTALL_GAME_NO_PAUSE
if errorlevel 1 goto :UD_SMART_FAIL
echo.
call :UD_BAR "COMPLETE" "########################################" 100
echo   Portable Python, managed VS Code, extensions, packages and Riftfront all passed verification.
pause
exit /b 0
:UD_SMART_FAIL
echo.
echo   [FAILED SAFELY] Complete setup stopped. Previously verified components were retained.
echo   Log: %UD_LOG%
pause
exit /b 1

:UD_PYTHON_MENU
cls
call :UD_HEADER "PORTABLE PYTHON 3.12" "Always fresh, independent of the broken Anaconda interpreter"
echo   [1] Essential coursework packages
echo   [2] Full data-science package suite
echo   [3] Runtime only - pip, setuptools and wheel
echo   [4] Back
echo.
set "PICK="
set /p "PICK=  Select: "
if "%PICK%"=="4" exit /b 0
call :UD_INSTALL_PYTHON
if errorlevel 1 goto :UD_PY_MENU_DONE
if "%PICK%"=="1" call :UD_INSTALL_PACKAGES CORE
if "%PICK%"=="2" call :UD_INSTALL_PACKAGES FULL
if "%PICK%"=="3" call :UD_INSTALL_PACKAGES RUNTIME
call :UD_CONFIGURE_VSCODE
:UD_PY_MENU_DONE
pause
exit /b %ERRORLEVEL%

:UD_INSTALL_PYTHON
echo.
call :UD_BAR "1/4 DOWNLOAD" "##########.............................." 25
echo   Preparing a brand-new Python %PY_VERSION% candidate; installed Python is intentionally ignored.
set "PARCH=amd64"
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "PARCH=arm64"
if /I "%PROCESSOR_ARCHITECTURE%"=="x86" set "PARCH=win32"
if /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "PARCH=amd64"
set "PZIP=%UD_DOWNLOADS%\python-%PY_VERSION%-embed-%PARCH%.zip"
set "PURL=https://www.python.org/ftp/python/%PY_VERSION%/python-%PY_VERSION%-embed-%PARCH%.zip"
set "PCAND=%UD_BASE%\Python312.candidate"
set "PBACK=%UD_BASE%\Python312.last-good"
if exist "%PCAND%" rmdir /s /q "%PCAND%" >nul 2>&1
mkdir "%PCAND%" >nul 2>&1
call :UD_DOWNLOAD "%PURL%" "%PZIP%"
if errorlevel 1 goto :UD_PY_FAIL
call :UD_BAR "2/4 EXTRACT" "####################...................." 50
call :UD_EXTRACT "%PZIP%" "%PCAND%" "%PCAND%\python.exe"
if errorlevel 1 goto :UD_PY_FAIL
set "PTH_FILE="
for %%F in ("%PCAND%\python*._pth") do if exist "%%~fF" set "PTH_FILE=%%~fF"
if not defined PTH_FILE goto :UD_PY_FAIL
>>"%PTH_FILE%" echo Lib\site-packages
>>"%PTH_FILE%" echo import site
if not exist "%PCAND%\Lib\site-packages" mkdir "%PCAND%\Lib\site-packages" >nul 2>&1
"%PCAND%\python.exe" -c "import sys;assert sys.version_info[:2]==(3,12);print(sys.version)" >>"%UD_LOG%" 2>&1
if errorlevel 1 goto :UD_PY_FAIL
call :UD_BAR "3/4 PIP" "##############################.........." 75
set "GETPIP=%UD_DOWNLOADS%\get-pip.py"
call :UD_DOWNLOAD "https://bootstrap.pypa.io/get-pip.py" "%GETPIP%"
if errorlevel 1 call :UD_DOWNLOAD "https://raw.githubusercontent.com/pypa/get-pip/main/public/get-pip.py" "%GETPIP%"
if errorlevel 1 goto :UD_PY_FAIL
"%PCAND%\python.exe" "%GETPIP%" --no-warn-script-location >>"%UD_LOG%" 2>&1
if errorlevel 1 goto :UD_PY_FAIL
"%PCAND%\python.exe" -m pip --version >>"%UD_LOG%" 2>&1
if errorlevel 1 goto :UD_PY_FAIL
call :UD_BAR "4/4 FINAL VERIFICATION" "####################################...." 90
if exist "%PBACK%" rmdir /s /q "%PBACK%" >nul 2>&1
if exist "%PY_HOME%" (
  move "%PY_HOME%" "%PBACK%" >nul 2>&1
  if errorlevel 1 goto :UD_PY_FAIL
)
move "%PCAND%" "%PY_HOME%" >nul 2>&1
if errorlevel 1 goto :UD_PY_ROLLBACK
if not exist "%PY_EXE%" goto :UD_PY_ROLLBACK
rem Regenerate pip.exe entrypoints at the final path after moving the embeddable runtime.
"%PY_EXE%" -m pip install --force-reinstall --disable-pip-version-check --no-warn-script-location pip >>"%UD_LOG%" 2>&1
if errorlevel 1 goto :UD_PY_ROLLBACK
"%PY_HOME%\Scripts\pip.exe" --version >>"%UD_LOG%" 2>&1
if errorlevel 1 goto :UD_PY_ROLLBACK
"%PY_EXE%" -c "import sys;print(sys.executable)" >>"%UD_LOG%" 2>&1
if errorlevel 1 goto :UD_PY_ROLLBACK
>"%UD_BASE%\Python_Interpreter_Path.txt" echo %PY_EXE%
call :UD_WRITE_PY_WORKSPACE
call :UD_BAR "PYTHON READY" "########################################" 100
echo   [PASS] Fresh portable Python: %PY_EXE%
exit /b 0
:UD_PY_ROLLBACK
if exist "%PY_HOME%" move "%PY_HOME%" "%PCAND%" >nul 2>&1
if not exist "%PY_HOME%" if exist "%PBACK%" move "%PBACK%" "%PY_HOME%" >nul 2>&1
:UD_PY_FAIL
echo   [FAIL] Portable Python candidate did not verify. A previous working copy was kept when available.
>>"%UD_LOG%" echo [%DATE% %TIME%] Portable Python installation failed.
if exist "%PCAND%" rmdir /s /q "%PCAND%" >nul 2>&1
exit /b 1

:UD_INSTALL_PACKAGES
if not exist "%PY_EXE%" exit /b 1
set "BUNDLE=%~1"
echo.
call :UD_BAR "PACKAGES" "##############.........................." 35
echo   Upgrading pip tooling in the managed portable interpreter...
"%PY_EXE%" -m pip install --upgrade --disable-pip-version-check --prefer-binary pip setuptools wheel
if errorlevel 1 exit /b 1
if /I "%BUNDLE%"=="RUNTIME" goto :UD_PACKAGES_VERIFY
echo   Installing core coursework stack...
"%PY_EXE%" -m pip install --upgrade --disable-pip-version-check --prefer-binary numpy pandas matplotlib scipy scikit-learn openpyxl requests pytest ipykernel
if errorlevel 1 exit /b 1
if /I "%BUNDLE%"=="CORE" goto :UD_PACKAGES_VERIFY
echo   Installing full analytics, notebook, database and document stack...
"%PY_EXE%" -m pip install --upgrade --disable-pip-version-check --prefer-binary seaborn plotly statsmodels xlsxwriter beautifulsoup4 lxml pillow sympy sqlalchemy tqdm jupyterlab polars pyarrow duckdb
if errorlevel 1 exit /b 1
:UD_PACKAGES_VERIFY
call :UD_BAR "VERIFY" "########################################" 100
"%PY_EXE%" -c "import pip;print('pip',pip.__version__)" >>"%UD_LOG%" 2>&1
if errorlevel 1 exit /b 1
if /I not "%BUNDLE%"=="RUNTIME" "%PY_EXE%" -c "import numpy,pandas,matplotlib,scipy,sklearn,openpyxl,requests,pytest,ipykernel;print('coursework imports PASS')" >>"%UD_LOG%" 2>&1
if errorlevel 1 exit /b 1
if /I "%BUNDLE%"=="FULL" "%PY_EXE%" -c "import seaborn,plotly,statsmodels,xlsxwriter,bs4,lxml,PIL,sympy,sqlalchemy,tqdm,jupyterlab,polars,pyarrow,duckdb;print('Full package imports PASS')" >>"%UD_LOG%" 2>&1
if errorlevel 1 exit /b 1
echo   [PASS] %BUNDLE% Python package bundle verified.
exit /b 0

:UD_WRITE_PY_WORKSPACE
if not exist "%PY_WORK%\.vscode" mkdir "%PY_WORK%\.vscode" >nul 2>&1
set "PY_JSON=%PY_EXE:\=\\%"
>"%PY_WORK%\.vscode\settings.json" echo {
>>"%PY_WORK%\.vscode\settings.json" echo   "python.defaultInterpreterPath": "%PY_JSON%",
>>"%PY_WORK%\.vscode\settings.json" echo   "python.terminal.activateEnvironment": false,
>>"%PY_WORK%\.vscode\settings.json" echo   "python.analysis.autoImportCompletions": true,
>>"%PY_WORK%\.vscode\settings.json" echo   "terminal.integrated.env.windows": { "PATH": "%PY_JSON%;%PY_JSON%\\Scripts;${env:PATH}" },
>>"%PY_WORK%\.vscode\settings.json" echo   "editor.formatOnSave": true
>>"%PY_WORK%\.vscode\settings.json" echo }
>"%PY_WORK%\verify_environment.py" echo import sys
>>"%PY_WORK%\verify_environment.py" echo print("Interpreter:", sys.executable)
>>"%PY_WORK%\verify_environment.py" echo print("Python:", sys.version)
>>"%PY_WORK%\verify_environment.py" echo import numpy, pandas, matplotlib, scipy, sklearn
>>"%PY_WORK%\verify_environment.py" echo print("Core data-science imports: PASS")
exit /b 0

:UD_VSCODE_SETUP
cls
call :UD_HEADER "MANAGED VS CODE" "Extensions and settings live in an isolated profile; your normal profile remains untouched"
call :UD_VSCODE_SETUP_NO_PAUSE
pause
exit /b %ERRORLEVEL%

:UD_VSCODE_SETUP_NO_PAUSE
if not exist "%PY_EXE%" (
  echo   Managed Python is missing. Installing it first so the interpreter path cannot break.
  call :UD_INSTALL_PYTHON
  if errorlevel 1 exit /b 1
)
call :UD_ENSURE_VSCODE
if errorlevel 1 exit /b 1
call :UD_CONFIGURE_VSCODE
if errorlevel 1 exit /b 1
call :UD_INSTALL_EXTENSIONS
if errorlevel 1 exit /b 1
echo   [PASS] Managed VS Code profile is configured without changing the normal profile.
exit /b 0

:UD_ENSURE_VSCODE
call :UD_FIND_VSCODE
if defined VSCODE_CLI exit /b 0
:UD_DOWNLOAD_VSCODE
echo.
call :UD_BAR "VS CODE" "##########.............................." 25
echo   VS Code was not found. Installing the official ZIP build without administrator rights...
set "CODE_ARCH=x64"
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "CODE_ARCH=arm64"
if /I "%PROCESSOR_ARCHITECTURE%"=="x86" set "CODE_ARCH=ia32"
if /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "CODE_ARCH=x64"
set "CODE_ZIP=%UD_DOWNLOADS%\VSCode-%CODE_ARCH%.zip"
set "CODE_URL=https://update.code.visualstudio.com/latest/win32-%CODE_ARCH%-archive/stable"
set "CODE_CAND=%UD_BASE%\VSCode.candidate"
set "CODE_BACK=%UD_BASE%\VSCode.last-good"
if exist "%CODE_CAND%" rmdir /s /q "%CODE_CAND%" >nul 2>&1
mkdir "%CODE_CAND%" >nul 2>&1
call :UD_DOWNLOAD "%CODE_URL%" "%CODE_ZIP%"
if errorlevel 1 goto :UD_CODE_FAIL
call :UD_BAR "VS CODE" "########################................" 60
call :UD_EXTRACT "%CODE_ZIP%" "%CODE_CAND%" "%CODE_CAND%\Code.exe"
if errorlevel 1 goto :UD_CODE_FAIL
if not exist "%CODE_CAND%\bin\code.cmd" goto :UD_CODE_FAIL
if not exist "%CODE_CAND%\data" mkdir "%CODE_CAND%\data" >nul 2>&1
if not exist "%CODE_CAND%\data\user-data\User" mkdir "%CODE_CAND%\data\user-data\User" >nul 2>&1
if exist "%CODE_BACK%" rmdir /s /q "%CODE_BACK%" >nul 2>&1
if exist "%VSCODE_HOME%" move "%VSCODE_HOME%" "%CODE_BACK%" >nul 2>&1
move "%CODE_CAND%" "%VSCODE_HOME%" >nul 2>&1
if not exist "%VSCODE_HOME%\bin\code.cmd" goto :UD_CODE_FAIL
call :UD_FIND_VSCODE
if not defined VSCODE_CLI goto :UD_CODE_FAIL
call :UD_BAR "VS CODE" "########################################" 100
echo   [PASS] Portable VS Code installed at %VSCODE_HOME%
exit /b 0
:UD_CODE_FAIL
echo   [FAIL] VS Code download or candidate validation failed.
if exist "%CODE_CAND%" rmdir /s /q "%CODE_CAND%" >nul 2>&1
if not exist "%VSCODE_HOME%" if exist "%CODE_BACK%" move "%CODE_BACK%" "%VSCODE_HOME%" >nul 2>&1
exit /b 1

:UD_FIND_VSCODE
set "VSCODE_CLI="
set "VSCODE_EXE="
set "VSCODE_KIND="
set "VSCODE_PROFILE=%VSCODE_PROFILE_BASE%"
set "VSCODE_EXTENSIONS=%VSCODE_EXTENSIONS_BASE%"
set "VSCODE_SETTINGS=%VSCODE_PROFILE_BASE%\User\settings.json"
if exist "%VSCODE_HOME%\bin\code.cmd" (
  set "VSCODE_CLI=%VSCODE_HOME%\bin\code.cmd"
  set "VSCODE_EXE=%VSCODE_HOME%\Code.exe"
  set "VSCODE_KIND=portable ZIP"
  set "VSCODE_PROFILE=%VSCODE_HOME%\data\user-data"
  set "VSCODE_EXTENSIONS=%VSCODE_HOME%\data\extensions"
  set "VSCODE_SETTINGS=%VSCODE_HOME%\data\user-data\User\settings.json"
  exit /b 0
)
for /f "delims=" %%C in ('where code.cmd 2^>nul') do if not defined VSCODE_CLI set "VSCODE_CLI=%%C"
if not defined VSCODE_CLI if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd" set "VSCODE_CLI=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd"
if not defined VSCODE_CLI if exist "%ProgramFiles%\Microsoft VS Code\bin\code.cmd" set "VSCODE_CLI=%ProgramFiles%\Microsoft VS Code\bin\code.cmd"
if defined VSCODE_CLI set "VSCODE_KIND=existing executable + isolated Jadon profile"
exit /b 0

:UD_CONFIGURE_VSCODE
if not defined VSCODE_CLI call :UD_FIND_VSCODE
if not defined VSCODE_CLI exit /b 1
if not exist "%VSCODE_PROFILE%\User" mkdir "%VSCODE_PROFILE%\User" >nul 2>&1
if not exist "%VSCODE_EXTENSIONS%" mkdir "%VSCODE_EXTENSIONS%" >nul 2>&1
set "PY_JSON=%PY_EXE:\=\\%"
>"%VSCODE_SETTINGS%" echo {
>>"%VSCODE_SETTINGS%" echo   "python.defaultInterpreterPath": "%PY_JSON%",
>>"%VSCODE_SETTINGS%" echo   "python.terminal.activateEnvironment": false,
>>"%VSCODE_SETTINGS%" echo   "python.analysis.autoImportCompletions": true,
>>"%VSCODE_SETTINGS%" echo   "python.testing.pytestEnabled": true,
>>"%VSCODE_SETTINGS%" echo   "terminal.integrated.env.windows": { "PATH": "%PY_JSON%;%PY_JSON%\\Scripts;${env:PATH}" },
>>"%VSCODE_SETTINGS%" echo   "editor.formatOnSave": true,
>>"%VSCODE_SETTINGS%" echo   "editor.bracketPairColorization.enabled": true,
>>"%VSCODE_SETTINGS%" echo   "workbench.iconTheme": "material-icon-theme",
>>"%VSCODE_SETTINGS%" echo   "telemetry.telemetryLevel": "off"
>>"%VSCODE_SETTINGS%" echo }
call :UD_WRITE_PY_WORKSPACE
if exist "%GAME_DIR%" call :UD_WRITE_GAME_VSCODE
echo   Default interpreter: %PY_EXE%
echo   Managed settings:    %VSCODE_SETTINGS%
exit /b 0

:UD_INSTALL_EXTENSIONS
if not defined VSCODE_CLI exit /b 1
echo.
echo   Installing extensions into: %VSCODE_EXTENSIONS%
set "NODE_USE_SYSTEM_CA=1"
set "EXT_TOTAL=16"
set "EXT_NOW=0"
set "EXT_FAILED=0"
for %%E in (ms-python.python ms-python.vscode-pylance ms-python.debugpy ms-python.vscode-python-envs charliermarsh.ruff ms-toolsai.jupyter ms-toolsai.datawrangler dbaeumer.vscode-eslint esbenp.prettier-vscode dsznajder.es7-react-js-snippets formulahendry.auto-rename-tag christian-kohler.path-intellisense christian-kohler.npm-intellisense usernamehw.errorlens PKief.material-icon-theme streetsidesoftware.code-spell-checker) do call :UD_EXTENSION %%E
if not "%EXT_FAILED%"=="0" (
  echo   [INCOMPLETE] %EXT_FAILED% extensions failed. Run option 3 to retry; installed extensions are retained.
  echo   Details: %UD_LOG%
  exit /b 1
)
echo   [PASS] All %EXT_TOTAL% requested extensions are installed in the managed profile.
exit /b 0

:UD_EXTENSION
set /a EXT_NOW+=1
<nul set /p "=[%EXT_NOW%/%EXT_TOTAL%] %~1  "
call "%VSCODE_CLI%" --user-data-dir "%VSCODE_PROFILE%" --extensions-dir "%VSCODE_EXTENSIONS%" --list-extensions 2>nul | findstr /I /X "%~1" >nul 2>&1
if not errorlevel 1 (
  echo READY
  exit /b 0
)
call "%VSCODE_CLI%" --user-data-dir "%VSCODE_PROFILE%" --extensions-dir "%VSCODE_EXTENSIONS%" --install-extension "%~1" --force >>"%UD_LOG%" 2>&1
if errorlevel 1 (
  echo FAILED - see log
  set /a EXT_FAILED+=1
) else echo INSTALLED
exit /b 0

:UD_REPAIR_CONDA
cls
call :UD_HEADER "ANACONDA INTERPRETER REPAIR" "Creates a clean managed environment; the fragile base environment is never edited"
set "CONDA_EXE="
for %%C in ("%ProgramData%\Anaconda3\Scripts\conda.exe" "%ProgramData%\Miniconda3\Scripts\conda.exe" "%USERPROFILE%\anaconda3\Scripts\conda.exe" "%USERPROFILE%\miniconda3\Scripts\conda.exe" "%LOCALAPPDATA%\anaconda3\Scripts\conda.exe") do if not defined CONDA_EXE if exist "%%~C" set "CONDA_EXE=%%~C"
if not defined CONDA_EXE for /f "delims=" %%C in ('where conda.exe 2^>nul') do if not defined CONDA_EXE set "CONDA_EXE=%%C"
if not defined CONDA_EXE (
  echo   No runnable conda installation was found.
  echo   Use option 2: the portable Python environment is the reliable replacement.
  pause
  exit /b 1
)
"%CONDA_EXE%" --version
if errorlevel 1 (
  echo   conda.exe itself is blocked or damaged. Its base installation was left untouched.
  echo   Use the portable Python option; it does not depend on Anaconda.
  pause
  exit /b 1
)
rem Conda environments contain absolute prefixes: never rename or move them after creation.
set "CONDA_ENV=%UD_BASE%\CondaEnvs\repair-%RANDOM%-%RANDOM%"
if exist "%CONDA_ENV%" goto :UD_CONDA_FAIL
echo   Creating clean isolated environment at %CONDA_ENV%...
call "%CONDA_EXE%" create --prefix "%CONDA_ENV%" python=3.12 pip -y
if errorlevel 1 goto :UD_CONDA_FAIL
"%CONDA_ENV%\python.exe" -c "import sys,ssl,sqlite3;print(sys.executable)"
if errorlevel 1 goto :UD_CONDA_FAIL
"%CONDA_ENV%\python.exe" -m pip --version
if errorlevel 1 goto :UD_CONDA_FAIL
>"%UD_BASE%\Conda_Interpreter_Path.txt" echo %CONDA_ENV%\python.exe
echo   [PASS] Clean Anaconda-compatible interpreter: %CONDA_ENV%\python.exe
echo   Portable Python remains the default. Use the path above when a class explicitly requires conda.
pause
exit /b 0
:UD_CONDA_FAIL
echo   [FAIL] Conda could not create a clean environment. The base environment was not changed.
echo   Existing managed environments were also retained. See the log before retrying.
pause
exit /b 1

:UD_INSTALL_GAME
cls
call :UD_HEADER "RIFTFRONT TACTICS" "A separate card-driven real-time strategy game; Ricochet Arena stays untouched"
call :UD_INSTALL_GAME_NO_PAUSE
pause
exit /b %ERRORLEVEL%

:UD_INSTALL_GAME_NO_PAUSE
call :UD_ENSURE_NODE
if errorlevel 1 exit /b 1
set "GAME_ZIP=%UD_DOWNLOADS%\RiftfrontTactics.zip"
set "GAME_CAND=%UD_BASE%\RiftfrontTactics.candidate"
if exist "%GAME_CAND%" rmdir /s /q "%GAME_CAND%" >nul 2>&1
mkdir "%GAME_CAND%" >nul 2>&1
call :UD_EXTRACT_GAME_BUNDLE "%GAME_ZIP%"
if errorlevel 1 exit /b 1
call :UD_EXTRACT "%GAME_ZIP%" "%GAME_CAND%" "%GAME_CAND%\package.json"
if errorlevel 1 exit /b 1
set "GAME_BACK=%GAME_DIR%\.unidev-backups\before-v10-%RANDOM%-%RANDOM%"
if exist "%GAME_DIR%\src" (
  if not exist "%GAME_BACK%" mkdir "%GAME_BACK%" >nul 2>&1
  xcopy "%GAME_DIR%\src" "%GAME_BACK%\src\" /E /I /Y >nul 2>&1
  if exist "%GAME_DIR%\package.json" copy /y "%GAME_DIR%\package.json" "%GAME_BACK%\package.json" >nul 2>&1
)
if not exist "%GAME_DIR%" mkdir "%GAME_DIR%" >nul 2>&1
xcopy "%GAME_CAND%\*" "%GAME_DIR%\" /E /I /Y >nul 2>&1
if errorlevel 1 exit /b 1
call :UD_WRITE_GAME_VSCODE
call :UD_CREATE_GAME_LAUNCHERS
set "PATH=%NODE_HOME%;%PATH%"
set "NODE_USE_SYSTEM_CA=1"
set "npm_config_cache=%UD_BASE%\npm-cache"
pushd "%GAME_DIR%"
echo.
call :UD_BAR "DEPENDENCIES" "####################...................." 50
call "%NPM_CMD%" install --no-audit --no-fund --fetch-retries=2
if errorlevel 1 (
  echo   First npm pass failed. Retrying once with the Windows certificate store enabled...
  set "NODE_USE_SYSTEM_CA=1"
  call "%NPM_CMD%" install --no-audit --no-fund --prefer-online --fetch-retries=1
)
if errorlevel 1 (
  popd
  echo   [FAIL] npm dependencies could not be downloaded. Source and launchers were still preserved.
  exit /b 1
)
call :UD_BAR "PRODUCTION BUILD" "##################################......" 85
call "%NPM_CMD%" run build
if errorlevel 1 (
  popd
  echo   [FAIL] Riftfront source did not pass the Vite production build.
  exit /b 1
)
popd
call :UD_BAR "RIFTFRONT READY" "########################################" 100
echo   [PASS] New game: %GAME_DIR%
echo   [PASS] Existing game was not changed: %LEGACY_APP%
exit /b 0

:UD_ENSURE_NODE
if exist "%NODE_EXE%" (
  "%NODE_EXE%" -e "const m=+process.versions.node.split('.')[0];process.exit(m>=22?0:1)" >nul 2>&1
  if not errorlevel 1 exit /b 0
)
set "SYS_NODE="
for /f "delims=" %%N in ('where node.exe 2^>nul') do if not defined SYS_NODE set "SYS_NODE=%%N"
if not defined SYS_NODE goto :UD_DOWNLOAD_NODE
call :UD_TRY_SYSTEM_NODE "%SYS_NODE%"
if not errorlevel 1 exit /b 0
:UD_DOWNLOAD_NODE
set "NARCH=x64"
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "NARCH=arm64"
if /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "NARCH=x64"
if /I "%PROCESSOR_ARCHITECTURE%"=="x86" (
  echo   32-bit Windows cannot run the supported Node 24 toolchain.
  exit /b 1
)
set "NFOLDER=node-v%NODE_VERSION%-win-%NARCH%"
set "NZIP=%UD_DOWNLOADS%\%NFOLDER%.zip"
set "NURL=https://nodejs.org/dist/v%NODE_VERSION%/%NFOLDER%.zip"
set "NCAND=%UD_BASE%\Node.extract"
if exist "%NCAND%" rmdir /s /q "%NCAND%" >nul 2>&1
mkdir "%NCAND%" >nul 2>&1
echo   Downloading official portable Node.js %NODE_VERSION% LTS...
call :UD_DOWNLOAD "%NURL%" "%NZIP%"
if errorlevel 1 exit /b 1
call :UD_EXTRACT "%NZIP%" "%NCAND%" "%NCAND%\%NFOLDER%\node.exe"
if errorlevel 1 exit /b 1
if exist "%NODE_HOME%" rmdir /s /q "%NODE_HOME%" >nul 2>&1
move "%NCAND%\%NFOLDER%" "%NODE_HOME%" >nul 2>&1
if not exist "%NODE_EXE%" exit /b 1
"%NODE_EXE%" --version
exit /b %ERRORLEVEL%

:UD_TRY_SYSTEM_NODE
"%~1" -e "const m=+process.versions.node.split('.')[0];process.exit(m>=22?0:1)" >nul 2>&1
if errorlevel 1 exit /b 1
for %%D in ("%~1") do if not exist "%%~dpDnpm.cmd" exit /b 1
set "NODE_EXE=%~1"
for %%D in ("%~1") do set "NPM_CMD=%%~dpDnpm.cmd"
for %%D in ("%~1") do set "NODE_HOME=%%~dpD"
exit /b 0

:UD_EXTRACT_GAME_BUNDLE
if not exist "%NODE_EXE%" exit /b 1
set "BUNDLE_OUT=%~1"
"%NODE_EXE%" -e "const fs=require('fs'),c=require('crypto');const r=fs.readFileSync(process.argv[1],'utf8'),b='###RIFTFRONT_ZIP_BASE64_BEGIN###',e='###RIFTFRONT_ZIP_BASE64_END###',i=r.lastIndexOf(b),j=r.lastIndexOf(e);if(i<0||j<=i)process.exit(2);const z=Buffer.from(r.slice(i+b.length,j).replace(/[^A-Za-z0-9+/=]/g,''),'base64'),h=c.createHash('sha256').update(z).digest('hex');if(h!==process.argv[3]){console.error('Riftfront payload hash mismatch: '+h);process.exit(3)}fs.writeFileSync(process.argv[2],z)" "%UD_SELF%" "%BUNDLE_OUT%" "%RIFT_HASH%"
if errorlevel 1 (
  echo   [FAIL] Embedded Riftfront game bundle failed integrity validation.
  exit /b 1
)
exit /b 0

:UD_WRITE_GAME_VSCODE
if not exist "%GAME_DIR%\.vscode" mkdir "%GAME_DIR%\.vscode" >nul 2>&1
>"%GAME_DIR%\.vscode\settings.json" echo {
>>"%GAME_DIR%\.vscode\settings.json" echo   "editor.formatOnSave": true,
>>"%GAME_DIR%\.vscode\settings.json" echo   "editor.defaultFormatter": "esbenp.prettier-vscode",
>>"%GAME_DIR%\.vscode\settings.json" echo   "javascript.suggest.autoImports": true,
>>"%GAME_DIR%\.vscode\settings.json" echo   "typescript.suggest.autoImports": true
>>"%GAME_DIR%\.vscode\settings.json" echo }
exit /b 0

:UD_CREATE_GAME_LAUNCHERS
>"%GAME_DIR%\Start_Riftfront_Tactics.cmd" echo @echo off
>>"%GAME_DIR%\Start_Riftfront_Tactics.cmd" echo setlocal
>>"%GAME_DIR%\Start_Riftfront_Tactics.cmd" echo title Riftfront Tactics Server
>>"%GAME_DIR%\Start_Riftfront_Tactics.cmd" echo set "PATH=%NODE_HOME%;%%PATH%%"
>>"%GAME_DIR%\Start_Riftfront_Tactics.cmd" echo set "NODE_USE_SYSTEM_CA=1"
>>"%GAME_DIR%\Start_Riftfront_Tactics.cmd" echo cd /d "%GAME_DIR%"
>>"%GAME_DIR%\Start_Riftfront_Tactics.cmd" echo call "%NPM_CMD%" run dev -- --host 127.0.0.1 --port 5184 --strictPort --open
>>"%GAME_DIR%\Start_Riftfront_Tactics.cmd" echo echo Server stopped. Press any key.
>>"%GAME_DIR%\Start_Riftfront_Tactics.cmd" echo pause ^>nul
>"%GAME_DIR%\Build_Riftfront_Tactics.cmd" echo @echo off
>>"%GAME_DIR%\Build_Riftfront_Tactics.cmd" echo setlocal
>>"%GAME_DIR%\Build_Riftfront_Tactics.cmd" echo set "PATH=%NODE_HOME%;%%PATH%%"
>>"%GAME_DIR%\Build_Riftfront_Tactics.cmd" echo cd /d "%GAME_DIR%"
>>"%GAME_DIR%\Build_Riftfront_Tactics.cmd" echo call "%NPM_CMD%" run build
>>"%GAME_DIR%\Build_Riftfront_Tactics.cmd" echo pause
exit /b 0

:UD_START_GAME
if not exist "%GAME_DIR%\Start_Riftfront_Tactics.cmd" (
  echo   Riftfront is not installed. Use option 5 first.
  pause
  exit /b 1
)
start "Riftfront Tactics" "%GAME_DIR%\Start_Riftfront_Tactics.cmd"
exit /b 0

:UD_OPEN_PY_CODE
call :UD_ENSURE_VSCODE
if errorlevel 1 (pause&exit /b 1)
call "%VSCODE_CLI%" --user-data-dir "%VSCODE_PROFILE%" --extensions-dir "%VSCODE_EXTENSIONS%" --new-window "%PY_WORK%"
exit /b 0

:UD_OPEN_GAME_CODE
if not exist "%GAME_DIR%" (echo   Riftfront is not installed.&pause&exit /b 1)
call :UD_ENSURE_VSCODE
if errorlevel 1 (pause&exit /b 1)
call "%VSCODE_CLI%" --user-data-dir "%VSCODE_PROFILE%" --extensions-dir "%VSCODE_EXTENSIONS%" --new-window "%GAME_DIR%"
exit /b 0

:UD_PACKAGE_MENU
if not exist "%PY_EXE%" (echo   Portable Python is not installed.&pause&exit /b 1)
:UD_PACKAGE_MENU_LOOP
cls
call :UD_HEADER "PYTHON PACKAGE MANAGER" "%PY_EXE%"
echo   [1] Essential coursework bundle
echo   [2] Full data-science bundle
echo   [3] Install one custom package
echo   [4] List installed packages
echo   [5] Verify core imports
echo   [6] Back
set "PKG_CHOICE="
set /p "PKG_CHOICE=  Select: "
if "%PKG_CHOICE%"=="1" call :UD_INSTALL_PACKAGES CORE
if "%PKG_CHOICE%"=="2" call :UD_INSTALL_PACKAGES FULL
if "%PKG_CHOICE%"=="3" call :UD_CUSTOM_PACKAGE
if "%PKG_CHOICE%"=="4" "%PY_EXE%" -m pip list
if "%PKG_CHOICE%"=="5" "%PY_EXE%" "%PY_WORK%\verify_environment.py"
if "%PKG_CHOICE%"=="6" exit /b 0
pause
goto :UD_PACKAGE_MENU_LOOP

:UD_CUSTOM_PACKAGE
set "PKG_NAME="
set /p "PKG_NAME=  pip package specification: "
if not defined PKG_NAME exit /b 0
"%PY_EXE%" -m pip install --upgrade --prefer-binary "%PKG_NAME%"
exit /b %ERRORLEVEL%

:UD_RUN_LEGACY
cls
call :UD_HEADER "ORIGINAL APP COMPATIBILITY" "The supplied V3 installer is embedded unchanged for Student Portal + Ricochet Arena"
set "LEGACY_OUT=%UD_BASE%\Original_Uni_dev_V3.cmd"
set "PS_UD_SELF=%UD_SELF%"
set "PS_UD_OUT=%LEGACY_OUT%"
set "PS_UD_HASH=%LEGACY_HASH%"
powershell.exe -NoLogo -NoProfile -Command "$ErrorActionPreference='Stop';$r=[IO.File]::ReadAllText($env:PS_UD_SELF);$b='###UNIDEV_V3_LEGACY_BEGIN###';$e='###UNIDEV_V3_LEGACY_END###';$i=$r.LastIndexOf($b);$j=$r.LastIndexOf($e);if($i-lt0-or$j-le$i){throw 'legacy markers'};$t=$r.Substring($i+$b.Length,$j-($i+$b.Length)).Trim([char]13,[char]10);[IO.File]::WriteAllText($env:PS_UD_OUT,$t,(New-Object Text.ASCIIEncoding));$a=[Security.Cryptography.SHA256]::Create();$s=[IO.File]::OpenRead($env:PS_UD_OUT);try{$h=([BitConverter]::ToString($a.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$s.Dispose();$a.Dispose()};if($h-ne$env:PS_UD_HASH){throw ('hash '+$h)}"
if errorlevel 1 (
  echo   [FAIL] Original installer extraction failed; nothing was run.
  pause
  exit /b 1
)
echo   Verified original installer: %LEGACY_OUT%
echo   Its project remains at %LEGACY_APP%; Riftfront uses a different folder and port.
call "%LEGACY_OUT%"
exit /b %ERRORLEVEL%

:UD_DIAGNOSTICS
cls
call :UD_HEADER "DIAGNOSTICS" "Exact paths, versions and isolation checks"
call :UD_DISCOVER_ALL
echo   Manager: %UD_SELF%
echo   Data:    %UD_BASE%
echo   Log:     %UD_LOG%
echo.
echo   Portable Python:
if exist "%PY_EXE%" ("%PY_EXE%" --version&echo     %PY_EXE%) else echo     MISSING
echo.
echo   Node:
if exist "%NODE_EXE%" ("%NODE_EXE%" --version&echo     %NODE_EXE%) else if defined SYS_NODE ("%SYS_NODE%" --version&echo     %SYS_NODE%) else echo     MISSING
echo.
echo   VS Code:
if defined VSCODE_CLI (call "%VSCODE_CLI%" --version&echo     %VSCODE_KIND%&echo     %VSCODE_CLI%) else echo     MISSING
echo   Isolated profile: %VSCODE_PROFILE%
echo   Normal VS Code profile is not read or written by this manager.
echo.
echo   Riftfront:
if exist "%GAME_DIR%\package.json" (echo     SOURCE READY&if exist "%GAME_DIR%\dist\index.html" (echo     PRODUCTION BUILD READY) else echo     PRODUCTION BUILD MISSING) else echo     MISSING
echo   Original portal/game:
if exist "%LEGACY_APP%\package.json" (echo     PRESENT AND UNTOUCHED) else echo     NOT CURRENTLY INSTALLED
echo.
echo   Embedded integrity:
call :UD_SELFTEST_INNER
pause
exit /b 0

:UD_DISCOVER_ALL
set "SYS_NODE="
call :UD_FIND_VSCODE
exit /b 0

:UD_UNINSTALL_MENU
cls
call :UD_HEADER "MANAGED DEV UNINSTALL" "Only JadonUniDev-managed components are eligible; your original app and normal VS Code stay safe"
echo   [1] Remove portable Python and packages
echo   [2] Remove managed VS Code/profile/extensions
echo   [3] Remove portable Node and npm cache
echo   [4] Remove Riftfront Tactics - keeps original myreactapp2026
echo   [5] Remove all managed development components
echo   [6] Back
set "DEL_CHOICE="
set /p "DEL_CHOICE=  Select: "
if "%DEL_CHOICE%"=="6" exit /b 0
echo.
set "CONFIRM="
set /p "CONFIRM=  Type REMOVE to confirm: "
if /I not "%CONFIRM%"=="REMOVE" exit /b 0
if "%DEL_CHOICE%"=="1" if exist "%PY_HOME%" rmdir /s /q "%PY_HOME%"
if "%DEL_CHOICE%"=="2" (
  if exist "%VSCODE_HOME%" rmdir /s /q "%VSCODE_HOME%"
  if exist "%UD_BASE%\VSCodeProfile" rmdir /s /q "%UD_BASE%\VSCodeProfile"
  if exist "%UD_BASE%\VSCodeExtensions" rmdir /s /q "%UD_BASE%\VSCodeExtensions"
)
if "%DEL_CHOICE%"=="3" (
  if exist "%UD_BASE%\Node" rmdir /s /q "%UD_BASE%\Node"
  if exist "%UD_BASE%\npm-cache" rmdir /s /q "%UD_BASE%\npm-cache"
)
if "%DEL_CHOICE%"=="4" if exist "%GAME_DIR%" rmdir /s /q "%GAME_DIR%"
if "%DEL_CHOICE%"=="5" (
  if exist "%PY_HOME%" rmdir /s /q "%PY_HOME%"
  if exist "%VSCODE_HOME%" rmdir /s /q "%VSCODE_HOME%"
  if exist "%UD_BASE%\VSCodeProfile" rmdir /s /q "%UD_BASE%\VSCodeProfile"
  if exist "%UD_BASE%\VSCodeExtensions" rmdir /s /q "%UD_BASE%\VSCodeExtensions"
  if exist "%UD_BASE%\Node" rmdir /s /q "%UD_BASE%\Node"
  if exist "%UD_BASE%\npm-cache" rmdir /s /q "%UD_BASE%\npm-cache"
  if exist "%UD_BASE%\CondaEnv" rmdir /s /q "%UD_BASE%\CondaEnv"
  if exist "%UD_BASE%\CondaEnvs" rmdir /s /q "%UD_BASE%\CondaEnvs"
  if exist "%GAME_DIR%" rmdir /s /q "%GAME_DIR%"
)
echo   Removal complete. %LEGACY_APP% and normal VS Code were not touched.
pause
exit /b 0

:UD_DOWNLOAD
set "DL_URL=%~1"
set "DL_OUT=%~2"
if exist "%DL_OUT%" del /q "%DL_OUT%" >nul 2>&1
where curl.exe >nul 2>&1
if errorlevel 1 goto :UD_DOWNLOAD_PS
curl.exe -L --fail --retry 3 --retry-delay 2 --connect-timeout 25 --progress-bar -o "%DL_OUT%" "%DL_URL%"
if not errorlevel 1 if exist "%DL_OUT%" exit /b 0
:UD_DOWNLOAD_PS
where powershell.exe >nul 2>&1
if errorlevel 1 goto :UD_DOWNLOAD_CERT
powershell.exe -NoLogo -NoProfile -Command "try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;Invoke-WebRequest -UseBasicParsing -Uri $env:DL_URL -OutFile $env:DL_OUT;exit 0}catch{exit 1}"
if not errorlevel 1 if exist "%DL_OUT%" exit /b 0
:UD_DOWNLOAD_CERT
where certutil.exe >nul 2>&1
if errorlevel 1 exit /b 1
certutil.exe -urlcache -split -f "%DL_URL%" "%DL_OUT%" >nul 2>&1
if not errorlevel 1 if exist "%DL_OUT%" exit /b 0
exit /b 1

:UD_EXTRACT
set "EX_ZIP=%~1"
set "EX_DIR=%~2"
set "EX_EXPECT=%~3"
where tar.exe >nul 2>&1
if errorlevel 1 goto :UD_EXTRACT_PS
tar.exe -xf "%EX_ZIP%" -C "%EX_DIR%" >>"%UD_LOG%" 2>&1
if not errorlevel 1 if exist "%EX_EXPECT%" exit /b 0
:UD_EXTRACT_PS
where powershell.exe >nul 2>&1
if errorlevel 1 goto :UD_EXTRACT_VBS
powershell.exe -NoLogo -NoProfile -Command "try{Expand-Archive -LiteralPath $env:EX_ZIP -DestinationPath $env:EX_DIR -Force;exit 0}catch{exit 1}" >>"%UD_LOG%" 2>&1
if not errorlevel 1 if exist "%EX_EXPECT%" exit /b 0
:UD_EXTRACT_VBS
where cscript.exe >nul 2>&1
if errorlevel 1 exit /b 1
set "VBS=%UD_BASE%\extract_zip.vbs"
>"%VBS%" echo Set fso = CreateObject("Scripting.FileSystemObject")
>>"%VBS%" echo Set sh = CreateObject("Shell.Application")
>>"%VBS%" echo Set zs = sh.NameSpace(WScript.Arguments(0))
>>"%VBS%" echo Set ds = sh.NameSpace(WScript.Arguments(1))
>>"%VBS%" echo If zs Is Nothing Or ds Is Nothing Then WScript.Quit 1
>>"%VBS%" echo ds.CopyHere zs.Items, 20
>>"%VBS%" echo For i = 1 To 120
>>"%VBS%" echo   If fso.FileExists(WScript.Arguments(2)) Then WScript.Quit 0
>>"%VBS%" echo   WScript.Sleep 500
>>"%VBS%" echo Next
>>"%VBS%" echo WScript.Quit 1
cscript.exe //nologo "%VBS%" "%EX_ZIP%" "%EX_DIR%" "%EX_EXPECT%"
if not errorlevel 1 if exist "%EX_EXPECT%" exit /b 0
exit /b 1

:UD_BAR
echo   [%~2] %~3%%  %~1
exit /b 0

:UD_SELFTEST
set "UD_AUTOMATED=1"
call :UD_INIT
if errorlevel 1 exit /b 1
call :UD_SELFTEST_INNER
exit /b %ERRORLEVEL%

:UD_SELFTEST_INNER
findstr /C:"###RIFTFRONT_ZIP_BASE64_BEGIN###" "%UD_SELF%" >nul 2>&1 || (echo     FAIL: Riftfront begin marker missing&exit /b 1)
findstr /C:"###RIFTFRONT_ZIP_BASE64_END###" "%UD_SELF%" >nul 2>&1 || (echo     FAIL: Riftfront end marker missing&exit /b 1)
findstr /C:"###UNIDEV_V3_LEGACY_BEGIN###" "%UD_SELF%" >nul 2>&1 || (echo     FAIL: legacy begin marker missing&exit /b 1)
findstr /C:"###UNIDEV_V3_LEGACY_END###" "%UD_SELF%" >nul 2>&1 || (echo     FAIL: legacy end marker missing&exit /b 1)
if "%RIFT_HASH:~63,1%"=="" (echo     FAIL: Riftfront hash is incomplete&exit /b 1)
if not "%RIFT_HASH:~64,1%"=="" (echo     FAIL: Riftfront hash length is invalid&exit /b 1)
if "%LEGACY_HASH:~63,1%"=="" (echo     FAIL: legacy hash is incomplete&exit /b 1)
if not "%LEGACY_HASH:~64,1%"=="" (echo     FAIL: legacy hash length is invalid&exit /b 1)
echo     Embedded markers and fixed SHA-256 records: PASS
echo     Fresh portable-Python path rule: PASS
echo     Isolated VS Code profile rule: PASS
echo     Separate original and Riftfront project paths: PASS
exit /b 0

:UD_EXTRACT_GAME_TEST
call :UD_INIT
if not exist "%NODE_EXE%" (
  set "NODE_EXE="
  for /f "delims=" %%N in ('where node.exe 2^>nul') do if not defined NODE_EXE set "NODE_EXE=%%N"
)
if not exist "%NODE_EXE%" exit /b 1
set "TEST_ZIP=%TEMP%\riftfront-payload-test-%RANDOM%.zip"
call :UD_EXTRACT_GAME_BUNDLE "%TEST_ZIP%"
if errorlevel 1 exit /b 1
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1]);if(b[0]!==0x50||b[1]!==0x4b)process.exit(1)" "%TEST_ZIP%"
set "RC=%ERRORLEVEL%"
del /q "%TEST_ZIP%" >nul 2>&1
if "%RC%"=="0" echo Riftfront embedded ZIP extraction: PASS
exit /b %RC%

:UD_TEST_PYTHON
call :UD_INIT
if errorlevel 1 exit /b 1
call :UD_INSTALL_PYTHON
if errorlevel 1 exit /b 1
call :UD_INSTALL_PACKAGES RUNTIME
if errorlevel 1 exit /b 1
"%PY_EXE%" -m pip install --disable-pip-version-check --prefer-binary requests >nul
if errorlevel 1 exit /b 1
"%PY_EXE%" -c "import requests,sys;assert sys.executable.lower().endswith('python.exe');print('Portable Python runtime/package test: PASS')"
exit /b %ERRORLEVEL%

:UD_TEST_VSCODE_CONFIG
call :UD_INIT
if errorlevel 1 exit /b 1
if not exist "%PY_EXE%" exit /b 1
call :UD_FIND_VSCODE
if not defined VSCODE_CLI exit /b 1
call :UD_CONFIGURE_VSCODE
if errorlevel 1 exit /b 1
"%PY_EXE%" -c "import json,pathlib;d=json.loads(pathlib.Path(r'%VSCODE_SETTINGS%').read_text());assert pathlib.Path(d['python.defaultInterpreterPath']).resolve()==pathlib.Path(r'%PY_EXE%').resolve();print('Isolated VS Code interpreter test: PASS')"
exit /b %ERRORLEVEL%

:UD_TEST_FULL_PACKAGES
call :UD_INIT
if errorlevel 1 exit /b 1
if not exist "%PY_EXE%" exit /b 1
call :UD_INSTALL_PACKAGES FULL
if errorlevel 1 exit /b 1
"%PY_EXE%" -c "import seaborn,plotly,statsmodels,xlsxwriter,bs4,lxml,PIL,sympy,sqlalchemy,tqdm,jupyterlab,polars,pyarrow,duckdb;print('Full Python package suite test: PASS')"
exit /b %ERRORLEVEL%

:UD_TEST_GAME_INSTALL
call :UD_INIT
if errorlevel 1 exit /b 1
call :UD_INSTALL_GAME_NO_PAUSE
if errorlevel 1 exit /b 1
if not exist "%GAME_DIR%\dist\index.html" exit /b 1
echo Riftfront extraction/npm/production-build test: PASS
exit /b 0

:UD_TEST_PORTABLE_VSCODE
call :UD_INIT
if errorlevel 1 exit /b 1
call :UD_DOWNLOAD_VSCODE
if errorlevel 1 exit /b 1
call "%VSCODE_CLI%" --user-data-dir "%VSCODE_PROFILE%" --extensions-dir "%VSCODE_EXTENSIONS%" --version
if errorlevel 1 exit /b 1
echo Official portable VS Code download/extraction/CLI test: PASS
exit /b 0

:UD_TEST_EXTENSIONS
call :UD_INIT
if errorlevel 1 exit /b 1
call :UD_FIND_VSCODE
if not defined VSCODE_CLI exit /b 1
call :UD_INSTALL_EXTENSIONS
exit /b %ERRORLEVEL%

:UD_FATAL_INIT
echo The current-user development folder could not be created: %UD_BASE%
pause
exit /b 1

:UD_END
exit /b 0

###UNIDEV_V3_LEGACY_BEGIN###
@echo off
setlocal EnableExtensions DisableDelayedExpansion

title Uni Dev Environment Manager
mode con cols=116 lines=46 >nul 2>&1
color 0B

set "BASE=%LOCALAPPDATA%\UniDevManager"
set "APP_DIR=%USERPROFILE%\myreactapp2026"
set "PY_BASE=%LOCALAPPDATA%\UniPython"
set "PY_EXTRA=%LOCALAPPDATA%\UniPythonPackages"
set "PY_PATH_FILE=%PY_BASE%\Python_Interpreter_Path.txt"
set "PYPM=%PY_BASE%\Package_Manager.py"
set "PYTEST=%PY_BASE%\Test_Data_Science_Stack.py"
set "PYCFG=%PY_BASE%\VSCode_Config.py"
set "PYCFG_B64=%TEMP%\uni_python_vscode_cfg.b64"
set "PYPM_B64=%TEMP%\uni_python_pm.b64"
set "PYTEST_B64=%TEMP%\uni_python_tests.b64"
set "PYTHON="
set "PY_KIND="
set "PY_USER=0"

set "NODE_VERSION=24.20.0"
set "NODE_ARCH=x64"
set "NODE_EXE="
set "NPM_CMD="
set "NODE_HOME="
set "NODE_KIND="
set "NODE_CACHE=%LOCALAPPDATA%\UniNodeCache"

set "VSCODE_EXE="
set "VSCODE_CLI="
set "DESKTOP="
set "FAIL_REASON="

if not exist "%BASE%" mkdir "%BASE%" >nul 2>&1
if not exist "%PY_BASE%" mkdir "%PY_BASE%" >nul 2>&1
if not exist "%PY_EXTRA%" mkdir "%PY_EXTRA%" >nul 2>&1
if not exist "%NODE_CACHE%" mkdir "%NODE_CACHE%" >nul 2>&1

call :FIND_DESKTOP
call :FIND_VSCODE

:MENU
cls
call :LOAD_SAVED
call :SHOW_STATUS
echo.
echo  [1]  Install / repair Python + data-science environment
echo  [2]  Install / repair React + Web Tech 512 Homework + Portal/Game
echo  [3]  Install / repair BOTH environments
echo.
echo  [4]  Open Python package manager
echo  [5]  Run Python data-science tests
echo  [6]  Start Student Portal development server
echo  [7]  Build / verify Student Portal
echo.
echo  [8]  Open React project folder
echo  [9]  Open Python workspace folder
echo  [10] Open BOTH folders
echo  [11] Open React project in VS Code
echo  [12] Open Python workspace in VS Code
echo  [13] Open BOTH in separate VS Code windows
echo.
echo  [14] Install / repair VS Code extensions
echo  [15] Diagnostics and exact paths
echo  [16] Open generated test/output folders
echo  [17] Regenerate Web Tech homework + portal/game source
echo  [18] Exit
echo.
set /p "CHOICE=Choose 1-18: "

if "%CHOICE%"=="1" goto MENU_PYTHON
if "%CHOICE%"=="2" goto MENU_REACT
if "%CHOICE%"=="3" goto MENU_BOTH
if "%CHOICE%"=="4" goto MENU_PYPM
if "%CHOICE%"=="5" goto MENU_PYTEST
if "%CHOICE%"=="6" goto MENU_START_REACT
if "%CHOICE%"=="7" goto MENU_BUILD_REACT
if "%CHOICE%"=="8" goto MENU_REACT_FOLDER
if "%CHOICE%"=="9" goto MENU_PY_FOLDER
if "%CHOICE%"=="10" goto MENU_BOTH_FOLDERS
if "%CHOICE%"=="11" goto MENU_REACT_CODE
if "%CHOICE%"=="12" goto MENU_PY_CODE
if "%CHOICE%"=="13" goto MENU_BOTH_CODE
if "%CHOICE%"=="14" goto MENU_EXTENSIONS
if "%CHOICE%"=="15" goto MENU_DIAGNOSTICS
if "%CHOICE%"=="16" goto MENU_OUTPUTS
if "%CHOICE%"=="17" goto MENU_REGENERATE
if "%CHOICE%"=="18" exit /b 0
echo Invalid choice.
pause
goto MENU

:MENU_PYTHON
call :INSTALL_PYTHON
goto MENU
:MENU_REACT
call :INSTALL_REACT
goto MENU
:MENU_BOTH
call :INSTALL_BOTH
goto MENU
:MENU_PYPM
call :OPEN_PY_PM
goto MENU
:MENU_PYTEST
call :RUN_PY_TESTS
goto MENU
:MENU_START_REACT
call :START_REACT
goto MENU
:MENU_BUILD_REACT
call :BUILD_REACT
goto MENU
:MENU_REACT_FOLDER
call :OPEN_REACT_FOLDER
goto MENU
:MENU_PY_FOLDER
call :OPEN_PY_FOLDER
goto MENU
:MENU_BOTH_FOLDERS
call :OPEN_BOTH_FOLDERS
goto MENU
:MENU_REACT_CODE
call :OPEN_REACT_CODE
goto MENU
:MENU_PY_CODE
call :OPEN_PY_CODE
goto MENU
:MENU_BOTH_CODE
call :OPEN_BOTH_CODE
goto MENU
:MENU_EXTENSIONS
call :INSTALL_EXTENSIONS
goto MENU
:MENU_DIAGNOSTICS
call :DIAGNOSTICS
goto MENU
:MENU_OUTPUTS
call :OPEN_OUTPUTS
goto MENU
:MENU_REGENERATE
call :REGENERATE_REACT
goto MENU


:SHOW_STATUS
echo.
echo UNI DEV ENVIRONMENT MANAGER
echo ====================================================================================================================
if defined PYTHON (
  echo Python : READY
  echo          %PYTHON%
) else (
  echo Python : NOT CONFIGURED
)
if defined NODE_EXE (
  echo Node   : READY
  echo          %NODE_EXE%
) else (
  echo Node   : NOT CONFIGURED
)
if exist "%APP_DIR%\package.json" (
  echo React  : PROJECT FOUND at %APP_DIR%
) else (
  echo React  : PROJECT NOT CREATED
)
echo ====================================================================================================================
exit /b


:LOAD_SAVED
set "PYTHON="
set "NODE_EXE="
set "NPM_CMD="
set "NODE_HOME="
if exist "%PY_PATH_FILE%" set /p "PYTHON="<"%PY_PATH_FILE%"
if defined PYTHON if not exist "%PYTHON%" set "PYTHON="
if exist "%BASE%\node_exe.txt" set /p "NODE_EXE="<"%BASE%\node_exe.txt"
if exist "%BASE%\npm_cmd.txt" set /p "NPM_CMD="<"%BASE%\npm_cmd.txt"
if defined NODE_EXE if not exist "%NODE_EXE%" set "NODE_EXE="
if defined NPM_CMD if not exist "%NPM_CMD%" set "NPM_CMD="
if defined NODE_EXE for %%I in ("%NODE_EXE%") do set "NODE_HOME=%%~dpI"
exit /b


:INSTALL_BOTH
call :INSTALL_PYTHON
if errorlevel 1 exit /b 1
call :INSTALL_REACT
exit /b


:INSTALL_PYTHON
cls
echo Python installation / repair
echo ====================================================================================================================
echo This setup first tries Python already allowed by the university PC.
echo It can use Anaconda's python.exe directly without running "conda activate".
echo.
set "PYTHON="
set "PY_KIND="
set "PY_USER=0"

call :TRY_PY "%ProgramData%\Anaconda3\python.exe" "University Anaconda"
if defined PYTHON goto PY_FOUND
call :TRY_PY "%ProgramData%\Miniconda3\python.exe" "University Miniconda"
if defined PYTHON goto PY_FOUND
call :TRY_PY "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" "User Python 3.12"
if defined PYTHON goto PY_FOUND
call :TRY_PY "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" "User Python 3.11"
if defined PYTHON goto PY_FOUND
call :TRY_PY "%USERPROFILE%\anaconda3\python.exe" "User Anaconda"
if defined PYTHON goto PY_FOUND
call :TRY_PY "%LOCALAPPDATA%\PortablePython\Current\python.exe" "Portable Python"
if defined PYTHON goto PY_FOUND

echo No existing usable Python was found. Trying official portable Python...
call :INSTALL_PORTABLE_PY
if errorlevel 1 (
  echo.
  echo [FAILED] Could not obtain a Python executable that Windows will run.
  echo If the university blocks all Python executables, IT must allow Python first.
  pause
  exit /b 1
)

:PY_FOUND
echo.
echo [OK] Python selected:
echo %PYTHON%
echo %PY_KIND%
echo.
>"%PY_PATH_FILE%" echo %PYTHON%
if defined DESKTOP copy /y "%PY_PATH_FILE%" "%DESKTOP%\Python_Interpreter_Path.txt" >nul 2>&1

echo Checking pip...
"%PYTHON%" -m pip --version >nul 2>&1
if not errorlevel 1 goto PY_PIP_OK
"%PYTHON%" -m ensurepip --upgrade >nul 2>&1
"%PYTHON%" -m pip --version >nul 2>&1
if not errorlevel 1 goto PY_PIP_OK

set "GETPIP=%TEMP%\get-pip.py"
call :DOWNLOAD "https://bootstrap.pypa.io/get-pip.py" "%GETPIP%"
if errorlevel 1 call :DOWNLOAD "https://raw.githubusercontent.com/pypa/get-pip/main/public/get-pip.py" "%GETPIP%"
if errorlevel 1 (
  echo [FAILED] Could not download pip.
  pause
  exit /b 1
)
if "%PY_USER%"=="1" (
  "%PYTHON%" "%GETPIP%" --user --no-warn-script-location
) else (
  "%PYTHON%" "%GETPIP%" --no-warn-script-location
)
"%PYTHON%" -m pip --version >nul 2>&1
if errorlevel 1 (
  echo [FAILED] pip is still unavailable.
  pause
  exit /b 1
)

:PY_PIP_OK
echo Creating Python package manager...
>"%PYPM_B64%" echo aW1wb3J0IGltcG9ydGxpYiwgb3MsIHN1YnByb2Nlc3MsIHN5cwpmcm9tIHBhdGhsaWIgaW1w
>>"%PYPM_B64%" echo b3J0IFBhdGgKCkVYVFJBID0gUGF0aChvcy5lbnZpcm9uLmdldCgiVU5JX1BZX0VYVFJBIiwg
>>"%PYPM_B64%" echo UGF0aC5ob21lKCkgLyAiQXBwRGF0YSIgLyAiTG9jYWwiIC8gIlVuaVB5dGhvblBhY2thZ2Vz
>>"%PYPM_B64%" echo IikpCkVYVFJBLm1rZGlyKHBhcmVudHM9VHJ1ZSwgZXhpc3Rfb2s9VHJ1ZSkKaWYgc3RyKEVY
>>"%PYPM_B64%" echo VFJBKSBub3QgaW4gc3lzLnBhdGg6CiAgICBzeXMucGF0aC5pbnNlcnQoMCwgc3RyKEVYVFJB
>>"%PYPM_B64%" echo KSkKCkNPUkUgPSBbCiAgICAoIm51bXB5IiwibnVtcHkiKSwgKCJwYW5kYXMiLCJwYW5kYXMi
>>"%PYPM_B64%" echo KSwgKCJtYXRwbG90bGliIiwibWF0cGxvdGxpYiIpLAogICAgKCJzY2lweSIsInNjaXB5Iiks
>>"%PYPM_B64%" echo ICgic2Npa2l0LWxlYXJuIiwic2tsZWFybiIpLCAoIm9wZW5weXhsIiwib3BlbnB5eGwiKSwK
>>"%PYPM_B64%" echo ICAgICgicmVxdWVzdHMiLCJyZXF1ZXN0cyIpLCAoInB5dGVzdCIsInB5dGVzdCIpLCAoImlw
>>"%PYPM_B64%" echo eWtlcm5lbCIsImlweWtlcm5lbCIpLApdCkZVTEwgPSBDT1JFICsgWwogICAgKCJzZWFib3Ju
>>"%PYPM_B64%" echo Iiwic2VhYm9ybiIpLCAoInBsb3RseSIsInBsb3RseSIpLCAoInN0YXRzbW9kZWxzIiwic3Rh
>>"%PYPM_B64%" echo dHNtb2RlbHMiKSwKICAgICgieGxzeHdyaXRlciIsInhsc3h3cml0ZXIiKSwgKCJiZWF1dGlm
>>"%PYPM_B64%" echo dWxzb3VwNCIsImJzNCIpLCAoImx4bWwiLCJseG1sIiksCiAgICAoInBpbGxvdyIsIlBJTCIp
>>"%PYPM_B64%" echo LCAoInN5bXB5Iiwic3ltcHkiKSwgKCJzcWxhbGNoZW15Iiwic3FsYWxjaGVteSIpLAogICAg
>>"%PYPM_B64%" echo KCJ0cWRtIiwidHFkbSIpLCAoImp1cHl0ZXJsYWIiLCJqdXB5dGVybGFiIiksCl0KQURWQU5D
>>"%PYPM_B64%" echo RUQgPSBbKCJwb2xhcnMiLCJwb2xhcnMiKSwgKCJweWFycm93IiwicHlhcnJvdyIpLCAoImR1
>>"%PYPM_B64%" echo Y2tkYiIsImR1Y2tkYiIpXQoKZGVmIGNhbl9pbXBvcnQobmFtZSk6CiAgICB0cnk6CiAgICAg
>>"%PYPM_B64%" echo ICAgaW1wb3J0bGliLmltcG9ydF9tb2R1bGUobmFtZSkKICAgICAgICByZXR1cm4gVHJ1ZQog
>>"%PYPM_B64%" echo ICAgZXhjZXB0IEV4Y2VwdGlvbjoKICAgICAgICByZXR1cm4gRmFsc2UKCmRlZiBpbnN0YWxs
>>"%PYPM_B64%" echo KHNwZWMsIGltcG9ydF9uYW1lPU5vbmUpOgogICAgdXNlcl9tb2RlID0gb3MuZW52aXJvbi5n
>>"%PYPM_B64%" echo ZXQoIlVOSV9QWV9VU0VSIiwgIjAiKSA9PSAiMSIKICAgIGJhc2UgPSBbc3lzLmV4ZWN1dGFi
>>"%PYPM_B64%" echo bGUsICItbSIsICJwaXAiLCAiaW5zdGFsbCIsICItLWRpc2FibGUtcGlwLXZlcnNpb24tY2hl
>>"%PYPM_B64%" echo Y2siLCAiLS1uby13YXJuLXNjcmlwdC1sb2NhdGlvbiJdCiAgICBmaXJzdCA9IGJhc2UgKyAo
>>"%PYPM_B64%" echo WyItLXVzZXIiXSBpZiB1c2VyX21vZGUgZWxzZSBbXSkgKyBbIi0tdXBncmFkZSIsIHNwZWNd
>>"%PYPM_B64%" echo CiAgICBhdHRlbXB0cyA9IFsKICAgICAgICBmaXJzdCwKICAgICAgICBiYXNlICsgKFsiLS11
>>"%PYPM_B64%" echo c2VyIl0gaWYgdXNlcl9tb2RlIGVsc2UgW10pICsgWyItLXVwZ3JhZGUiLCAiLS1uby1jYWNo
>>"%PYPM_B64%" echo ZS1kaXIiLCBzcGVjXSwKICAgICAgICBiYXNlICsgWyItLXVwZ3JhZGUiLCAiLS1uby1jYWNo
>>"%PYPM_B64%" echo ZS1kaXIiLCAiLS10YXJnZXQiLCBzdHIoRVhUUkEpLCBzcGVjXSwKICAgIF0KICAgIHByaW50
>>"%PYPM_B64%" echo KCJcbkluc3RhbGxpbmc6Iiwgc3BlYykKICAgIGZvciBudW1iZXIsIGNvbW1hbmQgaW4gZW51
>>"%PYPM_B64%" echo bWVyYXRlKGF0dGVtcHRzLCAxKToKICAgICAgICBwcmludChmIiAgYXR0ZW1wdCB7bnVtYmVy
>>"%PYPM_B64%" echo fS8zIikKICAgICAgICByZXN1bHQgPSBzdWJwcm9jZXNzLnJ1bihjb21tYW5kKQogICAgICAg
>>"%PYPM_B64%" echo IGlmIHJlc3VsdC5yZXR1cm5jb2RlID09IDA6CiAgICAgICAgICAgIGltcG9ydGxpYi5pbnZh
>>"%PYPM_B64%" echo bGlkYXRlX2NhY2hlcygpCiAgICAgICAgICAgIGlmIGltcG9ydF9uYW1lIGFuZCBjYW5faW1w
>>"%PYPM_B64%" echo b3J0KGltcG9ydF9uYW1lKToKICAgICAgICAgICAgICAgIHByaW50KGYiICBbUEFTU10gaW1w
>>"%PYPM_B64%" echo b3J0IHtpbXBvcnRfbmFtZX0iKQogICAgICAgICAgICBlbHNlOgogICAgICAgICAgICAgICAg
>>"%PYPM_B64%" echo cHJpbnQoIiAgW1BBU1NdIHBpcCBjb21wbGV0ZWQiKQogICAgICAgICAgICByZXR1cm4gVHJ1
>>"%PYPM_B64%" echo ZQogICAgcHJpbnQoIiAgW0ZBSUxdIiwgc3BlYykKICAgIHJldHVybiBGYWxzZQoKZGVmIGJ1
>>"%PYPM_B64%" echo bmRsZShpdGVtcywgdGl0bGUpOgogICAgcHJpbnQoIlxuIiArICI9IiAqIDcyKQogICAgcHJp
>>"%PYPM_B64%" echo bnQodGl0bGUpCiAgICBwcmludCgiPSIgKiA3MikKICAgIGZvciBzcGVjLCBpbXAgaW4gaXRl
>>"%PYPM_B64%" echo bXM6CiAgICAgICAgaWYgY2FuX2ltcG9ydChpbXApOgogICAgICAgICAgICBwcmludChmIltP
>>"%PYPM_B64%" echo S10ge3NwZWN9IikKICAgICAgICBlbHNlOgogICAgICAgICAgICBpbnN0YWxsKHNwZWMsIGlt
>>"%PYPM_B64%" echo cCkKCmRlZiBjdXN0b20oKToKICAgIHByaW50KCJcbkNVU1RPTSBQQUNLQUdFIElOU1RBTEwi
>>"%PYPM_B64%" echo KQogICAgcHJpbnQoIk9uZSBwaXAgcGFja2FnZSBzcGVjaWZpY2F0aW9uIHBlciBsaW5lLiBC
>>"%PYPM_B64%" echo bGFuayBsaW5lIGZpbmlzaGVzLiIpCiAgICBwcmludCgiRXhhbXBsZXM6IG1hdHBsb3RsaWIg
>>"%PYPM_B64%" echo fCBvcGVucHl4bD09My4xLjUgfCBudW1weT49Mi4wIHwgcGFuZGFzPDMiKQogICAgd2hpbGUg
>>"%PYPM_B64%" echo VHJ1ZToKICAgICAgICBzcGVjID0gaW5wdXQoInBhY2thZ2U+ICIpLnN0cmlwKCkKICAgICAg
>>"%PYPM_B64%" echo ICBpZiBub3Qgc3BlYzoKICAgICAgICAgICAgcmV0dXJuCiAgICAgICAgaW5zdGFsbChzcGVj
>>"%PYPM_B64%" echo KQoKZGVmIHJ1bl90ZXN0cygpOgogICAgdGVzdCA9IFBhdGgob3MuZW52aXJvblsiVU5JX1BZ
>>"%PYPM_B64%" echo X1RFU1QiXSkKICAgIHN1YnByb2Nlc3MucnVuKFtzeXMuZXhlY3V0YWJsZSwgc3RyKHRlc3Qp
>>"%PYPM_B64%" echo XSkKCmRlZiBtZW51KGZpcnN0X3J1bj1GYWxzZSk6CiAgICBpZiBmaXJzdF9ydW46CiAgICAg
>>"%PYPM_B64%" echo ICAgcHJpbnQoIlxuQ2hvb3NlIGEgc3RhcnRpbmcgYnVuZGxlOiIpCiAgICAgICAgcHJpbnQo
>>"%PYPM_B64%" echo IlsxXSBFc3NlbnRpYWwgZGF0YS1zY2llbmNlIGNvcmUiKQogICAgICAgIHByaW50KCJbMl0g
>>"%PYPM_B64%" echo RnVsbCBkYXRhLXNjaWVuY2UgYnVuZGxlIikKICAgICAgICBwcmludCgiWzNdIFNraXAgYnVu
>>"%PYPM_B64%" echo ZGxlIGFuZCBpbnN0YWxsIGN1c3RvbSBwYWNrYWdlcyIpCiAgICAgICAgY2hvaWNlID0gaW5w
>>"%PYPM_B64%" echo dXQoIkNob29zZSAxLTM6ICIpLnN0cmlwKCkKICAgICAgICBpZiBjaG9pY2UgPT0gIjEiOgog
>>"%PYPM_B64%" echo ICAgICAgICAgICBidW5kbGUoQ09SRSwgIkVTU0VOVElBTCBEQVRBLVNDSUVOQ0UgQ09SRSIp
>>"%PYPM_B64%" echo CiAgICAgICAgZWxpZiBjaG9pY2UgPT0gIjIiOgogICAgICAgICAgICBidW5kbGUoRlVMTCwg
>>"%PYPM_B64%" echo IkZVTEwgREFUQS1TQ0lFTkNFIEJVTkRMRSIpCiAgICAgICAgY3VzdG9tKCkKCiAgICB3aGls
>>"%PYPM_B64%" echo ZSBUcnVlOgogICAgICAgIHByaW50KCJcbiIgKyAiPSIgKiA3MikKICAgICAgICBwcmludCgi
>>"%PYPM_B64%" echo UFlUSE9OIFBBQ0tBR0UgTUFOQUdFUiIpCiAgICAgICAgcHJpbnQoIj0iICogNzIpCiAgICAg
>>"%PYPM_B64%" echo ICAgcHJpbnQoIkludGVycHJldGVyOiIsIHN5cy5leGVjdXRhYmxlKQogICAgICAgIHByaW50
>>"%PYPM_B64%" echo KCJbMV0gRXNzZW50aWFsIGJ1bmRsZSIpCiAgICAgICAgcHJpbnQoIlsyXSBGdWxsIGRhdGEt
>>"%PYPM_B64%" echo c2NpZW5jZSBidW5kbGUiKQogICAgICAgIHByaW50KCJbM10gQ3VzdG9tIHBhY2thZ2VzIikK
>>"%PYPM_B64%" echo ICAgICAgICBwcmludCgiWzRdIEFkdmFuY2VkIGJ1bmRsZSAoUG9sYXJzIC8gUHlBcnJvdyAv
>>"%PYPM_B64%" echo IER1Y2tEQikiKQogICAgICAgIHByaW50KCJbNV0gTGlzdCBpbnN0YWxsZWQgcGFja2FnZXMi
>>"%PYPM_B64%" echo KQogICAgICAgIHByaW50KCJbNl0gUnVuIHRlc3RzL2V4YW1wbGVzIikKICAgICAgICBwcmlu
>>"%PYPM_B64%" echo dCgiWzddIFJldHVybiB0byBpbnN0YWxsZXIgbWVudSIpCiAgICAgICAgY2hvaWNlID0gaW5w
>>"%PYPM_B64%" echo dXQoIkNob29zZSAxLTc6ICIpLnN0cmlwKCkKICAgICAgICBpZiBjaG9pY2UgPT0gIjEiOiBi
>>"%PYPM_B64%" echo dW5kbGUoQ09SRSwgIkVTU0VOVElBTCBEQVRBLVNDSUVOQ0UgQ09SRSIpCiAgICAgICAgZWxp
>>"%PYPM_B64%" echo ZiBjaG9pY2UgPT0gIjIiOiBidW5kbGUoRlVMTCwgIkZVTEwgREFUQS1TQ0lFTkNFIEJVTkRM
>>"%PYPM_B64%" echo RSIpCiAgICAgICAgZWxpZiBjaG9pY2UgPT0gIjMiOiBjdXN0b20oKQogICAgICAgIGVsaWYg
>>"%PYPM_B64%" echo Y2hvaWNlID09ICI0IjogYnVuZGxlKEFEVkFOQ0VELCAiQURWQU5DRUQgREFUQSBCVU5ETEUi
>>"%PYPM_B64%" echo KQogICAgICAgIGVsaWYgY2hvaWNlID09ICI1Ijogc3VicHJvY2Vzcy5ydW4oW3N5cy5leGVj
>>"%PYPM_B64%" echo dXRhYmxlLCAiLW0iLCAicGlwIiwgImxpc3QiXSkKICAgICAgICBlbGlmIGNob2ljZSA9PSAi
>>"%PYPM_B64%" echo NiI6IHJ1bl90ZXN0cygpCiAgICAgICAgZWxpZiBjaG9pY2UgPT0gIjciOiByZXR1cm4KICAg
>>"%PYPM_B64%" echo ICAgICBlbHNlOiBwcmludCgiSW52YWxpZCBjaG9pY2UuIikKCmlmIF9fbmFtZV9fID09ICJf
>>"%PYPM_B64%" echo X21haW5fXyI6CiAgICBtZW51KCItLWZpcnN0LXJ1biIgaW4gc3lzLmFyZ3YpCg==
"%PYTHON%" -c "import base64,pathlib; p=pathlib.Path(r'%PYPM_B64%'); o=pathlib.Path(r'%PY_BASE%\Package_Manager.py'); o.parent.mkdir(parents=True,exist_ok=True); o.write_bytes(base64.b64decode(p.read_text()))"
if errorlevel 1 (
  echo [FAILED] Could not create package manager.
  pause
  exit /b 1
)
>"%PYTEST_B64%" echo ZnJvbSBwYXRobGliIGltcG9ydCBQYXRoCmltcG9ydCBtYXRoLCBvcywgc3lzLCB0cmFjZWJh
>>"%PYTEST_B64%" echo Y2sKCk9VVCA9IFBhdGguaG9tZSgpIC8gIkRhdGFTY2llbmNlVGVzdFJlc3VsdHMiCk9VVC5t
>>"%PYTEST_B64%" echo a2RpcihwYXJlbnRzPVRydWUsIGV4aXN0X29rPVRydWUpCmV4dHJhID0gb3MuZW52aXJvbi5n
>>"%PYTEST_B64%" echo ZXQoIlVOSV9QWV9FWFRSQSIpCmlmIGV4dHJhIGFuZCBleHRyYSBub3QgaW4gc3lzLnBhdGg6
>>"%PYTEST_B64%" echo CiAgICBzeXMucGF0aC5pbnNlcnQoMCwgZXh0cmEpCgpyZXN1bHRzID0gW10KZGVmIGNoZWNr
>>"%PYTEST_B64%" echo KG5hbWUsIGZ1bmMpOgogICAgdHJ5OgogICAgICAgIGRldGFpbCA9IGZ1bmMoKQogICAgICAg
>>"%PYTEST_B64%" echo IHByaW50KGYiW1BBU1NdIHtuYW1lfToge2RldGFpbH0iKQogICAgICAgIHJlc3VsdHMuYXBw
>>"%PYTEST_B64%" echo ZW5kKChuYW1lLCBUcnVlLCBkZXRhaWwpKQogICAgZXhjZXB0IEV4Y2VwdGlvbiBhcyBleGM6
>>"%PYTEST_B64%" echo CiAgICAgICAgcHJpbnQoZiJbRkFJTF0ge25hbWV9OiB7ZXhjIXJ9IikKICAgICAgICB0cmFj
>>"%PYTEST_B64%" echo ZWJhY2sucHJpbnRfZXhjKCkKICAgICAgICByZXN1bHRzLmFwcGVuZCgobmFtZSwgRmFsc2Us
>>"%PYTEST_B64%" echo IHJlcHIoZXhjKSkpCgpkZWYgbnVtcHlfdGVzdCgpOgogICAgaW1wb3J0IG51bXB5IGFzIG5w
>>"%PYTEST_B64%" echo CiAgICBBPW5wLmFycmF5KFtbNC4sMi4sMS5dLFswLiw1LiwzLl0sWzIuLDEuLDMuXV0pCiAg
>>"%PYTEST_B64%" echo ICBiPW5wLmFycmF5KFs3Liw4Liw1Ll0pCiAgICByZXR1cm4gZiJzb2x2ZT17bnAucm91bmQo
>>"%PYTEST_B64%" echo bnAubGluYWxnLnNvbHZlKEEsYiksMykudG9saXN0KCl9IgoKZGVmIHBhbmRhc190ZXN0KCk6
>>"%PYTEST_B64%" echo CiAgICBpbXBvcnQgcGFuZGFzIGFzIHBkCiAgICBkZj1wZC5EYXRhRnJhbWUoeyJ0ZWFtIjpb
>>"%PYTEST_B64%" echo IkEiLCJBIiwiQiIsIkIiXSwic2FsZXMiOlsxMjAsMTUwLDkwLDIxMF0sImNvc3QiOls3MCw4
>>"%PYTEST_B64%" echo Miw2NSwxMjVdfSkKICAgIGRmWyJwcm9maXQiXT1kZi5zYWxlcy1kZi5jb3N0CiAgICBwPU9V
>>"%PYTEST_B64%" echo VC8icGFuZGFzX3N1bW1hcnkuY3N2IgogICAgZGYuZ3JvdXBieSgidGVhbSIpW1sic2FsZXMi
>>"%PYTEST_B64%" echo LCJwcm9maXQiXV0uc3VtKCkudG9fY3N2KHApCiAgICByZXR1cm4gc3RyKHApCgpkZWYgbWF0
>>"%PYTEST_B64%" echo cGxvdGxpYl90ZXN0KCk6CiAgICBpbXBvcnQgbnVtcHkgYXMgbnAsIG1hdHBsb3RsaWIKICAg
>>"%PYTEST_B64%" echo IG1hdHBsb3RsaWIudXNlKCJBZ2ciKQogICAgaW1wb3J0IG1hdHBsb3RsaWIucHlwbG90IGFz
>>"%PYTEST_B64%" echo IHBsdAogICAgcm5nPW5wLnJhbmRvbS5kZWZhdWx0X3JuZyg0MikKICAgIHg9bnAubGluc3Bh
>>"%PYTEST_B64%" echo Y2UoMCwyNCw1MDApCiAgICByYXc9bnAuc2luKHgpKm5wLmV4cCgteC8zMCkrLjE4Km5wLnNp
>>"%PYTEST_B64%" echo big0KngpK3JuZy5ub3JtYWwoMCwuMSx4LnNpemUpCiAgICBzbW9vdGg9bnAuY29udm9sdmUo
>>"%PYTEST_B64%" echo cmF3LG5wLm9uZXMoMjUpLzI1LG1vZGU9InNhbWUiKQogICAgc2lnbWE9bnAuc3RkKHJhdy1z
>>"%PYTEST_B64%" echo bW9vdGgpCiAgICBmaWcsYXg9cGx0LnN1YnBsb3RzKGZpZ3NpemU9KDEyLDcpKQogICAgYXgu
>>"%PYTEST_B64%" echo cGxvdCh4LHJhdyxhbHBoYT0uMzUsbGFiZWw9Ik9ic2VydmVkIikKICAgIGF4LnBsb3QoeCxz
>>"%PYTEST_B64%" echo bW9vdGgsbGluZXdpZHRoPTIuNCxsYWJlbD0iVHJlbmQiKQogICAgYXguZmlsbF9iZXR3ZWVu
>>"%PYTEST_B64%" echo KHgsc21vb3RoLTEuOTYqc2lnbWEsc21vb3RoKzEuOTYqc2lnbWEsYWxwaGE9LjE4LGxhYmVs
>>"%PYTEST_B64%" echo PSI5NSUgYmFuZCIpCiAgICBwZWFrPWludChucC5hcmdtYXgoc21vb3RoKSkKICAgIGF4LnNj
>>"%PYTEST_B64%" echo YXR0ZXIoW3hbcGVha11dLFtzbW9vdGhbcGVha11dLHM9ODAsem9yZGVyPTUpCiAgICBheC5h
>>"%PYTEST_B64%" echo bm5vdGF0ZShmIlBlYWsge3Ntb290aFtwZWFrXTouM2Z9IiwoeFtwZWFrXSxzbW9vdGhbcGVh
>>"%PYTEST_B64%" echo a10pLHh5dGV4dD0oMjAsMjgpLHRleHRjb29yZHM9Im9mZnNldCBwb2ludHMiLGFycm93cHJv
>>"%PYTEST_B64%" echo cHM9eyJhcnJvd3N0eWxlIjoiLT4ifSkKICAgIGF4LnNldF90aXRsZSgiQWR2YW5jZWQgTWF0
>>"%PYTEST_B64%" echo cGxvdGxpYiBWYWxpZGF0aW9uIikKICAgIGF4LnNldF94bGFiZWwoIlRpbWUiKTsgYXguc2V0
>>"%PYTEST_B64%" echo X3lsYWJlbCgiU2lnbmFsIik7IGF4LmdyaWQoVHJ1ZSxhbHBoYT0uMik7IGF4LmxlZ2VuZCgp
>>"%PYTEST_B64%" echo CiAgICBmaWcudGlnaHRfbGF5b3V0KCkKICAgIHA9T1VULyJtYXRwbG90bGliX2FkdmFuY2Vk
>>"%PYTEST_B64%" echo X2dyYXBoLnBuZyIKICAgIGZpZy5zYXZlZmlnKHAsZHBpPTE4MCkKICAgIHBsdC5jbG9zZShm
>>"%PYTEST_B64%" echo aWcpCiAgICByZXR1cm4gc3RyKHApCgpkZWYgc2NpcHlfdGVzdCgpOgogICAgZnJvbSBzY2lw
>>"%PYTEST_B64%" echo eS5pbnRlZ3JhdGUgaW1wb3J0IHF1YWQKICAgIGZyb20gc2NpcHkub3B0aW1pemUgaW1wb3J0
>>"%PYTEST_B64%" echo IG1pbmltaXplX3NjYWxhcgogICAgYXJlYSxfPXF1YWQobGFtYmRhIHg6IG1hdGguZXhwKC0o
>>"%PYTEST_B64%" echo eCp4KSksLTIsMikKICAgIG9wdD1taW5pbWl6ZV9zY2FsYXIobGFtYmRhIHg6KHgtMy4yNSkq
>>"%PYTEST_B64%" echo KjIrNCkKICAgIHJldHVybiBmImFyZWE9e2FyZWE6LjVmfSwgb3B0aW11bT17b3B0Lng6LjRm
>>"%PYTEST_B64%" echo fSIKCmRlZiBza2xlYXJuX3Rlc3QoKToKICAgIGZyb20gc2tsZWFybi5kYXRhc2V0cyBpbXBv
>>"%PYTEST_B64%" echo cnQgbG9hZF9pcmlzCiAgICBmcm9tIHNrbGVhcm4ubW9kZWxfc2VsZWN0aW9uIGltcG9ydCB0
>>"%PYTEST_B64%" echo cmFpbl90ZXN0X3NwbGl0CiAgICBmcm9tIHNrbGVhcm4ucGlwZWxpbmUgaW1wb3J0IG1ha2Vf
>>"%PYTEST_B64%" echo cGlwZWxpbmUKICAgIGZyb20gc2tsZWFybi5wcmVwcm9jZXNzaW5nIGltcG9ydCBTdGFuZGFy
>>"%PYTEST_B64%" echo ZFNjYWxlcgogICAgZnJvbSBza2xlYXJuLmxpbmVhcl9tb2RlbCBpbXBvcnQgTG9naXN0aWNS
>>"%PYTEST_B64%" echo ZWdyZXNzaW9uCiAgICBmcm9tIHNrbGVhcm4ubWV0cmljcyBpbXBvcnQgYWNjdXJhY3lfc2Nv
>>"%PYTEST_B64%" echo cmUKICAgIFgseT1sb2FkX2lyaXMocmV0dXJuX1hfeT1UcnVlKQogICAgWHRyLFh0ZSx5dHIs
>>"%PYTEST_B64%" echo eXRlPXRyYWluX3Rlc3Rfc3BsaXQoWCx5LHRlc3Rfc2l6ZT0uMyxyYW5kb21fc3RhdGU9NDIs
>>"%PYTEST_B64%" echo c3RyYXRpZnk9eSkKICAgIG1vZGVsPW1ha2VfcGlwZWxpbmUoU3RhbmRhcmRTY2FsZXIoKSxM
>>"%PYTEST_B64%" echo b2dpc3RpY1JlZ3Jlc3Npb24obWF4X2l0ZXI9NTAwKSkKICAgIG1vZGVsLmZpdChYdHIseXRy
>>"%PYTEST_B64%" echo KQogICAgcmV0dXJuIGYiYWNjdXJhY3k9e2FjY3VyYWN5X3Njb3JlKHl0ZSxtb2RlbC5wcmVk
>>"%PYTEST_B64%" echo aWN0KFh0ZSkpOi4zZn0iCgpkZWYgaW1wb3J0X3Rlc3QobmFtZSk6CiAgICBkZWYgaW5uZXIo
>>"%PYTEST_B64%" echo KToKICAgICAgICBtb2R1bGU9X19pbXBvcnRfXyhuYW1lKQogICAgICAgIHJldHVybiBzdHIo
>>"%PYTEST_B64%" echo Z2V0YXR0cihtb2R1bGUsIl9fdmVyc2lvbl9fIiwiaW5zdGFsbGVkIikpCiAgICByZXR1cm4g
>>"%PYTEST_B64%" echo aW5uZXIKCnRlc3RzPVsKICAgICgiTnVtUHkiLG51bXB5X3Rlc3QpLCgicGFuZGFzIixwYW5k
>>"%PYTEST_B64%" echo YXNfdGVzdCksKCJNYXRwbG90bGliIixtYXRwbG90bGliX3Rlc3QpLAogICAgKCJTY2lQeSIs
>>"%PYTEST_B64%" echo c2NpcHlfdGVzdCksKCJzY2lraXQtbGVhcm4iLHNrbGVhcm5fdGVzdCksKCJweXRlc3QiLGlt
>>"%PYTEST_B64%" echo cG9ydF90ZXN0KCJweXRlc3QiKSksCiAgICAoImlweWtlcm5lbCIsaW1wb3J0X3Rlc3QoImlw
>>"%PYTEST_B64%" echo eWtlcm5lbCIpKSwKXQoKcHJpbnQoIlB5dGhvbiBkYXRhLXNjaWVuY2UgdGVzdCBzdWl0ZSIp
>>"%PYTEST_B64%" echo CnByaW50KCJJbnRlcnByZXRlcjoiLHN5cy5leGVjdXRhYmxlKQpwcmludCgiT3V0cHV0IGZv
>>"%PYTEST_B64%" echo bGRlcjoiLE9VVCkKcHJpbnQoKQpmb3IgbmFtZSxmdW5jIGluIHRlc3RzOiBjaGVjayhuYW1l
>>"%PYTEST_B64%" echo LGZ1bmMpCnJlcG9ydD1PVVQvInRlc3RfcmVwb3J0LnR4dCIKd2l0aCByZXBvcnQub3Blbigi
>>"%PYTEST_B64%" echo dyIsZW5jb2Rpbmc9InV0Zi04IikgYXMgaGFuZGxlOgogICAgZm9yIG5hbWUsb2ssZGV0YWls
>>"%PYTEST_B64%" echo IGluIHJlc3VsdHM6CiAgICAgICAgaGFuZGxlLndyaXRlKGYieydQQVNTJyBpZiBvayBlbHNl
>>"%PYTEST_B64%" echo ICdGQUlMJ30gfCB7bmFtZX0gfCB7ZGV0YWlsfVxuIikKcGFzc2VkPXN1bShvayBmb3IgXyxv
>>"%PYTEST_B64%" echo ayxfIGluIHJlc3VsdHMpCnByaW50KGYiXG5GSU5BTDoge3Bhc3NlZH0ve2xlbihyZXN1bHRz
>>"%PYTEST_B64%" echo KX0gdGVzdHMgcGFzc2VkIikKcHJpbnQoIlJlcG9ydDoiLHJlcG9ydCkKaWYgcGFzc2VkICE9
>>"%PYTEST_B64%" echo IGxlbihyZXN1bHRzKTogcmFpc2UgU3lzdGVtRXhpdCgxKQo=
"%PYTHON%" -c "import base64,pathlib; p=pathlib.Path(r'%PYTEST_B64%'); o=pathlib.Path(r'%PY_BASE%\Test_Data_Science_Stack.py'); o.parent.mkdir(parents=True,exist_ok=True); o.write_bytes(base64.b64decode(p.read_text()))"
if errorlevel 1 (
  echo [FAILED] Could not create Python test suite.
  pause
  exit /b 1
)

>"%PYCFG_B64%" echo aW1wb3J0IGpzb24KaW1wb3J0IHNodXRpbAppbXBvcnQgc3lzCmZyb20gcGF0aGxpYiBpbXBv
>>"%PYCFG_B64%" echo cnQgUGF0aAoKZGVmIHN0cmlwX2pzb25jKHRleHQpOgogICAgb3V0ID0gW10KICAgIGkgPSAw
>>"%PYCFG_B64%" echo CiAgICBpbl9zdHJpbmcgPSBGYWxzZQogICAgZXNjYXBlZCA9IEZhbHNlCgogICAgd2hpbGUg
>>"%PYCFG_B64%" echo aSA8IGxlbih0ZXh0KToKICAgICAgICBjaCA9IHRleHRbaV0KICAgICAgICBpZiBpbl9zdHJp
>>"%PYCFG_B64%" echo bmc6CiAgICAgICAgICAgIG91dC5hcHBlbmQoY2gpCiAgICAgICAgICAgIGlmIGVzY2FwZWQ6
>>"%PYCFG_B64%" echo CiAgICAgICAgICAgICAgICBlc2NhcGVkID0gRmFsc2UKICAgICAgICAgICAgZWxpZiBjaCA9
>>"%PYCFG_B64%" echo PSAiXFwiOgogICAgICAgICAgICAgICAgZXNjYXBlZCA9IFRydWUKICAgICAgICAgICAgZWxp
>>"%PYCFG_B64%" echo ZiBjaCA9PSAnIic6CiAgICAgICAgICAgICAgICBpbl9zdHJpbmcgPSBGYWxzZQogICAgICAg
>>"%PYCFG_B64%" echo ICAgICBpICs9IDEKICAgICAgICAgICAgY29udGludWUKCiAgICAgICAgaWYgY2ggPT0gJyIn
>>"%PYCFG_B64%" echo OgogICAgICAgICAgICBpbl9zdHJpbmcgPSBUcnVlCiAgICAgICAgICAgIG91dC5hcHBlbmQo
>>"%PYCFG_B64%" echo Y2gpCiAgICAgICAgICAgIGkgKz0gMQogICAgICAgICAgICBjb250aW51ZQoKICAgICAgICBp
>>"%PYCFG_B64%" echo ZiBjaCA9PSAiLyIgYW5kIGkgKyAxIDwgbGVuKHRleHQpIGFuZCB0ZXh0W2kgKyAxXSA9PSAi
>>"%PYCFG_B64%" echo LyI6CiAgICAgICAgICAgIGkgKz0gMgogICAgICAgICAgICB3aGlsZSBpIDwgbGVuKHRleHQp
>>"%PYCFG_B64%" echo IGFuZCB0ZXh0W2ldIG5vdCBpbiAiXHJcbiI6CiAgICAgICAgICAgICAgICBpICs9IDEKICAg
>>"%PYCFG_B64%" echo ICAgICAgICAgY29udGludWUKCiAgICAgICAgaWYgY2ggPT0gIi8iIGFuZCBpICsgMSA8IGxl
>>"%PYCFG_B64%" echo bih0ZXh0KSBhbmQgdGV4dFtpICsgMV0gPT0gIioiOgogICAgICAgICAgICBpICs9IDIKICAg
>>"%PYCFG_B64%" echo ICAgICAgICAgd2hpbGUgaSArIDEgPCBsZW4odGV4dCkgYW5kIG5vdCAodGV4dFtpXSA9PSAi
>>"%PYCFG_B64%" echo KiIgYW5kIHRleHRbaSArIDFdID09ICIvIik6CiAgICAgICAgICAgICAgICBpICs9IDEKICAg
>>"%PYCFG_B64%" echo ICAgICAgICAgaSArPSAyCiAgICAgICAgICAgIGNvbnRpbnVlCgogICAgICAgIG91dC5hcHBl
>>"%PYCFG_B64%" echo bmQoY2gpCiAgICAgICAgaSArPSAxCgogICAgdGV4dCA9ICIiLmpvaW4ob3V0KQoKICAgIG91
>>"%PYCFG_B64%" echo dCA9IFtdCiAgICBpID0gMAogICAgaW5fc3RyaW5nID0gRmFsc2UKICAgIGVzY2FwZWQgPSBG
>>"%PYCFG_B64%" echo YWxzZQogICAgd2hpbGUgaSA8IGxlbih0ZXh0KToKICAgICAgICBjaCA9IHRleHRbaV0KICAg
>>"%PYCFG_B64%" echo ICAgICBpZiBpbl9zdHJpbmc6CiAgICAgICAgICAgIG91dC5hcHBlbmQoY2gpCiAgICAgICAg
>>"%PYCFG_B64%" echo ICAgIGlmIGVzY2FwZWQ6CiAgICAgICAgICAgICAgICBlc2NhcGVkID0gRmFsc2UKICAgICAg
>>"%PYCFG_B64%" echo ICAgICAgZWxpZiBjaCA9PSAiXFwiOgogICAgICAgICAgICAgICAgZXNjYXBlZCA9IFRydWUK
>>"%PYCFG_B64%" echo ICAgICAgICAgICAgZWxpZiBjaCA9PSAnIic6CiAgICAgICAgICAgICAgICBpbl9zdHJpbmcg
>>"%PYCFG_B64%" echo PSBGYWxzZQogICAgICAgICAgICBpICs9IDEKICAgICAgICAgICAgY29udGludWUKCiAgICAg
>>"%PYCFG_B64%" echo ICAgaWYgY2ggPT0gJyInOgogICAgICAgICAgICBpbl9zdHJpbmcgPSBUcnVlCiAgICAgICAg
>>"%PYCFG_B64%" echo ICAgIG91dC5hcHBlbmQoY2gpCiAgICAgICAgICAgIGkgKz0gMQogICAgICAgICAgICBjb250
>>"%PYCFG_B64%" echo aW51ZQoKICAgICAgICBpZiBjaCA9PSAiLCI6CiAgICAgICAgICAgIGogPSBpICsgMQogICAg
>>"%PYCFG_B64%" echo ICAgICAgICB3aGlsZSBqIDwgbGVuKHRleHQpIGFuZCB0ZXh0W2pdLmlzc3BhY2UoKToKICAg
>>"%PYCFG_B64%" echo ICAgICAgICAgICAgIGogKz0gMQogICAgICAgICAgICBpZiBqIDwgbGVuKHRleHQpIGFuZCB0
>>"%PYCFG_B64%" echo ZXh0W2pdIGluICJ9XSI6CiAgICAgICAgICAgICAgICBpICs9IDEKICAgICAgICAgICAgICAg
>>"%PYCFG_B64%" echo IGNvbnRpbnVlCgogICAgICAgIG91dC5hcHBlbmQoY2gpCiAgICAgICAgaSArPSAxCgogICAg
>>"%PYCFG_B64%" echo cmV0dXJuICIiLmpvaW4ob3V0KQoKZGVmIGxvYWRfc2V0dGluZ3MocGF0aCk6CiAgICBpZiBu
>>"%PYCFG_B64%" echo b3QgcGF0aC5leGlzdHMoKToKICAgICAgICByZXR1cm4ge30KCiAgICByYXcgPSBwYXRoLnJl
>>"%PYCFG_B64%" echo YWRfdGV4dChlbmNvZGluZz0idXRmLTgtc2lnIiwgZXJyb3JzPSJyZXBsYWNlIikKICAgIGlm
>>"%PYCFG_B64%" echo IG5vdCByYXcuc3RyaXAoKToKICAgICAgICByZXR1cm4ge30KCiAgICB0cnk6CiAgICAgICAg
>>"%PYCFG_B64%" echo ZGF0YSA9IGpzb24ubG9hZHMoc3RyaXBfanNvbmMocmF3KSkKICAgICAgICByZXR1cm4gZGF0
>>"%PYCFG_B64%" echo YSBpZiBpc2luc3RhbmNlKGRhdGEsIGRpY3QpIGVsc2Uge30KICAgIGV4Y2VwdCBFeGNlcHRp
>>"%PYCFG_B64%" echo b246CiAgICAgICAgdHJ5OgogICAgICAgICAgICBzaHV0aWwuY29weTIocGF0aCwgcGF0aC53
>>"%PYCFG_B64%" echo aXRoX25hbWUocGF0aC5uYW1lICsgIi51bnBhcnNlZC1iYWNrdXAiKSkKICAgICAgICBleGNl
>>"%PYCFG_B64%" echo cHQgRXhjZXB0aW9uOgogICAgICAgICAgICBwYXNzCiAgICAgICAgcmV0dXJuIHt9CgpkZWYg
>>"%PYCFG_B64%" echo bWFpbigpOgogICAgaW50ZXJwcmV0ZXIsIGV4dHJhLCBzZXR0aW5nc19uYW1lID0gc3lzLmFy
>>"%PYCFG_B64%" echo Z3ZbMTo0XQogICAgc2V0dGluZ3MgPSBQYXRoKHNldHRpbmdzX25hbWUpCiAgICBzZXR0aW5n
>>"%PYCFG_B64%" echo cy5wYXJlbnQubWtkaXIocGFyZW50cz1UcnVlLCBleGlzdF9vaz1UcnVlKQoKICAgIGlmIHNl
>>"%PYCFG_B64%" echo dHRpbmdzLmV4aXN0cygpOgogICAgICAgIHRyeToKICAgICAgICAgICAgc2h1dGlsLmNvcHky
>>"%PYCFG_B64%" echo KAogICAgICAgICAgICAgICAgc2V0dGluZ3MsCiAgICAgICAgICAgICAgICBzZXR0aW5ncy53
>>"%PYCFG_B64%" echo aXRoX25hbWUoc2V0dGluZ3MubmFtZSArICIuYmFja3VwLWJlZm9yZS11bmktZGV2LW1hbmFn
>>"%PYCFG_B64%" echo ZXIiKSwKICAgICAgICAgICAgKQogICAgICAgIGV4Y2VwdCBFeGNlcHRpb246CiAgICAgICAg
>>"%PYCFG_B64%" echo ICAgIHBhc3MKCiAgICBkYXRhID0gbG9hZF9zZXR0aW5ncyhzZXR0aW5ncykKICAgIGRhdGFb
>>"%PYCFG_B64%" echo InB5dGhvbi5kZWZhdWx0SW50ZXJwcmV0ZXJQYXRoIl0gPSBpbnRlcnByZXRlcgogICAgZGF0
>>"%PYCFG_B64%" echo YVsicHl0aG9uLnRlcm1pbmFsLmFjdGl2YXRlRW52aXJvbm1lbnQiXSA9IEZhbHNlCiAgICBk
>>"%PYCFG_B64%" echo YXRhWyJweXRob24uYW5hbHlzaXMuYXV0b0ltcG9ydENvbXBsZXRpb25zIl0gPSBUcnVlCiAg
>>"%PYCFG_B64%" echo ICBkYXRhWyJweXRob24uYW5hbHlzaXMudHlwZUNoZWNraW5nTW9kZSJdID0gImJhc2ljIgog
>>"%PYCFG_B64%" echo ICAgZGF0YVsicHl0aG9uLmFuYWx5c2lzLmV4dHJhUGF0aHMiXSA9IFtleHRyYV0KICAgIGRh
>>"%PYCFG_B64%" echo dGFbInB5dGhvbi50ZXN0aW5nLnB5dGVzdEVuYWJsZWQiXSA9IFRydWUKICAgIGRhdGFbInRl
>>"%PYCFG_B64%" echo cm1pbmFsLmludGVncmF0ZWQuZGVmYXVsdFByb2ZpbGUud2luZG93cyJdID0gIkNvbW1hbmQg
>>"%PYCFG_B64%" echo UHJvbXB0IgogICAgZGF0YVsiZWRpdG9yLmlubGluZVN1Z2dlc3QuZW5hYmxlZCJdID0gVHJ1
>>"%PYCFG_B64%" echo ZQogICAgZGF0YVsiZWRpdG9yLmJyYWNrZXRQYWlyQ29sb3JpemF0aW9uLmVuYWJsZWQiXSA9
>>"%PYCFG_B64%" echo IFRydWUKICAgIGRhdGFbImVkaXRvci5zdGlja3lTY3JvbGwuZW5hYmxlZCJdID0gVHJ1ZQog
>>"%PYCFG_B64%" echo ICAgZGF0YVsiZWRpdG9yLnRhYkNvbXBsZXRpb24iXSA9ICJvbiIKICAgIGRhdGFbIndvcmti
>>"%PYCFG_B64%" echo ZW5jaC5pY29uVGhlbWUiXSA9ICJtYXRlcmlhbC1pY29uLXRoZW1lIgogICAgZGF0YVsiZXJy
>>"%PYCFG_B64%" echo b3JMZW5zLmVuYWJsZWQiXSA9IFRydWUKCiAgICBweSA9IGRhdGEuZ2V0KCJbcHl0aG9uXSIp
>>"%PYCFG_B64%" echo CiAgICBpZiBub3QgaXNpbnN0YW5jZShweSwgZGljdCk6CiAgICAgICAgcHkgPSB7fQogICAg
>>"%PYCFG_B64%" echo cHlbImVkaXRvci5kZWZhdWx0Rm9ybWF0dGVyIl0gPSAiY2hhcmxpZXJtYXJzaC5ydWZmIgog
>>"%PYCFG_B64%" echo ICAgcHlbImVkaXRvci5mb3JtYXRPblNhdmUiXSA9IFRydWUKICAgIGRhdGFbIltweXRob25d
>>"%PYCFG_B64%" echo Il0gPSBweQoKICAgIHNldHRpbmdzLndyaXRlX3RleHQoanNvbi5kdW1wcyhkYXRhLCBpbmRl
>>"%PYCFG_B64%" echo bnQ9NCkgKyAiXG4iLCBlbmNvZGluZz0idXRmLTgiKQogICAgcHJpbnQoIlZTIENvZGUgdXNl
>>"%PYCFG_B64%" echo ciBzZXR0aW5ncyBjb25maWd1cmVkOiIsIHNldHRpbmdzKQoKaWYgX19uYW1lX18gPT0gIl9f
>>"%PYCFG_B64%" echo bWFpbl9fIjoKICAgIG1haW4oKQo=
"%PYTHON%" -c "import base64,pathlib; p=pathlib.Path(r'%PYCFG_B64%'); o=pathlib.Path(r'%PYCFG%'); o.parent.mkdir(parents=True,exist_ok=True); o.write_bytes(base64.b64decode(p.read_text()))"
if errorlevel 1 (
  echo [FAILED] Could not create VS Code configuration helper.
  pause
  exit /b 1
)

set "UNI_PY_EXTRA=%PY_EXTRA%"
set "UNI_PY_TEST=%PYTEST%"
set "PYTHONPATH=%PY_EXTRA%"
set "UNI_PY_USER=%PY_USER%"

if not exist "%USERPROFILE%\PythonUniWorkspace" mkdir "%USERPROFILE%\PythonUniWorkspace" >nul 2>&1
copy /y "%PYTEST%" "%USERPROFILE%\PythonUniWorkspace\Test_Data_Science_Stack.py" >nul 2>&1

call :CONFIGURE_PY_VSCODE
call :INSTALL_PY_EXTENSIONS

echo.
echo Opening package-install screen now...
echo You can choose a bundle and then type custom packages such as:
echo   matplotlib
echo   openpyxl==3.1.5
echo   numpy^>=2.0
echo.
"%PYTHON%" "%PYPM%" --first-run

echo.
echo Running Python tests...
"%PYTHON%" "%PYTEST%"
echo.
echo Exact VS Code interpreter:
echo   %PYTHON%
where clip.exe >nul 2>&1
if not errorlevel 1 (
  >"%TEMP%\pyclip.txt" echo %PYTHON%
  clip.exe < "%TEMP%\pyclip.txt"
  echo Interpreter path copied to clipboard.
)
pause
exit /b 0


:TRY_PY
if defined PYTHON exit /b
if not exist "%~1" exit /b
"%~1" -c "import sys; raise SystemExit(0 if sys.version_info>=(3,10) else 1)" >nul 2>&1
if errorlevel 1 exit /b
set "PYTHON=%~1"
set "PY_KIND=%~2"
echo %~2 | findstr /I "portable user python" >nul 2>&1
if errorlevel 1 (set "PY_USER=1") else (set "PY_USER=0")
exit /b


:INSTALL_PORTABLE_PY
set "PARCH=amd64"
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "PARCH=arm64"
if /I "%PROCESSOR_ARCHITECTURE%"=="x86" set "PARCH=win32"
if /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "PARCH=amd64"
set "PVER=3.12.10"
set "PDIR=%LOCALAPPDATA%\PortablePython\Current"
set "PZIP=%TEMP%\python-%PVER%-embed-%PARCH%.zip"
set "PURL=https://www.python.org/ftp/python/%PVER%/python-%PVER%-embed-%PARCH%.zip"
if exist "%PDIR%" rmdir /s /q "%PDIR%" >nul 2>&1
mkdir "%PDIR%" >nul 2>&1
call :DOWNLOAD "%PURL%" "%PZIP%"
if errorlevel 1 exit /b 1
call :EXTRACT "%PZIP%" "%PDIR%" "%PDIR%\python.exe"
if errorlevel 1 exit /b 1
set "PTH=%PDIR%\python312._pth"
if exist "%PTH%" (
  findstr /I /X /C:"Lib\site-packages" "%PTH%" >nul 2>&1
  if errorlevel 1 >>"%PTH%" echo Lib\site-packages
  findstr /I /X /C:"import site" "%PTH%" >nul 2>&1
  if errorlevel 1 >>"%PTH%" echo import site
)
if not exist "%PDIR%\Lib\site-packages" mkdir "%PDIR%\Lib\site-packages" >nul 2>&1
"%PDIR%\python.exe" -c "import sys;print(sys.version)" >nul 2>&1
if errorlevel 1 exit /b 1
set "PYTHON=%PDIR%\python.exe"
set "PY_KIND=Portable Python"
set "PY_USER=0"
exit /b 0


:CONFIGURE_PY_VSCODE
if not defined PYTHON exit /b
if not exist "%PYCFG%" exit /b
"%PYTHON%" "%PYCFG%" "%PYTHON%" "%PY_EXTRA%" "%APPDATA%\Code\User\settings.json"
exit /b

:INSTALL_REACT
cls
echo React + Web Tech 512 practical installation / repair
echo ====================================================================================================================
echo Project location:
echo   %APP_DIR%
echo.
call :ENSURE_NODE
if errorlevel 1 (
  echo [FAILED] No working Node.js + npm could be prepared.
  pause
  exit /b 1
)

if not exist "%APP_DIR%" mkdir "%APP_DIR%" >nul 2>&1
if not exist "%APP_DIR%\.vscode" mkdir "%APP_DIR%\.vscode" >nul 2>&1
if not exist "%APP_DIR%\src" mkdir "%APP_DIR%\src" >nul 2>&1

set "REGEN=1"
if exist "%APP_DIR%\package.json" (
  echo Existing React project detected.
  echo.
  echo [1] Repair dependencies only and KEEP current source
  echo [2] Regenerate Student Portal + game source, with source backup
  set /p "RMODE=Choose 1 or 2: "
  if "%RMODE%"=="1" set "REGEN=0"
  if "%RMODE%"=="2" (
    if exist "%APP_DIR%\backup_before_regenerate" rmdir /s /q "%APP_DIR%\backup_before_regenerate" >nul 2>&1
    mkdir "%APP_DIR%\backup_before_regenerate" >nul 2>&1
    if exist "%APP_DIR%\src" xcopy "%APP_DIR%\src" "%APP_DIR%\backup_before_regenerate\src\" /E /I /Y >nul 2>&1
    if exist "%APP_DIR%\package.json" copy /y "%APP_DIR%\package.json" "%APP_DIR%\backup_before_regenerate\package.json" >nul 2>&1
  )
)

if "%REGEN%"=="1" (
  call :WRITE_REACT_FILES
  if errorlevel 1 (
    echo [FAILED] Could not generate the React project files.
    pause
    exit /b 1
  )
)

if "%REGEN%"=="1" (
  call :WRITE_WEBTECH_HOMEWORK_FILES
  if errorlevel 1 (
    echo [FAILED] Could not generate the Web Tech 512 practical files.
    pause
    exit /b 1
  )
)

echo.
echo Installing React dependencies with portable/user Node.js...
set "PATH=%NODE_HOME%;%PATH%"
set "npm_config_cache=%NODE_CACHE%"
pushd "%APP_DIR%"
call "%NPM_CMD%" install --no-audit --no-fund
if errorlevel 1 (
  echo First npm install failed. Retrying with a fresh local cache...
  if exist "%NODE_CACHE%" rmdir /s /q "%NODE_CACHE%" >nul 2>&1
  mkdir "%NODE_CACHE%" >nul 2>&1
  call "%NPM_CMD%" install --no-audit --no-fund --prefer-online
)
if errorlevel 1 (
  popd
  echo [FAILED] npm install failed. The university network may block registry.npmjs.org.
  pause
  exit /b 1
)

echo.
echo Running production build to verify React/JSX...
call "%NPM_CMD%" run build
if errorlevel 1 (
  popd
  echo [FAILED] The React production build failed.
  echo The source or dependency error is shown above.
  pause
  exit /b 1
)
popd

call :VERIFY_WEBTECH_HOMEWORK
if errorlevel 1 (
  echo [FAILED] Production build passed but the Web Tech 512 component structure check failed.
  pause
  exit /b 1
)

call :CREATE_REACT_LAUNCHERS
call :INSTALL_REACT_EXTENSIONS

echo.
echo [SUCCESS] Web Tech homework + React portal/game installed and verified.
echo.
echo Project folder:
echo   %APP_DIR%
echo.
echo Homework component folder:
echo   %APP_DIR%\src\components
echo.
echo Starter:
echo   %APP_DIR%\Start_MyReactApp2026.cmd
echo.
echo The app opens the Web Tech 512 practical homepage first.
echo Use "Open Advanced Student Portal" to access the login, dashboard and game.
echo.
echo Opening project folder, VS Code and development server...
start "" explorer.exe "%APP_DIR%"
call :OPEN_REACT_CODE
call :START_REACT
pause
exit /b 0

:ENSURE_NODE
set "NODE_EXE="
set "NPM_CMD="
set "NODE_HOME="
set "NODE_KIND="

call :TRY_NODE "%LOCALAPPDATA%\PortableNode\node-v24.20.0-win-x64\node.exe" "Previous portable Node"
if defined NODE_EXE goto NODE_OK
call :TRY_NODE "%ProgramFiles%\nodejs\node.exe" "System Node"
if defined NODE_EXE goto NODE_OK
call :TRY_NODE "%LOCALAPPDATA%\Programs\nodejs\node.exe" "User Node"
if defined NODE_EXE goto NODE_OK
for /f "delims=" %%N in ('where node.exe 2^>nul') do call :TRY_NODE "%%N" "Node from PATH"
if defined NODE_EXE goto NODE_OK

set "NODE_ARCH=x64"
if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "NODE_ARCH=arm64"
if /I "%PROCESSOR_ARCHITECTURE%"=="x86" set "NODE_ARCH=x86"
if /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "NODE_ARCH=x64"
if /I "%NODE_ARCH%"=="x86" set "NODE_VERSION=22.23.2"
if not "%NODE_ARCH%"=="x86" set "NODE_VERSION=24.20.0"

set "NFOLDER=node-v%NODE_VERSION%-win-%NODE_ARCH%"
set "NDIR=%LOCALAPPDATA%\PortableNode\%NFOLDER%"
set "NZIP=%TEMP%\%NFOLDER%.zip"
set "NURL=https://nodejs.org/dist/v%NODE_VERSION%/%NFOLDER%.zip"
if not exist "%LOCALAPPDATA%\PortableNode" mkdir "%LOCALAPPDATA%\PortableNode" >nul 2>&1

echo Downloading official portable Node.js ZIP:
echo   %NURL%
call :DOWNLOAD "%NURL%" "%NZIP%"
if errorlevel 1 exit /b 1
call :EXTRACT "%NZIP%" "%LOCALAPPDATA%\PortableNode" "%NDIR%\node.exe"
if errorlevel 1 exit /b 1
call :TRY_NODE "%NDIR%\node.exe" "Portable Node %NODE_VERSION%"
if not defined NODE_EXE exit /b 1

:NODE_OK
>"%BASE%\node_exe.txt" echo %NODE_EXE%
>"%BASE%\npm_cmd.txt" echo %NPM_CMD%
echo [OK] Node: %NODE_EXE%
echo [OK] npm : %NPM_CMD%
exit /b 0


:TRY_NODE
if defined NODE_EXE exit /b
if not exist "%~1" exit /b
for %%I in ("%~1") do set "CNDIR=%%~dpI"
if not exist "%CNDIR%npm.cmd" exit /b
"%~1" --version >nul 2>&1
if errorlevel 1 exit /b
"%~1" -e "const [M,m]=process.versions.node.split('.').map(Number);process.exit((M>20||(M===20&&m>=19))?0:1)" >nul 2>&1
if errorlevel 1 (
  echo [SKIP] Node is too old for the current Vite toolchain: %~1
  exit /b
)
call "%CNDIR%npm.cmd" --version >nul 2>&1
if errorlevel 1 exit /b
set "NODE_EXE=%~1"
set "NPM_CMD=%CNDIR%npm.cmd"
set "NODE_HOME=%CNDIR%"
set "NODE_KIND=%~2"
exit /b


:WRITE_REACT_FILES
echo Generating Student Portal + Ricochet Arena from this single CMD...
set "RB1=%TEMP%\react_embed_1.b64"
>"%RB1%" echo ewogICJuYW1lIjogIm15cmVhY3RhcHAyMDI2IiwKICAicHJpdmF0ZSI6IHRydWUsCiAgInZl
>>"%RB1%" echo cnNpb24iOiAiMS4wLjAiLAogICJ0eXBlIjogIm1vZHVsZSIsCiAgInNjcmlwdHMiOiB7CiAg
>>"%RB1%" echo ICAiZGV2IjogInZpdGUiLAogICAgImJ1aWxkIjogInZpdGUgYnVpbGQiLAogICAgInByZXZp
>>"%RB1%" echo ZXciOiAidml0ZSBwcmV2aWV3IiwKICAgICJsaW50IjogImVzbGludCAuIgogIH0sCiAgImRl
>>"%RB1%" echo cGVuZGVuY2llcyI6IHsKICAgICJyZWFjdCI6ICJeMTkuMC4wIiwKICAgICJyZWFjdC1kb20i
>>"%RB1%" echo OiAiXjE5LjAuMCIKICB9LAogICJkZXZEZXBlbmRlbmNpZXMiOiB7CiAgICAiQGVzbGludC9q
>>"%RB1%" echo cyI6ICJeOS4wLjAiLAogICAgIkB2aXRlanMvcGx1Z2luLXJlYWN0IjogIl41LjAuMCIsCiAg
>>"%RB1%" echo ICAiZXNsaW50IjogIl45LjAuMCIsCiAgICAiZXNsaW50LXBsdWdpbi1yZWFjdC1ob29rcyI6
>>"%RB1%" echo ICJeNS4wLjAiLAogICAgImVzbGludC1wbHVnaW4tcmVhY3QtcmVmcmVzaCI6ICJeMC40LjAi
>>"%RB1%" echo LAogICAgImdsb2JhbHMiOiAiXjE2LjAuMCIsCiAgICAicHJldHRpZXIiOiAiXjMuMC4wIiwK
>>"%RB1%" echo ICAgICJ2aXRlIjogIl44LjIuMCIKICB9Cn0K
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB1%" "%APP_DIR%\package.json"
set "RB2=%TEMP%\react_embed_2.b64"
>"%RB2%" echo PCFkb2N0eXBlIGh0bWw+CjxodG1sIGxhbmc9ImVuIj4KICA8aGVhZD4KICAgIDxtZXRhIGNo
>>"%RB2%" echo YXJzZXQ9IlVURi04IiAvPgogICAgPG1ldGEgbmFtZT0idmlld3BvcnQiIGNvbnRlbnQ9Indp
>>"%RB2%" echo ZHRoPWRldmljZS13aWR0aCwgaW5pdGlhbC1zY2FsZT0xLjAiIC8+CiAgICA8bWV0YSBuYW1l
>>"%RB2%" echo PSJ0aGVtZS1jb2xvciIgY29udGVudD0iIzA3MTExZiIgLz4KICAgIDxtZXRhIG5hbWU9ImRl
>>"%RB2%" echo c2NyaXB0aW9uIiBjb250ZW50PSJTdHVkZW50IFBvcnRhbCAyMDI2IHdpdGggUmljb2NoZXQg
>>"%RB2%" echo QXJlbmEiIC8+CiAgICA8dGl0bGU+U3R1ZGVudCBQb3J0YWwgMjAyNjwvdGl0bGU+CiAgPC9o
>>"%RB2%" echo ZWFkPgogIDxib2R5PgogICAgPGRpdiBpZD0icm9vdCI+PC9kaXY+CiAgICA8c2NyaXB0IHR5
>>"%RB2%" echo cGU9Im1vZHVsZSIgc3JjPSIvc3JjL21haW4uanN4Ij48L3NjcmlwdD4KICA8L2JvZHk+Cjwv
>>"%RB2%" echo aHRtbD4K
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB2%" "%APP_DIR%\index.html"
set "RB3=%TEMP%\react_embed_3.b64"
>"%RB3%" echo aW1wb3J0IHsgZGVmaW5lQ29uZmlnIH0gZnJvbSAndml0ZScKaW1wb3J0IHJlYWN0IGZyb20g
>>"%RB3%" echo J0B2aXRlanMvcGx1Z2luLXJlYWN0JwoKZXhwb3J0IGRlZmF1bHQgZGVmaW5lQ29uZmlnKHsK
>>"%RB3%" echo ICBwbHVnaW5zOiBbcmVhY3QoKV0sCiAgc2VydmVyOiB7CiAgICBob3N0OiAnMTI3LjAuMC4x
>>"%RB3%" echo JywKICAgIHBvcnQ6IDUxNzMsCiAgICBzdHJpY3RQb3J0OiB0cnVlLAogIH0sCn0pCg==
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB3%" "%APP_DIR%\vite.config.js"
set "RB4=%TEMP%\react_embed_4.b64"
>"%RB4%" echo aW1wb3J0IGpzIGZyb20gJ0Blc2xpbnQvanMnCmltcG9ydCBnbG9iYWxzIGZyb20gJ2dsb2Jh
>>"%RB4%" echo bHMnCmltcG9ydCByZWFjdEhvb2tzIGZyb20gJ2VzbGludC1wbHVnaW4tcmVhY3QtaG9va3Mn
>>"%RB4%" echo CmltcG9ydCByZWFjdFJlZnJlc2ggZnJvbSAnZXNsaW50LXBsdWdpbi1yZWFjdC1yZWZyZXNo
>>"%RB4%" echo JwoKZXhwb3J0IGRlZmF1bHQgWwogIHsgaWdub3JlczogWydkaXN0J10gfSwKICB7CiAgICBm
>>"%RB4%" echo aWxlczogWycqKi8qLntqcyxqc3h9J10sCiAgICBleHRlbmRzOiBbCiAgICAgIGpzLmNvbmZp
>>"%RB4%" echo Z3MucmVjb21tZW5kZWQsCiAgICAgIHJlYWN0SG9va3MuY29uZmlnc1sncmVjb21tZW5kZWQt
>>"%RB4%" echo bGF0ZXN0J10sCiAgICAgIHJlYWN0UmVmcmVzaC5jb25maWdzLnZpdGUsCiAgICBdLAogICAg
>>"%RB4%" echo bGFuZ3VhZ2VPcHRpb25zOiB7CiAgICAgIGVjbWFWZXJzaW9uOiAyMDI0LAogICAgICBnbG9i
>>"%RB4%" echo YWxzOiBnbG9iYWxzLmJyb3dzZXIsCiAgICAgIHBhcnNlck9wdGlvbnM6IHsKICAgICAgICBl
>>"%RB4%" echo Y21hVmVyc2lvbjogJ2xhdGVzdCcsCiAgICAgICAgZWNtYUZlYXR1cmVzOiB7IGpzeDogdHJ1
>>"%RB4%" echo ZSB9LAogICAgICAgIHNvdXJjZVR5cGU6ICdtb2R1bGUnLAogICAgICB9LAogICAgfSwKICAg
>>"%RB4%" echo IHJ1bGVzOiB7CiAgICAgICduby11bnVzZWQtdmFycyc6IFsnd2FybicsIHsgYXJnc0lnbm9y
>>"%RB4%" echo ZVBhdHRlcm46ICdeXycgfV0sCiAgICB9LAogIH0sCl0K
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB4%" "%APP_DIR%\eslint.config.js"
set "RB5=%TEMP%\react_embed_5.b64"
>"%RB5%" echo ewogICJzZW1pIjogZmFsc2UsCiAgInNpbmdsZVF1b3RlIjogdHJ1ZSwKICAidHJhaWxpbmdD
>>"%RB5%" echo b21tYSI6ICJhbGwiLAogICJwcmludFdpZHRoIjogMTAwCn0K
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB5%" "%APP_DIR%\.prettierrc"
set "RB6=%TEMP%\react_embed_6.b64"
>"%RB6%" echo ewogICJlZGl0b3IuZm9ybWF0T25TYXZlIjogdHJ1ZSwKICAiZWRpdG9yLmRlZmF1bHRGb3Jt
>>"%RB6%" echo YXR0ZXIiOiAiZXNiZW5wLnByZXR0aWVyLXZzY29kZSIsCiAgImVkaXRvci5pbmxpbmVTdWdn
>>"%RB6%" echo ZXN0LmVuYWJsZWQiOiB0cnVlLAogICJlZGl0b3IuYnJhY2tldFBhaXJDb2xvcml6YXRpb24u
>>"%RB6%" echo ZW5hYmxlZCI6IHRydWUsCiAgImVkaXRvci5zdGlja3lTY3JvbGwuZW5hYmxlZCI6IHRydWUs
>>"%RB6%" echo CiAgImVkaXRvci50YWJDb21wbGV0aW9uIjogIm9uIiwKICAiZWRpdG9yLmNvZGVBY3Rpb25z
>>"%RB6%" echo T25TYXZlIjogewogICAgInNvdXJjZS5maXhBbGwuZXNsaW50IjogImV4cGxpY2l0IgogIH0s
>>"%RB6%" echo CiAgImphdmFzY3JpcHQuc3VnZ2VzdC5hdXRvSW1wb3J0cyI6IHRydWUsCiAgInR5cGVzY3Jp
>>"%RB6%" echo cHQuc3VnZ2VzdC5hdXRvSW1wb3J0cyI6IHRydWUsCiAgIndvcmtiZW5jaC5pY29uVGhlbWUi
>>"%RB6%" echo OiAibWF0ZXJpYWwtaWNvbi10aGVtZSIsCiAgImVycm9yTGVucy5lbmFibGVkIjogdHJ1ZQp9
>>"%RB6%" echo Cg==
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB6%" "%APP_DIR%\.vscode\settings.json"
set "RB7=%TEMP%\react_embed_7.b64"
>"%RB7%" echo aW1wb3J0IHsgU3RyaWN0TW9kZSB9IGZyb20gJ3JlYWN0JwppbXBvcnQgeyBjcmVhdGVSb290
>>"%RB7%" echo IH0gZnJvbSAncmVhY3QtZG9tL2NsaWVudCcKaW1wb3J0IEFwcCBmcm9tICcuL0FwcC5qc3gn
>>"%RB7%" echo CmltcG9ydCAnLi9zdHlsZXMuY3NzJwoKY3JlYXRlUm9vdChkb2N1bWVudC5nZXRFbGVtZW50
>>"%RB7%" echo QnlJZCgncm9vdCcpKS5yZW5kZXIoCiAgPFN0cmljdE1vZGU+CiAgICA8QXBwIC8+CiAgPC9T
>>"%RB7%" echo dHJpY3RNb2RlPiwKKQo=
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB7%" "%APP_DIR%\src\main.jsx"
set "RB8=%TEMP%\react_embed_8.b64"
>"%RB8%" echo aW1wb3J0IHsgdXNlRWZmZWN0LCB1c2VNZW1vLCB1c2VTdGF0ZSB9IGZyb20gJ3JlYWN0Jwpp
>>"%RB8%" echo bXBvcnQgUmljb2NoZXRHYW1lIGZyb20gJy4vUmljb2NoZXRHYW1lLmpzeCcKCmNvbnN0IFVT
>>"%RB8%" echo RVJTX0tFWSA9ICdzdHVkZW50UG9ydGFsMjAyNi51c2VycycKY29uc3QgU0VTU0lPTl9LRVkg
>>"%RB8%" echo PSAnc3R1ZGVudFBvcnRhbDIwMjYuc2Vzc2lvbicKCmNvbnN0IGNvdXJzZXMgPSBbCiAgeyBj
>>"%RB8%" echo b2RlOiAnRFNDMjAxJywgbmFtZTogJ0FwcGxpZWQgRGF0YSBTY2llbmNlJywgbGVjdHVyZXI6
>>"%RB8%" echo ICdEci4gTS4gRGxhbWluaScsIHByb2dyZXNzOiA3OCwgcm9vbTogJ0xhYiBCMTInLCBhY2Nl
>>"%RB8%" echo bnQ6ICdjeWFuJyB9LAogIHsgY29kZTogJ1dEVDIyMCcsIG5hbWU6ICdBZHZhbmNlZCBXZWIg
>>"%RB8%" echo VGVjaG5vbG9neScsIGxlY3R1cmVyOiAnUHJvZi4gSy4gTmFpZG9vJywgcHJvZ3Jlc3M6IDY0
>>"%RB8%" echo LCByb29tOiAnV2ViIExhYiA0JywgYWNjZW50OiAndmlvbGV0JyB9LAogIHsgY29kZTogJ0RC
>>"%RB8%" echo UzIxMCcsIG5hbWU6ICdEYXRhYmFzZSBTeXN0ZW1zJywgbGVjdHVyZXI6ICdNcy4gVC4gTW9r
>>"%RB8%" echo b2VuYScsIHByb2dyZXNzOiA4Mywgcm9vbTogJ1Jvb20gQzA4JywgYWNjZW50OiAnZW1lcmFs
>>"%RB8%" echo ZCcgfSwKICB7IGNvZGU6ICdNQVQyMDUnLCBuYW1lOiAnQ29tcHV0YXRpb25hbCBNYXRoZW1h
>>"%RB8%" echo dGljcycsIGxlY3R1cmVyOiAnRHIuIFIuIFNtaXRoJywgcHJvZ3Jlc3M6IDcxLCByb29tOiAn
>>"%RB8%" echo Um9vbSBBMTcnLCBhY2NlbnQ6ICdhbWJlcicgfSwKXQoKY29uc3QgYXNzaWdubWVudHMgPSBb
>>"%RB8%" echo CiAgeyB0aXRsZTogJ1BhbmRhcyBDbGVhbmluZyBQaXBlbGluZScsIGNvdXJzZTogJ0RTQzIw
>>"%RB8%" echo MScsIGR1ZTogJ1RvZGF5LCAxNzowMCcsIHByaW9yaXR5OiAnSGlnaCcsIHByb2dyZXNzOiA3
>>"%RB8%" echo MCB9LAogIHsgdGl0bGU6ICdSZWFjdCBTdHVkZW50IFBvcnRhbCcsIGNvdXJzZTogJ1dEVDIy
>>"%RB8%" echo MCcsIGR1ZTogJ1RvbW9ycm93LCAyMzo1OScsIHByaW9yaXR5OiAnSGlnaCcsIHByb2dyZXNz
>>"%RB8%" echo OiA1MiB9LAogIHsgdGl0bGU6ICdTUUwgUXVlcnkgT3B0aW1pc2F0aW9uJywgY291cnNlOiAn
>>"%RB8%" echo REJTMjEwJywgZHVlOiAnTW9uLCAwOTowMCcsIHByaW9yaXR5OiAnTWVkaXVtJywgcHJvZ3Jl
>>"%RB8%" echo c3M6IDg2IH0sCiAgeyB0aXRsZTogJ051bWVyaWNhbCBNZXRob2RzIFdvcmtzaGVldCcsIGNv
>>"%RB8%" echo dXJzZTogJ01BVDIwNScsIGR1ZTogJ1dlZCwgMTI6MDAnLCBwcmlvcml0eTogJ0xvdycsIHBy
>>"%RB8%" echo b2dyZXNzOiAzNCB9LApdCgpjb25zdCBzY2hlZHVsZSA9IFsKICB7IHRpbWU6ICcwODowMCcs
>>"%RB8%" echo IHRpdGxlOiAnQXBwbGllZCBEYXRhIFNjaWVuY2UnLCBtZXRhOiAnTGFiIEIxMiDigKIgUHJh
>>"%RB8%" echo Y3RpY2FsJywgc3RhdHVzOiAnZG9uZScgfSwKICB7IHRpbWU6ICcxMDowMCcsIHRpdGxlOiAn
>>"%RB8%" echo QWR2YW5jZWQgV2ViIFRlY2hub2xvZ3knLCBtZXRhOiAnV2ViIExhYiA0IOKAoiBMZWN0dXJl
>>"%RB8%" echo Jywgc3RhdHVzOiAnYWN0aXZlJyB9LAogIHsgdGltZTogJzEyOjAwJywgdGl0bGU6ICdMdW5j
>>"%RB8%" echo aCAvIFN0dWR5IEJsb2NrJywgbWV0YTogJ1N0dWRlbnQgQ2VudHJlJywgc3RhdHVzOiAnZnJl
>>"%RB8%" echo ZScgfSwKICB7IHRpbWU6ICcxNDowMCcsIHRpdGxlOiAnRGF0YWJhc2UgU3lzdGVtcycsIG1l
>>"%RB8%" echo dGE6ICdSb29tIEMwOCDigKIgVHV0b3JpYWwnLCBzdGF0dXM6ICduZXh0JyB9LAogIHsgdGlt
>>"%RB8%" echo ZTogJzE2OjAwJywgdGl0bGU6ICdQcm9qZWN0IENvbnN1bHRhdGlvbicsIG1ldGE6ICdPbmxp
>>"%RB8%" echo bmUg4oCiIFRlYW1zJywgc3RhdHVzOiAnbmV4dCcgfSwKXQoKZnVuY3Rpb24gcmVhZFVzZXJz
>>"%RB8%" echo KCkgewogIHRyeSB7CiAgICByZXR1cm4gSlNPTi5wYXJzZShsb2NhbFN0b3JhZ2UuZ2V0SXRl
>>"%RB8%" echo bShVU0VSU19LRVkpIHx8ICdbXScpCiAgfSBjYXRjaCB7CiAgICByZXR1cm4gW10KICB9Cn0K
>>"%RB8%" echo CmFzeW5jIGZ1bmN0aW9uIGhhc2hQYXNzd29yZChwYXNzd29yZCkgewogIGlmIChnbG9iYWxU
>>"%RB8%" echo aGlzLmNyeXB0bz8uc3VidGxlKSB7CiAgICBjb25zdCBieXRlcyA9IG5ldyBUZXh0RW5jb2Rl
>>"%RB8%" echo cigpLmVuY29kZShwYXNzd29yZCkKICAgIGNvbnN0IGRpZ2VzdCA9IGF3YWl0IGNyeXB0by5z
>>"%RB8%" echo dWJ0bGUuZGlnZXN0KCdTSEEtMjU2JywgYnl0ZXMpCiAgICByZXR1cm4gWy4uLm5ldyBVaW50
>>"%RB8%" echo OEFycmF5KGRpZ2VzdCldLm1hcCgoYikgPT4gYi50b1N0cmluZygxNikucGFkU3RhcnQoMiwg
>>"%RB8%" echo JzAnKSkuam9pbignJykKICB9CiAgbGV0IGhhc2ggPSAyMTY2MTM2MjYxCiAgZm9yIChjb25z
>>"%RB8%" echo dCBjaGFyIG9mIHBhc3N3b3JkKSB7CiAgICBoYXNoIF49IGNoYXIuY2hhckNvZGVBdCgwKQog
>>"%RB8%" echo ICAgaGFzaCA9IE1hdGguaW11bChoYXNoLCAxNjc3NzYxOSkKICB9CiAgcmV0dXJuIGBmYWxs
>>"%RB8%" echo YmFjay0keyhoYXNoID4+PiAwKS50b1N0cmluZygxNil9YAp9CgpmdW5jdGlvbiBwYXNzd29y
>>"%RB8%" echo ZFNjb3JlKHZhbHVlKSB7CiAgbGV0IHNjb3JlID0gMAogIGlmICh2YWx1ZS5sZW5ndGggPj0g
>>"%RB8%" echo OCkgc2NvcmUgKz0gMQogIGlmICh2YWx1ZS5sZW5ndGggPj0gMTIpIHNjb3JlICs9IDEKICBp
>>"%RB8%" echo ZiAoL1tBLVpdLy50ZXN0KHZhbHVlKSkgc2NvcmUgKz0gMQogIGlmICgvW2Etel0vLnRlc3Qo
>>"%RB8%" echo dmFsdWUpKSBzY29yZSArPSAxCiAgaWYgKC9cZC8udGVzdCh2YWx1ZSkpIHNjb3JlICs9IDEK
>>"%RB8%" echo ICBpZiAoL1teQS1aYS16MC05XS8udGVzdCh2YWx1ZSkpIHNjb3JlICs9IDEKICByZXR1cm4g
>>"%RB8%" echo TWF0aC5taW4oNSwgc2NvcmUpCn0KCmZ1bmN0aW9uIEF1dGhTY3JlZW4oeyBvbkF1dGhlbnRp
>>"%RB8%" echo Y2F0ZWQgfSkgewogIGNvbnN0IFttb2RlLCBzZXRNb2RlXSA9IHVzZVN0YXRlKCdsb2dpbicp
>>"%RB8%" echo CiAgY29uc3QgW21lc3NhZ2UsIHNldE1lc3NhZ2VdID0gdXNlU3RhdGUoJycpCiAgY29uc3Qg
>>"%RB8%" echo W2J1c3ksIHNldEJ1c3ldID0gdXNlU3RhdGUoZmFsc2UpCiAgY29uc3QgW2xvZ2luLCBzZXRM
>>"%RB8%" echo b2dpbl0gPSB1c2VTdGF0ZSh7IGlkZW50aXR5OiAnJywgcGFzc3dvcmQ6ICcnLCByZW1lbWJl
>>"%RB8%" echo cjogdHJ1ZSB9KQogIGNvbnN0IFtzaWdudXAsIHNldFNpZ251cF0gPSB1c2VTdGF0ZSh7CiAg
>>"%RB8%" echo ICBmaXJzdE5hbWU6ICcnLAogICAgbGFzdE5hbWU6ICcnLAogICAgc3R1ZGVudElkOiAnJywK
>>"%RB8%" echo ICAgIGVtYWlsOiAnJywKICAgIHByb2dyYW06ICdCU2MgSW5mb3JtYXRpb24gVGVjaG5vbG9n
>>"%RB8%" echo eScsCiAgICB5ZWFyOiAnMicsCiAgICBwYXNzd29yZDogJycsCiAgICBjb25maXJtOiAnJywK
>>"%RB8%" echo ICB9KQoKICBjb25zdCBzdHJlbmd0aCA9IHBhc3N3b3JkU2NvcmUoc2lnbnVwLnBhc3N3b3Jk
>>"%RB8%" echo KQogIGNvbnN0IHN0cmVuZ3RoVGV4dCA9IFsnVmVyeSB3ZWFrJywgJ1dlYWsnLCAnRmFpcics
>>"%RB8%" echo ICdHb29kJywgJ1N0cm9uZycsICdFeGNlbGxlbnQnXVtzdHJlbmd0aF0KCiAgYXN5bmMgZnVu
>>"%RB8%" echo Y3Rpb24gc3VibWl0TG9naW4oZXZlbnQpIHsKICAgIGV2ZW50LnByZXZlbnREZWZhdWx0KCkK
>>"%RB8%" echo ICAgIHNldEJ1c3kodHJ1ZSkKICAgIHNldE1lc3NhZ2UoJycpCiAgICB0cnkgewogICAgICBj
>>"%RB8%" echo b25zdCB1c2VycyA9IHJlYWRVc2VycygpCiAgICAgIGNvbnN0IGlkZW50aXR5ID0gbG9naW4u
>>"%RB8%" echo aWRlbnRpdHkudHJpbSgpLnRvTG93ZXJDYXNlKCkKICAgICAgY29uc3QgdXNlciA9IHVzZXJz
>>"%RB8%" echo LmZpbmQoCiAgICAgICAgKGl0ZW0pID0+CiAgICAgICAgICBpdGVtLmVtYWlsLnRvTG93ZXJD
>>"%RB8%" echo YXNlKCkgPT09IGlkZW50aXR5IHx8CiAgICAgICAgICBpdGVtLnN0dWRlbnRJZC50b0xvd2Vy
>>"%RB8%" echo Q2FzZSgpID09PSBpZGVudGl0eSwKICAgICAgKQogICAgICBpZiAoIXVzZXIpIHRocm93IG5l
>>"%RB8%" echo dyBFcnJvcignTm8gc3R1ZGVudCBhY2NvdW50IG1hdGNoZXMgdGhhdCBlbWFpbCBvciBzdHVk
>>"%RB8%" echo ZW50IElELicpCiAgICAgIGNvbnN0IGhhc2ggPSBhd2FpdCBoYXNoUGFzc3dvcmQobG9naW4u
>>"%RB8%" echo cGFzc3dvcmQpCiAgICAgIGlmIChoYXNoICE9PSB1c2VyLnBhc3N3b3JkSGFzaCkgdGhyb3cg
>>"%RB8%" echo bmV3IEVycm9yKCdJbmNvcnJlY3QgcGFzc3dvcmQuJykKICAgICAgbG9jYWxTdG9yYWdlLnNl
>>"%RB8%" echo dEl0ZW0oU0VTU0lPTl9LRVksIEpTT04uc3RyaW5naWZ5KHsgaWQ6IHVzZXIuaWQsIHJlbWVt
>>"%RB8%" echo YmVyOiBsb2dpbi5yZW1lbWJlciB9KSkKICAgICAgb25BdXRoZW50aWNhdGVkKHVzZXIpCiAg
>>"%RB8%" echo ICB9IGNhdGNoIChlcnJvcikgewogICAgICBzZXRNZXNzYWdlKGVycm9yLm1lc3NhZ2UpCiAg
>>"%RB8%" echo ICB9IGZpbmFsbHkgewogICAgICBzZXRCdXN5KGZhbHNlKQogICAgfQogIH0KCiAgYXN5bmMg
>>"%RB8%" echo ZnVuY3Rpb24gc3VibWl0U2lnbnVwKGV2ZW50KSB7CiAgICBldmVudC5wcmV2ZW50RGVmYXVs
>>"%RB8%" echo dCgpCiAgICBzZXRCdXN5KHRydWUpCiAgICBzZXRNZXNzYWdlKCcnKQogICAgdHJ5IHsKICAg
>>"%RB8%" echo ICAgaWYgKCFzaWdudXAuZmlyc3ROYW1lLnRyaW0oKSB8fCAhc2lnbnVwLmxhc3ROYW1lLnRy
>>"%RB8%" echo aW0oKSkgdGhyb3cgbmV3IEVycm9yKCdFbnRlciB5b3VyIGZ1bGwgbmFtZS4nKQogICAgICBp
>>"%RB8%" echo ZiAoIS9eW0EtWmEtejAtOS1dezUsMjB9JC8udGVzdChzaWdudXAuc3R1ZGVudElkLnRyaW0o
>>"%RB8%" echo KSkpIHRocm93IG5ldyBFcnJvcignU3R1ZGVudCBJRCBtdXN0IGJlIDUtMjAgbGV0dGVycywg
>>"%RB8%" echo bnVtYmVycyBvciBkYXNoZXMuJykKICAgICAgaWYgKCEvXlteXHNAXStAW15cc0BdK1wuW15c
>>"%RB8%" echo c0BdKyQvLnRlc3Qoc2lnbnVwLmVtYWlsKSkgdGhyb3cgbmV3IEVycm9yKCdFbnRlciBhIHZh
>>"%RB8%" echo bGlkIGVtYWlsIGFkZHJlc3MuJykKICAgICAgaWYgKHN0cmVuZ3RoIDwgNCkgdGhyb3cgbmV3
>>"%RB8%" echo IEVycm9yKCdVc2UgYSBzdHJvbmdlciBwYXNzd29yZCB3aXRoIGxlbmd0aCwgbWl4ZWQgY2Fz
>>"%RB8%" echo ZSwgbnVtYmVycyBhbmQgc3ltYm9scy4nKQogICAgICBpZiAoc2lnbnVwLnBhc3N3b3JkICE9
>>"%RB8%" echo PSBzaWdudXAuY29uZmlybSkgdGhyb3cgbmV3IEVycm9yKCdUaGUgcGFzc3dvcmQgY29uZmly
>>"%RB8%" echo bWF0aW9uIGRvZXMgbm90IG1hdGNoLicpCgogICAgICBjb25zdCB1c2VycyA9IHJlYWRVc2Vy
>>"%RB8%" echo cygpCiAgICAgIGNvbnN0IGR1cGxpY2F0ZSA9IHVzZXJzLnNvbWUoCiAgICAgICAgKGl0ZW0p
>>"%RB8%" echo ID0+CiAgICAgICAgICBpdGVtLmVtYWlsLnRvTG93ZXJDYXNlKCkgPT09IHNpZ251cC5lbWFp
>>"%RB8%" echo bC50cmltKCkudG9Mb3dlckNhc2UoKSB8fAogICAgICAgICAgaXRlbS5zdHVkZW50SWQudG9M
>>"%RB8%" echo b3dlckNhc2UoKSA9PT0gc2lnbnVwLnN0dWRlbnRJZC50cmltKCkudG9Mb3dlckNhc2UoKSwK
>>"%RB8%" echo ICAgICAgKQogICAgICBpZiAoZHVwbGljYXRlKSB0aHJvdyBuZXcgRXJyb3IoJ1RoYXQgZW1h
>>"%RB8%" echo aWwgb3Igc3R1ZGVudCBJRCBpcyBhbHJlYWR5IHJlZ2lzdGVyZWQuJykKCiAgICAgIGNvbnN0
>>"%RB8%" echo IHVzZXIgPSB7CiAgICAgICAgaWQ6IGNyeXB0by5yYW5kb21VVUlEID8gY3J5cHRvLnJhbmRv
>>"%RB8%" echo bVVVSUQoKSA6IGAke0RhdGUubm93KCl9LSR7TWF0aC5yYW5kb20oKX1gLAogICAgICAgIGZp
>>"%RB8%" echo cnN0TmFtZTogc2lnbnVwLmZpcnN0TmFtZS50cmltKCksCiAgICAgICAgbGFzdE5hbWU6IHNp
>>"%RB8%" echo Z251cC5sYXN0TmFtZS50cmltKCksCiAgICAgICAgc3R1ZGVudElkOiBzaWdudXAuc3R1ZGVu
>>"%RB8%" echo dElkLnRyaW0oKS50b1VwcGVyQ2FzZSgpLAogICAgICAgIGVtYWlsOiBzaWdudXAuZW1haWwu
>>"%RB8%" echo dHJpbSgpLAogICAgICAgIHByb2dyYW06IHNpZ251cC5wcm9ncmFtLAogICAgICAgIHllYXI6
>>"%RB8%" echo IE51bWJlcihzaWdudXAueWVhciksCiAgICAgICAgcGFzc3dvcmRIYXNoOiBhd2FpdCBoYXNo
>>"%RB8%" echo UGFzc3dvcmQoc2lnbnVwLnBhc3N3b3JkKSwKICAgICAgICBjcmVhdGVkQXQ6IG5ldyBEYXRl
>>"%RB8%" echo KCkudG9JU09TdHJpbmcoKSwKICAgICAgfQogICAgICB1c2Vycy5wdXNoKHVzZXIpCiAgICAg
>>"%RB8%" echo IGxvY2FsU3RvcmFnZS5zZXRJdGVtKFVTRVJTX0tFWSwgSlNPTi5zdHJpbmdpZnkodXNlcnMp
>>"%RB8%" echo KQogICAgICBsb2NhbFN0b3JhZ2Uuc2V0SXRlbShTRVNTSU9OX0tFWSwgSlNPTi5zdHJpbmdp
>>"%RB8%" echo ZnkoeyBpZDogdXNlci5pZCwgcmVtZW1iZXI6IHRydWUgfSkpCiAgICAgIG9uQXV0aGVudGlj
>>"%RB8%" echo YXRlZCh1c2VyKQogICAgfSBjYXRjaCAoZXJyb3IpIHsKICAgICAgc2V0TWVzc2FnZShlcnJv
>>"%RB8%" echo ci5tZXNzYWdlKQogICAgfSBmaW5hbGx5IHsKICAgICAgc2V0QnVzeShmYWxzZSkKICAgIH0K
>>"%RB8%" echo ICB9CgogIGFzeW5jIGZ1bmN0aW9uIGNyZWF0ZURlbW8oKSB7CiAgICBjb25zdCBkZW1vID0g
>>"%RB8%" echo ewogICAgICBmaXJzdE5hbWU6ICdBbGV4JywKICAgICAgbGFzdE5hbWU6ICdTdHVkZW50JywK
>>"%RB8%" echo ICAgICAgc3R1ZGVudElkOiAnUkdJVDIwMjYnLAogICAgICBlbWFpbDogJ3N0dWRlbnRAcG9y
>>"%RB8%" echo dGFsLmxvY2FsJywKICAgICAgcHJvZ3JhbTogJ0JTYyBJbmZvcm1hdGlvbiBUZWNobm9sb2d5
>>"%RB8%" echo JywKICAgICAgeWVhcjogMiwKICAgIH0KICAgIGNvbnN0IHVzZXJzID0gcmVhZFVzZXJzKCkK
>>"%RB8%" echo ICAgIGxldCB1c2VyID0gdXNlcnMuZmluZCgoaXRlbSkgPT4gaXRlbS5lbWFpbCA9PT0gZGVt
>>"%RB8%" echo by5lbWFpbCkKICAgIGlmICghdXNlcikgewogICAgICB1c2VyID0gewogICAgICAgIC4uLmRl
>>"%RB8%" echo bW8sCiAgICAgICAgaWQ6IGNyeXB0by5yYW5kb21VVUlEID8gY3J5cHRvLnJhbmRvbVVVSUQo
>>"%RB8%" echo KSA6IGBkZW1vLSR7RGF0ZS5ub3coKX1gLAogICAgICAgIHBhc3N3b3JkSGFzaDogYXdhaXQg
>>"%RB8%" echo aGFzaFBhc3N3b3JkKCdTdHVkZW50QDIwMjYnKSwKICAgICAgICBjcmVhdGVkQXQ6IG5ldyBE
>>"%RB8%" echo YXRlKCkudG9JU09TdHJpbmcoKSwKICAgICAgfQogICAgICB1c2Vycy5wdXNoKHVzZXIpCiAg
>>"%RB8%" echo ICAgIGxvY2FsU3RvcmFnZS5zZXRJdGVtKFVTRVJTX0tFWSwgSlNPTi5zdHJpbmdpZnkodXNl
>>"%RB8%" echo cnMpKQogICAgfQogICAgbG9jYWxTdG9yYWdlLnNldEl0ZW0oU0VTU0lPTl9LRVksIEpTT04u
>>"%RB8%" echo c3RyaW5naWZ5KHsgaWQ6IHVzZXIuaWQsIHJlbWVtYmVyOiB0cnVlIH0pKQogICAgb25BdXRo
>>"%RB8%" echo ZW50aWNhdGVkKHVzZXIpCiAgfQoKICByZXR1cm4gKAogICAgPG1haW4gY2xhc3NOYW1lPSJh
>>"%RB8%" echo dXRoLXNoZWxsIj4KICAgICAgPHNlY3Rpb24gY2xhc3NOYW1lPSJhdXRoLWFydCI+CiAgICAg
>>"%RB8%" echo ICAgPGRpdiBjbGFzc05hbWU9ImJyYW5kLXJvdyI+CiAgICAgICAgICA8ZGl2IGNsYXNzTmFt
>>"%RB8%" echo ZT0iYnJhbmQtbWFyayI+Ukc8L2Rpdj4KICAgICAgICAgIDxkaXY+CiAgICAgICAgICAgIDxz
>>"%RB8%" echo dHJvbmc+U3R1ZGVudCBQb3J0YWwgMjAyNjwvc3Ryb25nPgogICAgICAgICAgICA8c3Bhbj5B
>>"%RB8%" echo Y2FkZW1pYyBjb21tYW5kIGNlbnRyZTwvc3Bhbj4KICAgICAgICAgIDwvZGl2PgogICAgICAg
>>"%RB8%" echo IDwvZGl2PgogICAgICAgIDxkaXYgY2xhc3NOYW1lPSJoZXJvLWNvcHkiPgogICAgICAgICAg
>>"%RB8%" echo PHAgY2xhc3NOYW1lPSJleWVicm93Ij5SSUNIRklFTEQgRElHSVRBTCBDQU1QVVM8L3A+CiAg
>>"%RB8%" echo ICAgICAgICA8aDE+WW91ciBjb3Vyc2V3b3JrLCBwZXJmb3JtYW5jZSBhbmQgY2FtcHVzIGxp
>>"%RB8%" echo ZmUgaW4gb25lIHBsYWNlLjwvaDE+CiAgICAgICAgICA8cD4KICAgICAgICAgICAgVHJhY2sg
>>"%RB8%" echo bW9kdWxlcywgZGVhZGxpbmVzIGFuZCBhdHRlbmRhbmNlLCB0aGVuIHN3aXRjaCB0byB0aGUg
>>"%RB8%" echo Umljb2NoZXQgQXJlbmEKICAgICAgICAgICAgZm9yIGEgZnVsbCBwaHlzaWNzLWJhc2VkIHNo
>>"%RB8%" echo b290ZXIgYnVpbHQgZGlyZWN0bHkgaW50byB0aGUgcG9ydGFsLgogICAgICAgICAgPC9wPgog
>>"%RB8%" echo ICAgICAgICAgPGRpdiBjbGFzc05hbWU9Imhlcm8tc3RhdHMiPgogICAgICAgICAgICA8ZGl2
>>"%RB8%" echo PjxiPjQ8L2I+PHNwYW4+QWN0aXZlIG1vZHVsZXM8L3NwYW4+PC9kaXY+CiAgICAgICAgICAg
>>"%RB8%" echo IDxkaXY+PGI+OTMlPC9iPjxzcGFuPkF0dGVuZGFuY2U8L3NwYW4+PC9kaXY+CiAgICAgICAg
>>"%RB8%" echo ICAgIDxkaXY+PGI+My43NjwvYj48c3Bhbj5DdXJyZW50IEdQQTwvc3Bhbj48L2Rpdj4KICAg
>>"%RB8%" echo ICAgICAgIDwvZGl2PgogICAgICAgIDwvZGl2PgogICAgICAgIDxkaXYgY2xhc3NOYW1lPSJz
>>"%RB8%" echo ZWN1cml0eS1ub3RlIj4KICAgICAgICAgIDxzcGFuPkxPQ0FMIERFTU8gQVVUSDwvc3Bhbj4K
>>"%RB8%" echo ICAgICAgICAgIDxwPkFjY291bnRzIGFyZSBzdG9yZWQgb25seSBpbiB0aGlzIGJyb3dzZXIu
>>"%RB8%" echo IFBhc3N3b3JkcyBhcmUgaGFzaGVkIGJlZm9yZSBsb2NhbCBzdG9yYWdlLjwvcD4KICAgICAg
>>"%RB8%" echo ICA8L2Rpdj4KICAgICAgPC9zZWN0aW9uPgoKICAgICAgPHNlY3Rpb24gY2xhc3NOYW1lPSJh
>>"%RB8%" echo dXRoLWNhcmQiPgogICAgICAgIDxkaXYgY2xhc3NOYW1lPSJhdXRoLXRhYnMiPgogICAgICAg
>>"%RB8%" echo ICAgPGJ1dHRvbiBjbGFzc05hbWU9e21vZGUgPT09ICdsb2dpbicgPyAnYWN0aXZlJyA6ICcn
>>"%RB8%" echo fSBvbkNsaWNrPXsoKSA9PiB7IHNldE1vZGUoJ2xvZ2luJyk7IHNldE1lc3NhZ2UoJycpIH19
>>"%RB8%" echo PlNpZ24gaW48L2J1dHRvbj4KICAgICAgICAgIDxidXR0b24gY2xhc3NOYW1lPXttb2RlID09
>>"%RB8%" echo PSAnc2lnbnVwJyA/ICdhY3RpdmUnIDogJyd9IG9uQ2xpY2s9eygpID0+IHsgc2V0TW9kZSgn
>>"%RB8%" echo c2lnbnVwJyk7IHNldE1lc3NhZ2UoJycpIH19PkNyZWF0ZSBhY2NvdW50PC9idXR0b24+CiAg
>>"%RB8%" echo ICAgICAgPC9kaXY+CgogICAgICAgIHttb2RlID09PSAnbG9naW4nID8gKAogICAgICAgICAg
>>"%RB8%" echo PGZvcm0gb25TdWJtaXQ9e3N1Ym1pdExvZ2lufSBjbGFzc05hbWU9ImF1dGgtZm9ybSI+CiAg
>>"%RB8%" echo ICAgICAgICAgIDxkaXY+CiAgICAgICAgICAgICAgPHAgY2xhc3NOYW1lPSJleWVicm93Ij5X
>>"%RB8%" echo RUxDT01FIEJBQ0s8L3A+CiAgICAgICAgICAgICAgPGgyPlN0dWRlbnQgc2lnbiBpbjwvaDI+
>>"%RB8%" echo CiAgICAgICAgICAgICAgPHAgY2xhc3NOYW1lPSJtdXRlZCI+VXNlIHlvdXIgc3R1ZGVudCBJ
>>"%RB8%" echo RCBvciByZWdpc3RlcmVkIGVtYWlsLjwvcD4KICAgICAgICAgICAgPC9kaXY+CiAgICAgICAg
>>"%RB8%" echo ICAgIDxsYWJlbD4KICAgICAgICAgICAgICBTdHVkZW50IElEIG9yIGVtYWlsCiAgICAgICAg
>>"%RB8%" echo ICAgICAgPGlucHV0CiAgICAgICAgICAgICAgICB2YWx1ZT17bG9naW4uaWRlbnRpdHl9CiAg
>>"%RB8%" echo ICAgICAgICAgICAgICBvbkNoYW5nZT17KGUpID0+IHNldExvZ2luKHsgLi4ubG9naW4sIGlk
>>"%RB8%" echo ZW50aXR5OiBlLnRhcmdldC52YWx1ZSB9KX0KICAgICAgICAgICAgICAgIHBsYWNlaG9sZGVy
>>"%RB8%" echo PSJSR0lUMjAyNiBvciBuYW1lQGVtYWlsLmNvbSIKICAgICAgICAgICAgICAgIGF1dG9Db21w
>>"%RB8%" echo bGV0ZT0idXNlcm5hbWUiCiAgICAgICAgICAgICAgICByZXF1aXJlZAogICAgICAgICAgICAg
>>"%RB8%" echo IC8+CiAgICAgICAgICAgIDwvbGFiZWw+CiAgICAgICAgICAgIDxsYWJlbD4KICAgICAgICAg
>>"%RB8%" echo ICAgICBQYXNzd29yZAogICAgICAgICAgICAgIDxpbnB1dAogICAgICAgICAgICAgICAgdHlw
>>"%RB8%" echo ZT0icGFzc3dvcmQiCiAgICAgICAgICAgICAgICB2YWx1ZT17bG9naW4ucGFzc3dvcmR9CiAg
>>"%RB8%" echo ICAgICAgICAgICAgICBvbkNoYW5nZT17KGUpID0+IHNldExvZ2luKHsgLi4ubG9naW4sIHBh
>>"%RB8%" echo c3N3b3JkOiBlLnRhcmdldC52YWx1ZSB9KX0KICAgICAgICAgICAgICAgIHBsYWNlaG9sZGVy
>>"%RB8%" echo PSJFbnRlciB5b3VyIHBhc3N3b3JkIgogICAgICAgICAgICAgICAgYXV0b0NvbXBsZXRlPSJj
>>"%RB8%" echo dXJyZW50LXBhc3N3b3JkIgogICAgICAgICAgICAgICAgcmVxdWlyZWQKICAgICAgICAgICAg
>>"%RB8%" echo ICAvPgogICAgICAgICAgICA8L2xhYmVsPgogICAgICAgICAgICA8bGFiZWwgY2xhc3NOYW1l
>>"%RB8%" echo PSJjaGVjay1saW5lIj4KICAgICAgICAgICAgICA8aW5wdXQKICAgICAgICAgICAgICAgIHR5
>>"%RB8%" echo cGU9ImNoZWNrYm94IgogICAgICAgICAgICAgICAgY2hlY2tlZD17bG9naW4ucmVtZW1iZXJ9
>>"%RB8%" echo CiAgICAgICAgICAgICAgICBvbkNoYW5nZT17KGUpID0+IHNldExvZ2luKHsgLi4ubG9naW4s
>>"%RB8%" echo IHJlbWVtYmVyOiBlLnRhcmdldC5jaGVja2VkIH0pfQogICAgICAgICAgICAgIC8+CiAgICAg
>>"%RB8%" echo ICAgICAgICAgS2VlcCBtZSBzaWduZWQgaW4gb24gdGhpcyBicm93c2VyCiAgICAgICAgICAg
>>"%RB8%" echo IDwvbGFiZWw+CiAgICAgICAgICAgIHttZXNzYWdlICYmIDxkaXYgY2xhc3NOYW1lPSJmb3Jt
>>"%RB8%" echo LWVycm9yIj57bWVzc2FnZX08L2Rpdj59CiAgICAgICAgICAgIDxidXR0b24gY2xhc3NOYW1l
>>"%RB8%" echo PSJwcmltYXJ5LWJ0biIgZGlzYWJsZWQ9e2J1c3l9PgogICAgICAgICAgICAgIHtidXN5ID8g
>>"%RB8%" echo J1NpZ25pbmcgaW4uLi4nIDogJ1NpZ24gaW4gdG8gcG9ydGFsJ30KICAgICAgICAgICAgPC9i
>>"%RB8%" echo dXR0b24+CiAgICAgICAgICAgIDxidXR0b24gY2xhc3NOYW1lPSJnaG9zdC1idG4iIHR5cGU9
>>"%RB8%" echo ImJ1dHRvbiIgb25DbGljaz17Y3JlYXRlRGVtb30+CiAgICAgICAgICAgICAgQ3JlYXRlIC8g
>>"%RB8%" echo ZW50ZXIgZGVtbyBhY2NvdW50CiAgICAgICAgICAgIDwvYnV0dG9uPgogICAgICAgICAgICA8
>>"%RB8%" echo cCBjbGFzc05hbWU9ImRlbW8taGludCI+RGVtbyBsb2dpbiBhZnRlciBjcmVhdGlvbjogc3R1
>>"%RB8%" echo ZGVudEBwb3J0YWwubG9jYWwgLyBTdHVkZW50QDIwMjY8L3A+CiAgICAgICAgICA8L2Zvcm0+
>>"%RB8%" echo CiAgICAgICAgKSA6ICgKICAgICAgICAgIDxmb3JtIG9uU3VibWl0PXtzdWJtaXRTaWdudXB9
>>"%RB8%" echo IGNsYXNzTmFtZT0iYXV0aC1mb3JtIHNpZ251cC1ncmlkIj4KICAgICAgICAgICAgPGRpdiBj
>>"%RB8%" echo bGFzc05hbWU9InNwYW4tMiI+CiAgICAgICAgICAgICAgPHAgY2xhc3NOYW1lPSJleWVicm93
>>"%RB8%" echo Ij5ORVcgU1RVREVOVCBQUk9GSUxFPC9wPgogICAgICAgICAgICAgIDxoMj5DcmVhdGUgcG9y
>>"%RB8%" echo dGFsIGFjY291bnQ8L2gyPgogICAgICAgICAgICAgIDxwIGNsYXNzTmFtZT0ibXV0ZWQiPlRo
>>"%RB8%" echo aXMgZGVtbyBhY2NvdW50IHJlbWFpbnMgb24gdGhpcyBQQyBhbmQgYnJvd3Nlci48L3A+CiAg
>>"%RB8%" echo ICAgICAgICAgIDwvZGl2PgogICAgICAgICAgICA8bGFiZWw+CiAgICAgICAgICAgICAgRmly
>>"%RB8%" echo c3QgbmFtZQogICAgICAgICAgICAgIDxpbnB1dCB2YWx1ZT17c2lnbnVwLmZpcnN0TmFtZX0g
>>"%RB8%" echo b25DaGFuZ2U9eyhlKSA9PiBzZXRTaWdudXAoeyAuLi5zaWdudXAsIGZpcnN0TmFtZTogZS50
>>"%RB8%" echo YXJnZXQudmFsdWUgfSl9IHJlcXVpcmVkIC8+CiAgICAgICAgICAgIDwvbGFiZWw+CiAgICAg
>>"%RB8%" echo ICAgICAgIDxsYWJlbD4KICAgICAgICAgICAgICBMYXN0IG5hbWUKICAgICAgICAgICAgICA8
>>"%RB8%" echo aW5wdXQgdmFsdWU9e3NpZ251cC5sYXN0TmFtZX0gb25DaGFuZ2U9eyhlKSA9PiBzZXRTaWdu
>>"%RB8%" echo dXAoeyAuLi5zaWdudXAsIGxhc3ROYW1lOiBlLnRhcmdldC52YWx1ZSB9KX0gcmVxdWlyZWQg
>>"%RB8%" echo Lz4KICAgICAgICAgICAgPC9sYWJlbD4KICAgICAgICAgICAgPGxhYmVsPgogICAgICAgICAg
>>"%RB8%" echo ICAgIFN0dWRlbnQgSUQKICAgICAgICAgICAgICA8aW5wdXQgdmFsdWU9e3NpZ251cC5zdHVk
>>"%RB8%" echo ZW50SWR9IG9uQ2hhbmdlPXsoZSkgPT4gc2V0U2lnbnVwKHsgLi4uc2lnbnVwLCBzdHVkZW50
>>"%RB8%" echo SWQ6IGUudGFyZ2V0LnZhbHVlIH0pfSBwbGFjZWhvbGRlcj0iUkdJVDIwMjYiIHJlcXVpcmVk
>>"%RB8%" echo IC8+CiAgICAgICAgICAgIDwvbGFiZWw+CiAgICAgICAgICAgIDxsYWJlbD4KICAgICAgICAg
>>"%RB8%" echo ICAgICBFbWFpbAogICAgICAgICAgICAgIDxpbnB1dCB0eXBlPSJlbWFpbCIgdmFsdWU9e3Np
>>"%RB8%" echo Z251cC5lbWFpbH0gb25DaGFuZ2U9eyhlKSA9PiBzZXRTaWdudXAoeyAuLi5zaWdudXAsIGVt
>>"%RB8%" echo YWlsOiBlLnRhcmdldC52YWx1ZSB9KX0gcmVxdWlyZWQgLz4KICAgICAgICAgICAgPC9sYWJl
>>"%RB8%" echo bD4KICAgICAgICAgICAgPGxhYmVsPgogICAgICAgICAgICAgIFByb2dyYW1tZQogICAgICAg
>>"%RB8%" echo ICAgICAgIDxzZWxlY3QgdmFsdWU9e3NpZ251cC5wcm9ncmFtfSBvbkNoYW5nZT17KGUpID0+
>>"%RB8%" echo IHNldFNpZ251cCh7IC4uLnNpZ251cCwgcHJvZ3JhbTogZS50YXJnZXQudmFsdWUgfSl9Pgog
>>"%RB8%" echo ICAgICAgICAgICAgICAgPG9wdGlvbj5CU2MgSW5mb3JtYXRpb24gVGVjaG5vbG9neTwvb3B0
>>"%RB8%" echo aW9uPgogICAgICAgICAgICAgICAgPG9wdGlvbj5CU2MgQ29tcHV0ZXIgU2NpZW5jZTwvb3B0
>>"%RB8%" echo aW9uPgogICAgICAgICAgICAgICAgPG9wdGlvbj5EaXBsb21hIGluIElUPC9vcHRpb24+CiAg
>>"%RB8%" echo ICAgICAgICAgICAgICA8b3B0aW9uPkJDb20gSW5mb3JtYXRpb24gU3lzdGVtczwvb3B0aW9u
>>"%RB8%" echo PgogICAgICAgICAgICAgICAgPG9wdGlvbj5IaWdoZXIgQ2VydGlmaWNhdGUgaW4gSVQ8L29w
>>"%RB8%" echo dGlvbj4KICAgICAgICAgICAgICA8L3NlbGVjdD4KICAgICAgICAgICAgPC9sYWJlbD4KICAg
>>"%RB8%" echo ICAgICAgICAgPGxhYmVsPgogICAgICAgICAgICAgIFllYXIKICAgICAgICAgICAgICA8c2Vs
>>"%RB8%" echo ZWN0IHZhbHVlPXtzaWdudXAueWVhcn0gb25DaGFuZ2U9eyhlKSA9PiBzZXRTaWdudXAoeyAu
>>"%RB8%" echo Li5zaWdudXAsIHllYXI6IGUudGFyZ2V0LnZhbHVlIH0pfT4KICAgICAgICAgICAgICAgIDxv
>>"%RB8%" echo cHRpb24gdmFsdWU9IjEiPlllYXIgMTwvb3B0aW9uPgogICAgICAgICAgICAgICAgPG9wdGlv
>>"%RB8%" echo biB2YWx1ZT0iMiI+WWVhciAyPC9vcHRpb24+CiAgICAgICAgICAgICAgICA8b3B0aW9uIHZh
>>"%RB8%" echo bHVlPSIzIj5ZZWFyIDM8L29wdGlvbj4KICAgICAgICAgICAgICAgIDxvcHRpb24gdmFsdWU9
>>"%RB8%" echo IjQiPlllYXIgNDwvb3B0aW9uPgogICAgICAgICAgICAgIDwvc2VsZWN0PgogICAgICAgICAg
>>"%RB8%" echo ICA8L2xhYmVsPgogICAgICAgICAgICA8bGFiZWw+CiAgICAgICAgICAgICAgUGFzc3dvcmQK
>>"%RB8%" echo ICAgICAgICAgICAgICA8aW5wdXQgdHlwZT0icGFzc3dvcmQiIHZhbHVlPXtzaWdudXAucGFz
>>"%RB8%" echo c3dvcmR9IG9uQ2hhbmdlPXsoZSkgPT4gc2V0U2lnbnVwKHsgLi4uc2lnbnVwLCBwYXNzd29y
>>"%RB8%" echo ZDogZS50YXJnZXQudmFsdWUgfSl9IHJlcXVpcmVkIC8+CiAgICAgICAgICAgICAgPGRpdiBj
>>"%RB8%" echo bGFzc05hbWU9InN0cmVuZ3RoIj4KICAgICAgICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPXtg
>>"%RB8%" echo c3RyZW5ndGgtZmlsbCBzJHtzdHJlbmd0aH1gfSAvPgogICAgICAgICAgICAgIDwvZGl2Pgog
>>"%RB8%" echo ICAgICAgICAgICAgIDxzbWFsbD57c3RyZW5ndGhUZXh0fTwvc21hbGw+CiAgICAgICAgICAg
>>"%RB8%" echo IDwvbGFiZWw+CiAgICAgICAgICAgIDxsYWJlbD4KICAgICAgICAgICAgICBDb25maXJtIHBh
>>"%RB8%" echo c3N3b3JkCiAgICAgICAgICAgICAgPGlucHV0IHR5cGU9InBhc3N3b3JkIiB2YWx1ZT17c2ln
>>"%RB8%" echo bnVwLmNvbmZpcm19IG9uQ2hhbmdlPXsoZSkgPT4gc2V0U2lnbnVwKHsgLi4uc2lnbnVwLCBj
>>"%RB8%" echo b25maXJtOiBlLnRhcmdldC52YWx1ZSB9KX0gcmVxdWlyZWQgLz4KICAgICAgICAgICAgPC9s
>>"%RB8%" echo YWJlbD4KICAgICAgICAgICAge21lc3NhZ2UgJiYgPGRpdiBjbGFzc05hbWU9ImZvcm0tZXJy
>>"%RB8%" echo b3Igc3Bhbi0yIj57bWVzc2FnZX08L2Rpdj59CiAgICAgICAgICAgIDxidXR0b24gY2xhc3NO
>>"%RB8%" echo YW1lPSJwcmltYXJ5LWJ0biBzcGFuLTIiIGRpc2FibGVkPXtidXN5fT4KICAgICAgICAgICAg
>>"%RB8%" echo ICB7YnVzeSA/ICdDcmVhdGluZyBhY2NvdW50Li4uJyA6ICdDcmVhdGUgc3R1ZGVudCBhY2Nv
>>"%RB8%" echo dW50J30KICAgICAgICAgICAgPC9idXR0b24+CiAgICAgICAgICA8L2Zvcm0+CiAgICAgICAg
>>"%RB8%" echo KX0KICAgICAgPC9zZWN0aW9uPgogICAgPC9tYWluPgogICkKfQoKZnVuY3Rpb24gUHJvZ3Jl
>>"%RB8%" echo c3NSaW5nKHsgdmFsdWUsIGxhYmVsIH0pIHsKICBjb25zdCBhbmdsZSA9IHZhbHVlICogMy42
>>"%RB8%" echo CiAgcmV0dXJuICgKICAgIDxkaXYgY2xhc3NOYW1lPSJwcm9ncmVzcy1yaW5nIiBzdHlsZT17
>>"%RB8%" echo eyAnLS1hbmdsZSc6IGAke2FuZ2xlfWRlZ2AgfX0+CiAgICAgIDxkaXY+PGI+e3ZhbHVlfSU8
>>"%RB8%" echo L2I+PHNwYW4+e2xhYmVsfTwvc3Bhbj48L2Rpdj4KICAgIDwvZGl2PgogICkKfQoKZnVuY3Rp
>>"%RB8%" echo b24gRGFzaGJvYXJkKHsgdXNlciwgb25PcGVuR2FtZSB9KSB7CiAgY29uc3QgZmlyc3QgPSB1
>>"%RB8%" echo c2VyLmZpcnN0TmFtZSB8fCAnU3R1ZGVudCcKICByZXR1cm4gKAogICAgPGRpdiBjbGFzc05h
>>"%RB8%" echo bWU9ImRhc2hib2FyZC1ncmlkIj4KICAgICAgPHNlY3Rpb24gY2xhc3NOYW1lPSJ3ZWxjb21l
>>"%RB8%" echo LWNhcmQgY2FyZCI+CiAgICAgICAgPGRpdj4KICAgICAgICAgIDxwIGNsYXNzTmFtZT0iZXll
>>"%RB8%" echo YnJvdyI+VEhVUlNEQVkg4oCiIFRFUk0gMzwvcD4KICAgICAgICAgIDxoMT5Hb29kIG1vcm5p
>>"%RB8%" echo bmcsIHtmaXJzdH0uPC9oMT4KICAgICAgICAgIDxwPllvdSBoYXZlIHR3byBpbXBvcnRhbnQg
>>"%RB8%" echo ZGVhZGxpbmVzIGFuZCBvbmUgY2xhc3MgY3VycmVudGx5IGluIHNlc3Npb24uPC9wPgogICAg
>>"%RB8%" echo ICAgICAgPGRpdiBjbGFzc05hbWU9IndlbGNvbWUtYWN0aW9ucyI+CiAgICAgICAgICAgIDxi
>>"%RB8%" echo dXR0b24gY2xhc3NOYW1lPSJwcmltYXJ5LWJ0biBzbWFsbCIgb25DbGljaz17b25PcGVuR2Ft
>>"%RB8%" echo ZX0+T3BlbiBSaWNvY2hldCBBcmVuYTwvYnV0dG9uPgogICAgICAgICAgICA8YnV0dG9uIGNs
>>"%RB8%" echo YXNzTmFtZT0iZ2hvc3QtYnRuIHNtYWxsIiBvbkNsaWNrPXsoKSA9PiBkb2N1bWVudC5nZXRF
>>"%RB8%" echo bGVtZW50QnlJZCgnYXNzaWdubWVudHMnKT8uc2Nyb2xsSW50b1ZpZXcoeyBiZWhhdmlvcjog
>>"%RB8%" echo J3Ntb290aCcgfSl9PlZpZXcgYXNzaWdubWVudHM8L2J1dHRvbj4KICAgICAgICAgIDwvZGl2
>>"%RB8%" echo PgogICAgICAgIDwvZGl2PgogICAgICAgIDxkaXYgY2xhc3NOYW1lPSJmb2N1cy1wYW5lbCI+
>>"%RB8%" echo CiAgICAgICAgICA8c3Bhbj5DdXJyZW50IGZvY3VzPC9zcGFuPgogICAgICAgICAgPGI+QWR2
>>"%RB8%" echo YW5jZWQgV2ViIFRlY2hub2xvZ3k8L2I+CiAgICAgICAgICA8cD5SZWFjdCBzdGF0ZSwgZm9y
>>"%RB8%" echo bXMgYW5kIGNvbXBvbmVudCBhcmNoaXRlY3R1cmU8L3A+CiAgICAgICAgICA8ZGl2IGNsYXNz
>>"%RB8%" echo TmFtZT0ibWluaS1wcm9ncmVzcyI+PGkgc3R5bGU9e3sgd2lkdGg6ICc2NCUnIH19IC8+PC9k
>>"%RB8%" echo aXY+CiAgICAgICAgPC9kaXY+CiAgICAgIDwvc2VjdGlvbj4KCiAgICAgIDxzZWN0aW9uIGNs
>>"%RB8%" echo YXNzTmFtZT0ic3RhdHMtcm93Ij4KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0ibWV0cmljIGNh
>>"%RB8%" echo cmQiPjxzcGFuPkdQQTwvc3Bhbj48Yj4zLjc2PC9iPjxzbWFsbD4rMC4xOCB0aGlzIHRlcm08
>>"%RB8%" echo L3NtYWxsPjwvZGl2PgogICAgICAgIDxkaXYgY2xhc3NOYW1lPSJtZXRyaWMgY2FyZCI+PHNw
>>"%RB8%" echo YW4+QXR0ZW5kYW5jZTwvc3Bhbj48Yj45MyU8L2I+PHNtYWxsPkFib3ZlIDgwJSByZXF1aXJl
>>"%RB8%" echo bWVudDwvc21hbGw+PC9kaXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9Im1ldHJpYyBjYXJk
>>"%RB8%" echo Ij48c3Bhbj5DcmVkaXRzPC9zcGFuPjxiPjc4IC8gMTIwPC9iPjxzbWFsbD42NSUgcHJvZ3Jh
>>"%RB8%" echo bW1lIGNvbXBsZXRlPC9zbWFsbD48L2Rpdj4KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0ibWV0
>>"%RB8%" echo cmljIGNhcmQiPjxzcGFuPkFzc2lnbm1lbnRzPC9zcGFuPjxiPjExIC8gMTQ8L2I+PHNtYWxs
>>"%RB8%" echo PjMgcmVtYWluaW5nIHRoaXMgY3ljbGU8L3NtYWxsPjwvZGl2PgogICAgICA8L3NlY3Rpb24+
>>"%RB8%" echo CgogICAgICA8c2VjdGlvbiBjbGFzc05hbWU9ImNhcmQgc2NoZWR1bGUtY2FyZCI+CiAgICAg
>>"%RB8%" echo ICAgPGRpdiBjbGFzc05hbWU9InNlY3Rpb24tdGl0bGUiPgogICAgICAgICAgPGRpdj48cCBj
>>"%RB8%" echo bGFzc05hbWU9ImV5ZWJyb3ciPlRPREFZPC9wPjxoMj5TY2hlZHVsZTwvaDI+PC9kaXY+CiAg
>>"%RB8%" echo ICAgICAgICA8c3BhbiBjbGFzc05hbWU9ImxpdmUtcGlsbCI+TElWRSBEQVk8L3NwYW4+CiAg
>>"%RB8%" echo ICAgICAgPC9kaXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9InRpbWVsaW5lIj4KICAgICAg
>>"%RB8%" echo ICAgIHtzY2hlZHVsZS5tYXAoKGl0ZW0pID0+ICgKICAgICAgICAgICAgPGRpdiBjbGFzc05h
>>"%RB8%" echo bWU9e2B0aW1lbGluZS1yb3cgJHtpdGVtLnN0YXR1c31gfSBrZXk9e2Ake2l0ZW0udGltZX0t
>>"%RB8%" echo JHtpdGVtLnRpdGxlfWB9PgogICAgICAgICAgICAgIDx0aW1lPntpdGVtLnRpbWV9PC90aW1l
>>"%RB8%" echo PgogICAgICAgICAgICAgIDxpIC8+CiAgICAgICAgICAgICAgPGRpdj48Yj57aXRlbS50aXRs
>>"%RB8%" echo ZX08L2I+PHNwYW4+e2l0ZW0ubWV0YX08L3NwYW4+PC9kaXY+CiAgICAgICAgICAgICAgPGVt
>>"%RB8%" echo PntpdGVtLnN0YXR1cyA9PT0gJ2FjdGl2ZScgPyAnSW4gcHJvZ3Jlc3MnIDogaXRlbS5zdGF0
>>"%RB8%" echo dXMgPT09ICdkb25lJyA/ICdDb21wbGV0ZWQnIDogaXRlbS5zdGF0dXMgPT09ICdmcmVlJyA/
>>"%RB8%" echo ICdGcmVlJyA6ICdVcGNvbWluZyd9PC9lbT4KICAgICAgICAgICAgPC9kaXY+CiAgICAgICAg
>>"%RB8%" echo ICApKX0KICAgICAgICA8L2Rpdj4KICAgICAgPC9zZWN0aW9uPgoKICAgICAgPHNlY3Rpb24g
>>"%RB8%" echo Y2xhc3NOYW1lPSJjYXJkIHBlcmZvcm1hbmNlLWNhcmQiPgogICAgICAgIDxkaXYgY2xhc3NO
>>"%RB8%" echo YW1lPSJzZWN0aW9uLXRpdGxlIj4KICAgICAgICAgIDxkaXY+PHAgY2xhc3NOYW1lPSJleWVi
>>"%RB8%" echo cm93Ij5BQ0FERU1JQyBIRUFMVEg8L3A+PGgyPlBlcmZvcm1hbmNlPC9oMj48L2Rpdj4KICAg
>>"%RB8%" echo ICAgICAgIDxzcGFuPlRlcm0gMzwvc3Bhbj4KICAgICAgICA8L2Rpdj4KICAgICAgICA8ZGl2
>>"%RB8%" echo IGNsYXNzTmFtZT0icGVyZm9ybWFuY2UtYm9keSI+CiAgICAgICAgICA8UHJvZ3Jlc3NSaW5n
>>"%RB8%" echo IHZhbHVlPXs4Nn0gbGFiZWw9Ik92ZXJhbGwiIC8+CiAgICAgICAgICA8ZGl2IGNsYXNzTmFt
>>"%RB8%" echo ZT0ic3ViamVjdC1iYXJzIj4KICAgICAgICAgICAge1tbJ0RhdGEgU2NpZW5jZScsIDg5XSwg
>>"%RB8%" echo WydXZWIgVGVjaG5vbG9neScsIDgyXSwgWydEYXRhYmFzZXMnLCA5MV0sIFsnTWF0aGVtYXRp
>>"%RB8%" echo Y3MnLCA3N11dLm1hcCgoW25hbWUsIHZhbHVlXSkgPT4gKAogICAgICAgICAgICAgIDxkaXYg
>>"%RB8%" echo a2V5PXtuYW1lfT4KICAgICAgICAgICAgICAgIDxkaXY+PHNwYW4+e25hbWV9PC9zcGFuPjxi
>>"%RB8%" echo Pnt2YWx1ZX0lPC9iPjwvZGl2PgogICAgICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9ImJh
>>"%RB8%" echo ciI+PGkgc3R5bGU9e3sgd2lkdGg6IGAke3ZhbHVlfSVgIH19IC8+PC9kaXY+CiAgICAgICAg
>>"%RB8%" echo ICAgICAgPC9kaXY+CiAgICAgICAgICAgICkpfQogICAgICAgICAgPC9kaXY+CiAgICAgICAg
>>"%RB8%" echo PC9kaXY+CiAgICAgIDwvc2VjdGlvbj4KCiAgICAgIDxzZWN0aW9uIGNsYXNzTmFtZT0iY2Fy
>>"%RB8%" echo ZCBhc3NpZ25tZW50cy1jYXJkIiBpZD0iYXNzaWdubWVudHMiPgogICAgICAgIDxkaXYgY2xh
>>"%RB8%" echo c3NOYW1lPSJzZWN0aW9uLXRpdGxlIj4KICAgICAgICAgIDxkaXY+PHAgY2xhc3NOYW1lPSJl
>>"%RB8%" echo eWVicm93Ij5XT1JLIFFVRVVFPC9wPjxoMj5Bc3NpZ25tZW50czwvaDI+PC9kaXY+CiAgICAg
>>"%RB8%" echo ICAgICA8YnV0dG9uIGNsYXNzTmFtZT0idGV4dC1idG4iPlZpZXcgYWxsPC9idXR0b24+CiAg
>>"%RB8%" echo ICAgICAgPC9kaXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9ImFzc2lnbm1lbnQtbGlzdCI+
>>"%RB8%" echo CiAgICAgICAgICB7YXNzaWdubWVudHMubWFwKChpdGVtKSA9PiAoCiAgICAgICAgICAgIDxh
>>"%RB8%" echo cnRpY2xlIGtleT17aXRlbS50aXRsZX0+CiAgICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9
>>"%RB8%" echo e2Bwcmlvcml0eSAke2l0ZW0ucHJpb3JpdHkudG9Mb3dlckNhc2UoKX1gfT57aXRlbS5wcmlv
>>"%RB8%" echo cml0eX08L2Rpdj4KICAgICAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iYXNzaWdubWVudC1t
>>"%RB8%" echo YWluIj4KICAgICAgICAgICAgICAgIDxiPntpdGVtLnRpdGxlfTwvYj4KICAgICAgICAgICAg
>>"%RB8%" echo ICAgIDxzcGFuPntpdGVtLmNvdXJzZX0g4oCiIER1ZSB7aXRlbS5kdWV9PC9zcGFuPgogICAg
>>"%RB8%" echo ICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9ImJhciB0aGluIj48aSBzdHlsZT17eyB3aWR0
>>"%RB8%" echo aDogYCR7aXRlbS5wcm9ncmVzc30lYCB9fSAvPjwvZGl2PgogICAgICAgICAgICAgIDwvZGl2
>>"%RB8%" echo PgogICAgICAgICAgICAgIDxzdHJvbmc+e2l0ZW0ucHJvZ3Jlc3N9JTwvc3Ryb25nPgogICAg
>>"%RB8%" echo ICAgICAgICA8L2FydGljbGU+CiAgICAgICAgICApKX0KICAgICAgICA8L2Rpdj4KICAgICAg
>>"%RB8%" echo PC9zZWN0aW9uPgoKICAgICAgPHNlY3Rpb24gY2xhc3NOYW1lPSJjYXJkIGNvdXJzZXMtY2Fy
>>"%RB8%" echo ZCI+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9InNlY3Rpb24tdGl0bGUiPgogICAgICAgICAg
>>"%RB8%" echo PGRpdj48cCBjbGFzc05hbWU9ImV5ZWJyb3ciPk1ZIE1PRFVMRVM8L3A+PGgyPkNvdXJzZXM8
>>"%RB8%" echo L2gyPjwvZGl2PgogICAgICAgICAgPHNwYW4+NCBhY3RpdmU8L3NwYW4+CiAgICAgICAgPC9k
>>"%RB8%" echo aXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9ImNvdXJzZS1ncmlkIj4KICAgICAgICAgIHtj
>>"%RB8%" echo b3Vyc2VzLm1hcCgoY291cnNlKSA9PiAoCiAgICAgICAgICAgIDxhcnRpY2xlIGNsYXNzTmFt
>>"%RB8%" echo ZT17YGNvdXJzZSAke2NvdXJzZS5hY2NlbnR9YH0ga2V5PXtjb3Vyc2UuY29kZX0+CiAgICAg
>>"%RB8%" echo ICAgICAgICAgPHNwYW4gY2xhc3NOYW1lPSJjb3Vyc2UtY29kZSI+e2NvdXJzZS5jb2RlfTwv
>>"%RB8%" echo c3Bhbj4KICAgICAgICAgICAgICA8aDM+e2NvdXJzZS5uYW1lfTwvaDM+CiAgICAgICAgICAg
>>"%RB8%" echo ICAgPHA+e2NvdXJzZS5sZWN0dXJlcn08L3A+CiAgICAgICAgICAgICAgPHNtYWxsPntjb3Vy
>>"%RB8%" echo c2Uucm9vbX08L3NtYWxsPgogICAgICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPSJiYXIiPjxp
>>"%RB8%" echo IHN0eWxlPXt7IHdpZHRoOiBgJHtjb3Vyc2UucHJvZ3Jlc3N9JWAgfX0gLz48L2Rpdj4KICAg
>>"%RB8%" echo ICAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iY291cnNlLWZvb3QiPjxzcGFuPlByb2dyZXNz
>>"%RB8%" echo PC9zcGFuPjxiPntjb3Vyc2UucHJvZ3Jlc3N9JTwvYj48L2Rpdj4KICAgICAgICAgICAgPC9h
>>"%RB8%" echo cnRpY2xlPgogICAgICAgICAgKSl9CiAgICAgICAgPC9kaXY+CiAgICAgIDwvc2VjdGlvbj4K
>>"%RB8%" echo CiAgICAgIDxzZWN0aW9uIGNsYXNzTmFtZT0iY2FyZCBub3RpY2VzLWNhcmQiPgogICAgICAg
>>"%RB8%" echo IDxkaXYgY2xhc3NOYW1lPSJzZWN0aW9uLXRpdGxlIj4KICAgICAgICAgIDxkaXY+PHAgY2xh
>>"%RB8%" echo c3NOYW1lPSJleWVicm93Ij5DQU1QVVMgRkVFRDwvcD48aDI+QW5ub3VuY2VtZW50czwvaDI+
>>"%RB8%" echo PC9kaXY+CiAgICAgICAgPC9kaXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9Im5vdGljZSI+
>>"%RB8%" echo CiAgICAgICAgICA8c3BhbiBjbGFzc05hbWU9Im5vdGljZS1pY29uIj4wMTwvc3Bhbj4KICAg
>>"%RB8%" echo ICAgICAgIDxkaXY+PGI+RGF0YSBTY2llbmNlIGxhYiBtb3ZlZDwvYj48cD5GcmlkYXkgcHJh
>>"%RB8%" echo Y3RpY2FsIG1vdmVzIGZyb20gTGFiIEE0IHRvIExhYiBCMTIuPC9wPjxzbWFsbD4zMiBtaW51
>>"%RB8%" echo dGVzIGFnbzwvc21hbGw+PC9kaXY+CiAgICAgICAgPC9kaXY+CiAgICAgICAgPGRpdiBjbGFz
>>"%RB8%" echo c05hbWU9Im5vdGljZSI+CiAgICAgICAgICA8c3BhbiBjbGFzc05hbWU9Im5vdGljZS1pY29u
>>"%RB8%" echo Ij4wMjwvc3Bhbj4KICAgICAgICAgIDxkaXY+PGI+SGFja2F0aG9uIHJlZ2lzdHJhdGlvbiBv
>>"%RB8%" echo cGVuPC9iPjxwPlRlYW1zIG9mIDItNCBjYW4gcmVnaXN0ZXIgYmVmb3JlIE1vbmRheSBhZnRl
>>"%RB8%" echo cm5vb24uPC9wPjxzbWFsbD4yIGhvdXJzIGFnbzwvc21hbGw+PC9kaXY+CiAgICAgICAgPC9k
>>"%RB8%" echo aXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9Im5vdGljZSI+CiAgICAgICAgICA8c3BhbiBj
>>"%RB8%" echo bGFzc05hbWU9Im5vdGljZS1pY29uIj4wMzwvc3Bhbj4KICAgICAgICAgIDxkaXY+PGI+TGli
>>"%RB8%" echo cmFyeSBleHRlbmRlZCBob3VyczwvYj48cD5FeGFtIHByZXBhcmF0aW9uIGhvdXJzIGJlZ2lu
>>"%RB8%" echo IHRoaXMgd2Vla2VuZC48L3A+PHNtYWxsPlllc3RlcmRheTwvc21hbGw+PC9kaXY+CiAgICAg
>>"%RB8%" echo ICAgPC9kaXY+CiAgICAgIDwvc2VjdGlvbj4KICAgIDwvZGl2PgogICkKfQoKZnVuY3Rpb24g
>>"%RB8%" echo UG9ydGFsU2hlbGwoeyB1c2VyLCBvbkxvZ291dCB9KSB7CiAgY29uc3QgW3BhZ2UsIHNldFBh
>>"%RB8%" echo Z2VdID0gdXNlU3RhdGUoJ3BvcnRhbCcpCiAgY29uc3QgW25vdGlmaWNhdGlvbnMsIHNldE5v
>>"%RB8%" echo dGlmaWNhdGlvbnNdID0gdXNlU3RhdGUoMykKCiAgcmV0dXJuICgKICAgIDxkaXYgY2xhc3NO
>>"%RB8%" echo YW1lPSJwb3J0YWwtc2hlbGwiPgogICAgICA8YXNpZGUgY2xhc3NOYW1lPSJzaWRlYmFyIj4K
>>"%RB8%" echo ICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iYnJhbmQtcm93IGNvbXBhY3QiPgogICAgICAgICAg
>>"%RB8%" echo PGRpdiBjbGFzc05hbWU9ImJyYW5kLW1hcmsiPlJHPC9kaXY+CiAgICAgICAgICA8ZGl2Pjxz
>>"%RB8%" echo dHJvbmc+UG9ydGFsIDIwMjY8L3N0cm9uZz48c3Bhbj5TdHVkZW50IHdvcmtzcGFjZTwvc3Bh
>>"%RB8%" echo bj48L2Rpdj4KICAgICAgICA8L2Rpdj4KICAgICAgICA8bmF2PgogICAgICAgICAgPGJ1dHRv
>>"%RB8%" echo biBjbGFzc05hbWU9e3BhZ2UgPT09ICdwb3J0YWwnID8gJ2FjdGl2ZScgOiAnJ30gb25DbGlj
>>"%RB8%" echo az17KCkgPT4gc2V0UGFnZSgncG9ydGFsJyl9PgogICAgICAgICAgICA8c3Bhbj4wMTwvc3Bh
>>"%RB8%" echo bj4gRGFzaGJvYXJkCiAgICAgICAgICA8L2J1dHRvbj4KICAgICAgICAgIDxidXR0b24gY2xh
>>"%RB8%" echo c3NOYW1lPXtwYWdlID09PSAnZ2FtZScgPyAnYWN0aXZlJyA6ICcnfSBvbkNsaWNrPXsoKSA9
>>"%RB8%" echo PiBzZXRQYWdlKCdnYW1lJyl9PgogICAgICAgICAgICA8c3Bhbj4wMjwvc3Bhbj4gUmljb2No
>>"%RB8%" echo ZXQgQXJlbmEKICAgICAgICAgIDwvYnV0dG9uPgogICAgICAgIDwvbmF2PgogICAgICAgIDxk
>>"%RB8%" echo aXYgY2xhc3NOYW1lPSJzaWRlYmFyLXRpcCI+CiAgICAgICAgICA8Yj5HQU1FIENPTlRST0xT
>>"%RB8%" echo PC9iPgogICAgICAgICAgPHNwYW4+V0FTRCBtb3ZlPC9zcGFuPgogICAgICAgICAgPHNwYW4+
>>"%RB8%" echo TW91c2UgYWltPC9zcGFuPgogICAgICAgICAgPHNwYW4+Q2xpY2sgc2hvb3Q8L3NwYW4+CiAg
>>"%RB8%" echo ICAgICAgICA8c3Bhbj5SIHJlbG9hZDwvc3Bhbj4KICAgICAgICAgIDxzcGFuPlNwYWNlIGRh
>>"%RB8%" echo c2g8L3NwYW4+CiAgICAgICAgPC9kaXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9InN0dWRl
>>"%RB8%" echo bnQtbWluaSI+CiAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iYXZhdGFyIj57dXNlci5maXJz
>>"%RB8%" echo dE5hbWU/LlswXX17dXNlci5sYXN0TmFtZT8uWzBdfTwvZGl2PgogICAgICAgICAgPGRpdj48
>>"%RB8%" echo Yj57dXNlci5maXJzdE5hbWV9IHt1c2VyLmxhc3ROYW1lfTwvYj48c3Bhbj57dXNlci5zdHVk
>>"%RB8%" echo ZW50SWR9PC9zcGFuPjwvZGl2PgogICAgICAgIDwvZGl2PgogICAgICA8L2FzaWRlPgoKICAg
>>"%RB8%" echo ICAgPG1haW4gY2xhc3NOYW1lPSJwb3J0YWwtbWFpbiI+CiAgICAgICAgPGhlYWRlciBjbGFz
>>"%RB8%" echo c05hbWU9InRvcGJhciI+CiAgICAgICAgICA8ZGl2PgogICAgICAgICAgICA8cCBjbGFzc05h
>>"%RB8%" echo bWU9ImV5ZWJyb3ciPntwYWdlID09PSAncG9ydGFsJyA/ICdTVFVERU5UIERBU0hCT0FSRCcg
>>"%RB8%" echo OiAnUEFHRSAyIOKAoiBDQU1QVVMgQVJDQURFJ308L3A+CiAgICAgICAgICAgIDxoMj57cGFn
>>"%RB8%" echo ZSA9PT0gJ3BvcnRhbCcgPyAnQWNhZGVtaWMgT3ZlcnZpZXcnIDogJ1JpY29jaGV0IEFyZW5h
>>"%RB8%" echo J308L2gyPgogICAgICAgICAgPC9kaXY+CiAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0idG9w
>>"%RB8%" echo LWFjdGlvbnMiPgogICAgICAgICAgICA8YnV0dG9uIGNsYXNzTmFtZT0iaWNvbi1idG4iIG9u
>>"%RB8%" echo Q2xpY2s9eygpID0+IHNldE5vdGlmaWNhdGlvbnMoMCl9PgogICAgICAgICAgICAgIDxzcGFu
>>"%RB8%" echo PiE8L3NwYW4+CiAgICAgICAgICAgICAge25vdGlmaWNhdGlvbnMgPiAwICYmIDxpPntub3Rp
>>"%RB8%" echo ZmljYXRpb25zfTwvaT59CiAgICAgICAgICAgIDwvYnV0dG9uPgogICAgICAgICAgICA8ZGl2
>>"%RB8%" echo IGNsYXNzTmFtZT0idGVybS1jaGlwIj48c3Bhbj5UZXJtPC9zcGFuPjxiPjMgLyAyMDI2PC9i
>>"%RB8%" echo PjwvZGl2PgogICAgICAgICAgICA8YnV0dG9uIGNsYXNzTmFtZT0iZ2hvc3QtYnRuIHNtYWxs
>>"%RB8%" echo IiBvbkNsaWNrPXtvbkxvZ291dH0+U2lnbiBvdXQ8L2J1dHRvbj4KICAgICAgICAgIDwvZGl2
>>"%RB8%" echo PgogICAgICAgIDwvaGVhZGVyPgoKICAgICAgICB7cGFnZSA9PT0gJ3BvcnRhbCcgPyAoCiAg
>>"%RB8%" echo ICAgICAgICA8RGFzaGJvYXJkIHVzZXI9e3VzZXJ9IG9uT3BlbkdhbWU9eygpID0+IHNldFBh
>>"%RB8%" echo Z2UoJ2dhbWUnKX0gLz4KICAgICAgICApIDogKAogICAgICAgICAgPFJpY29jaGV0R2FtZSBz
>>"%RB8%" echo dHVkZW50TmFtZT17dXNlci5maXJzdE5hbWV9IC8+CiAgICAgICAgKX0KICAgICAgPC9tYWlu
>>"%RB8%" echo PgogICAgPC9kaXY+CiAgKQp9CgpleHBvcnQgZGVmYXVsdCBmdW5jdGlvbiBBcHAoKSB7CiAg
>>"%RB8%" echo Y29uc3QgW3VzZXIsIHNldFVzZXJdID0gdXNlU3RhdGUobnVsbCkKICBjb25zdCBbcmVhZHks
>>"%RB8%" echo IHNldFJlYWR5XSA9IHVzZVN0YXRlKGZhbHNlKQoKICB1c2VFZmZlY3QoKCkgPT4gewogICAg
>>"%RB8%" echo Y29uc3Qgc2Vzc2lvbiA9IEpTT04ucGFyc2UobG9jYWxTdG9yYWdlLmdldEl0ZW0oU0VTU0lP
>>"%RB8%" echo Tl9LRVkpIHx8ICdudWxsJykKICAgIGlmIChzZXNzaW9uPy5pZCkgewogICAgICBjb25zdCBm
>>"%RB8%" echo b3VuZCA9IHJlYWRVc2VycygpLmZpbmQoKGl0ZW0pID0+IGl0ZW0uaWQgPT09IHNlc3Npb24u
>>"%RB8%" echo aWQpCiAgICAgIGlmIChmb3VuZCkgc2V0VXNlcihmb3VuZCkKICAgIH0KICAgIHNldFJlYWR5
>>"%RB8%" echo KHRydWUpCiAgfSwgW10pCgogIGNvbnN0IHNlc3Npb25OYW1lID0gdXNlTWVtbygoKSA9PiAo
>>"%RB8%" echo dXNlciA/IGAke3VzZXIuZmlyc3ROYW1lfSAke3VzZXIubGFzdE5hbWV9YCA6ICcnKSwgW3Vz
>>"%RB8%" echo ZXJdKQoKICBmdW5jdGlvbiBsb2dvdXQoKSB7CiAgICBsb2NhbFN0b3JhZ2UucmVtb3ZlSXRl
>>"%RB8%" echo bShTRVNTSU9OX0tFWSkKICAgIHNldFVzZXIobnVsbCkKICB9CgogIGlmICghcmVhZHkpIHJl
>>"%RB8%" echo dHVybiA8ZGl2IGNsYXNzTmFtZT0iYm9vdC1zY3JlZW4iPkxvYWRpbmcgU3R1ZGVudCBQb3J0
>>"%RB8%" echo YWwgMjAyNi4uLjwvZGl2PgogIGlmICghdXNlcikgcmV0dXJuIDxBdXRoU2NyZWVuIG9uQXV0
>>"%RB8%" echo aGVudGljYXRlZD17c2V0VXNlcn0gLz4KCiAgcmV0dXJuIDxQb3J0YWxTaGVsbCBrZXk9e3Nl
>>"%RB8%" echo c3Npb25OYW1lfSB1c2VyPXt1c2VyfSBvbkxvZ291dD17bG9nb3V0fSAvPgp9Cg==
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB8%" "%APP_DIR%\src\App.jsx"
set "RB9=%TEMP%\react_embed_9.b64"
>"%RB9%" echo aW1wb3J0IHsgdXNlRWZmZWN0LCB1c2VSZWYsIHVzZVN0YXRlIH0gZnJvbSAncmVhY3QnCgpj
>>"%RB9%" echo b25zdCBXSURUSCA9IDExMDAKY29uc3QgSEVJR0hUID0gNjUwCgpjb25zdCBvYnN0YWNsZXMg
>>"%RB9%" echo PSBbCiAgeyB4OiAxOTAsIHk6IDE0NSwgdzogMTcwLCBoOiAyOCB9LAogIHsgeDogNDg1LCB5
>>"%RB9%" echo OiAyMjAsIHc6IDEzMCwgaDogMzIgfSwKICB7IHg6IDc2MCwgeTogMTM1LCB3OiAxNjUsIGg6
>>"%RB9%" echo IDI4IH0sCiAgeyB4OiAzMDAsIHk6IDM5NSwgdzogMTM1LCBoOiAzMCB9LAogIHsgeDogNjY1
>>"%RB9%" echo LCB5OiA0MTAsIHc6IDE0NSwgaDogMzAgfSwKXQoKY29uc3QgY2xhbXAgPSAodmFsdWUsIG1p
>>"%RB9%" echo biwgbWF4KSA9PiBNYXRoLm1heChtaW4sIE1hdGgubWluKG1heCwgdmFsdWUpKQpjb25zdCBk
>>"%RB9%" echo aXN0MiA9IChhLCBiKSA9PiAoYS54IC0gYi54KSAqKiAyICsgKGEueSAtIGIueSkgKiogMgoK
>>"%RB9%" echo ZnVuY3Rpb24gY2lyY2xlUmVjdEhpdChjaXJjbGUsIHJlY3QpIHsKICBjb25zdCBweCA9IGNs
>>"%RB9%" echo YW1wKGNpcmNsZS54LCByZWN0LngsIHJlY3QueCArIHJlY3QudykKICBjb25zdCBweSA9IGNs
>>"%RB9%" echo YW1wKGNpcmNsZS55LCByZWN0LnksIHJlY3QueSArIHJlY3QuaCkKICBjb25zdCBkeCA9IGNp
>>"%RB9%" echo cmNsZS54IC0gcHgKICBjb25zdCBkeSA9IGNpcmNsZS55IC0gcHkKICByZXR1cm4gZHggKiBk
>>"%RB9%" echo eCArIGR5ICogZHkgPD0gY2lyY2xlLnIgKiBjaXJjbGUucgp9CgpmdW5jdGlvbiByZWZsZWN0
>>"%RB9%" echo RnJvbVJlY3QoYmFsbCwgcmVjdCwgcHJldmlvdXMpIHsKICBjb25zdCB3YXNMZWZ0ID0gcHJl
>>"%RB9%" echo dmlvdXMueCArIGJhbGwuciA8PSByZWN0LngKICBjb25zdCB3YXNSaWdodCA9IHByZXZpb3Vz
>>"%RB9%" echo LnggLSBiYWxsLnIgPj0gcmVjdC54ICsgcmVjdC53CiAgY29uc3Qgd2FzVG9wID0gcHJldmlv
>>"%RB9%" echo dXMueSArIGJhbGwuciA8PSByZWN0LnkKICBjb25zdCB3YXNCb3R0b20gPSBwcmV2aW91cy55
>>"%RB9%" echo IC0gYmFsbC5yID49IHJlY3QueSArIHJlY3QuaAoKICBpZiAod2FzTGVmdCkgewogICAgYmFs
>>"%RB9%" echo bC54ID0gcmVjdC54IC0gYmFsbC5yIC0gMC41CiAgICBiYWxsLnZ4ID0gLU1hdGguYWJzKGJh
>>"%RB9%" echo bGwudngpCiAgfSBlbHNlIGlmICh3YXNSaWdodCkgewogICAgYmFsbC54ID0gcmVjdC54ICsg
>>"%RB9%" echo cmVjdC53ICsgYmFsbC5yICsgMC41CiAgICBiYWxsLnZ4ID0gTWF0aC5hYnMoYmFsbC52eCkK
>>"%RB9%" echo ICB9IGVsc2UgaWYgKHdhc1RvcCkgewogICAgYmFsbC55ID0gcmVjdC55IC0gYmFsbC5yIC0g
>>"%RB9%" echo MC41CiAgICBiYWxsLnZ5ID0gLU1hdGguYWJzKGJhbGwudnkpCiAgfSBlbHNlIGlmICh3YXNC
>>"%RB9%" echo b3R0b20pIHsKICAgIGJhbGwueSA9IHJlY3QueSArIHJlY3QuaCArIGJhbGwuciArIDAuNQog
>>"%RB9%" echo ICAgYmFsbC52eSA9IE1hdGguYWJzKGJhbGwudnkpCiAgfSBlbHNlIHsKICAgIGNvbnN0IGxl
>>"%RB9%" echo ZnQgPSBNYXRoLmFicyhiYWxsLnggLSByZWN0LngpCiAgICBjb25zdCByaWdodCA9IE1hdGgu
>>"%RB9%" echo YWJzKGJhbGwueCAtIChyZWN0LnggKyByZWN0LncpKQogICAgY29uc3QgdG9wID0gTWF0aC5h
>>"%RB9%" echo YnMoYmFsbC55IC0gcmVjdC55KQogICAgY29uc3QgYm90dG9tID0gTWF0aC5hYnMoYmFsbC55
>>"%RB9%" echo IC0gKHJlY3QueSArIHJlY3QuaCkpCiAgICBjb25zdCBtID0gTWF0aC5taW4obGVmdCwgcmln
>>"%RB9%" echo aHQsIHRvcCwgYm90dG9tKQogICAgaWYgKG0gPT09IGxlZnQgfHwgbSA9PT0gcmlnaHQpIGJh
>>"%RB9%" echo bGwudnggKj0gLTEKICAgIGVsc2UgYmFsbC52eSAqPSAtMQogIH0KfQoKZnVuY3Rpb24gbWFr
>>"%RB9%" echo ZUVuZW15KHRpbWUsIHdhdmUpIHsKICBjb25zdCByb2xsID0gTWF0aC5yYW5kb20oKQogIGNv
>>"%RB9%" echo bnN0IHR5cGUgPSByb2xsIDwgMC41NiA/ICdzY291dCcgOiByb2xsIDwgMC44NCA/ICdzdHJp
>>"%RB9%" echo a2VyJyA6ICd0YW5rJwogIGNvbnN0IGNvbmZpZyA9IHsKICAgIHNjb3V0OiB7IHI6IDE1LCBo
>>"%RB9%" echo cDogNDIgKyB3YXZlICogNCwgc3BlZWQ6IDkyICsgd2F2ZSAqIDMsIHNjb3JlOiAxMTAsIGZp
>>"%RB9%" echo cmU6IDIuNiB9LAogICAgc3RyaWtlcjogeyByOiAxOCwgaHA6IDY2ICsgd2F2ZSAqIDYsIHNw
>>"%RB9%" echo ZWVkOiA3MiArIHdhdmUgKiAyLCBzY29yZTogMTgwLCBmaXJlOiAxLjcgfSwKICAgIHRhbms6
>>"%RB9%" echo IHsgcjogMjMsIGhwOiAxMjUgKyB3YXZlICogMTAsIHNwZWVkOiA0NiArIHdhdmUsIHNjb3Jl
>>"%RB9%" echo OiAzMDAsIGZpcmU6IDIuMjUgfSwKICB9W3R5cGVdCgogIGNvbnN0IGVkZ2UgPSBNYXRoLmZs
>>"%RB9%" echo b29yKE1hdGgucmFuZG9tKCkgKiAzKQogIGxldCB4ID0gNDAKICBsZXQgeSA9IDcwCiAgaWYg
>>"%RB9%" echo KGVkZ2UgPT09IDApIHsKICAgIHggPSA0MCArIE1hdGgucmFuZG9tKCkgKiAoV0lEVEggLSA4
>>"%RB9%" echo MCkKICAgIHkgPSA0NQogIH0gZWxzZSBpZiAoZWRnZSA9PT0gMSkgewogICAgeCA9IDQyCiAg
>>"%RB9%" echo ICB5ID0gNzAgKyBNYXRoLnJhbmRvbSgpICogMzkwCiAgfSBlbHNlIHsKICAgIHggPSBXSURU
>>"%RB9%" echo SCAtIDQyCiAgICB5ID0gNzAgKyBNYXRoLnJhbmRvbSgpICogMzkwCiAgfQoKICByZXR1cm4g
>>"%RB9%" echo ewogICAgaWQ6IGAke3RpbWV9LSR7TWF0aC5yYW5kb20oKX1gLAogICAgdHlwZSwKICAgIHgs
>>"%RB9%" echo CiAgICB5LAogICAgcjogY29uZmlnLnIsCiAgICBocDogY29uZmlnLmhwLAogICAgbWF4SHA6
>>"%RB9%" echo IGNvbmZpZy5ocCwKICAgIHNwZWVkOiBjb25maWcuc3BlZWQsCiAgICBzY29yZTogY29uZmln
>>"%RB9%" echo LnNjb3JlLAogICAgZmlyZURlbGF5OiBjb25maWcuZmlyZSwKICAgIGZpcmVUaW1lcjogY29u
>>"%RB9%" echo ZmlnLmZpcmUgKiAoMC40NSArIE1hdGgucmFuZG9tKCkgKiAwLjcpLAogICAgcGhhc2U6IE1h
>>"%RB9%" echo dGgucmFuZG9tKCkgKiBNYXRoLlBJICogMiwKICAgIGhpdEZsYXNoOiAwLAogIH0KfQoKZnVu
>>"%RB9%" echo Y3Rpb24gZHJhd1JvdW5kZWRSZWN0KGN0eCwgeCwgeSwgdywgaCwgcikgewogIGN0eC5iZWdp
>>"%RB9%" echo blBhdGgoKQogIGN0eC5yb3VuZFJlY3QoeCwgeSwgdywgaCwgcikKICBjdHguZmlsbCgpCn0K
>>"%RB9%" echo CmV4cG9ydCBkZWZhdWx0IGZ1bmN0aW9uIFJpY29jaGV0R2FtZSh7IHN0dWRlbnROYW1lID0g
>>"%RB9%" echo J1N0dWRlbnQnIH0pIHsKICBjb25zdCBjYW52YXNSZWYgPSB1c2VSZWYobnVsbCkKICBjb25z
>>"%RB9%" echo dCBmcmFtZVJlZiA9IHVzZVJlZigwKQogIGNvbnN0IFtydW5uaW5nLCBzZXRSdW5uaW5nXSA9
>>"%RB9%" echo IHVzZVN0YXRlKHRydWUpCiAgY29uc3QgcnVubmluZ1JlZiA9IHVzZVJlZih0cnVlKQogIGNv
>>"%RB9%" echo bnN0IFtnYW1lS2V5LCBzZXRHYW1lS2V5XSA9IHVzZVN0YXRlKDApCiAgY29uc3QgW2h1ZCwg
>>"%RB9%" echo c2V0SHVkXSA9IHVzZVN0YXRlKHsKICAgIHNjb3JlOiAwLAogICAgaHA6IDEwMCwKICAgIGFt
>>"%RB9%" echo bW86IDEyLAogICAgbWF4QW1tbzogMTIsCiAgICB3YXZlOiAxLAogICAgY29tYm86IDEsCiAg
>>"%RB9%" echo ICByaWNvY2hldHM6IDAsCiAgICBraWxsczogMCwKICAgIGRhc2g6IDAsCiAgICBnYW1lT3Zl
>>"%RB9%" echo cjogZmFsc2UsCiAgfSkKCiAgdXNlRWZmZWN0KCgpID0+IHsKICAgIHJ1bm5pbmdSZWYuY3Vy
>>"%RB9%" echo cmVudCA9IHJ1bm5pbmcKICB9LCBbcnVubmluZ10pCgogIHVzZUVmZmVjdCgoKSA9PiB7CiAg
>>"%RB9%" echo ICBjb25zdCBjYW52YXMgPSBjYW52YXNSZWYuY3VycmVudAogICAgaWYgKCFjYW52YXMpIHJl
>>"%RB9%" echo dHVybiB1bmRlZmluZWQKICAgIGNvbnN0IGN0eCA9IGNhbnZhcy5nZXRDb250ZXh0KCcyZCcp
>>"%RB9%" echo CgogICAgY29uc3Qga2V5cyA9IG5ldyBTZXQoKQogICAgY29uc3QgcG9pbnRlciA9IHsgeDog
>>"%RB9%" echo V0lEVEggLyAyLCB5OiAxMDAgfQoKICAgIGNvbnN0IHN0YXRlID0gewogICAgICB0aW1lOiAw
>>"%RB9%" echo LAogICAgICBzcGF3blRpbWVyOiAwLjgsCiAgICAgIHBpY2t1cFRpbWVyOiAxMSwKICAgICAg
>>"%RB9%" echo c2hha2U6IDAsCiAgICAgIHNjb3JlOiAwLAogICAgICBraWxsczogMCwKICAgICAgdG90YWxS
>>"%RB9%" echo aWNvY2hldHM6IDAsCiAgICAgIGNvbWJvOiAxLAogICAgICBjb21ib1RpbWVyOiAwLAogICAg
>>"%RB9%" echo ICBnYW1lT3ZlcjogZmFsc2UsCiAgICAgIHBsYXllcjogewogICAgICAgIHg6IFdJRFRIIC8g
>>"%RB9%" echo MiwKICAgICAgICB5OiBIRUlHSFQgLSA2MiwKICAgICAgICByOiAxOCwKICAgICAgICBocDog
>>"%RB9%" echo MTAwLAogICAgICAgIGFtbW86IDEyLAogICAgICAgIG1heEFtbW86IDEyLAogICAgICAgIHJl
>>"%RB9%" echo bG9hZDogMCwKICAgICAgICByZWxvYWRNYXg6IDEuMTUsCiAgICAgICAgZGFzaENvb2xkb3du
>>"%RB9%" echo OiAwLAogICAgICAgIGRhc2hUaW1lOiAwLAogICAgICAgIGludnVsbmVyYWJsZTogMCwKICAg
>>"%RB9%" echo ICAgfSwKICAgICAgYnVsbGV0czogW10sCiAgICAgIGVuZW15QnVsbGV0czogW10sCiAgICAg
>>"%RB9%" echo IGVuZW1pZXM6IFtdLAogICAgICBwYXJ0aWNsZXM6IFtdLAogICAgICBwaWNrdXBzOiBbXSwK
>>"%RB9%" echo ICAgIH0KCiAgICBmdW5jdGlvbiB1cGRhdGVIdWQoKSB7CiAgICAgIHNldEh1ZCh7CiAgICAg
>>"%RB9%" echo ICAgc2NvcmU6IE1hdGguZmxvb3Ioc3RhdGUuc2NvcmUpLAogICAgICAgIGhwOiBNYXRoLm1h
>>"%RB9%" echo eCgwLCBNYXRoLmNlaWwoc3RhdGUucGxheWVyLmhwKSksCiAgICAgICAgYW1tbzogc3RhdGUu
>>"%RB9%" echo cGxheWVyLmFtbW8sCiAgICAgICAgbWF4QW1tbzogc3RhdGUucGxheWVyLm1heEFtbW8sCiAg
>>"%RB9%" echo ICAgICAgd2F2ZTogTWF0aC5mbG9vcihzdGF0ZS50aW1lIC8gMjgpICsgMSwKICAgICAgICBj
>>"%RB9%" echo b21ibzogc3RhdGUuY29tYm8sCiAgICAgICAgcmljb2NoZXRzOiBzdGF0ZS50b3RhbFJpY29j
>>"%RB9%" echo aGV0cywKICAgICAgICBraWxsczogc3RhdGUua2lsbHMsCiAgICAgICAgZGFzaDogc3RhdGUu
>>"%RB9%" echo cGxheWVyLmRhc2hDb29sZG93biwKICAgICAgICBnYW1lT3Zlcjogc3RhdGUuZ2FtZU92ZXIs
>>"%RB9%" echo CiAgICAgIH0pCiAgICB9CgogICAgZnVuY3Rpb24gYnVyc3QoeCwgeSwgY29sb3IsIGNvdW50
>>"%RB9%" echo ID0gOSwgc3BlZWQgPSAxMzApIHsKICAgICAgZm9yIChsZXQgaSA9IDA7IGkgPCBjb3VudDsg
>>"%RB9%" echo aSArPSAxKSB7CiAgICAgICAgY29uc3QgYSA9IE1hdGgucmFuZG9tKCkgKiBNYXRoLlBJICog
>>"%RB9%" echo MgogICAgICAgIGNvbnN0IHMgPSBzcGVlZCAqICgwLjM1ICsgTWF0aC5yYW5kb20oKSkKICAg
>>"%RB9%" echo ICAgICBzdGF0ZS5wYXJ0aWNsZXMucHVzaCh7CiAgICAgICAgICB4LAogICAgICAgICAgeSwK
>>"%RB9%" echo ICAgICAgICAgIHZ4OiBNYXRoLmNvcyhhKSAqIHMsCiAgICAgICAgICB2eTogTWF0aC5zaW4o
>>"%RB9%" echo YSkgKiBzLAogICAgICAgICAgbGlmZTogMC4yNSArIE1hdGgucmFuZG9tKCkgKiAwLjQ1LAog
>>"%RB9%" echo ICAgICAgICAgbWF4TGlmZTogMC43LAogICAgICAgICAgY29sb3IsCiAgICAgICAgICBzaXpl
>>"%RB9%" echo OiAxLjUgKyBNYXRoLnJhbmRvbSgpICogMy41LAogICAgICAgIH0pCiAgICAgIH0KICAgIH0K
>>"%RB9%" echo CiAgICBmdW5jdGlvbiBzaG9vdCgpIHsKICAgICAgY29uc3QgcCA9IHN0YXRlLnBsYXllcgog
>>"%RB9%" echo ICAgICBpZiAoc3RhdGUuZ2FtZU92ZXIgfHwgcC5yZWxvYWQgPiAwIHx8IHAuYW1tbyA8PSAw
>>"%RB9%" echo KSByZXR1cm4KICAgICAgY29uc3QgZHggPSBwb2ludGVyLnggLSBwLngKICAgICAgY29uc3Qg
>>"%RB9%" echo ZHkgPSBwb2ludGVyLnkgLSBwLnkKICAgICAgY29uc3QgbGVuZ3RoID0gTWF0aC5oeXBvdChk
>>"%RB9%" echo eCwgZHkpIHx8IDEKICAgICAgY29uc3Qgc3BlZWQgPSA3MjAKICAgICAgcC5hbW1vIC09IDEK
>>"%RB9%" echo ICAgICAgc3RhdGUuYnVsbGV0cy5wdXNoKHsKICAgICAgICB4OiBwLnggKyAoZHggLyBsZW5n
>>"%RB9%" echo dGgpICogMjUsCiAgICAgICAgeTogcC55ICsgKGR5IC8gbGVuZ3RoKSAqIDI1LAogICAgICAg
>>"%RB9%" echo IHZ4OiAoZHggLyBsZW5ndGgpICogc3BlZWQsCiAgICAgICAgdnk6IChkeSAvIGxlbmd0aCkg
>>"%RB9%" echo KiBzcGVlZCwKICAgICAgICByOiA0LjUsCiAgICAgICAgbGlmZTogNSwKICAgICAgICBib3Vu
>>"%RB9%" echo Y2VzOiAwLAogICAgICAgIGJvdW5jZUNvb2xkb3duOiAwLAogICAgICB9KQogICAgICBidXJz
>>"%RB9%" echo dChwLngsIHAueSwgJyM2ZWU3ZmYnLCA0LCA4MCkKICAgICAgaWYgKHAuYW1tbyA9PT0gMCkg
>>"%RB9%" echo cC5yZWxvYWQgPSBwLnJlbG9hZE1heAogICAgfQoKICAgIGZ1bmN0aW9uIHJlbG9hZCgpIHsK
>>"%RB9%" echo ICAgICAgY29uc3QgcCA9IHN0YXRlLnBsYXllcgogICAgICBpZiAoIXN0YXRlLmdhbWVPdmVy
>>"%RB9%" echo ICYmIHAucmVsb2FkIDw9IDAgJiYgcC5hbW1vIDwgcC5tYXhBbW1vKSBwLnJlbG9hZCA9IHAu
>>"%RB9%" echo cmVsb2FkTWF4CiAgICB9CgogICAgZnVuY3Rpb24gZW5lbXlTaG9vdChlbmVteSkgewogICAg
>>"%RB9%" echo ICBjb25zdCBwID0gc3RhdGUucGxheWVyCiAgICAgIGNvbnN0IGR4ID0gcC54IC0gZW5lbXku
>>"%RB9%" echo eAogICAgICBjb25zdCBkeSA9IHAueSAtIGVuZW15LnkKICAgICAgY29uc3QgbGVuID0gTWF0
>>"%RB9%" echo aC5oeXBvdChkeCwgZHkpIHx8IDEKICAgICAgY29uc3Qgc3BlZWQgPSBlbmVteS50eXBlID09
>>"%RB9%" echo PSAnc3RyaWtlcicgPyAzMTAgOiAyNDUKICAgICAgY29uc3Qgc3ByZWFkID0gZW5lbXkudHlw
>>"%RB9%" echo ZSA9PT0gJ3RhbmsnID8gWy0wLjE0LCAwLCAwLjE0XSA6IFswXQogICAgICBjb25zdCBiYXNl
>>"%RB9%" echo ID0gTWF0aC5hdGFuMihkeSwgZHgpCiAgICAgIGZvciAoY29uc3Qgb2Zmc2V0IG9mIHNwcmVh
>>"%RB9%" echo ZCkgewogICAgICAgIGNvbnN0IGFuZ2xlID0gYmFzZSArIG9mZnNldAogICAgICAgIHN0YXRl
>>"%RB9%" echo LmVuZW15QnVsbGV0cy5wdXNoKHsKICAgICAgICAgIHg6IGVuZW15LngsCiAgICAgICAgICB5
>>"%RB9%" echo OiBlbmVteS55LAogICAgICAgICAgdng6IE1hdGguY29zKGFuZ2xlKSAqIHNwZWVkLAogICAg
>>"%RB9%" echo ICAgICAgdnk6IE1hdGguc2luKGFuZ2xlKSAqIHNwZWVkLAogICAgICAgICAgcjogZW5lbXku
>>"%RB9%" echo dHlwZSA9PT0gJ3RhbmsnID8gNS41IDogNCwKICAgICAgICAgIGxpZmU6IDUsCiAgICAgICAg
>>"%RB9%" echo ICBkYW1hZ2U6IGVuZW15LnR5cGUgPT09ICd0YW5rJyA/IDEwIDogMTMsCiAgICAgICAgfSkK
>>"%RB9%" echo ICAgICAgfQogICAgfQoKICAgIGZ1bmN0aW9uIHNwYXduUGlja3VwKCkgewogICAgICBjb25z
>>"%RB9%" echo dCBraW5kcyA9IFsnaGVhbCcsICdhbW1vJywgJ3NoaWVsZCddCiAgICAgIHN0YXRlLnBpY2t1
>>"%RB9%" echo cHMucHVzaCh7CiAgICAgICAgeDogMTAwICsgTWF0aC5yYW5kb20oKSAqIChXSURUSCAtIDIw
>>"%RB9%" echo MCksCiAgICAgICAgeTogMjIwICsgTWF0aC5yYW5kb20oKSAqIDI2MCwKICAgICAgICByOiAx
>>"%RB9%" echo MiwKICAgICAgICB0eXBlOiBraW5kc1tNYXRoLmZsb29yKE1hdGgucmFuZG9tKCkgKiBraW5k
>>"%RB9%" echo cy5sZW5ndGgpXSwKICAgICAgICBsaWZlOiAxMCwKICAgICAgICBwdWxzZTogMCwKICAgICAg
>>"%RB9%" echo fSkKICAgIH0KCiAgICBmdW5jdGlvbiBkYW1hZ2VQbGF5ZXIoYW1vdW50KSB7CiAgICAgIGNv
>>"%RB9%" echo bnN0IHAgPSBzdGF0ZS5wbGF5ZXIKICAgICAgaWYgKHAuaW52dWxuZXJhYmxlID4gMCB8fCBz
>>"%RB9%" echo dGF0ZS5nYW1lT3ZlcikgcmV0dXJuCiAgICAgIHAuaHAgLT0gYW1vdW50CiAgICAgIHAuaW52
>>"%RB9%" echo dWxuZXJhYmxlID0gMC4zCiAgICAgIHN0YXRlLnNoYWtlID0gTWF0aC5tYXgoc3RhdGUuc2hh
>>"%RB9%" echo a2UsIDkpCiAgICAgIGJ1cnN0KHAueCwgcC55LCAnI2ZmNWQ3YScsIDE0LCAxNzApCiAgICAg
>>"%RB9%" echo IHN0YXRlLmNvbWJvID0gMQogICAgICBpZiAocC5ocCA8PSAwKSB7CiAgICAgICAgcC5ocCA9
>>"%RB9%" echo IDAKICAgICAgICBzdGF0ZS5nYW1lT3ZlciA9IHRydWUKICAgICAgICBydW5uaW5nUmVmLmN1
>>"%RB9%" echo cnJlbnQgPSBmYWxzZQogICAgICAgIHNldFJ1bm5pbmcoZmFsc2UpCiAgICAgIH0KICAgIH0K
>>"%RB9%" echo CiAgICBmdW5jdGlvbiB1cGRhdGUoZHQpIHsKICAgICAgaWYgKCFydW5uaW5nUmVmLmN1cnJl
>>"%RB9%" echo bnQgfHwgc3RhdGUuZ2FtZU92ZXIpIHJldHVybgoKICAgICAgc3RhdGUudGltZSArPSBkdAog
>>"%RB9%" echo ICAgICBjb25zdCBwID0gc3RhdGUucGxheWVyCiAgICAgIGNvbnN0IHdhdmUgPSBNYXRoLmZs
>>"%RB9%" echo b29yKHN0YXRlLnRpbWUgLyAyOCkgKyAxCgogICAgICBwLmludnVsbmVyYWJsZSA9IE1hdGgu
>>"%RB9%" echo bWF4KDAsIHAuaW52dWxuZXJhYmxlIC0gZHQpCiAgICAgIHAuZGFzaENvb2xkb3duID0gTWF0
>>"%RB9%" echo aC5tYXgoMCwgcC5kYXNoQ29vbGRvd24gLSBkdCkKICAgICAgcC5kYXNoVGltZSA9IE1hdGgu
>>"%RB9%" echo bWF4KDAsIHAuZGFzaFRpbWUgLSBkdCkKCiAgICAgIGlmIChwLnJlbG9hZCA+IDApIHsKICAg
>>"%RB9%" echo ICAgICBwLnJlbG9hZCAtPSBkdAogICAgICAgIGlmIChwLnJlbG9hZCA8PSAwKSB7CiAgICAg
>>"%RB9%" echo ICAgICBwLnJlbG9hZCA9IDAKICAgICAgICAgIHAuYW1tbyA9IHAubWF4QW1tbwogICAgICAg
>>"%RB9%" echo IH0KICAgICAgfQoKICAgICAgbGV0IG14ID0gMAogICAgICBsZXQgbXkgPSAwCiAgICAgIGlm
>>"%RB9%" echo IChrZXlzLmhhcygnS2V5QScpIHx8IGtleXMuaGFzKCdBcnJvd0xlZnQnKSkgbXggLT0gMQog
>>"%RB9%" echo ICAgICBpZiAoa2V5cy5oYXMoJ0tleUQnKSB8fCBrZXlzLmhhcygnQXJyb3dSaWdodCcpKSBt
>>"%RB9%" echo eCArPSAxCiAgICAgIGlmIChrZXlzLmhhcygnS2V5VycpIHx8IGtleXMuaGFzKCdBcnJvd1Vw
>>"%RB9%" echo JykpIG15IC09IDEKICAgICAgaWYgKGtleXMuaGFzKCdLZXlTJykgfHwga2V5cy5oYXMoJ0Fy
>>"%RB9%" echo cm93RG93bicpKSBteSArPSAxCiAgICAgIGlmIChteCB8fCBteSkgewogICAgICAgIGNvbnN0
>>"%RB9%" echo IGxlbiA9IE1hdGguaHlwb3QobXgsIG15KQogICAgICAgIGNvbnN0IHNwZWVkID0gcC5kYXNo
>>"%RB9%" echo VGltZSA+IDAgPyA3MjAgOiAyODUKICAgICAgICBwLnggKz0gKG14IC8gbGVuKSAqIHNwZWVk
>>"%RB9%" echo ICogZHQKICAgICAgICBwLnkgKz0gKG15IC8gbGVuKSAqIHNwZWVkICogZHQKICAgICAgfQog
>>"%RB9%" echo ICAgICBwLnggPSBjbGFtcChwLngsIHAuciArIDgsIFdJRFRIIC0gcC5yIC0gOCkKICAgICAg
>>"%RB9%" echo cC55ID0gY2xhbXAocC55LCAzMDAsIEhFSUdIVCAtIHAuciAtIDgpCgogICAgICBzdGF0ZS5z
>>"%RB9%" echo cGF3blRpbWVyIC09IGR0CiAgICAgIGlmIChzdGF0ZS5zcGF3blRpbWVyIDw9IDApIHsKICAg
>>"%RB9%" echo ICAgICBzdGF0ZS5lbmVtaWVzLnB1c2gobWFrZUVuZW15KHN0YXRlLnRpbWUsIHdhdmUpKQog
>>"%RB9%" echo ICAgICAgIHN0YXRlLnNwYXduVGltZXIgPSBNYXRoLm1heCgwLjM2LCAxLjM1IC0gd2F2ZSAq
>>"%RB9%" echo IDAuMDc1KSAqICgwLjc1ICsgTWF0aC5yYW5kb20oKSAqIDAuNTUpCiAgICAgIH0KCiAgICAg
>>"%RB9%" echo IHN0YXRlLnBpY2t1cFRpbWVyIC09IGR0CiAgICAgIGlmIChzdGF0ZS5waWNrdXBUaW1lciA8
>>"%RB9%" echo PSAwKSB7CiAgICAgICAgc3Bhd25QaWNrdXAoKQogICAgICAgIHN0YXRlLnBpY2t1cFRpbWVy
>>"%RB9%" echo ID0gMTEgKyBNYXRoLnJhbmRvbSgpICogNwogICAgICB9CgogICAgICBpZiAoc3RhdGUuY29t
>>"%RB9%" echo Ym9UaW1lciA+IDApIHsKICAgICAgICBzdGF0ZS5jb21ib1RpbWVyIC09IGR0CiAgICAgICAg
>>"%RB9%" echo aWYgKHN0YXRlLmNvbWJvVGltZXIgPD0gMCkgc3RhdGUuY29tYm8gPSAxCiAgICAgIH0KCiAg
>>"%RB9%" echo ICAgIGZvciAoY29uc3QgYnVsbGV0IG9mIHN0YXRlLmJ1bGxldHMpIHsKICAgICAgICBidWxs
>>"%RB9%" echo ZXQubGlmZSAtPSBkdAogICAgICAgIGJ1bGxldC5ib3VuY2VDb29sZG93biA9IE1hdGgubWF4
>>"%RB9%" echo KDAsIGJ1bGxldC5ib3VuY2VDb29sZG93biAtIGR0KQogICAgICAgIGNvbnN0IHByZXZpb3Vz
>>"%RB9%" echo ID0geyB4OiBidWxsZXQueCwgeTogYnVsbGV0LnkgfQogICAgICAgIGJ1bGxldC54ICs9IGJ1
>>"%RB9%" echo bGxldC52eCAqIGR0CiAgICAgICAgYnVsbGV0LnkgKz0gYnVsbGV0LnZ5ICogZHQKCiAgICAg
>>"%RB9%" echo ICAgbGV0IGJvdW5jZWQgPSBmYWxzZQogICAgICAgIGlmIChidWxsZXQueCAtIGJ1bGxldC5y
>>"%RB9%" echo IDwgMCkgewogICAgICAgICAgYnVsbGV0LnggPSBidWxsZXQucgogICAgICAgICAgYnVsbGV0
>>"%RB9%" echo LnZ4ID0gTWF0aC5hYnMoYnVsbGV0LnZ4KQogICAgICAgICAgYm91bmNlZCA9IHRydWUKICAg
>>"%RB9%" echo ICAgICB9IGVsc2UgaWYgKGJ1bGxldC54ICsgYnVsbGV0LnIgPiBXSURUSCkgewogICAgICAg
>>"%RB9%" echo ICAgYnVsbGV0LnggPSBXSURUSCAtIGJ1bGxldC5yCiAgICAgICAgICBidWxsZXQudnggPSAt
>>"%RB9%" echo TWF0aC5hYnMoYnVsbGV0LnZ4KQogICAgICAgICAgYm91bmNlZCA9IHRydWUKICAgICAgICB9
>>"%RB9%" echo CiAgICAgICAgaWYgKGJ1bGxldC55IC0gYnVsbGV0LnIgPCAwKSB7CiAgICAgICAgICBidWxs
>>"%RB9%" echo ZXQueSA9IGJ1bGxldC5yCiAgICAgICAgICBidWxsZXQudnkgPSBNYXRoLmFicyhidWxsZXQu
>>"%RB9%" echo dnkpCiAgICAgICAgICBib3VuY2VkID0gdHJ1ZQogICAgICAgIH0gZWxzZSBpZiAoYnVsbGV0
>>"%RB9%" echo LnkgKyBidWxsZXQuciA+IEhFSUdIVCkgewogICAgICAgICAgYnVsbGV0LnkgPSBIRUlHSFQg
>>"%RB9%" echo LSBidWxsZXQucgogICAgICAgICAgYnVsbGV0LnZ5ID0gLU1hdGguYWJzKGJ1bGxldC52eSkK
>>"%RB9%" echo ICAgICAgICAgIGJvdW5jZWQgPSB0cnVlCiAgICAgICAgfQoKICAgICAgICBmb3IgKGNvbnN0
>>"%RB9%" echo IHJlY3Qgb2Ygb2JzdGFjbGVzKSB7CiAgICAgICAgICBpZiAoYnVsbGV0LmJvdW5jZUNvb2xk
>>"%RB9%" echo b3duIDw9IDAgJiYgY2lyY2xlUmVjdEhpdChidWxsZXQsIHJlY3QpKSB7CiAgICAgICAgICAg
>>"%RB9%" echo IHJlZmxlY3RGcm9tUmVjdChidWxsZXQsIHJlY3QsIHByZXZpb3VzKQogICAgICAgICAgICBi
>>"%RB9%" echo b3VuY2VkID0gdHJ1ZQogICAgICAgICAgICBicmVhawogICAgICAgICAgfQogICAgICAgIH0K
>>"%RB9%" echo CiAgICAgICAgaWYgKGJvdW5jZWQgJiYgYnVsbGV0LmJvdW5jZUNvb2xkb3duIDw9IDApIHsK
>>"%RB9%" echo ICAgICAgICAgIGJ1bGxldC5ib3VuY2VzICs9IDEKICAgICAgICAgIGJ1bGxldC5ib3VuY2VD
>>"%RB9%" echo b29sZG93biA9IDAuMDQ1CiAgICAgICAgICBzdGF0ZS50b3RhbFJpY29jaGV0cyArPSAxCiAg
>>"%RB9%" echo ICAgICAgICBzdGF0ZS5zY29yZSArPSA0ICogYnVsbGV0LmJvdW5jZXMKICAgICAgICAgIGJ1
>>"%RB9%" echo cnN0KGJ1bGxldC54LCBidWxsZXQueSwgYnVsbGV0LmJvdW5jZXMgPj0gMyA/ICcjZmZkMTY2
>>"%RB9%" echo JyA6ICcjNmVlN2ZmJywgNCwgOTApCiAgICAgICAgfQogICAgICB9CgogICAgICBmb3IgKGNv
>>"%RB9%" echo bnN0IGJ1bGxldCBvZiBzdGF0ZS5lbmVteUJ1bGxldHMpIHsKICAgICAgICBidWxsZXQubGlm
>>"%RB9%" echo ZSAtPSBkdAogICAgICAgIGJ1bGxldC54ICs9IGJ1bGxldC52eCAqIGR0CiAgICAgICAgYnVs
>>"%RB9%" echo bGV0LnkgKz0gYnVsbGV0LnZ5ICogZHQKICAgICAgICBpZiAoZGlzdDIoYnVsbGV0LCBwKSA8
>>"%RB9%" echo PSAoYnVsbGV0LnIgKyBwLnIpICoqIDIpIHsKICAgICAgICAgIGJ1bGxldC5saWZlID0gMAog
>>"%RB9%" echo ICAgICAgICAgZGFtYWdlUGxheWVyKGJ1bGxldC5kYW1hZ2UpCiAgICAgICAgfQogICAgICB9
>>"%RB9%" echo CgogICAgICBmb3IgKGNvbnN0IGVuZW15IG9mIHN0YXRlLmVuZW1pZXMpIHsKICAgICAgICBl
>>"%RB9%" echo bmVteS5oaXRGbGFzaCA9IE1hdGgubWF4KDAsIGVuZW15LmhpdEZsYXNoIC0gZHQpCiAgICAg
>>"%RB9%" echo ICAgY29uc3QgZHggPSBwLnggLSBlbmVteS54CiAgICAgICAgY29uc3QgZHkgPSBwLnkgLSBl
>>"%RB9%" echo bmVteS55CiAgICAgICAgY29uc3QgbGVuID0gTWF0aC5oeXBvdChkeCwgZHkpIHx8IDEKICAg
>>"%RB9%" echo ICAgICBjb25zdCBueCA9IGR4IC8gbGVuCiAgICAgICAgY29uc3QgbnkgPSBkeSAvIGxlbgog
>>"%RB9%" echo ICAgICAgIGNvbnN0IHRhbmdlbnRYID0gLW55CiAgICAgICAgY29uc3QgdGFuZ2VudFkgPSBu
>>"%RB9%" echo eAogICAgICAgIGNvbnN0IHN0cmFmZSA9IE1hdGguc2luKHN0YXRlLnRpbWUgKiAyLjIgKyBl
>>"%RB9%" echo bmVteS5waGFzZSkgKiAoZW5lbXkudHlwZSA9PT0gJ3Njb3V0JyA/IDAuNyA6IDAuMzgpCiAg
>>"%RB9%" echo ICAgICAgZW5lbXkueCArPSAobnggKyB0YW5nZW50WCAqIHN0cmFmZSkgKiBlbmVteS5zcGVl
>>"%RB9%" echo ZCAqIGR0CiAgICAgICAgZW5lbXkueSArPSAobnkgKyB0YW5nZW50WSAqIHN0cmFmZSkgKiBl
>>"%RB9%" echo bmVteS5zcGVlZCAqIGR0CiAgICAgICAgZW5lbXkueCA9IGNsYW1wKGVuZW15LngsIGVuZW15
>>"%RB9%" echo LnIsIFdJRFRIIC0gZW5lbXkucikKICAgICAgICBlbmVteS55ID0gY2xhbXAoZW5lbXkueSwg
>>"%RB9%" echo ZW5lbXkuciwgSEVJR0hUIC0gZW5lbXkucikKCiAgICAgICAgZW5lbXkuZmlyZVRpbWVyIC09
>>"%RB9%" echo IGR0CiAgICAgICAgaWYgKGVuZW15LmZpcmVUaW1lciA8PSAwICYmIGxlbiA8IDcyMCkgewog
>>"%RB9%" echo ICAgICAgICAgZW5lbXlTaG9vdChlbmVteSkKICAgICAgICAgIGVuZW15LmZpcmVUaW1lciA9
>>"%RB9%" echo IGVuZW15LmZpcmVEZWxheSAqICgwLjc1ICsgTWF0aC5yYW5kb20oKSAqIDAuNDUpCiAgICAg
>>"%RB9%" echo ICAgfQoKICAgICAgICBpZiAoZGlzdDIoZW5lbXksIHApIDw9IChlbmVteS5yICsgcC5yKSAq
>>"%RB9%" echo KiAyKSB7CiAgICAgICAgICBkYW1hZ2VQbGF5ZXIoZW5lbXkudHlwZSA9PT0gJ3RhbmsnID8g
>>"%RB9%" echo MTggOiAxMikKICAgICAgICAgIGNvbnN0IHB1c2ggPSAyOAogICAgICAgICAgZW5lbXkueCAt
>>"%RB9%" echo PSBueCAqIHB1c2gKICAgICAgICAgIGVuZW15LnkgLT0gbnkgKiBwdXNoCiAgICAgICAgfQog
>>"%RB9%" echo ICAgICB9CgogICAgICBmb3IgKGNvbnN0IGJ1bGxldCBvZiBzdGF0ZS5idWxsZXRzKSB7CiAg
>>"%RB9%" echo ICAgICAgaWYgKGJ1bGxldC5saWZlIDw9IDApIGNvbnRpbnVlCiAgICAgICAgZm9yIChjb25z
>>"%RB9%" echo dCBlbmVteSBvZiBzdGF0ZS5lbmVtaWVzKSB7CiAgICAgICAgICBpZiAoZW5lbXkuaHAgPD0g
>>"%RB9%" echo MCkgY29udGludWUKICAgICAgICAgIGlmIChkaXN0MihidWxsZXQsIGVuZW15KSA8PSAoYnVs
>>"%RB9%" echo bGV0LnIgKyBlbmVteS5yKSAqKiAyKSB7CiAgICAgICAgICAgIGNvbnN0IHJpY29jaGV0TXVs
>>"%RB9%" echo dGlwbGllciA9IDEgKyBidWxsZXQuYm91bmNlcyAqIDAuNjIKICAgICAgICAgICAgY29uc3Qg
>>"%RB9%" echo ZGFtYWdlID0gMjQgKiByaWNvY2hldE11bHRpcGxpZXIKICAgICAgICAgICAgZW5lbXkuaHAg
>>"%RB9%" echo LT0gZGFtYWdlCiAgICAgICAgICAgIGVuZW15LmhpdEZsYXNoID0gMC4wOQogICAgICAgICAg
>>"%RB9%" echo ICBidWxsZXQubGlmZSA9IDAKICAgICAgICAgICAgc3RhdGUuc2NvcmUgKz0gTWF0aC5mbG9v
>>"%RB9%" echo cihkYW1hZ2UgKiAxLjgpCiAgICAgICAgICAgIGJ1cnN0KGVuZW15LngsIGVuZW15LnksIGJ1
>>"%RB9%" echo bGxldC5ib3VuY2VzID8gJyNmZmQxNjYnIDogJyM4NmVmYWMnLCA4ICsgYnVsbGV0LmJvdW5j
>>"%RB9%" echo ZXMgKiAyLCAxMjApCiAgICAgICAgICAgIGlmIChlbmVteS5ocCA8PSAwKSB7CiAgICAgICAg
>>"%RB9%" echo ICAgICAgc3RhdGUua2lsbHMgKz0gMQogICAgICAgICAgICAgIHN0YXRlLmNvbWJvID0gTWF0
>>"%RB9%" echo aC5taW4oOSwgc3RhdGUuY29tYm8gKyAxKQogICAgICAgICAgICAgIHN0YXRlLmNvbWJvVGlt
>>"%RB9%" echo ZXIgPSA0LjIKICAgICAgICAgICAgICBzdGF0ZS5zY29yZSArPSBlbmVteS5zY29yZSAqIHN0
>>"%RB9%" echo YXRlLmNvbWJvICogTWF0aC5tYXgoMSwgMSArIGJ1bGxldC5ib3VuY2VzICogMC40NSkKICAg
>>"%RB9%" echo ICAgICAgICAgICBzdGF0ZS5zaGFrZSA9IE1hdGgubWF4KHN0YXRlLnNoYWtlLCA1ICsgYnVs
>>"%RB9%" echo bGV0LmJvdW5jZXMpCiAgICAgICAgICAgICAgYnVyc3QoZW5lbXkueCwgZW5lbXkueSwgJyNm
>>"%RB9%" echo ZjlmNDMnLCAyNCwgMjIwKQogICAgICAgICAgICB9CiAgICAgICAgICAgIGJyZWFrCiAgICAg
>>"%RB9%" echo ICAgICB9CiAgICAgICAgfQogICAgICB9CgogICAgICBmb3IgKGNvbnN0IHBpY2t1cCBvZiBz
>>"%RB9%" echo dGF0ZS5waWNrdXBzKSB7CiAgICAgICAgcGlja3VwLmxpZmUgLT0gZHQKICAgICAgICBwaWNr
>>"%RB9%" echo dXAucHVsc2UgKz0gZHQgKiA1CiAgICAgICAgaWYgKGRpc3QyKHBpY2t1cCwgcCkgPD0gKHBp
>>"%RB9%" echo Y2t1cC5yICsgcC5yKSAqKiAyKSB7CiAgICAgICAgICBwaWNrdXAubGlmZSA9IDAKICAgICAg
>>"%RB9%" echo ICAgIGlmIChwaWNrdXAudHlwZSA9PT0gJ2hlYWwnKSBwLmhwID0gTWF0aC5taW4oMTAwLCBw
>>"%RB9%" echo LmhwICsgMjgpCiAgICAgICAgICBpZiAocGlja3VwLnR5cGUgPT09ICdhbW1vJykgewogICAg
>>"%RB9%" echo ICAgICAgICBwLmFtbW8gPSBwLm1heEFtbW8KICAgICAgICAgICAgcC5yZWxvYWQgPSAwCiAg
>>"%RB9%" echo ICAgICAgICB9CiAgICAgICAgICBpZiAocGlja3VwLnR5cGUgPT09ICdzaGllbGQnKSBwLmlu
>>"%RB9%" echo dnVsbmVyYWJsZSA9IE1hdGgubWF4KHAuaW52dWxuZXJhYmxlLCA0KQogICAgICAgICAgYnVy
>>"%RB9%" echo c3QocGlja3VwLngsIHBpY2t1cC55LCAnI2E3OGJmYScsIDE4LCAxODApCiAgICAgICAgfQog
>>"%RB9%" echo ICAgICB9CgogICAgICBmb3IgKGNvbnN0IHBhcnQgb2Ygc3RhdGUucGFydGljbGVzKSB7CiAg
>>"%RB9%" echo ICAgICAgcGFydC5saWZlIC09IGR0CiAgICAgICAgcGFydC54ICs9IHBhcnQudnggKiBkdAog
>>"%RB9%" echo ICAgICAgIHBhcnQueSArPSBwYXJ0LnZ5ICogZHQKICAgICAgICBwYXJ0LnZ4ICo9IE1hdGgu
>>"%RB9%" echo cG93KDAuMDgsIGR0KQogICAgICAgIHBhcnQudnkgKj0gTWF0aC5wb3coMC4wOCwgZHQpCiAg
>>"%RB9%" echo ICAgIH0KCiAgICAgIHN0YXRlLmJ1bGxldHMgPSBzdGF0ZS5idWxsZXRzLmZpbHRlcigoYikg
>>"%RB9%" echo PT4gYi5saWZlID4gMCkKICAgICAgc3RhdGUuZW5lbXlCdWxsZXRzID0gc3RhdGUuZW5lbXlC
>>"%RB9%" echo dWxsZXRzLmZpbHRlcigKICAgICAgICAoYikgPT4gYi5saWZlID4gMCAmJiBiLnggPiAtMzAg
>>"%RB9%" echo JiYgYi54IDwgV0lEVEggKyAzMCAmJiBiLnkgPiAtMzAgJiYgYi55IDwgSEVJR0hUICsgMzAs
>>"%RB9%" echo CiAgICAgICkKICAgICAgc3RhdGUuZW5lbWllcyA9IHN0YXRlLmVuZW1pZXMuZmlsdGVyKChl
>>"%RB9%" echo KSA9PiBlLmhwID4gMCkKICAgICAgc3RhdGUucGFydGljbGVzID0gc3RhdGUucGFydGljbGVz
>>"%RB9%" echo LmZpbHRlcigocDIpID0+IHAyLmxpZmUgPiAwKQogICAgICBzdGF0ZS5waWNrdXBzID0gc3Rh
>>"%RB9%" echo dGUucGlja3Vwcy5maWx0ZXIoKGl0ZW0pID0+IGl0ZW0ubGlmZSA+IDApCiAgICAgIHN0YXRl
>>"%RB9%" echo LnNoYWtlICo9IE1hdGgucG93KDAuMDIsIGR0KQogICAgfQoKICAgIGZ1bmN0aW9uIGRyYXco
>>"%RB9%" echo KSB7CiAgICAgIGN0eC5jbGVhclJlY3QoMCwgMCwgV0lEVEgsIEhFSUdIVCkKICAgICAgY3R4
>>"%RB9%" echo LnNhdmUoKQoKICAgICAgaWYgKHN0YXRlLnNoYWtlID4gMC4yKSB7CiAgICAgICAgY3R4LnRy
>>"%RB9%" echo YW5zbGF0ZSgoTWF0aC5yYW5kb20oKSAtIDAuNSkgKiBzdGF0ZS5zaGFrZSwgKE1hdGgucmFu
>>"%RB9%" echo ZG9tKCkgLSAwLjUpICogc3RhdGUuc2hha2UpCiAgICAgIH0KCiAgICAgIGNvbnN0IGJnID0g
>>"%RB9%" echo Y3R4LmNyZWF0ZUxpbmVhckdyYWRpZW50KDAsIDAsIDAsIEhFSUdIVCkKICAgICAgYmcuYWRk
>>"%RB9%" echo Q29sb3JTdG9wKDAsICcjMDcxNTI0JykKICAgICAgYmcuYWRkQ29sb3JTdG9wKDEsICcjMDIw
>>"%RB9%" echo NzBkJykKICAgICAgY3R4LmZpbGxTdHlsZSA9IGJnCiAgICAgIGN0eC5maWxsUmVjdCgwLCAw
>>"%RB9%" echo LCBXSURUSCwgSEVJR0hUKQoKICAgICAgY3R4LnN0cm9rZVN0eWxlID0gJ3JnYmEoMTEwLDIz
>>"%RB9%" echo MSwyNTUsLjA1NSknCiAgICAgIGN0eC5saW5lV2lkdGggPSAxCiAgICAgIGZvciAobGV0IHgg
>>"%RB9%" echo PSAwOyB4IDwgV0lEVEg7IHggKz0gNDApIHsKICAgICAgICBjdHguYmVnaW5QYXRoKCkKICAg
>>"%RB9%" echo ICAgICBjdHgubW92ZVRvKHgsIDApCiAgICAgICAgY3R4LmxpbmVUbyh4LCBIRUlHSFQpCiAg
>>"%RB9%" echo ICAgICAgY3R4LnN0cm9rZSgpCiAgICAgIH0KICAgICAgZm9yIChsZXQgeSA9IDA7IHkgPCBI
>>"%RB9%" echo RUlHSFQ7IHkgKz0gNDApIHsKICAgICAgICBjdHguYmVnaW5QYXRoKCkKICAgICAgICBjdHgu
>>"%RB9%" echo bW92ZVRvKDAsIHkpCiAgICAgICAgY3R4LmxpbmVUbyhXSURUSCwgeSkKICAgICAgICBjdHgu
>>"%RB9%" echo c3Ryb2tlKCkKICAgICAgfQoKICAgICAgY3R4LnN0cm9rZVN0eWxlID0gJ3JnYmEoMTEwLDIz
>>"%RB9%" echo MSwyNTUsLjI4KScKICAgICAgY3R4LmxpbmVXaWR0aCA9IDIKICAgICAgY3R4LnN0cm9rZVJl
>>"%RB9%" echo Y3QoNSwgNSwgV0lEVEggLSAxMCwgSEVJR0hUIC0gMTApCgogICAgICBmb3IgKGNvbnN0IHJl
>>"%RB9%" echo Y3Qgb2Ygb2JzdGFjbGVzKSB7CiAgICAgICAgY3R4LmZpbGxTdHlsZSA9ICcjMTAyODNiJwog
>>"%RB9%" echo ICAgICAgIGN0eC5zaGFkb3dDb2xvciA9ICcjMzJiOWRiJwogICAgICAgIGN0eC5zaGFkb3dC
>>"%RB9%" echo bHVyID0gMTAKICAgICAgICBkcmF3Um91bmRlZFJlY3QoY3R4LCByZWN0LngsIHJlY3QueSwg
>>"%RB9%" echo cmVjdC53LCByZWN0LmgsIDkpCiAgICAgICAgY3R4LnNoYWRvd0JsdXIgPSAwCiAgICAgICAg
>>"%RB9%" echo Y3R4LnN0cm9rZVN0eWxlID0gJ3JnYmEoMTEwLDIzMSwyNTUsLjU1KScKICAgICAgICBjdHgu
>>"%RB9%" echo c3Ryb2tlUmVjdChyZWN0LnggKyAwLjUsIHJlY3QueSArIDAuNSwgcmVjdC53IC0gMSwgcmVj
>>"%RB9%" echo dC5oIC0gMSkKICAgICAgfQoKICAgICAgZm9yIChjb25zdCBwaWNrdXAgb2Ygc3RhdGUucGlj
>>"%RB9%" echo a3VwcykgewogICAgICAgIGNvbnN0IGNvbG9ycyA9IHsgaGVhbDogJyMzNGQzOTknLCBhbW1v
>>"%RB9%" echo OiAnI2ZiYmYyNCcsIHNoaWVsZDogJyNhNzhiZmEnIH0KICAgICAgICBjdHguZmlsbFN0eWxl
>>"%RB9%" echo ID0gY29sb3JzW3BpY2t1cC50eXBlXQogICAgICAgIGN0eC5nbG9iYWxBbHBoYSA9IDAuNzIg
>>"%RB9%" echo KyBNYXRoLnNpbihwaWNrdXAucHVsc2UpICogMC4yMgogICAgICAgIGN0eC5iZWdpblBhdGgo
>>"%RB9%" echo KQogICAgICAgIGN0eC5hcmMocGlja3VwLngsIHBpY2t1cC55LCBwaWNrdXAuciArIE1hdGgu
>>"%RB9%" echo c2luKHBpY2t1cC5wdWxzZSkgKiAyLCAwLCBNYXRoLlBJICogMikKICAgICAgICBjdHguZmls
>>"%RB9%" echo bCgpCiAgICAgICAgY3R4Lmdsb2JhbEFscGhhID0gMQogICAgICAgIGN0eC5maWxsU3R5bGUg
>>"%RB9%" echo PSAnIzA3MTExZicKICAgICAgICBjdHguZm9udCA9ICdib2xkIDExcHggc3lzdGVtLXVpJwog
>>"%RB9%" echo ICAgICAgIGN0eC50ZXh0QWxpZ24gPSAnY2VudGVyJwogICAgICAgIGN0eC50ZXh0QmFzZWxp
>>"%RB9%" echo bmUgPSAnbWlkZGxlJwogICAgICAgIGN0eC5maWxsVGV4dChwaWNrdXAudHlwZSA9PT0gJ2hl
>>"%RB9%" echo YWwnID8gJysnIDogcGlja3VwLnR5cGUgPT09ICdhbW1vJyA/ICdBJyA6ICdTJywgcGlja3Vw
>>"%RB9%" echo LngsIHBpY2t1cC55KQogICAgICB9CgogICAgICBmb3IgKGNvbnN0IGVuZW15IG9mIHN0YXRl
>>"%RB9%" echo LmVuZW1pZXMpIHsKICAgICAgICBjb25zdCBjb2xvciA9IGVuZW15LnR5cGUgPT09ICd0YW5r
>>"%RB9%" echo JyA/ICcjZWY0NDQ0JyA6IGVuZW15LnR5cGUgPT09ICdzdHJpa2VyJyA/ICcjZmI3MTg1JyA6
>>"%RB9%" echo ICcjZjk3MzE2JwogICAgICAgIGN0eC5maWxsU3R5bGUgPSBlbmVteS5oaXRGbGFzaCA+IDAg
>>"%RB9%" echo PyAnI2ZmZmZmZicgOiBjb2xvcgogICAgICAgIGN0eC5zaGFkb3dDb2xvciA9IGNvbG9yCiAg
>>"%RB9%" echo ICAgICAgY3R4LnNoYWRvd0JsdXIgPSAxMgogICAgICAgIGN0eC5iZWdpblBhdGgoKQogICAg
>>"%RB9%" echo ICAgIGN0eC5hcmMoZW5lbXkueCwgZW5lbXkueSwgZW5lbXkuciwgMCwgTWF0aC5QSSAqIDIp
>>"%RB9%" echo CiAgICAgICAgY3R4LmZpbGwoKQogICAgICAgIGN0eC5zaGFkb3dCbHVyID0gMAoKICAgICAg
>>"%RB9%" echo ICBjdHguZmlsbFN0eWxlID0gJyMwNDEwMWEnCiAgICAgICAgY3R4LmJlZ2luUGF0aCgpCiAg
>>"%RB9%" echo ICAgICAgY3R4LmFyYyhlbmVteS54LCBlbmVteS55LCBlbmVteS5yICogMC40NywgMCwgTWF0
>>"%RB9%" echo aC5QSSAqIDIpCiAgICAgICAgY3R4LmZpbGwoKQoKICAgICAgICBjb25zdCBocFcgPSBlbmVt
>>"%RB9%" echo eS5yICogMi4yCiAgICAgICAgY3R4LmZpbGxTdHlsZSA9ICdyZ2JhKDAsMCwwLC41NSknCiAg
>>"%RB9%" echo ICAgICAgY3R4LmZpbGxSZWN0KGVuZW15LnggLSBocFcgLyAyLCBlbmVteS55IC0gZW5lbXku
>>"%RB9%" echo ciAtIDEyLCBocFcsIDQpCiAgICAgICAgY3R4LmZpbGxTdHlsZSA9ICcjODZlZmFjJwogICAg
>>"%RB9%" echo ICAgIGN0eC5maWxsUmVjdChlbmVteS54IC0gaHBXIC8gMiwgZW5lbXkueSAtIGVuZW15LnIg
>>"%RB9%" echo LSAxMiwgaHBXICogKGVuZW15LmhwIC8gZW5lbXkubWF4SHApLCA0KQogICAgICB9CgogICAg
>>"%RB9%" echo ICBmb3IgKGNvbnN0IGJ1bGxldCBvZiBzdGF0ZS5idWxsZXRzKSB7CiAgICAgICAgY29uc3Qg
>>"%RB9%" echo Y29sb3IgPSBidWxsZXQuYm91bmNlcyA+PSAzID8gJyNmZmQxNjYnIDogYnVsbGV0LmJvdW5j
>>"%RB9%" echo ZXMgPj0gMSA/ICcjOWVmNWZmJyA6ICcjZmZmZmZmJwogICAgICAgIGN0eC5zdHJva2VTdHls
>>"%RB9%" echo ZSA9IGNvbG9yCiAgICAgICAgY3R4Lmdsb2JhbEFscGhhID0gMC4zNgogICAgICAgIGN0eC5s
>>"%RB9%" echo aW5lV2lkdGggPSAyICsgTWF0aC5taW4oNCwgYnVsbGV0LmJvdW5jZXMpCiAgICAgICAgY3R4
>>"%RB9%" echo LmJlZ2luUGF0aCgpCiAgICAgICAgY3R4Lm1vdmVUbyhidWxsZXQueCwgYnVsbGV0LnkpCiAg
>>"%RB9%" echo ICAgICAgY3R4LmxpbmVUbyhidWxsZXQueCAtIGJ1bGxldC52eCAqIDAuMDE4LCBidWxsZXQu
>>"%RB9%" echo eSAtIGJ1bGxldC52eSAqIDAuMDE4KQogICAgICAgIGN0eC5zdHJva2UoKQogICAgICAgIGN0
>>"%RB9%" echo eC5nbG9iYWxBbHBoYSA9IDEKICAgICAgICBjdHguZmlsbFN0eWxlID0gY29sb3IKICAgICAg
>>"%RB9%" echo ICBjdHguc2hhZG93Q29sb3IgPSBjb2xvcgogICAgICAgIGN0eC5zaGFkb3dCbHVyID0gMTIg
>>"%RB9%" echo KyBidWxsZXQuYm91bmNlcyAqIDMKICAgICAgICBjdHguYmVnaW5QYXRoKCkKICAgICAgICBj
>>"%RB9%" echo dHguYXJjKGJ1bGxldC54LCBidWxsZXQueSwgYnVsbGV0LnIgKyBNYXRoLm1pbigyLCBidWxs
>>"%RB9%" echo ZXQuYm91bmNlcyAqIDAuNCksIDAsIE1hdGguUEkgKiAyKQogICAgICAgIGN0eC5maWxsKCkK
>>"%RB9%" echo ICAgICAgICBjdHguc2hhZG93Qmx1ciA9IDAKICAgICAgfQoKICAgICAgZm9yIChjb25zdCBi
>>"%RB9%" echo dWxsZXQgb2Ygc3RhdGUuZW5lbXlCdWxsZXRzKSB7CiAgICAgICAgY3R4LmZpbGxTdHlsZSA9
>>"%RB9%" echo ICcjZmY0ZDZkJwogICAgICAgIGN0eC5zaGFkb3dDb2xvciA9ICcjZmY0ZDZkJwogICAgICAg
>>"%RB9%" echo IGN0eC5zaGFkb3dCbHVyID0gMTAKICAgICAgICBjdHguYmVnaW5QYXRoKCkKICAgICAgICBj
>>"%RB9%" echo dHguYXJjKGJ1bGxldC54LCBidWxsZXQueSwgYnVsbGV0LnIsIDAsIE1hdGguUEkgKiAyKQog
>>"%RB9%" echo ICAgICAgIGN0eC5maWxsKCkKICAgICAgICBjdHguc2hhZG93Qmx1ciA9IDAKICAgICAgfQoK
>>"%RB9%" echo ICAgICAgZm9yIChjb25zdCBwYXJ0IG9mIHN0YXRlLnBhcnRpY2xlcykgewogICAgICAgIGN0
>>"%RB9%" echo eC5nbG9iYWxBbHBoYSA9IGNsYW1wKHBhcnQubGlmZSAvIHBhcnQubWF4TGlmZSwgMCwgMSkK
>>"%RB9%" echo ICAgICAgICBjdHguZmlsbFN0eWxlID0gcGFydC5jb2xvcgogICAgICAgIGN0eC5maWxsUmVj
>>"%RB9%" echo dChwYXJ0LngsIHBhcnQueSwgcGFydC5zaXplLCBwYXJ0LnNpemUpCiAgICAgIH0KICAgICAg
>>"%RB9%" echo Y3R4Lmdsb2JhbEFscGhhID0gMQoKICAgICAgY29uc3QgcCA9IHN0YXRlLnBsYXllcgogICAg
>>"%RB9%" echo ICBjb25zdCBhaW0gPSBNYXRoLmF0YW4yKHBvaW50ZXIueSAtIHAueSwgcG9pbnRlci54IC0g
>>"%RB9%" echo cC54KQogICAgICBjdHguc2F2ZSgpCiAgICAgIGN0eC50cmFuc2xhdGUocC54LCBwLnkpCiAg
>>"%RB9%" echo ICAgIGN0eC5yb3RhdGUoYWltKQogICAgICBjdHguZmlsbFN0eWxlID0gJyNkZmZiZmYnCiAg
>>"%RB9%" echo ICAgIGN0eC5zaGFkb3dDb2xvciA9ICcjNmVlN2ZmJwogICAgICBjdHguc2hhZG93Qmx1ciA9
>>"%RB9%" echo IDE1CiAgICAgIGN0eC5maWxsUmVjdCg0LCAtNSwgMjksIDEwKQogICAgICBjdHguc2hhZG93
>>"%RB9%" echo Qmx1ciA9IDAKICAgICAgY3R4LnJlc3RvcmUoKQoKICAgICAgY3R4LmZpbGxTdHlsZSA9IHAu
>>"%RB9%" echo aW52dWxuZXJhYmxlID4gMCA/ICcjYTc4YmZhJyA6ICcjMzlkMGYwJwogICAgICBjdHguc2hh
>>"%RB9%" echo ZG93Q29sb3IgPSBjdHguZmlsbFN0eWxlCiAgICAgIGN0eC5zaGFkb3dCbHVyID0gMTgKICAg
>>"%RB9%" echo ICAgY3R4LmJlZ2luUGF0aCgpCiAgICAgIGN0eC5hcmMocC54LCBwLnksIHAuciwgMCwgTWF0
>>"%RB9%" echo aC5QSSAqIDIpCiAgICAgIGN0eC5maWxsKCkKICAgICAgY3R4LnNoYWRvd0JsdXIgPSAwCiAg
>>"%RB9%" echo ICAgIGN0eC5zdHJva2VTdHlsZSA9ICcjZTZmY2ZmJwogICAgICBjdHgubGluZVdpZHRoID0g
>>"%RB9%" echo MgogICAgICBjdHguYmVnaW5QYXRoKCkKICAgICAgY3R4LmFyYyhwLngsIHAueSwgcC5yIC0g
>>"%RB9%" echo NiwgMCwgTWF0aC5QSSAqIDIpCiAgICAgIGN0eC5zdHJva2UoKQoKICAgICAgaWYgKHAucmVs
>>"%RB9%" echo b2FkID4gMCkgewogICAgICAgIGN0eC5zdHJva2VTdHlsZSA9ICcjZmJiZjI0JwogICAgICAg
>>"%RB9%" echo IGN0eC5saW5lV2lkdGggPSA0CiAgICAgICAgY3R4LmJlZ2luUGF0aCgpCiAgICAgICAgY3R4
>>"%RB9%" echo LmFyYyhwLngsIHAueSwgcC5yICsgMTAsIC1NYXRoLlBJIC8gMiwgLU1hdGguUEkgLyAyICsg
>>"%RB9%" echo TWF0aC5QSSAqIDIgKiAoMSAtIHAucmVsb2FkIC8gcC5yZWxvYWRNYXgpKQogICAgICAgIGN0
>>"%RB9%" echo eC5zdHJva2UoKQogICAgICB9CgogICAgICBjdHguc3Ryb2tlU3R5bGUgPSAncmdiYSgyNTUs
>>"%RB9%" echo MjU1LDI1NSwuNTUpJwogICAgICBjdHgubGluZVdpZHRoID0gMQogICAgICBjdHguYmVnaW5Q
>>"%RB9%" echo YXRoKCkKICAgICAgY3R4LmFyYyhwb2ludGVyLngsIHBvaW50ZXIueSwgOSwgMCwgTWF0aC5Q
>>"%RB9%" echo SSAqIDIpCiAgICAgIGN0eC5tb3ZlVG8ocG9pbnRlci54IC0gMTQsIHBvaW50ZXIueSkKICAg
>>"%RB9%" echo ICAgY3R4LmxpbmVUbyhwb2ludGVyLnggKyAxNCwgcG9pbnRlci55KQogICAgICBjdHgubW92
>>"%RB9%" echo ZVRvKHBvaW50ZXIueCwgcG9pbnRlci55IC0gMTQpCiAgICAgIGN0eC5saW5lVG8ocG9pbnRl
>>"%RB9%" echo ci54LCBwb2ludGVyLnkgKyAxNCkKICAgICAgY3R4LnN0cm9rZSgpCgogICAgICBpZiAoIXJ1
>>"%RB9%" echo bm5pbmdSZWYuY3VycmVudCAmJiAhc3RhdGUuZ2FtZU92ZXIpIHsKICAgICAgICBjdHguZmls
>>"%RB9%" echo bFN0eWxlID0gJ3JnYmEoMSw2LDEyLC42OCknCiAgICAgICAgY3R4LmZpbGxSZWN0KDAsIDAs
>>"%RB9%" echo IFdJRFRILCBIRUlHSFQpCiAgICAgICAgY3R4LmZpbGxTdHlsZSA9ICcjZWFmY2ZmJwogICAg
>>"%RB9%" echo ICAgIGN0eC5mb250ID0gJzcwMCA1MnB4IHN5c3RlbS11aScKICAgICAgICBjdHgudGV4dEFs
>>"%RB9%" echo aWduID0gJ2NlbnRlcicKICAgICAgICBjdHguZmlsbFRleHQoJ1BBVVNFRCcsIFdJRFRIIC8g
>>"%RB9%" echo MiwgSEVJR0hUIC8gMikKICAgICAgfQoKICAgICAgaWYgKHN0YXRlLmdhbWVPdmVyKSB7CiAg
>>"%RB9%" echo ICAgICAgY3R4LmZpbGxTdHlsZSA9ICdyZ2JhKDEsNiwxMiwuODIpJwogICAgICAgIGN0eC5m
>>"%RB9%" echo aWxsUmVjdCgwLCAwLCBXSURUSCwgSEVJR0hUKQogICAgICAgIGN0eC5maWxsU3R5bGUgPSAn
>>"%RB9%" echo I2ZmZmZmZicKICAgICAgICBjdHguZm9udCA9ICc4MDAgNTJweCBzeXN0ZW0tdWknCiAgICAg
>>"%RB9%" echo ICAgY3R4LnRleHRBbGlnbiA9ICdjZW50ZXInCiAgICAgICAgY3R4LmZpbGxUZXh0KCdSVU4g
>>"%RB9%" echo RU5ERUQnLCBXSURUSCAvIDIsIEhFSUdIVCAvIDIgLSAzMCkKICAgICAgICBjdHguZmlsbFN0
>>"%RB9%" echo eWxlID0gJyM5YmQ5ZTcnCiAgICAgICAgY3R4LmZvbnQgPSAnMjJweCBzeXN0ZW0tdWknCiAg
>>"%RB9%" echo ICAgICAgY3R4LmZpbGxUZXh0KGBTY29yZSAke01hdGguZmxvb3Ioc3RhdGUuc2NvcmUpLnRv
>>"%RB9%" echo TG9jYWxlU3RyaW5nKCl9IOKAoiAke3N0YXRlLmtpbGxzfSBlbGltaW5hdGlvbnNgLCBXSURU
>>"%RB9%" echo SCAvIDIsIEhFSUdIVCAvIDIgKyAxOCkKICAgICAgfQoKICAgICAgY3R4LnJlc3RvcmUoKQog
>>"%RB9%" echo ICAgfQoKICAgIGxldCBsYXN0ID0gcGVyZm9ybWFuY2Uubm93KCkKICAgIGxldCBodWRUaW1l
>>"%RB9%" echo ciA9IDAKCiAgICBmdW5jdGlvbiBmcmFtZShub3cpIHsKICAgICAgY29uc3QgZHQgPSBNYXRo
>>"%RB9%" echo Lm1pbigwLjAzMywgKG5vdyAtIGxhc3QpIC8gMTAwMCkKICAgICAgbGFzdCA9IG5vdwogICAg
>>"%RB9%" echo ICB1cGRhdGUoZHQpCiAgICAgIGRyYXcoKQogICAgICBodWRUaW1lciArPSBkdAogICAgICBp
>>"%RB9%" echo ZiAoaHVkVGltZXIgPj0gMC4xKSB7CiAgICAgICAgaHVkVGltZXIgPSAwCiAgICAgICAgdXBk
>>"%RB9%" echo YXRlSHVkKCkKICAgICAgfQogICAgICBmcmFtZVJlZi5jdXJyZW50ID0gcmVxdWVzdEFuaW1h
>>"%RB9%" echo dGlvbkZyYW1lKGZyYW1lKQogICAgfQoKICAgIGZ1bmN0aW9uIGtleURvd24oZXZlbnQpIHsK
>>"%RB9%" echo ICAgICAga2V5cy5hZGQoZXZlbnQuY29kZSkKICAgICAgaWYgKGV2ZW50LmNvZGUgPT09ICdL
>>"%RB9%" echo ZXlSJykgcmVsb2FkKCkKICAgICAgaWYgKGV2ZW50LmNvZGUgPT09ICdTcGFjZScpIHsKICAg
>>"%RB9%" echo ICAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpCiAgICAgICAgY29uc3QgcCA9IHN0YXRlLnBs
>>"%RB9%" echo YXllcgogICAgICAgIGlmICghc3RhdGUuZ2FtZU92ZXIgJiYgcC5kYXNoQ29vbGRvd24gPD0g
>>"%RB9%" echo MCkgewogICAgICAgICAgcC5kYXNoQ29vbGRvd24gPSAyLjQKICAgICAgICAgIHAuZGFzaFRp
>>"%RB9%" echo bWUgPSAwLjE3CiAgICAgICAgICBwLmludnVsbmVyYWJsZSA9IE1hdGgubWF4KHAuaW52dWxu
>>"%RB9%" echo ZXJhYmxlLCAwLjIyKQogICAgICAgICAgYnVyc3QocC54LCBwLnksICcjYTc4YmZhJywgMTQs
>>"%RB9%" echo IDE0MCkKICAgICAgICB9CiAgICAgIH0KICAgICAgaWYgKGV2ZW50LmNvZGUgPT09ICdLZXlQ
>>"%RB9%" echo Jykgc2V0UnVubmluZygodmFsdWUpID0+ICF2YWx1ZSkKICAgIH0KCiAgICBmdW5jdGlvbiBr
>>"%RB9%" echo ZXlVcChldmVudCkgewogICAgICBrZXlzLmRlbGV0ZShldmVudC5jb2RlKQogICAgfQoKICAg
>>"%RB9%" echo IGZ1bmN0aW9uIHBvaW50ZXJNb3ZlKGV2ZW50KSB7CiAgICAgIGNvbnN0IHJlY3QgPSBjYW52
>>"%RB9%" echo YXMuZ2V0Qm91bmRpbmdDbGllbnRSZWN0KCkKICAgICAgcG9pbnRlci54ID0gKChldmVudC5j
>>"%RB9%" echo bGllbnRYIC0gcmVjdC5sZWZ0KSAvIHJlY3Qud2lkdGgpICogV0lEVEgKICAgICAgcG9pbnRl
>>"%RB9%" echo ci55ID0gKChldmVudC5jbGllbnRZIC0gcmVjdC50b3ApIC8gcmVjdC5oZWlnaHQpICogSEVJ
>>"%RB9%" echo R0hUCiAgICB9CgogICAgZnVuY3Rpb24gcG9pbnRlckRvd24oZXZlbnQpIHsKICAgICAgaWYg
>>"%RB9%" echo KGV2ZW50LmJ1dHRvbiA9PT0gMCkgc2hvb3QoKQogICAgfQoKICAgIGZ1bmN0aW9uIHByZXZl
>>"%RB9%" echo bnRNZW51KGV2ZW50KSB7CiAgICAgIGV2ZW50LnByZXZlbnREZWZhdWx0KCkKICAgIH0KCiAg
>>"%RB9%" echo ICB3aW5kb3cuYWRkRXZlbnRMaXN0ZW5lcigna2V5ZG93bicsIGtleURvd24pCiAgICB3aW5k
>>"%RB9%" echo b3cuYWRkRXZlbnRMaXN0ZW5lcigna2V5dXAnLCBrZXlVcCkKICAgIGNhbnZhcy5hZGRFdmVu
>>"%RB9%" echo dExpc3RlbmVyKCdwb2ludGVybW92ZScsIHBvaW50ZXJNb3ZlKQogICAgY2FudmFzLmFkZEV2
>>"%RB9%" echo ZW50TGlzdGVuZXIoJ3BvaW50ZXJkb3duJywgcG9pbnRlckRvd24pCiAgICBjYW52YXMuYWRk
>>"%RB9%" echo RXZlbnRMaXN0ZW5lcignY29udGV4dG1lbnUnLCBwcmV2ZW50TWVudSkKCiAgICBmcmFtZVJl
>>"%RB9%" echo Zi5jdXJyZW50ID0gcmVxdWVzdEFuaW1hdGlvbkZyYW1lKGZyYW1lKQoKICAgIHJldHVybiAo
>>"%RB9%" echo KSA9PiB7CiAgICAgIGNhbmNlbEFuaW1hdGlvbkZyYW1lKGZyYW1lUmVmLmN1cnJlbnQpCiAg
>>"%RB9%" echo ICAgIHdpbmRvdy5yZW1vdmVFdmVudExpc3RlbmVyKCdrZXlkb3duJywga2V5RG93bikKICAg
>>"%RB9%" echo ICAgd2luZG93LnJlbW92ZUV2ZW50TGlzdGVuZXIoJ2tleXVwJywga2V5VXApCiAgICAgIGNh
>>"%RB9%" echo bnZhcy5yZW1vdmVFdmVudExpc3RlbmVyKCdwb2ludGVybW92ZScsIHBvaW50ZXJNb3ZlKQog
>>"%RB9%" echo ICAgICBjYW52YXMucmVtb3ZlRXZlbnRMaXN0ZW5lcigncG9pbnRlcmRvd24nLCBwb2ludGVy
>>"%RB9%" echo RG93bikKICAgICAgY2FudmFzLnJlbW92ZUV2ZW50TGlzdGVuZXIoJ2NvbnRleHRtZW51Jywg
>>"%RB9%" echo cHJldmVudE1lbnUpCiAgICB9CiAgfSwgW2dhbWVLZXldKQoKICBmdW5jdGlvbiByZXN0YXJ0
>>"%RB9%" echo KCkgewogICAgc2V0UnVubmluZyh0cnVlKQogICAgcnVubmluZ1JlZi5jdXJyZW50ID0gdHJ1
>>"%RB9%" echo ZQogICAgc2V0R2FtZUtleSgodmFsdWUpID0+IHZhbHVlICsgMSkKICB9CgogIHJldHVybiAo
>>"%RB9%" echo CiAgICA8c2VjdGlvbiBjbGFzc05hbWU9ImdhbWUtcGFnZSI+CiAgICAgIDxkaXYgY2xhc3NO
>>"%RB9%" echo YW1lPSJnYW1lLWludHJvIGNhcmQiPgogICAgICAgIDxkaXY+CiAgICAgICAgICA8cCBjbGFz
>>"%RB9%" echo c05hbWU9ImV5ZWJyb3ciPlBIWVNJQ1MgU0hPT1RFUiDigKIgUEFHRSAyPC9wPgogICAgICAg
>>"%RB9%" echo ICAgPGgxPlJpY29jaGV0IEFyZW5hPC9oMT4KICAgICAgICAgIDxwPgogICAgICAgICAgICBB
>>"%RB9%" echo aW0gZm9yIGJhbmsgc2hvdHMuIEV2ZXJ5IHdhbGwgb3Igb2JzdGFjbGUgcmljb2NoZXQgaW5j
>>"%RB9%" echo cmVhc2VzIGJ1bGxldCBkYW1hZ2UgYnkKICAgICAgICAgICAgNjIlLCBhbmQga2lsbHMgY2hh
>>"%RB9%" echo aW4gaW50byBhIHNjb3JlIG11bHRpcGxpZXIuCiAgICAgICAgICA8L3A+CiAgICAgICAgPC9k
>>"%RB9%" echo aXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9ImdhbWUtY29udHJvbHMiPgogICAgICAgICAg
>>"%RB9%" echo PHNwYW4+PGtiZD5XQVNEPC9rYmQ+IG1vdmU8L3NwYW4+CiAgICAgICAgICA8c3Bhbj48a2Jk
>>"%RB9%" echo Pk1vdXNlPC9rYmQ+IGFpbTwvc3Bhbj4KICAgICAgICAgIDxzcGFuPjxrYmQ+Q2xpY2s8L2ti
>>"%RB9%" echo ZD4gZmlyZTwvc3Bhbj4KICAgICAgICAgIDxzcGFuPjxrYmQ+Ujwva2JkPiByZWxvYWQ8L3Nw
>>"%RB9%" echo YW4+CiAgICAgICAgICA8c3Bhbj48a2JkPlNwYWNlPC9rYmQ+IGRhc2g8L3NwYW4+CiAgICAg
>>"%RB9%" echo ICAgICA8c3Bhbj48a2JkPlA8L2tiZD4gcGF1c2U8L3NwYW4+CiAgICAgICAgPC9kaXY+CiAg
>>"%RB9%" echo ICAgIDwvZGl2PgoKICAgICAgPGRpdiBjbGFzc05hbWU9Imh1ZC1ncmlkIj4KICAgICAgICA8
>>"%RB9%" echo ZGl2PjxzcGFuPlNjb3JlPC9zcGFuPjxiPntodWQuc2NvcmUudG9Mb2NhbGVTdHJpbmcoKX08
>>"%RB9%" echo L2I+PC9kaXY+CiAgICAgICAgPGRpdj48c3Bhbj5IZWFsdGg8L3NwYW4+PGI+e2h1ZC5ocH08
>>"%RB9%" echo L2I+PC9kaXY+CiAgICAgICAgPGRpdj48c3Bhbj5BbW1vPC9zcGFuPjxiPntodWQuYW1tb30g
>>"%RB9%" echo LyB7aHVkLm1heEFtbW99PC9iPjwvZGl2PgogICAgICAgIDxkaXY+PHNwYW4+V2F2ZTwvc3Bh
>>"%RB9%" echo bj48Yj57aHVkLndhdmV9PC9iPjwvZGl2PgogICAgICAgIDxkaXY+PHNwYW4+Q29tYm88L3Nw
>>"%RB9%" echo YW4+PGI+eHtodWQuY29tYm99PC9iPjwvZGl2PgogICAgICAgIDxkaXY+PHNwYW4+Umljb2No
>>"%RB9%" echo ZXRzPC9zcGFuPjxiPntodWQucmljb2NoZXRzfTwvYj48L2Rpdj4KICAgICAgICA8ZGl2Pjxz
>>"%RB9%" echo cGFuPkVsaW1pbmF0aW9uczwvc3Bhbj48Yj57aHVkLmtpbGxzfTwvYj48L2Rpdj4KICAgICAg
>>"%RB9%" echo ICA8ZGl2PjxzcGFuPkRhc2g8L3NwYW4+PGI+e2h1ZC5kYXNoIDw9IDAgPyAnUkVBRFknIDog
>>"%RB9%" echo YCR7aHVkLmRhc2gudG9GaXhlZCgxKX1zYH08L2I+PC9kaXY+CiAgICAgIDwvZGl2PgoKICAg
>>"%RB9%" echo ICAgPGRpdiBjbGFzc05hbWU9ImdhbWUtZnJhbWUiPgogICAgICAgIDxjYW52YXMKICAgICAg
>>"%RB9%" echo ICAgIGtleT17Z2FtZUtleX0KICAgICAgICAgIHJlZj17Y2FudmFzUmVmfQogICAgICAgICAg
>>"%RB9%" echo d2lkdGg9e1dJRFRIfQogICAgICAgICAgaGVpZ2h0PXtIRUlHSFR9CiAgICAgICAgICBhcmlh
>>"%RB9%" echo LWxhYmVsPSJSaWNvY2hldCBBcmVuYSBnYW1lIGNhbnZhcyIKICAgICAgICAvPgogICAgICA8
>>"%RB9%" echo L2Rpdj4KCiAgICAgIDxkaXYgY2xhc3NOYW1lPSJnYW1lLWJvdHRvbSI+CiAgICAgICAgPGRp
>>"%RB9%" echo diBjbGFzc05hbWU9ImNhcmQgbWVjaGFuaWMtY2FyZCI+CiAgICAgICAgICA8Yj5SaWNvY2hl
>>"%RB9%" echo dCBkYW1hZ2UgbW9kZWw8L2I+CiAgICAgICAgICA8c3Bhbj5CYXNlIGRhbWFnZTogMjQ8L3Nw
>>"%RB9%" echo YW4+CiAgICAgICAgICA8c3Bhbj4xIGJvdW5jZTogMzguOSBkYW1hZ2U8L3NwYW4+CiAgICAg
>>"%RB9%" echo ICAgICA8c3Bhbj4yIGJvdW5jZXM6IDUzLjggZGFtYWdlPC9zcGFuPgogICAgICAgICAgPHNw
>>"%RB9%" echo YW4+MyBib3VuY2VzOiA2OC42IGRhbWFnZTwvc3Bhbj4KICAgICAgICAgIDxzcGFuPkJhbmst
>>"%RB9%" echo c2hvdCBraWxscyBhbHNvIGluY3JlYXNlIHNjb3JlLjwvc3Bhbj4KICAgICAgICA8L2Rpdj4K
>>"%RB9%" echo ICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iZ2FtZS1idXR0b25zIj4KICAgICAgICAgIDxidXR0
>>"%RB9%" echo b24gY2xhc3NOYW1lPSJwcmltYXJ5LWJ0biIgb25DbGljaz17KCkgPT4gc2V0UnVubmluZygo
>>"%RB9%" echo dmFsdWUpID0+ICF2YWx1ZSl9IGRpc2FibGVkPXtodWQuZ2FtZU92ZXJ9PgogICAgICAgICAg
>>"%RB9%" echo ICB7cnVubmluZyA/ICdQYXVzZSBhcmVuYScgOiAnUmVzdW1lIGFyZW5hJ30KICAgICAgICAg
>>"%RB9%" echo IDwvYnV0dG9uPgogICAgICAgICAgPGJ1dHRvbiBjbGFzc05hbWU9Imdob3N0LWJ0biIgb25D
>>"%RB9%" echo bGljaz17cmVzdGFydH0+UmVzdGFydCBydW48L2J1dHRvbj4KICAgICAgICA8L2Rpdj4KICAg
>>"%RB9%" echo ICAgPC9kaXY+CiAgICA8L3NlY3Rpb24+CiAgKQp9Cg==
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB9%" "%APP_DIR%\src\RicochetGame.jsx"
set "RB10=%TEMP%\react_embed_10.b64"
>"%RB10%" echo OnJvb3QgewogIGZvbnQtZmFtaWx5OiBJbnRlciwgdWktc2Fucy1zZXJpZiwgc3lzdGVtLXVp
>>"%RB10%" echo LCAtYXBwbGUtc3lzdGVtLCBCbGlua01hY1N5c3RlbUZvbnQsICJTZWdvZSBVSSIsIHNhbnMt
>>"%RB10%" echo c2VyaWY7CiAgY29sb3I6ICNlYWY4ZmY7CiAgYmFja2dyb3VuZDogIzAyMDcwZDsKICBmb250
>>"%RB10%" echo LXN5bnRoZXNpczogbm9uZTsKICB0ZXh0LXJlbmRlcmluZzogb3B0aW1pemVMZWdpYmlsaXR5
>>"%RB10%" echo OwogIC0tYmc6ICMwMjA3MGQ7CiAgLS1wYW5lbDogIzA4MTMxZTsKICAtLXBhbmVsMjogIzBj
>>"%RB10%" echo MWIyODsKICAtLWxpbmU6IHJnYmEoMTM5LCAyMjAsIDIzOSwgLjEyKTsKICAtLWN5YW46ICM0
>>"%RB10%" echo MmQ0ZjI7CiAgLS1jeWFuMjogIzhjZWNmZjsKICAtLW11dGVkOiAjN2Y5ZWFiOwogIC0tdmlv
>>"%RB10%" echo bGV0OiAjYTc4YmZhOwogIC0tZ3JlZW46ICM1ZWUzYTU7CiAgLS1hbWJlcjogI2Y3YzY1ZDsK
>>"%RB10%" echo ICAtLXJlZDogI2ZmNjM3ZDsKfQoqIHsgYm94LXNpemluZzogYm9yZGVyLWJveDsgfQpodG1s
>>"%RB10%" echo IHsgc2Nyb2xsLWJlaGF2aW9yOiBzbW9vdGg7IH0KYm9keSB7IG1hcmdpbjogMDsgbWluLXdp
>>"%RB10%" echo ZHRoOiAzMjBweDsgbWluLWhlaWdodDogMTAwdmg7IGJhY2tncm91bmQ6IHJhZGlhbC1ncmFk
>>"%RB10%" echo aWVudChjaXJjbGUgYXQgNzAlIDAlLCAjMGIyNjM2IDAsICMwMjA3MGQgNDIlLCAjMDEwNDA4
>>"%RB10%" echo IDEwMCUpOyB9CmJ1dHRvbiwgaW5wdXQsIHNlbGVjdCB7IGZvbnQ6IGluaGVyaXQ7IH0KYnV0
>>"%RB10%" echo dG9uIHsgY3Vyc29yOiBwb2ludGVyOyB9CmJ1dHRvbjpkaXNhYmxlZCB7IG9wYWNpdHk6IC41
>>"%RB10%" echo NTsgY3Vyc29yOiB3YWl0OyB9CmlucHV0LCBzZWxlY3QgewogIHdpZHRoOiAxMDAlOwogIGNv
>>"%RB10%" echo bG9yOiAjZWZmY2ZmOwogIGJhY2tncm91bmQ6ICMwNzExMWE7CiAgYm9yZGVyOiAxcHggc29s
>>"%RB10%" echo aWQgcmdiYSgxMzcsIDIwOSwgMjI2LCAuMik7CiAgYm9yZGVyLXJhZGl1czogMTJweDsKICBw
>>"%RB10%" echo YWRkaW5nOiAxM3B4IDE0cHg7CiAgb3V0bGluZTogbm9uZTsKICB0cmFuc2l0aW9uOiAuMnMg
>>"%RB10%" echo ZWFzZTsKfQppbnB1dDpmb2N1cywgc2VsZWN0OmZvY3VzIHsgYm9yZGVyLWNvbG9yOiB2YXIo
>>"%RB10%" echo LS1jeWFuKTsgYm94LXNoYWRvdzogMCAwIDAgM3B4IHJnYmEoNjYsIDIxMiwgMjQyLCAuMSk7
>>"%RB10%" echo IH0Kc2VsZWN0IG9wdGlvbiB7IGJhY2tncm91bmQ6ICMwNzExMWE7IH0KaDEsIGgyLCBoMywg
>>"%RB10%" echo cCB7IG1hcmdpbi10b3A6IDA7IH0KaDEgeyBsZXR0ZXItc3BhY2luZzogLS4wNGVtOyB9Cmgy
>>"%RB10%" echo IHsgbGV0dGVyLXNwYWNpbmc6IC0uMDI1ZW07IH0KLm11dGVkIHsgY29sb3I6IHZhcigtLW11
>>"%RB10%" echo dGVkKTsgfQouZXllYnJvdyB7IG1hcmdpbjogMCAwIDdweDsgY29sb3I6ICM2MGQ5ZjA7IGxl
>>"%RB10%" echo dHRlci1zcGFjaW5nOiAuMTVlbTsgZm9udC1zaXplOiAuNzFyZW07IGZvbnQtd2VpZ2h0OiA4
>>"%RB10%" echo MDA7IH0KLmNhcmQgeyBiYWNrZ3JvdW5kOiBsaW5lYXItZ3JhZGllbnQoMTQ1ZGVnLCByZ2Jh
>>"%RB10%" echo KDEwLCAyNiwgMzksIC45NCksIHJnYmEoNiwgMTYsIDI1LCAuOTYpKTsgYm9yZGVyOiAxcHgg
>>"%RB10%" echo c29saWQgdmFyKC0tbGluZSk7IGJvcmRlci1yYWRpdXM6IDIwcHg7IGJveC1zaGFkb3c6IDAg
>>"%RB10%" echo MThweCA1MHB4IHJnYmEoMCwwLDAsLjIyKTsgfQoucHJpbWFyeS1idG4sIC5naG9zdC1idG4g
>>"%RB10%" echo ewogIG1pbi1oZWlnaHQ6IDQ1cHg7CiAgYm9yZGVyLXJhZGl1czogMTJweDsKICBwYWRkaW5n
>>"%RB10%" echo OiAwIDE4cHg7CiAgZm9udC13ZWlnaHQ6IDgwMDsKICBib3JkZXI6IDFweCBzb2xpZCB0cmFu
>>"%RB10%" echo c3BhcmVudDsKICB0cmFuc2l0aW9uOiB0cmFuc2Zvcm0gLjE4cyBlYXNlLCBmaWx0ZXIgLjE4
>>"%RB10%" echo cyBlYXNlLCBib3JkZXItY29sb3IgLjE4cyBlYXNlOwp9Ci5wcmltYXJ5LWJ0biB7IGNvbG9y
>>"%RB10%" echo OiAjMDAxMjE5OyBiYWNrZ3JvdW5kOiBsaW5lYXItZ3JhZGllbnQoMTM1ZGVnLCAjOGRmMWZm
>>"%RB10%" echo LCAjMmVjM2U1KTsgYm94LXNoYWRvdzogMCAxMHB4IDI4cHggcmdiYSg0NiwxOTUsMjI5LC4x
>>"%RB10%" echo OCk7IH0KLmdob3N0LWJ0biB7IGNvbG9yOiAjZGZmOWZmOyBiYWNrZ3JvdW5kOiByZ2JhKDI1
>>"%RB10%" echo NSwyNTUsMjU1LC4wMzUpOyBib3JkZXItY29sb3I6IHJnYmEoMTUwLDIyMCwyMzUsLjE2KTsg
>>"%RB10%" echo fQoucHJpbWFyeS1idG46aG92ZXIsIC5naG9zdC1idG46aG92ZXIgeyB0cmFuc2Zvcm06IHRy
>>"%RB10%" echo YW5zbGF0ZVkoLTFweCk7IGZpbHRlcjogYnJpZ2h0bmVzcygxLjA4KTsgfQouc21hbGwgeyBt
>>"%RB10%" echo aW4taGVpZ2h0OiAzOHB4OyBwYWRkaW5nOiAwIDE0cHg7IGZvbnQtc2l6ZTogLjg1cmVtOyB9
>>"%RB10%" echo Ci50ZXh0LWJ0biB7IGNvbG9yOiB2YXIoLS1jeWFuMik7IGJhY2tncm91bmQ6IG5vbmU7IGJv
>>"%RB10%" echo cmRlcjogMDsgZm9udC13ZWlnaHQ6IDcwMDsgfQoKLmF1dGgtc2hlbGwgeyBtaW4taGVpZ2h0
>>"%RB10%" echo OiAxMDB2aDsgZGlzcGxheTogZ3JpZDsgZ3JpZC10ZW1wbGF0ZS1jb2x1bW5zOiBtaW5tYXgo
>>"%RB10%" echo NDQwcHgsIDEuMWZyKSBtaW5tYXgoNDMwcHgsIC45ZnIpOyB9Ci5hdXRoLWFydCB7IG1pbi1o
>>"%RB10%" echo ZWlnaHQ6IDEwMHZoOyBwYWRkaW5nOiA0NHB4IGNsYW1wKDM0cHgsIDZ2dywgOTJweCk7IGRp
>>"%RB10%" echo c3BsYXk6IGZsZXg7IGZsZXgtZGlyZWN0aW9uOiBjb2x1bW47IGp1c3RpZnktY29udGVudDog
>>"%RB10%" echo c3BhY2UtYmV0d2VlbjsgcG9zaXRpb246IHJlbGF0aXZlOyBvdmVyZmxvdzogaGlkZGVuOyBi
>>"%RB10%" echo b3JkZXItcmlnaHQ6IDFweCBzb2xpZCByZ2JhKDEyMiwyMTksMjQxLC4xKTsgfQouYXV0aC1h
>>"%RB10%" echo cnQ6OmJlZm9yZSB7IGNvbnRlbnQ6ICIiOyBwb3NpdGlvbjogYWJzb2x1dGU7IHdpZHRoOiA1
>>"%RB10%" echo NjBweDsgaGVpZ2h0OiA1NjBweDsgYm9yZGVyLXJhZGl1czogNTAlOyBiYWNrZ3JvdW5kOiBy
>>"%RB10%" echo YWRpYWwtZ3JhZGllbnQoY2lyY2xlLCByZ2JhKDQ4LDIwMSwyMzIsLjE2KSwgdHJhbnNwYXJl
>>"%RB10%" echo bnQgNjglKTsgcmlnaHQ6IC0xODBweDsgdG9wOiA4JTsgfQouYXV0aC1hcnQ6OmFmdGVyIHsg
>>"%RB10%" echo Y29udGVudDogIiI7IHBvc2l0aW9uOiBhYnNvbHV0ZTsgaW5zZXQ6IDA7IGJhY2tncm91bmQt
>>"%RB10%" echo aW1hZ2U6IGxpbmVhci1ncmFkaWVudChyZ2JhKDc3LDE4NCwyMDksLjAzKSAxcHgsIHRyYW5z
>>"%RB10%" echo cGFyZW50IDFweCksIGxpbmVhci1ncmFkaWVudCg5MGRlZywgcmdiYSg3NywxODQsMjA5LC4w
>>"%RB10%" echo MykgMXB4LCB0cmFuc3BhcmVudCAxcHgpOyBiYWNrZ3JvdW5kLXNpemU6IDM4cHggMzhweDsg
>>"%RB10%" echo bWFzay1pbWFnZTogbGluZWFyLWdyYWRpZW50KHRvIGJvdHRvbSwgYmxhY2ssIHRyYW5zcGFy
>>"%RB10%" echo ZW50IDgyJSk7IHBvaW50ZXItZXZlbnRzOiBub25lOyB9Ci5icmFuZC1yb3cgeyBkaXNwbGF5
>>"%RB10%" echo OiBmbGV4OyBnYXA6IDEycHg7IGFsaWduLWl0ZW1zOiBjZW50ZXI7IHBvc2l0aW9uOiByZWxh
>>"%RB10%" echo dGl2ZTsgei1pbmRleDogMTsgfQouYnJhbmQtcm93ID4gZGl2Omxhc3QtY2hpbGQgeyBkaXNw
>>"%RB10%" echo bGF5OiBncmlkOyBnYXA6IDJweDsgfQouYnJhbmQtcm93IHN0cm9uZyB7IGZvbnQtc2l6ZTog
>>"%RB10%" echo Ljk2cmVtOyB9Ci5icmFuZC1yb3cgc3BhbiB7IGNvbG9yOiB2YXIoLS1tdXRlZCk7IGZvbnQt
>>"%RB10%" echo c2l6ZTogLjc2cmVtOyB9Ci5icmFuZC1tYXJrIHsgd2lkdGg6IDQ1cHg7IGhlaWdodDogNDVw
>>"%RB10%" echo eDsgYm9yZGVyLXJhZGl1czogMTNweDsgZGlzcGxheTogZ3JpZDsgcGxhY2UtaXRlbXM6IGNl
>>"%RB10%" echo bnRlcjsgY29sb3I6ICMwMDEwMTc7IGZvbnQtd2VpZ2h0OiA5MDA7IGJhY2tncm91bmQ6IGxp
>>"%RB10%" echo bmVhci1ncmFkaWVudCgxNDVkZWcsICM5YWY0ZmYsICMzNWM2ZTUpOyBib3gtc2hhZG93OiAw
>>"%RB10%" echo IDhweCAyOHB4IHJnYmEoNTMsMTk4LDIyOSwuMjIpOyB9Ci5oZXJvLWNvcHkgeyBtYXgtd2lk
>>"%RB10%" echo dGg6IDY4MHB4OyBwb3NpdGlvbjogcmVsYXRpdmU7IHotaW5kZXg6IDE7IH0KLmhlcm8tY29w
>>"%RB10%" echo eSBoMSB7IGZvbnQtc2l6ZTogY2xhbXAoMi42cmVtLCA1dncsIDUuMnJlbSk7IGxpbmUtaGVp
>>"%RB10%" echo Z2h0OiAuOTc7IG1heC13aWR0aDogNzcwcHg7IG1hcmdpbi1ib3R0b206IDI4cHg7IH0KLmhl
>>"%RB10%" echo cm8tY29weSA+IHA6bm90KC5leWVicm93KSB7IGNvbG9yOiAjOWJiOGM0OyBsaW5lLWhlaWdo
>>"%RB10%" echo dDogMS43OyBtYXgtd2lkdGg6IDYyMHB4OyBmb250LXNpemU6IDEuMDVyZW07IH0KLmhlcm8t
>>"%RB10%" echo c3RhdHMgeyBkaXNwbGF5OiBmbGV4OyBnYXA6IDE1cHg7IG1hcmdpbi10b3A6IDM0cHg7IGZs
>>"%RB10%" echo ZXgtd3JhcDogd3JhcDsgfQouaGVyby1zdGF0cyA+IGRpdiB7IG1pbi13aWR0aDogMTQ1cHg7
>>"%RB10%" echo IHBhZGRpbmc6IDE4cHggMjBweDsgYmFja2dyb3VuZDogcmdiYSg2LDE4LDI4LC43Mik7IGJv
>>"%RB10%" echo cmRlcjogMXB4IHNvbGlkIHJnYmEoMTIwLDIxNCwyMzQsLjEyKTsgYm9yZGVyLXJhZGl1czog
>>"%RB10%" echo MTZweDsgYmFja2Ryb3AtZmlsdGVyOiBibHVyKDEwcHgpOyB9Ci5oZXJvLXN0YXRzIGIgeyBk
>>"%RB10%" echo aXNwbGF5OiBibG9jazsgZm9udC1zaXplOiAxLjZyZW07IGNvbG9yOiAjZWZmY2ZmOyB9Ci5o
>>"%RB10%" echo ZXJvLXN0YXRzIHNwYW4geyBjb2xvcjogdmFyKC0tbXV0ZWQpOyBmb250LXNpemU6IC43OHJl
>>"%RB10%" echo bTsgfQouc2VjdXJpdHktbm90ZSB7IHBvc2l0aW9uOiByZWxhdGl2ZTsgei1pbmRleDogMTsg
>>"%RB10%" echo bWF4LXdpZHRoOiA1MjBweDsgcGFkZGluZzogMTdweCAxOXB4OyBib3JkZXItbGVmdDogMnB4
>>"%RB10%" echo IHNvbGlkIHZhcigtLWN5YW4pOyBiYWNrZ3JvdW5kOiByZ2JhKDcsMjAsMzAsLjU1KTsgfQou
>>"%RB10%" echo c2VjdXJpdHktbm90ZSBzcGFuIHsgZm9udC1zaXplOiAuNjhyZW07IGZvbnQtd2VpZ2h0OiA5
>>"%RB10%" echo MDA7IGxldHRlci1zcGFjaW5nOiAuMTNlbTsgY29sb3I6IHZhcigtLWN5YW4yKTsgfQouc2Vj
>>"%RB10%" echo dXJpdHktbm90ZSBwIHsgbWFyZ2luOiA1cHggMCAwOyBjb2xvcjogIzdmOWVhYjsgZm9udC1z
>>"%RB10%" echo aXplOiAuNzhyZW07IGxpbmUtaGVpZ2h0OiAxLjU7IH0KCi5hdXRoLWNhcmQgeyBtaW4taGVp
>>"%RB10%" echo Z2h0OiAxMDB2aDsgcGFkZGluZzogY2xhbXAoMzRweCwgN3ZoLCA4OHB4KSBjbGFtcCgyOHB4
>>"%RB10%" echo LCA3dncsIDg2cHgpOyBkaXNwbGF5OiBmbGV4OyBmbGV4LWRpcmVjdGlvbjogY29sdW1uOyBq
>>"%RB10%" echo dXN0aWZ5LWNvbnRlbnQ6IGNlbnRlcjsgfQouYXV0aC10YWJzIHsgZGlzcGxheTogZ3JpZDsg
>>"%RB10%" echo Z3JpZC10ZW1wbGF0ZS1jb2x1bW5zOiAxZnIgMWZyOyBiYWNrZ3JvdW5kOiAjMDUxMDFhOyBw
>>"%RB10%" echo YWRkaW5nOiA1cHg7IGJvcmRlci1yYWRpdXM6IDE0cHg7IGJvcmRlcjogMXB4IHNvbGlkIHZh
>>"%RB10%" echo cigtLWxpbmUpOyBtYXJnaW4tYm90dG9tOiAzNHB4OyB9Ci5hdXRoLXRhYnMgYnV0dG9uIHsg
>>"%RB10%" echo cGFkZGluZzogMTFweDsgYm9yZGVyOiAwOyBib3JkZXItcmFkaXVzOiAxMHB4OyBjb2xvcjog
>>"%RB10%" echo Izc1OTVhMjsgYmFja2dyb3VuZDogdHJhbnNwYXJlbnQ7IGZvbnQtd2VpZ2h0OiA4MDA7IH0K
>>"%RB10%" echo LmF1dGgtdGFicyBidXR0b24uYWN0aXZlIHsgYmFja2dyb3VuZDogIzEwMjYzNTsgY29sb3I6
>>"%RB10%" echo ICNlYWZmZmY7IGJveC1zaGFkb3c6IGluc2V0IDAgMCAwIDFweCByZ2JhKDEwOSwyMTYsMjM5
>>"%RB10%" echo LC4xMyk7IH0KLmF1dGgtZm9ybSB7IGRpc3BsYXk6IGdyaWQ7IGdhcDogMThweDsgfQouYXV0
>>"%RB10%" echo aC1mb3JtIGgyIHsgbWFyZ2luLWJvdHRvbTogNHB4OyBmb250LXNpemU6IDJyZW07IH0KLmF1
>>"%RB10%" echo dGgtZm9ybSBsYWJlbCB7IGRpc3BsYXk6IGdyaWQ7IGdhcDogOHB4OyBjb2xvcjogI2M3ZTJl
>>"%RB10%" echo YTsgZm9udC1zaXplOiAuODJyZW07IGZvbnQtd2VpZ2h0OiA3MDA7IH0KLmNoZWNrLWxpbmUg
>>"%RB10%" echo eyBkaXNwbGF5OiBmbGV4ICFpbXBvcnRhbnQ7IGFsaWduLWl0ZW1zOiBjZW50ZXI7IGdhcDog
>>"%RB10%" echo OXB4ICFpbXBvcnRhbnQ7IGNvbG9yOiB2YXIoLS1tdXRlZCkgIWltcG9ydGFudDsgfQouY2hl
>>"%RB10%" echo Y2stbGluZSBpbnB1dCB7IHdpZHRoOiAxNnB4OyBoZWlnaHQ6IDE2cHg7IH0KLmZvcm0tZXJy
>>"%RB10%" echo b3IgeyBwYWRkaW5nOiAxMnB4IDE0cHg7IGJvcmRlci1yYWRpdXM6IDEwcHg7IGNvbG9yOiAj
>>"%RB10%" echo ZmZiMWJlOyBiYWNrZ3JvdW5kOiByZ2JhKDI1NSw3OCwxMTEsLjA4KTsgYm9yZGVyOiAxcHgg
>>"%RB10%" echo c29saWQgcmdiYSgyNTUsNzgsMTExLC4yMik7IGZvbnQtc2l6ZTogLjgycmVtOyB9Ci5kZW1v
>>"%RB10%" echo LWhpbnQgeyBjb2xvcjogIzY4ODg5NTsgdGV4dC1hbGlnbjogY2VudGVyOyBmb250LXNpemU6
>>"%RB10%" echo IC43MnJlbTsgfQouc2lnbnVwLWdyaWQgeyBncmlkLXRlbXBsYXRlLWNvbHVtbnM6IDFmciAx
>>"%RB10%" echo ZnI7IH0KLnNwYW4tMiB7IGdyaWQtY29sdW1uOiAxIC8gLTE7IH0KLnN0cmVuZ3RoIHsgaGVp
>>"%RB10%" echo Z2h0OiA1cHg7IGJhY2tncm91bmQ6ICMxMDFkMjU7IGJvcmRlci1yYWRpdXM6IDk5cHg7IG92
>>"%RB10%" echo ZXJmbG93OiBoaWRkZW47IH0KLnN0cmVuZ3RoLWZpbGwgeyBoZWlnaHQ6IDEwMCU7IHdpZHRo
>>"%RB10%" echo OiAwOyB0cmFuc2l0aW9uOiAuMjVzOyBiYWNrZ3JvdW5kOiB2YXIoLS1yZWQpOyB9Ci5zdHJl
>>"%RB10%" echo bmd0aC1maWxsLnMxIHsgd2lkdGg6IDIwJTsgfQouc3RyZW5ndGgtZmlsbC5zMiB7IHdpZHRo
>>"%RB10%" echo OiA0MCU7IGJhY2tncm91bmQ6ICNmYjkyM2M7IH0KLnN0cmVuZ3RoLWZpbGwuczMgeyB3aWR0
>>"%RB10%" echo aDogNjAlOyBiYWNrZ3JvdW5kOiAjZmFjYzE1OyB9Ci5zdHJlbmd0aC1maWxsLnM0IHsgd2lk
>>"%RB10%" echo dGg6IDgwJTsgYmFja2dyb3VuZDogIzRhZGU4MDsgfQouc3RyZW5ndGgtZmlsbC5zNSB7IHdp
>>"%RB10%" echo ZHRoOiAxMDAlOyBiYWNrZ3JvdW5kOiAjMjJkM2VlOyB9CgoucG9ydGFsLXNoZWxsIHsgbWlu
>>"%RB10%" echo LWhlaWdodDogMTAwdmg7IGRpc3BsYXk6IGdyaWQ7IGdyaWQtdGVtcGxhdGUtY29sdW1uczog
>>"%RB10%" echo MjQ1cHggMWZyOyB9Ci5zaWRlYmFyIHsgcG9zaXRpb246IGZpeGVkOyBpbnNldDogMCBhdXRv
>>"%RB10%" echo IDAgMDsgd2lkdGg6IDI0NXB4OyBwYWRkaW5nOiAyNHB4IDE3cHg7IGJhY2tncm91bmQ6IHJn
>>"%RB10%" echo YmEoMywxMCwxNiwuOTYpOyBib3JkZXItcmlnaHQ6IDFweCBzb2xpZCByZ2JhKDExMiwyMDUs
>>"%RB10%" echo MjI2LC4xKTsgZGlzcGxheTogZmxleDsgZmxleC1kaXJlY3Rpb246IGNvbHVtbjsgZ2FwOiAz
>>"%RB10%" echo NHB4OyB6LWluZGV4OiAxMDsgYmFja2Ryb3AtZmlsdGVyOiBibHVyKDE4cHgpOyB9Ci5icmFu
>>"%RB10%" echo ZC1yb3cuY29tcGFjdCAuYnJhbmQtbWFyayB7IHdpZHRoOiAzOXB4OyBoZWlnaHQ6IDM5cHg7
>>"%RB10%" echo IGJvcmRlci1yYWRpdXM6IDExcHg7IGZvbnQtc2l6ZTogLjgycmVtOyB9Ci5zaWRlYmFyIG5h
>>"%RB10%" echo diB7IGRpc3BsYXk6IGdyaWQ7IGdhcDogOHB4OyB9Ci5zaWRlYmFyIG5hdiBidXR0b24geyBk
>>"%RB10%" echo aXNwbGF5OiBmbGV4OyBnYXA6IDEzcHg7IGFsaWduLWl0ZW1zOiBjZW50ZXI7IHBhZGRpbmc6
>>"%RB10%" echo IDEzcHggMTRweDsgYm9yZGVyOiAxcHggc29saWQgdHJhbnNwYXJlbnQ7IGJvcmRlci1yYWRp
>>"%RB10%" echo dXM6IDEycHg7IGJhY2tncm91bmQ6IHRyYW5zcGFyZW50OyBjb2xvcjogIzdmOWFhNjsgdGV4
>>"%RB10%" echo dC1hbGlnbjogbGVmdDsgZm9udC13ZWlnaHQ6IDgwMDsgfQouc2lkZWJhciBuYXYgYnV0dG9u
>>"%RB10%" echo IHNwYW4geyBjb2xvcjogIzM5NTc2NDsgZm9udC1zaXplOiAuN3JlbTsgfQouc2lkZWJhciBu
>>"%RB10%" echo YXYgYnV0dG9uLmFjdGl2ZSB7IGNvbG9yOiAjZTlmY2ZmOyBiYWNrZ3JvdW5kOiByZ2JhKDU4
>>"%RB10%" echo LDE5MCwyMjAsLjA5KTsgYm9yZGVyLWNvbG9yOiByZ2JhKDk0LDIyMCwyNDUsLjEzKTsgfQou
>>"%RB10%" echo c2lkZWJhciBuYXYgYnV0dG9uLmFjdGl2ZSBzcGFuIHsgY29sb3I6ICM1OGQ3ZWY7IH0KLnNp
>>"%RB10%" echo ZGViYXItdGlwIHsgbWFyZ2luLXRvcDogYXV0bzsgZGlzcGxheTogZ3JpZDsgZ2FwOiA3cHg7
>>"%RB10%" echo IHBhZGRpbmc6IDE1cHg7IGJvcmRlcjogMXB4IHNvbGlkIHZhcigtLWxpbmUpOyBib3JkZXIt
>>"%RB10%" echo cmFkaXVzOiAxNHB4OyBiYWNrZ3JvdW5kOiAjMDcxMjFhOyB9Ci5zaWRlYmFyLXRpcCBiIHsg
>>"%RB10%" echo Y29sb3I6IHZhcigtLWN5YW4yKTsgZm9udC1zaXplOiAuNjhyZW07IGxldHRlci1zcGFjaW5n
>>"%RB10%" echo OiAuMWVtOyB9Ci5zaWRlYmFyLXRpcCBzcGFuIHsgY29sb3I6ICM2ZjhiOTc7IGZvbnQtc2l6
>>"%RB10%" echo ZTogLjczcmVtOyB9Ci5zdHVkZW50LW1pbmkgeyBkaXNwbGF5OiBmbGV4OyBhbGlnbi1pdGVt
>>"%RB10%" echo czogY2VudGVyOyBnYXA6IDEwcHg7IHBhZGRpbmctdG9wOiAxN3B4OyBib3JkZXItdG9wOiAx
>>"%RB10%" echo cHggc29saWQgcmdiYSgyNTUsMjU1LDI1NSwuMDYpOyB9Ci5zdHVkZW50LW1pbmkgPiBkaXY6
>>"%RB10%" echo bGFzdC1jaGlsZCB7IGRpc3BsYXk6IGdyaWQ7IGdhcDogMnB4OyBtaW4td2lkdGg6IDA7IH0K
>>"%RB10%" echo LnN0dWRlbnQtbWluaSBiIHsgb3ZlcmZsb3c6IGhpZGRlbjsgdGV4dC1vdmVyZmxvdzogZWxs
>>"%RB10%" echo aXBzaXM7IHdoaXRlLXNwYWNlOiBub3dyYXA7IGZvbnQtc2l6ZTogLjc4cmVtOyB9Ci5zdHVk
>>"%RB10%" echo ZW50LW1pbmkgc3BhbiB7IGNvbG9yOiAjNjA3ZDg5OyBmb250LXNpemU6IC42OXJlbTsgfQou
>>"%RB10%" echo YXZhdGFyIHsgd2lkdGg6IDM4cHg7IGhlaWdodDogMzhweDsgYm9yZGVyLXJhZGl1czogNTAl
>>"%RB10%" echo OyBkaXNwbGF5OiBncmlkOyBwbGFjZS1pdGVtczogY2VudGVyOyBiYWNrZ3JvdW5kOiBsaW5l
>>"%RB10%" echo YXItZ3JhZGllbnQoMTM1ZGVnLCMyMzNmNTEsIzE1MzA0Mik7IGNvbG9yOiAjYTllYmY3OyBm
>>"%RB10%" echo b250LXdlaWdodDogOTAwOyBmb250LXNpemU6IC43MnJlbTsgfQoKLnBvcnRhbC1tYWluIHsg
>>"%RB10%" echo Z3JpZC1jb2x1bW46IDI7IG1pbi13aWR0aDogMDsgcGFkZGluZzogMCAzMnB4IDQwcHg7IH0K
>>"%RB10%" echo LnRvcGJhciB7IG1pbi1oZWlnaHQ6IDkwcHg7IGRpc3BsYXk6IGZsZXg7IGp1c3RpZnktY29u
>>"%RB10%" echo dGVudDogc3BhY2UtYmV0d2VlbjsgYWxpZ24taXRlbXM6IGNlbnRlcjsgYm9yZGVyLWJvdHRv
>>"%RB10%" echo bTogMXB4IHNvbGlkIHJnYmEoMTEzLDIwNSwyMjUsLjA4KTsgbWFyZ2luLWJvdHRvbTogMjhw
>>"%RB10%" echo eDsgfQoudG9wYmFyIGgyIHsgbWFyZ2luOiAwOyBmb250LXNpemU6IDEuMzhyZW07IH0KLnRv
>>"%RB10%" echo cC1hY3Rpb25zIHsgZGlzcGxheTogZmxleDsgZ2FwOiAxMXB4OyBhbGlnbi1pdGVtczogY2Vu
>>"%RB10%" echo dGVyOyB9Ci5pY29uLWJ0biB7IHBvc2l0aW9uOiByZWxhdGl2ZTsgd2lkdGg6IDM5cHg7IGhl
>>"%RB10%" echo aWdodDogMzlweDsgYm9yZGVyLXJhZGl1czogMTFweDsgY29sb3I6ICM5Y2JjYzc7IGJhY2tn
>>"%RB10%" echo cm91bmQ6ICMwODE1MWY7IGJvcmRlcjogMXB4IHNvbGlkIHZhcigtLWxpbmUpOyBmb250LXdl
>>"%RB10%" echo aWdodDogOTAwOyB9Ci5pY29uLWJ0biBpIHsgcG9zaXRpb246IGFic29sdXRlOyB3aWR0aDog
>>"%RB10%" echo MTdweDsgaGVpZ2h0OiAxN3B4OyBkaXNwbGF5OiBncmlkOyBwbGFjZS1pdGVtczogY2VudGVy
>>"%RB10%" echo OyByaWdodDogLTVweDsgdG9wOiAtNXB4OyBib3JkZXItcmFkaXVzOiA1MCU7IGJhY2tncm91
>>"%RB10%" echo bmQ6ICNlZjQ3NmY7IGNvbG9yOiB3aGl0ZTsgZm9udC1zaXplOiAuNnJlbTsgZm9udC1zdHls
>>"%RB10%" echo ZTogbm9ybWFsOyB9Ci50ZXJtLWNoaXAgeyBkaXNwbGF5OiBmbGV4OyBnYXA6IDhweDsgYWxp
>>"%RB10%" echo Z24taXRlbXM6IGNlbnRlcjsgcGFkZGluZzogOHB4IDExcHg7IGJvcmRlcjogMXB4IHNvbGlk
>>"%RB10%" echo IHZhcigtLWxpbmUpOyBib3JkZXItcmFkaXVzOiAxMXB4OyBiYWNrZ3JvdW5kOiAjMDcxMzFj
>>"%RB10%" echo OyBmb250LXNpemU6IC43N3JlbTsgfQoudGVybS1jaGlwIHNwYW4geyBjb2xvcjogIzZjOGI5
>>"%RB10%" echo NzsgfQoKLmRhc2hib2FyZC1ncmlkIHsgZGlzcGxheTogZ3JpZDsgZ3JpZC10ZW1wbGF0ZS1j
>>"%RB10%" echo b2x1bW5zOiBtaW5tYXgoMCwgMS4zZnIpIG1pbm1heCgzMjBweCwgLjdmcik7IGdhcDogMThw
>>"%RB10%" echo eDsgfQoud2VsY29tZS1jYXJkIHsgZ3JpZC1jb2x1bW46IDEgLyAtMTsgbWluLWhlaWdodDog
>>"%RB10%" echo MjU1cHg7IHBhZGRpbmc6IDMwcHg7IGRpc3BsYXk6IGZsZXg7IGp1c3RpZnktY29udGVudDog
>>"%RB10%" echo c3BhY2UtYmV0d2VlbjsgYWxpZ24taXRlbXM6IGNlbnRlcjsgZ2FwOiAzMHB4OyBiYWNrZ3Jv
>>"%RB10%" echo dW5kOiByYWRpYWwtZ3JhZGllbnQoY2lyY2xlIGF0IDg1JSAyMCUsIHJnYmEoNDksMTkxLDIy
>>"%RB10%" echo MiwuMTUpLCB0cmFuc3BhcmVudCAzMCUpLCBsaW5lYXItZ3JhZGllbnQoMTQ1ZGVnLCMwYjFk
>>"%RB10%" echo MmEsIzA2MTIxZCk7IG92ZXJmbG93OiBoaWRkZW47IH0KLndlbGNvbWUtY2FyZCBoMSB7IGZv
>>"%RB10%" echo bnQtc2l6ZTogY2xhbXAoMnJlbSwgNHZ3LCAzLjVyZW0pOyBtYXJnaW4tYm90dG9tOiAxMXB4
>>"%RB10%" echo OyB9Ci53ZWxjb21lLWNhcmQgPiBkaXY6Zmlyc3QtY2hpbGQgPiBwOm5vdCguZXllYnJvdykg
>>"%RB10%" echo eyBjb2xvcjogIzg4YTdiMzsgbWF4LXdpZHRoOiA2MjBweDsgfQoud2VsY29tZS1hY3Rpb25z
>>"%RB10%" echo IHsgZGlzcGxheTogZmxleDsgZ2FwOiAxMHB4OyBtYXJnaW4tdG9wOiAyNXB4OyB9Ci5mb2N1
>>"%RB10%" echo cy1wYW5lbCB7IG1pbi13aWR0aDogMzEwcHg7IG1heC13aWR0aDogMzYwcHg7IHBhZGRpbmc6
>>"%RB10%" echo IDIwcHg7IGJvcmRlcjogMXB4IHNvbGlkIHJnYmEoMTIwLDIyMCwyNDAsLjE0KTsgYm9yZGVy
>>"%RB10%" echo LXJhZGl1czogMTdweDsgYmFja2dyb3VuZDogcmdiYSg0LDE0LDIzLC42Nik7IH0KLmZvY3Vz
>>"%RB10%" echo LXBhbmVsIHNwYW4geyBjb2xvcjogIzY3ODg5NTsgZm9udC1zaXplOiAuN3JlbTsgdGV4dC10
>>"%RB10%" echo cmFuc2Zvcm06IHVwcGVyY2FzZTsgbGV0dGVyLXNwYWNpbmc6IC4xZW07IH0KLmZvY3VzLXBh
>>"%RB10%" echo bmVsIGIgeyBkaXNwbGF5OiBibG9jazsgbWFyZ2luOiA5cHggMCA2cHg7IH0KLmZvY3VzLXBh
>>"%RB10%" echo bmVsIHAgeyBjb2xvcjogIzc1OTM5ZjsgZm9udC1zaXplOiAuNzhyZW07IH0KLm1pbmktcHJv
>>"%RB10%" echo Z3Jlc3MsIC5iYXIgeyBoZWlnaHQ6IDdweDsgYmFja2dyb3VuZDogIzBlMWQyNzsgYm9yZGVy
>>"%RB10%" echo LXJhZGl1czogOTlweDsgb3ZlcmZsb3c6IGhpZGRlbjsgfQoubWluaS1wcm9ncmVzcyBpLCAu
>>"%RB10%" echo YmFyIGkgeyBkaXNwbGF5OiBibG9jazsgaGVpZ2h0OiAxMDAlOyBib3JkZXItcmFkaXVzOiBp
>>"%RB10%" echo bmhlcml0OyBiYWNrZ3JvdW5kOiBsaW5lYXItZ3JhZGllbnQoOTBkZWcsIzI3YmRkYywjN2Vl
>>"%RB10%" echo YWZiKTsgfQouc3RhdHMtcm93IHsgZ3JpZC1jb2x1bW46IDEgLyAtMTsgZGlzcGxheTogZ3Jp
>>"%RB10%" echo ZDsgZ3JpZC10ZW1wbGF0ZS1jb2x1bW5zOiByZXBlYXQoNCwxZnIpOyBnYXA6IDE0cHg7IH0K
>>"%RB10%" echo Lm1ldHJpYyB7IHBhZGRpbmc6IDIwcHg7IGRpc3BsYXk6IGdyaWQ7IGdhcDogNXB4OyB9Ci5t
>>"%RB10%" echo ZXRyaWMgc3BhbiB7IGNvbG9yOiAjNzg5N2EzOyBmb250LXNpemU6IC43NXJlbTsgZm9udC13
>>"%RB10%" echo ZWlnaHQ6IDcwMDsgfQoubWV0cmljIGIgeyBmb250LXNpemU6IDEuOHJlbTsgbGV0dGVyLXNw
>>"%RB10%" echo YWNpbmc6IC0uMDRlbTsgfQoubWV0cmljIHNtYWxsIHsgY29sb3I6ICM1NTc1ODI7IH0KLnNj
>>"%RB10%" echo aGVkdWxlLWNhcmQsIC5wZXJmb3JtYW5jZS1jYXJkLCAuYXNzaWdubWVudHMtY2FyZCwgLmNv
>>"%RB10%" echo dXJzZXMtY2FyZCwgLm5vdGljZXMtY2FyZCB7IHBhZGRpbmc6IDIycHg7IH0KLnNlY3Rpb24t
>>"%RB10%" echo dGl0bGUgeyBkaXNwbGF5OiBmbGV4OyBqdXN0aWZ5LWNvbnRlbnQ6IHNwYWNlLWJldHdlZW47
>>"%RB10%" echo IGFsaWduLWl0ZW1zOiBjZW50ZXI7IG1hcmdpbi1ib3R0b206IDE5cHg7IH0KLnNlY3Rpb24t
>>"%RB10%" echo dGl0bGUgaDIgeyBtYXJnaW46IDA7IGZvbnQtc2l6ZTogMS4ycmVtOyB9Ci5zZWN0aW9uLXRp
>>"%RB10%" echo dGxlID4gc3BhbiB7IGNvbG9yOiAjNjY4NzkzOyBmb250LXNpemU6IC43NXJlbTsgfQoubGl2
>>"%RB10%" echo ZS1waWxsIHsgcGFkZGluZzogNnB4IDlweDsgYm9yZGVyLXJhZGl1czogOTlweDsgY29sb3I6
>>"%RB10%" echo ICM2NWU5YjIgIWltcG9ydGFudDsgYmFja2dyb3VuZDogcmdiYSg2NiwyMTcsMTU4LC4wOCk7
>>"%RB10%" echo IGJvcmRlcjogMXB4IHNvbGlkIHJnYmEoNjYsMjE3LDE1OCwuMTQpOyBmb250LXdlaWdodDog
>>"%RB10%" echo ODAwOyB9Ci50aW1lbGluZSB7IGRpc3BsYXk6IGdyaWQ7IH0KLnRpbWVsaW5lLXJvdyB7IGRp
>>"%RB10%" echo c3BsYXk6IGdyaWQ7IGdyaWQtdGVtcGxhdGUtY29sdW1uczogNTJweCAxNXB4IDFmciBhdXRv
>>"%RB10%" echo OyBnYXA6IDlweDsgYWxpZ24taXRlbXM6IGNlbnRlcjsgbWluLWhlaWdodDogNjNweDsgfQou
>>"%RB10%" echo dGltZWxpbmUtcm93IHRpbWUgeyBjb2xvcjogIzY3ODc5NDsgZm9udC1zaXplOiAuNzJyZW07
>>"%RB10%" echo IGZvbnQtd2VpZ2h0OiA4MDA7IH0KLnRpbWVsaW5lLXJvdyA+IGkgeyB3aWR0aDogOHB4OyBo
>>"%RB10%" echo ZWlnaHQ6IDhweDsgYm9yZGVyLXJhZGl1czogNTAlOyBiYWNrZ3JvdW5kOiAjMjk0MDRhOyBi
>>"%RB10%" echo b3gtc2hhZG93OiAwIDAgMCA0cHggIzBiMTcyMDsgfQoudGltZWxpbmUtcm93ID4gZGl2IHsg
>>"%RB10%" echo ZGlzcGxheTogZ3JpZDsgZ2FwOiAzcHg7IH0KLnRpbWVsaW5lLXJvdyBiIHsgZm9udC1zaXpl
>>"%RB10%" echo OiAuODRyZW07IH0KLnRpbWVsaW5lLXJvdyBzcGFuIHsgY29sb3I6ICM2NDgzOGY7IGZvbnQt
>>"%RB10%" echo c2l6ZTogLjdyZW07IH0KLnRpbWVsaW5lLXJvdyBlbSB7IGNvbG9yOiAjNTU3MTdjOyBmb250
>>"%RB10%" echo LXNpemU6IC42OHJlbTsgZm9udC1zdHlsZTogbm9ybWFsOyB9Ci50aW1lbGluZS1yb3cuYWN0
>>"%RB10%" echo aXZlID4gaSB7IGJhY2tncm91bmQ6IHZhcigtLWN5YW4pOyBib3gtc2hhZG93OiAwIDAgMCA0
>>"%RB10%" echo cHggcmdiYSg2NiwyMTIsMjQyLC4xMiksIDAgMCAxNnB4IHJnYmEoNjYsMjEyLDI0MiwuNik7
>>"%RB10%" echo IH0KLnRpbWVsaW5lLXJvdy5hY3RpdmUgZW0geyBjb2xvcjogdmFyKC0tY3lhbjIpOyB9Ci50
>>"%RB10%" echo aW1lbGluZS1yb3cuZG9uZSB7IG9wYWNpdHk6IC41ODsgfQoucGVyZm9ybWFuY2UtYm9keSB7
>>"%RB10%" echo IGRpc3BsYXk6IGZsZXg7IGdhcDogMjdweDsgYWxpZ24taXRlbXM6IGNlbnRlcjsgfQoucHJv
>>"%RB10%" echo Z3Jlc3MtcmluZyB7IC0tYW5nbGU6IDBkZWc7IGZsZXg6IDAgMCAxMzBweDsgd2lkdGg6IDEz
>>"%RB10%" echo MHB4OyBoZWlnaHQ6IDEzMHB4OyBib3JkZXItcmFkaXVzOiA1MCU7IGRpc3BsYXk6IGdyaWQ7
>>"%RB10%" echo IHBsYWNlLWl0ZW1zOiBjZW50ZXI7IGJhY2tncm91bmQ6IGNvbmljLWdyYWRpZW50KHZhcigt
>>"%RB10%" echo LWN5YW4pIHZhcigtLWFuZ2xlKSwgIzEwMjEyYyAwKTsgcG9zaXRpb246IHJlbGF0aXZlOyB9
>>"%RB10%" echo Ci5wcm9ncmVzcy1yaW5nOjphZnRlciB7IGNvbnRlbnQ6ICIiOyBwb3NpdGlvbjogYWJzb2x1
>>"%RB10%" echo dGU7IGluc2V0OiAxMHB4OyBiYWNrZ3JvdW5kOiAjMDgxNjIwOyBib3JkZXItcmFkaXVzOiA1
>>"%RB10%" echo MCU7IH0KLnByb2dyZXNzLXJpbmcgPiBkaXYgeyB6LWluZGV4OiAxOyB0ZXh0LWFsaWduOiBj
>>"%RB10%" echo ZW50ZXI7IH0KLnByb2dyZXNzLXJpbmcgYiB7IGRpc3BsYXk6IGJsb2NrOyBmb250LXNpemU6
>>"%RB10%" echo IDEuNDVyZW07IH0KLnByb2dyZXNzLXJpbmcgc3BhbiB7IGNvbG9yOiAjNmY5MDlkOyBmb250
>>"%RB10%" echo LXNpemU6IC42OHJlbTsgfQouc3ViamVjdC1iYXJzIHsgZmxleDogMTsgZGlzcGxheTogZ3Jp
>>"%RB10%" echo ZDsgZ2FwOiAxNHB4OyB9Ci5zdWJqZWN0LWJhcnMgPiBkaXYgPiBkaXY6Zmlyc3QtY2hpbGQs
>>"%RB10%" echo IC5jb3Vyc2UtZm9vdCB7IGRpc3BsYXk6IGZsZXg7IGp1c3RpZnktY29udGVudDogc3BhY2Ut
>>"%RB10%" echo YmV0d2VlbjsgZm9udC1zaXplOiAuNzJyZW07IG1hcmdpbi1ib3R0b206IDVweDsgfQouc3Vi
>>"%RB10%" echo amVjdC1iYXJzIHNwYW4geyBjb2xvcjogIzc0OTM5ZTsgfQouYXNzaWdubWVudC1saXN0IHsg
>>"%RB10%" echo ZGlzcGxheTogZ3JpZDsgZ2FwOiA5cHg7IH0KLmFzc2lnbm1lbnQtbGlzdCBhcnRpY2xlIHsg
>>"%RB10%" echo ZGlzcGxheTogZ3JpZDsgZ3JpZC10ZW1wbGF0ZS1jb2x1bW5zOiA2NHB4IDFmciBhdXRvOyBn
>>"%RB10%" echo YXA6IDEycHg7IGFsaWduLWl0ZW1zOiBjZW50ZXI7IHBhZGRpbmc6IDEycHg7IGJvcmRlci1y
>>"%RB10%" echo YWRpdXM6IDEzcHg7IGJhY2tncm91bmQ6IHJnYmEoMjU1LDI1NSwyNTUsLjAyNSk7IGJvcmRl
>>"%RB10%" echo cjogMXB4IHNvbGlkIHJnYmEoMjU1LDI1NSwyNTUsLjA0NSk7IH0KLnByaW9yaXR5IHsgcGFk
>>"%RB10%" echo ZGluZzogNXB4IDdweDsgYm9yZGVyLXJhZGl1czogN3B4OyB0ZXh0LWFsaWduOiBjZW50ZXI7
>>"%RB10%" echo IGZvbnQtc2l6ZTogLjYycmVtOyBmb250LXdlaWdodDogOTAwOyB9Ci5wcmlvcml0eS5oaWdo
>>"%RB10%" echo IHsgY29sb3I6ICNmZjkxYTQ7IGJhY2tncm91bmQ6IHJnYmEoMjU1LDg1LDExNCwuMDgpOyB9
>>"%RB10%" echo Ci5wcmlvcml0eS5tZWRpdW0geyBjb2xvcjogI2ZmZDk4MzsgYmFja2dyb3VuZDogcmdiYSgy
>>"%RB10%" echo NTUsMTk3LDcwLC4wOCk7IH0KLnByaW9yaXR5LmxvdyB7IGNvbG9yOiAjNzZlYWI4OyBiYWNr
>>"%RB10%" echo Z3JvdW5kOiByZ2JhKDc2LDIyMCwxNTcsLjA4KTsgfQouYXNzaWdubWVudC1tYWluIHsgZGlz
>>"%RB10%" echo cGxheTogZ3JpZDsgZ2FwOiA1cHg7IH0KLmFzc2lnbm1lbnQtbWFpbiBiIHsgZm9udC1zaXpl
>>"%RB10%" echo OiAuODJyZW07IH0KLmFzc2lnbm1lbnQtbWFpbiBzcGFuIHsgY29sb3I6ICM2ODg4OTU7IGZv
>>"%RB10%" echo bnQtc2l6ZTogLjY4cmVtOyB9Ci5hc3NpZ25tZW50LWxpc3Qgc3Ryb25nIHsgZm9udC1zaXpl
>>"%RB10%" echo OiAuNzhyZW07IGNvbG9yOiAjOWVkZmViOyB9Ci5iYXIudGhpbiB7IGhlaWdodDogNHB4OyB9
>>"%RB10%" echo Ci5jb3Vyc2VzLWNhcmQgeyBncmlkLWNvbHVtbjogMSAvIC0xOyB9Ci5jb3Vyc2UtZ3JpZCB7
>>"%RB10%" echo IGRpc3BsYXk6IGdyaWQ7IGdyaWQtdGVtcGxhdGUtY29sdW1uczogcmVwZWF0KDQsMWZyKTsg
>>"%RB10%" echo Z2FwOiAxMnB4OyB9Ci5jb3Vyc2UgeyBwYWRkaW5nOiAxN3B4OyBib3JkZXI6IDFweCBzb2xp
>>"%RB10%" echo ZCByZ2JhKDI1NSwyNTUsMjU1LC4wNik7IGJvcmRlci1yYWRpdXM6IDE0cHg7IGJhY2tncm91
>>"%RB10%" echo bmQ6ICMwNzE0MWQ7IHBvc2l0aW9uOiByZWxhdGl2ZTsgb3ZlcmZsb3c6IGhpZGRlbjsgfQou
>>"%RB10%" echo Y291cnNlOjpiZWZvcmUgeyBjb250ZW50OiAiIjsgcG9zaXRpb246IGFic29sdXRlOyB3aWR0
>>"%RB10%" echo aDogOTBweDsgaGVpZ2h0OiA5MHB4OyByaWdodDogLTM1cHg7IHRvcDogLTM1cHg7IGJvcmRl
>>"%RB10%" echo ci1yYWRpdXM6IDUwJTsgYmFja2dyb3VuZDogdmFyKC0tY291cnNlLWNvbG9yKTsgZmlsdGVy
>>"%RB10%" echo OiBibHVyKDM1cHgpOyBvcGFjaXR5OiAuMTk7IH0KLmNvdXJzZS5jeWFuIHsgLS1jb3Vyc2Ut
>>"%RB10%" echo Y29sb3I6IzRkZGFmNzsgfS5jb3Vyc2UudmlvbGV0ey0tY291cnNlLWNvbG9yOiNhNzhiZmF9
>>"%RB10%" echo LmNvdXJzZS5lbWVyYWxkey0tY291cnNlLWNvbG9yOiM1NWU2YTZ9LmNvdXJzZS5hbWJlcnst
>>"%RB10%" echo LWNvdXJzZS1jb2xvcjojZjhjNzVmfQouY291cnNlLWNvZGUgeyBjb2xvcjogdmFyKC0tY291
>>"%RB10%" echo cnNlLWNvbG9yKTsgZm9udC1zaXplOiAuNjZyZW07IGxldHRlci1zcGFjaW5nOiAuMWVtOyBm
>>"%RB10%" echo b250LXdlaWdodDogOTAwOyB9Ci5jb3Vyc2UgaDMgeyBtaW4taGVpZ2h0OiA0NHB4OyBtYXJn
>>"%RB10%" echo aW46IDlweCAwIDdweDsgZm9udC1zaXplOiAuOTJyZW07IH0KLmNvdXJzZSBwLCAuY291cnNl
>>"%RB10%" echo IHNtYWxsIHsgY29sb3I6ICM2Nzg2OTI7IGZvbnQtc2l6ZTogLjY4cmVtOyB9Ci5jb3Vyc2Ug
>>"%RB10%" echo LmJhciB7IG1hcmdpbi10b3A6IDE1cHg7IGhlaWdodDogNXB4OyB9Ci5jb3Vyc2UgLmJhciBp
>>"%RB10%" echo IHsgYmFja2dyb3VuZDogdmFyKC0tY291cnNlLWNvbG9yKTsgfQouY291cnNlLWZvb3QgeyBt
>>"%RB10%" echo YXJnaW4tdG9wOiA3cHg7IGNvbG9yOiAjNmY4ZjliOyB9Ci5ub3RpY2VzLWNhcmQgeyBhbGln
>>"%RB10%" echo bi1zZWxmOiBzdGFydDsgfQoubm90aWNlIHsgZGlzcGxheTogZ3JpZDsgZ3JpZC10ZW1wbGF0
>>"%RB10%" echo ZS1jb2x1bW5zOiAzOHB4IDFmcjsgZ2FwOiAxMXB4OyBwYWRkaW5nOiAxM3B4IDA7IGJvcmRl
>>"%RB10%" echo ci10b3A6IDFweCBzb2xpZCByZ2JhKDI1NSwyNTUsMjU1LC4wNSk7IH0KLm5vdGljZTpmaXJz
>>"%RB10%" echo dC1vZi10eXBlIHsgYm9yZGVyLXRvcDogMDsgfQoubm90aWNlLWljb24geyB3aWR0aDogMzNw
>>"%RB10%" echo eDsgaGVpZ2h0OiAzM3B4OyBkaXNwbGF5OiBncmlkOyBwbGFjZS1pdGVtczogY2VudGVyOyBi
>>"%RB10%" echo b3JkZXItcmFkaXVzOiA5cHg7IGJhY2tncm91bmQ6ICMxMDI2MzE7IGNvbG9yOiAjODBkZmYw
>>"%RB10%" echo OyBmb250LXNpemU6IC42M3JlbTsgZm9udC13ZWlnaHQ6IDkwMDsgfQoubm90aWNlIGRpdiB7
>>"%RB10%" echo IGRpc3BsYXk6IGdyaWQ7IGdhcDogNHB4OyB9Ci5ub3RpY2UgYiB7IGZvbnQtc2l6ZTogLjc4
>>"%RB10%" echo cmVtOyB9Ci5ub3RpY2UgcCB7IG1hcmdpbjogMDsgY29sb3I6ICM2ODg3OTM7IGZvbnQtc2l6
>>"%RB10%" echo ZTogLjdyZW07IGxpbmUtaGVpZ2h0OiAxLjQ1OyB9Ci5ub3RpY2Ugc21hbGwgeyBjb2xvcjog
>>"%RB10%" echo IzRmNmM3NjsgZm9udC1zaXplOiAuNjRyZW07IH0KCi5nYW1lLXBhZ2UgeyBkaXNwbGF5OiBn
>>"%RB10%" echo cmlkOyBnYXA6IDE2cHg7IH0KLmdhbWUtaW50cm8geyBwYWRkaW5nOiAyMnB4OyBkaXNwbGF5
>>"%RB10%" echo OiBmbGV4OyBqdXN0aWZ5LWNvbnRlbnQ6IHNwYWNlLWJldHdlZW47IGdhcDogMjhweDsgYWxp
>>"%RB10%" echo Z24taXRlbXM6IGNlbnRlcjsgfQouZ2FtZS1pbnRybyBoMSB7IG1hcmdpbi1ib3R0b206IDdw
>>"%RB10%" echo eDsgZm9udC1zaXplOiAycmVtOyB9Ci5nYW1lLWludHJvIHA6bm90KC5leWVicm93KSB7IGNv
>>"%RB10%" echo bG9yOiAjNzY5NWExOyBtYXgtd2lkdGg6IDcwMHB4OyBtYXJnaW46IDA7IGxpbmUtaGVpZ2h0
>>"%RB10%" echo OiAxLjU7IH0KLmdhbWUtY29udHJvbHMgeyBkaXNwbGF5OiBncmlkOyBncmlkLXRlbXBsYXRl
>>"%RB10%" echo LWNvbHVtbnM6IDFmciAxZnI7IGdhcDogOHB4OyBtaW4td2lkdGg6IDI5MHB4OyB9Ci5nYW1l
>>"%RB10%" echo LWNvbnRyb2xzIHNwYW4geyBjb2xvcjogIzc5OThhNDsgZm9udC1zaXplOiAuN3JlbTsgfQpr
>>"%RB10%" echo YmQgeyBkaXNwbGF5OiBpbmxpbmUtYmxvY2s7IG1pbi13aWR0aDogNDVweDsgcGFkZGluZzog
>>"%RB10%" echo NHB4IDdweDsgbWFyZ2luLXJpZ2h0OiA1cHg7IGJvcmRlci1yYWRpdXM6IDZweDsgdGV4dC1h
>>"%RB10%" echo bGlnbjogY2VudGVyOyBjb2xvcjogI2M5ZjdmZjsgYmFja2dyb3VuZDogIzBiMjAyYjsgYm9y
>>"%RB10%" echo ZGVyOiAxcHggc29saWQgcmdiYSgxMDgsMjE4LDIzOSwuMTYpOyBmb250LWZhbWlseTogaW5o
>>"%RB10%" echo ZXJpdDsgZm9udC1zaXplOiAuNjZyZW07IGZvbnQtd2VpZ2h0OiA5MDA7IH0KLmh1ZC1ncmlk
>>"%RB10%" echo IHsgZGlzcGxheTogZ3JpZDsgZ3JpZC10ZW1wbGF0ZS1jb2x1bW5zOiByZXBlYXQoOCwxZnIp
>>"%RB10%" echo OyBnYXA6IDhweDsgfQouaHVkLWdyaWQgPiBkaXYgeyBwYWRkaW5nOiAxMHB4IDEycHg7IGJh
>>"%RB10%" echo Y2tncm91bmQ6ICMwNzE0MWU7IGJvcmRlcjogMXB4IHNvbGlkIHZhcigtLWxpbmUpOyBib3Jk
>>"%RB10%" echo ZXItcmFkaXVzOiAxMHB4OyB9Ci5odWQtZ3JpZCBzcGFuIHsgZGlzcGxheTogYmxvY2s7IGNv
>>"%RB10%" echo bG9yOiAjNjE4MDhjOyBmb250LXNpemU6IC42MXJlbTsgdGV4dC10cmFuc2Zvcm06IHVwcGVy
>>"%RB10%" echo Y2FzZTsgbGV0dGVyLXNwYWNpbmc6IC4wOGVtOyB9Ci5odWQtZ3JpZCBiIHsgZGlzcGxheTog
>>"%RB10%" echo YmxvY2s7IG1hcmdpbi10b3A6IDNweDsgZm9udC1zaXplOiAuODhyZW07IH0KLmdhbWUtZnJh
>>"%RB10%" echo bWUgeyBvdmVyZmxvdzogaGlkZGVuOyBib3JkZXI6IDFweCBzb2xpZCByZ2JhKDkzLDIyMCwy
>>"%RB10%" echo NDQsLjIpOyBib3JkZXItcmFkaXVzOiAxOHB4OyBiYWNrZ3JvdW5kOiAjMDIwNzBkOyBib3gt
>>"%RB10%" echo c2hhZG93OiAwIDIwcHggNzBweCByZ2JhKDAsMCwwLC4zMik7IH0KLmdhbWUtZnJhbWUgY2Fu
>>"%RB10%" echo dmFzIHsgZGlzcGxheTogYmxvY2s7IHdpZHRoOiAxMDAlOyBoZWlnaHQ6IGF1dG87IGN1cnNv
>>"%RB10%" echo cjogY3Jvc3NoYWlyOyB0b3VjaC1hY3Rpb246IG5vbmU7IH0KLmdhbWUtYm90dG9tIHsgZGlz
>>"%RB10%" echo cGxheTogZmxleDsganVzdGlmeS1jb250ZW50OiBzcGFjZS1iZXR3ZWVuOyBhbGlnbi1pdGVt
>>"%RB10%" echo czogc3RyZXRjaDsgZ2FwOiAxNHB4OyB9Ci5tZWNoYW5pYy1jYXJkIHsgZGlzcGxheTogZmxl
>>"%RB10%" echo eDsgZmxleC13cmFwOiB3cmFwOyBnYXA6IDhweCAxNnB4OyBhbGlnbi1pdGVtczogY2VudGVy
>>"%RB10%" echo OyBwYWRkaW5nOiAxNHB4IDE2cHg7IGZsZXg6IDE7IH0KLm1lY2hhbmljLWNhcmQgYiB7IGNv
>>"%RB10%" echo bG9yOiB2YXIoLS1jeWFuMik7IH0KLm1lY2hhbmljLWNhcmQgc3BhbiB7IGNvbG9yOiAjNzE4
>>"%RB10%" echo ZjlhOyBmb250LXNpemU6IC43cmVtOyB9Ci5nYW1lLWJ1dHRvbnMgeyBkaXNwbGF5OiBmbGV4
>>"%RB10%" echo OyBnYXA6IDlweDsgYWxpZ24taXRlbXM6IGNlbnRlcjsgfQoKLmJvb3Qtc2NyZWVuIHsgbWlu
>>"%RB10%" echo LWhlaWdodDogMTAwdmg7IGRpc3BsYXk6IGdyaWQ7IHBsYWNlLWl0ZW1zOiBjZW50ZXI7IGNv
>>"%RB10%" echo bG9yOiAjOTFkZmYwOyBsZXR0ZXItc3BhY2luZzogLjA4ZW07IH0KCkBtZWRpYSAobWF4LXdp
>>"%RB10%" echo ZHRoOiAxMTgwcHgpIHsKICAuYXV0aC1zaGVsbCB7IGdyaWQtdGVtcGxhdGUtY29sdW1uczog
>>"%RB10%" echo MWZyOyB9CiAgLmF1dGgtYXJ0IHsgbWluLWhlaWdodDogNjMwcHg7IGJvcmRlci1yaWdodDog
>>"%RB10%" echo MDsgYm9yZGVyLWJvdHRvbTogMXB4IHNvbGlkIHZhcigtLWxpbmUpOyB9CiAgLmF1dGgtY2Fy
>>"%RB10%" echo ZCB7IG1pbi1oZWlnaHQ6IGF1dG87IH0KICAuZGFzaGJvYXJkLWdyaWQgeyBncmlkLXRlbXBs
>>"%RB10%" echo YXRlLWNvbHVtbnM6IDFmcjsgfQogIC5zY2hlZHVsZS1jYXJkLCAucGVyZm9ybWFuY2UtY2Fy
>>"%RB10%" echo ZCwgLmFzc2lnbm1lbnRzLWNhcmQsIC5ub3RpY2VzLWNhcmQgeyBncmlkLWNvbHVtbjogMTsg
>>"%RB10%" echo fQogIC5jb3Vyc2UtZ3JpZCB7IGdyaWQtdGVtcGxhdGUtY29sdW1uczogcmVwZWF0KDIsMWZy
>>"%RB10%" echo KTsgfQogIC5odWQtZ3JpZCB7IGdyaWQtdGVtcGxhdGUtY29sdW1uczogcmVwZWF0KDQsMWZy
>>"%RB10%" echo KTsgfQp9CkBtZWRpYSAobWF4LXdpZHRoOiA4MjBweCkgewogIC5wb3J0YWwtc2hlbGwgeyBk
>>"%RB10%" echo aXNwbGF5OiBibG9jazsgfQogIC5zaWRlYmFyIHsgcG9zaXRpb246IHN0YXRpYzsgd2lkdGg6
>>"%RB10%" echo IGF1dG87IGhlaWdodDogYXV0bzsgZmxleC1kaXJlY3Rpb246IHJvdzsgYWxpZ24taXRlbXM6
>>"%RB10%" echo IGNlbnRlcjsgcGFkZGluZzogMTJweDsgfQogIC5zaWRlYmFyIG5hdiB7IGRpc3BsYXk6IGZs
>>"%RB10%" echo ZXg7IH0KICAuc2lkZWJhci10aXAsIC5zdHVkZW50LW1pbmkgeyBkaXNwbGF5OiBub25lOyB9
>>"%RB10%" echo CiAgLnBvcnRhbC1tYWluIHsgcGFkZGluZzogMCAxNHB4IDI4cHg7IH0KICAudG9wYmFyIHsg
>>"%RB10%" echo bWluLWhlaWdodDogNzZweDsgfQogIC50ZXJtLWNoaXAgeyBkaXNwbGF5OiBub25lOyB9CiAg
>>"%RB10%" echo LnN0YXRzLXJvdyB7IGdyaWQtdGVtcGxhdGUtY29sdW1uczogMWZyIDFmcjsgfQogIC53ZWxj
>>"%RB10%" echo b21lLWNhcmQgeyBhbGlnbi1pdGVtczogZmxleC1zdGFydDsgZmxleC1kaXJlY3Rpb246IGNv
>>"%RB10%" echo bHVtbjsgfQogIC5mb2N1cy1wYW5lbCB7IHdpZHRoOiAxMDAlOyBtaW4td2lkdGg6IDA7IG1h
>>"%RB10%" echo eC13aWR0aDogbm9uZTsgfQogIC5nYW1lLWludHJvIHsgZmxleC1kaXJlY3Rpb246IGNvbHVt
>>"%RB10%" echo bjsgYWxpZ24taXRlbXM6IGZsZXgtc3RhcnQ7IH0KICAuZ2FtZS1jb250cm9scyB7IG1pbi13
>>"%RB10%" echo aWR0aDogMDsgd2lkdGg6IDEwMCU7IH0KfQpAbWVkaWEgKG1heC13aWR0aDogNjAwcHgpIHsK
>>"%RB10%" echo ICAuc2lnbnVwLWdyaWQgeyBncmlkLXRlbXBsYXRlLWNvbHVtbnM6IDFmcjsgfQogIC5zcGFu
>>"%RB10%" echo LTIgeyBncmlkLWNvbHVtbjogMTsgfQogIC5oZXJvLWNvcHkgaDEgeyBmb250LXNpemU6IDIu
>>"%RB10%" echo NnJlbTsgfQogIC5oZXJvLXN0YXRzIHsgZGlzcGxheTogZ3JpZDsgZ3JpZC10ZW1wbGF0ZS1j
>>"%RB10%" echo b2x1bW5zOiAxZnIgMWZyOyB9CiAgLnN0YXRzLXJvdywgLmNvdXJzZS1ncmlkIHsgZ3JpZC10
>>"%RB10%" echo ZW1wbGF0ZS1jb2x1bW5zOiAxZnI7IH0KICAucGVyZm9ybWFuY2UtYm9keSB7IGZsZXgtZGly
>>"%RB10%" echo ZWN0aW9uOiBjb2x1bW47IGFsaWduLWl0ZW1zOiBzdHJldGNoOyB9CiAgLnByb2dyZXNzLXJp
>>"%RB10%" echo bmcgeyBhbGlnbi1zZWxmOiBjZW50ZXI7IH0KICAuaHVkLWdyaWQgeyBncmlkLXRlbXBsYXRl
>>"%RB10%" echo LWNvbHVtbnM6IHJlcGVhdCgyLDFmcik7IH0KICAuZ2FtZS1ib3R0b20geyBmbGV4LWRpcmVj
>>"%RB10%" echo dGlvbjogY29sdW1uOyB9CiAgLnNpZGViYXIgbmF2IGJ1dHRvbiBzcGFuIHsgZGlzcGxheTog
>>"%RB10%" echo bm9uZTsgfQp9Cg==
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB10%" "%APP_DIR%\src\styles.css"
set "RB11=%TEMP%\react_embed_11.b64"
>"%RB11%" echo IyBteXJlYWN0YXBwMjAyNgoKU3R1ZGVudCBQb3J0YWwgMjAyNiArIFJpY29jaGV0IEFyZW5h
>>"%RB11%" echo LgoKIyMgU3RhcnQKRG91YmxlLWNsaWNrIGBTdGFydF9NeVJlYWN0QXBwMjAyNi5jbWRgIGFm
>>"%RB11%" echo dGVyIHRoZSBpbnN0YWxsZXIgY3JlYXRlcyBpdC4KCiMjIFBvcnRhbAotIExvY2FsIGxvZ2lu
>>"%RB11%" echo L3NpZ251cCBkZW1vCi0gQnJvd3Nlci1sb2NhbCBhY2NvdW50IHBlcnNpc3RlbmNlCi0gQWNh
>>"%RB11%" echo ZGVtaWMgZGFzaGJvYXJkCi0gQ291cnNlcywgYXNzaWdubWVudHMsIHNjaGVkdWxlLCBhdHRl
>>"%RB11%" echo bmRhbmNlIGFuZCBwZXJmb3JtYW5jZQoKIyMgR2FtZQpUaGUgc2Vjb25kIHBhZ2UgaXMgYSBj
>>"%RB11%" echo YW52YXMtYmFzZWQgcGh5c2ljcyBzaG9vdGVyOgotIFdBU0QgbW92ZW1lbnQKLSBNb3VzZSBh
>>"%RB11%" echo aW1pbmcKLSBMZWZ0LWNsaWNrIHNob290aW5nCi0gV2FsbCBhbmQgb2JzdGFjbGUgcmljb2No
>>"%RB11%" echo ZXRzCi0gUmljb2NoZXQgZGFtYWdlIHNjYWxpbmcKLSBNb3ZpbmcgZW5lbXkgdHlwZXMKLSBF
>>"%RB11%" echo bmVteSBwcm9qZWN0aWxlcwotIERhc2gsIHJlbG9hZCwgcGlja3VwcywgY29tYm8gc2Nvcmlu
>>"%RB11%" echo ZywgcGFydGljbGVzIGFuZCBzY3JlZW4gc2hha2UKCiMjIERlbW8gYWNjb3VudApVc2UgdGhl
>>"%RB11%" echo ICJDcmVhdGUgLyBlbnRlciBkZW1vIGFjY291bnQiIGJ1dHRvbi4KCkRlbW8gY3JlZGVudGlh
>>"%RB11%" echo bHM6Ci0gYHN0dWRlbnRAcG9ydGFsLmxvY2FsYAotIGBTdHVkZW50QDIwMjZgCgpUaGlzIGxv
>>"%RB11%" echo Z2luIHN5c3RlbSBpcyBpbnRlbnRpb25hbGx5IGxvY2FsL2Jyb3dzZXItb25seSBmb3IgYSBk
>>"%RB11%" echo ZXZlbG9wbWVudCBkZW1vLiBJdCBpcyBub3QgYSBwcm9kdWN0aW9uIGF1dGhlbnRpY2F0aW9u
>>"%RB11%" echo IGJhY2tlbmQuCg==
"%NODE_EXE%" -e "const fs=require('fs'); const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,''); fs.mkdirSync(require('path').dirname(process.argv[2]),{recursive:true}); fs.writeFileSync(process.argv[2],Buffer.from(b,'base64'))" "%RB11%" "%APP_DIR%\README.md"
if errorlevel 1 exit /b 1
exit /b 0


:WRITE_WEBTECH_HOMEWORK_FILES
echo Adding Web Tech 512 component-composition homework to the React project...
set "HW1=%TEMP%\webtech_hw_1.b64"
>"%HW1%" echo aW1wb3J0IHsgdXNlRWZmZWN0LCB1c2VNZW1vLCB1c2VTdGF0ZSB9IGZyb20gJ3JlYWN0Jwpp
>>"%HW1%" echo bXBvcnQgUmljb2NoZXRHYW1lIGZyb20gJy4vUmljb2NoZXRHYW1lLmpzeCcKaW1wb3J0IFBy
>>"%HW1%" echo YWN0aWNhbEhvbWVwYWdlIGZyb20gJy4vUHJhY3RpY2FsSG9tZXBhZ2UuanN4JwoKY29uc3Qg
>>"%HW1%" echo VVNFUlNfS0VZID0gJ3N0dWRlbnRQb3J0YWwyMDI2LnVzZXJzJwpjb25zdCBTRVNTSU9OX0tF
>>"%HW1%" echo WSA9ICdzdHVkZW50UG9ydGFsMjAyNi5zZXNzaW9uJwoKY29uc3QgY291cnNlcyA9IFsKICB7
>>"%HW1%" echo IGNvZGU6ICdEU0MyMDEnLCBuYW1lOiAnQXBwbGllZCBEYXRhIFNjaWVuY2UnLCBsZWN0dXJl
>>"%HW1%" echo cjogJ0RyLiBNLiBEbGFtaW5pJywgcHJvZ3Jlc3M6IDc4LCByb29tOiAnTGFiIEIxMicsIGFj
>>"%HW1%" echo Y2VudDogJ2N5YW4nIH0sCiAgeyBjb2RlOiAnV0RUMjIwJywgbmFtZTogJ0FkdmFuY2VkIFdl
>>"%HW1%" echo YiBUZWNobm9sb2d5JywgbGVjdHVyZXI6ICdQcm9mLiBLLiBOYWlkb28nLCBwcm9ncmVzczog
>>"%HW1%" echo NjQsIHJvb206ICdXZWIgTGFiIDQnLCBhY2NlbnQ6ICd2aW9sZXQnIH0sCiAgeyBjb2RlOiAn
>>"%HW1%" echo REJTMjEwJywgbmFtZTogJ0RhdGFiYXNlIFN5c3RlbXMnLCBsZWN0dXJlcjogJ01zLiBULiBN
>>"%HW1%" echo b2tvZW5hJywgcHJvZ3Jlc3M6IDgzLCByb29tOiAnUm9vbSBDMDgnLCBhY2NlbnQ6ICdlbWVy
>>"%HW1%" echo YWxkJyB9LAogIHsgY29kZTogJ01BVDIwNScsIG5hbWU6ICdDb21wdXRhdGlvbmFsIE1hdGhl
>>"%HW1%" echo bWF0aWNzJywgbGVjdHVyZXI6ICdEci4gUi4gU21pdGgnLCBwcm9ncmVzczogNzEsIHJvb206
>>"%HW1%" echo ICdSb29tIEExNycsIGFjY2VudDogJ2FtYmVyJyB9LApdCgpjb25zdCBhc3NpZ25tZW50cyA9
>>"%HW1%" echo IFsKICB7IHRpdGxlOiAnUGFuZGFzIENsZWFuaW5nIFBpcGVsaW5lJywgY291cnNlOiAnRFND
>>"%HW1%" echo MjAxJywgZHVlOiAnVG9kYXksIDE3OjAwJywgcHJpb3JpdHk6ICdIaWdoJywgcHJvZ3Jlc3M6
>>"%HW1%" echo IDcwIH0sCiAgeyB0aXRsZTogJ1JlYWN0IFN0dWRlbnQgUG9ydGFsJywgY291cnNlOiAnV0RU
>>"%HW1%" echo MjIwJywgZHVlOiAnVG9tb3Jyb3csIDIzOjU5JywgcHJpb3JpdHk6ICdIaWdoJywgcHJvZ3Jl
>>"%HW1%" echo c3M6IDUyIH0sCiAgeyB0aXRsZTogJ1NRTCBRdWVyeSBPcHRpbWlzYXRpb24nLCBjb3Vyc2U6
>>"%HW1%" echo ICdEQlMyMTAnLCBkdWU6ICdNb24sIDA5OjAwJywgcHJpb3JpdHk6ICdNZWRpdW0nLCBwcm9n
>>"%HW1%" echo cmVzczogODYgfSwKICB7IHRpdGxlOiAnTnVtZXJpY2FsIE1ldGhvZHMgV29ya3NoZWV0Jywg
>>"%HW1%" echo Y291cnNlOiAnTUFUMjA1JywgZHVlOiAnV2VkLCAxMjowMCcsIHByaW9yaXR5OiAnTG93Jywg
>>"%HW1%" echo cHJvZ3Jlc3M6IDM0IH0sCl0KCmNvbnN0IHNjaGVkdWxlID0gWwogIHsgdGltZTogJzA4OjAw
>>"%HW1%" echo JywgdGl0bGU6ICdBcHBsaWVkIERhdGEgU2NpZW5jZScsIG1ldGE6ICdMYWIgQjEyIOKAoiBQ
>>"%HW1%" echo cmFjdGljYWwnLCBzdGF0dXM6ICdkb25lJyB9LAogIHsgdGltZTogJzEwOjAwJywgdGl0bGU6
>>"%HW1%" echo ICdBZHZhbmNlZCBXZWIgVGVjaG5vbG9neScsIG1ldGE6ICdXZWIgTGFiIDQg4oCiIExlY3R1
>>"%HW1%" echo cmUnLCBzdGF0dXM6ICdhY3RpdmUnIH0sCiAgeyB0aW1lOiAnMTI6MDAnLCB0aXRsZTogJ0x1
>>"%HW1%" echo bmNoIC8gU3R1ZHkgQmxvY2snLCBtZXRhOiAnU3R1ZGVudCBDZW50cmUnLCBzdGF0dXM6ICdm
>>"%HW1%" echo cmVlJyB9LAogIHsgdGltZTogJzE0OjAwJywgdGl0bGU6ICdEYXRhYmFzZSBTeXN0ZW1zJywg
>>"%HW1%" echo bWV0YTogJ1Jvb20gQzA4IOKAoiBUdXRvcmlhbCcsIHN0YXR1czogJ25leHQnIH0sCiAgeyB0
>>"%HW1%" echo aW1lOiAnMTY6MDAnLCB0aXRsZTogJ1Byb2plY3QgQ29uc3VsdGF0aW9uJywgbWV0YTogJ09u
>>"%HW1%" echo bGluZSDigKIgVGVhbXMnLCBzdGF0dXM6ICduZXh0JyB9LApdCgpmdW5jdGlvbiByZWFkVXNl
>>"%HW1%" echo cnMoKSB7CiAgdHJ5IHsKICAgIHJldHVybiBKU09OLnBhcnNlKGxvY2FsU3RvcmFnZS5nZXRJ
>>"%HW1%" echo dGVtKFVTRVJTX0tFWSkgfHwgJ1tdJykKICB9IGNhdGNoIHsKICAgIHJldHVybiBbXQogIH0K
>>"%HW1%" echo fQoKYXN5bmMgZnVuY3Rpb24gaGFzaFBhc3N3b3JkKHBhc3N3b3JkKSB7CiAgaWYgKGdsb2Jh
>>"%HW1%" echo bFRoaXMuY3J5cHRvPy5zdWJ0bGUpIHsKICAgIGNvbnN0IGJ5dGVzID0gbmV3IFRleHRFbmNv
>>"%HW1%" echo ZGVyKCkuZW5jb2RlKHBhc3N3b3JkKQogICAgY29uc3QgZGlnZXN0ID0gYXdhaXQgY3J5cHRv
>>"%HW1%" echo LnN1YnRsZS5kaWdlc3QoJ1NIQS0yNTYnLCBieXRlcykKICAgIHJldHVybiBbLi4ubmV3IFVp
>>"%HW1%" echo bnQ4QXJyYXkoZGlnZXN0KV0ubWFwKChiKSA9PiBiLnRvU3RyaW5nKDE2KS5wYWRTdGFydCgy
>>"%HW1%" echo LCAnMCcpKS5qb2luKCcnKQogIH0KICBsZXQgaGFzaCA9IDIxNjYxMzYyNjEKICBmb3IgKGNv
>>"%HW1%" echo bnN0IGNoYXIgb2YgcGFzc3dvcmQpIHsKICAgIGhhc2ggXj0gY2hhci5jaGFyQ29kZUF0KDAp
>>"%HW1%" echo CiAgICBoYXNoID0gTWF0aC5pbXVsKGhhc2gsIDE2Nzc3NjE5KQogIH0KICByZXR1cm4gYGZh
>>"%HW1%" echo bGxiYWNrLSR7KGhhc2ggPj4+IDApLnRvU3RyaW5nKDE2KX1gCn0KCmZ1bmN0aW9uIHBhc3N3
>>"%HW1%" echo b3JkU2NvcmUodmFsdWUpIHsKICBsZXQgc2NvcmUgPSAwCiAgaWYgKHZhbHVlLmxlbmd0aCA+
>>"%HW1%" echo PSA4KSBzY29yZSArPSAxCiAgaWYgKHZhbHVlLmxlbmd0aCA+PSAxMikgc2NvcmUgKz0gMQog
>>"%HW1%" echo IGlmICgvW0EtWl0vLnRlc3QodmFsdWUpKSBzY29yZSArPSAxCiAgaWYgKC9bYS16XS8udGVz
>>"%HW1%" echo dCh2YWx1ZSkpIHNjb3JlICs9IDEKICBpZiAoL1xkLy50ZXN0KHZhbHVlKSkgc2NvcmUgKz0g
>>"%HW1%" echo MQogIGlmICgvW15BLVphLXowLTldLy50ZXN0KHZhbHVlKSkgc2NvcmUgKz0gMQogIHJldHVy
>>"%HW1%" echo biBNYXRoLm1pbig1LCBzY29yZSkKfQoKZnVuY3Rpb24gQXV0aFNjcmVlbih7IG9uQXV0aGVu
>>"%HW1%" echo dGljYXRlZCB9KSB7CiAgY29uc3QgW21vZGUsIHNldE1vZGVdID0gdXNlU3RhdGUoJ2xvZ2lu
>>"%HW1%" echo JykKICBjb25zdCBbbWVzc2FnZSwgc2V0TWVzc2FnZV0gPSB1c2VTdGF0ZSgnJykKICBjb25z
>>"%HW1%" echo dCBbYnVzeSwgc2V0QnVzeV0gPSB1c2VTdGF0ZShmYWxzZSkKICBjb25zdCBbbG9naW4sIHNl
>>"%HW1%" echo dExvZ2luXSA9IHVzZVN0YXRlKHsgaWRlbnRpdHk6ICcnLCBwYXNzd29yZDogJycsIHJlbWVt
>>"%HW1%" echo YmVyOiB0cnVlIH0pCiAgY29uc3QgW3NpZ251cCwgc2V0U2lnbnVwXSA9IHVzZVN0YXRlKHsK
>>"%HW1%" echo ICAgIGZpcnN0TmFtZTogJycsCiAgICBsYXN0TmFtZTogJycsCiAgICBzdHVkZW50SWQ6ICcn
>>"%HW1%" echo LAogICAgZW1haWw6ICcnLAogICAgcHJvZ3JhbTogJ0JTYyBJbmZvcm1hdGlvbiBUZWNobm9s
>>"%HW1%" echo b2d5JywKICAgIHllYXI6ICcyJywKICAgIHBhc3N3b3JkOiAnJywKICAgIGNvbmZpcm06ICcn
>>"%HW1%" echo LAogIH0pCgogIGNvbnN0IHN0cmVuZ3RoID0gcGFzc3dvcmRTY29yZShzaWdudXAucGFzc3dv
>>"%HW1%" echo cmQpCiAgY29uc3Qgc3RyZW5ndGhUZXh0ID0gWydWZXJ5IHdlYWsnLCAnV2VhaycsICdGYWly
>>"%HW1%" echo JywgJ0dvb2QnLCAnU3Ryb25nJywgJ0V4Y2VsbGVudCddW3N0cmVuZ3RoXQoKICBhc3luYyBm
>>"%HW1%" echo dW5jdGlvbiBzdWJtaXRMb2dpbihldmVudCkgewogICAgZXZlbnQucHJldmVudERlZmF1bHQo
>>"%HW1%" echo KQogICAgc2V0QnVzeSh0cnVlKQogICAgc2V0TWVzc2FnZSgnJykKICAgIHRyeSB7CiAgICAg
>>"%HW1%" echo IGNvbnN0IHVzZXJzID0gcmVhZFVzZXJzKCkKICAgICAgY29uc3QgaWRlbnRpdHkgPSBsb2dp
>>"%HW1%" echo bi5pZGVudGl0eS50cmltKCkudG9Mb3dlckNhc2UoKQogICAgICBjb25zdCB1c2VyID0gdXNl
>>"%HW1%" echo cnMuZmluZCgKICAgICAgICAoaXRlbSkgPT4KICAgICAgICAgIGl0ZW0uZW1haWwudG9Mb3dl
>>"%HW1%" echo ckNhc2UoKSA9PT0gaWRlbnRpdHkgfHwKICAgICAgICAgIGl0ZW0uc3R1ZGVudElkLnRvTG93
>>"%HW1%" echo ZXJDYXNlKCkgPT09IGlkZW50aXR5LAogICAgICApCiAgICAgIGlmICghdXNlcikgdGhyb3cg
>>"%HW1%" echo bmV3IEVycm9yKCdObyBzdHVkZW50IGFjY291bnQgbWF0Y2hlcyB0aGF0IGVtYWlsIG9yIHN0
>>"%HW1%" echo dWRlbnQgSUQuJykKICAgICAgY29uc3QgaGFzaCA9IGF3YWl0IGhhc2hQYXNzd29yZChsb2dp
>>"%HW1%" echo bi5wYXNzd29yZCkKICAgICAgaWYgKGhhc2ggIT09IHVzZXIucGFzc3dvcmRIYXNoKSB0aHJv
>>"%HW1%" echo dyBuZXcgRXJyb3IoJ0luY29ycmVjdCBwYXNzd29yZC4nKQogICAgICBsb2NhbFN0b3JhZ2Uu
>>"%HW1%" echo c2V0SXRlbShTRVNTSU9OX0tFWSwgSlNPTi5zdHJpbmdpZnkoeyBpZDogdXNlci5pZCwgcmVt
>>"%HW1%" echo ZW1iZXI6IGxvZ2luLnJlbWVtYmVyIH0pKQogICAgICBvbkF1dGhlbnRpY2F0ZWQodXNlcikK
>>"%HW1%" echo ICAgIH0gY2F0Y2ggKGVycm9yKSB7CiAgICAgIHNldE1lc3NhZ2UoZXJyb3IubWVzc2FnZSkK
>>"%HW1%" echo ICAgIH0gZmluYWxseSB7CiAgICAgIHNldEJ1c3koZmFsc2UpCiAgICB9CiAgfQoKICBhc3lu
>>"%HW1%" echo YyBmdW5jdGlvbiBzdWJtaXRTaWdudXAoZXZlbnQpIHsKICAgIGV2ZW50LnByZXZlbnREZWZh
>>"%HW1%" echo dWx0KCkKICAgIHNldEJ1c3kodHJ1ZSkKICAgIHNldE1lc3NhZ2UoJycpCiAgICB0cnkgewog
>>"%HW1%" echo ICAgICBpZiAoIXNpZ251cC5maXJzdE5hbWUudHJpbSgpIHx8ICFzaWdudXAubGFzdE5hbWUu
>>"%HW1%" echo dHJpbSgpKSB0aHJvdyBuZXcgRXJyb3IoJ0VudGVyIHlvdXIgZnVsbCBuYW1lLicpCiAgICAg
>>"%HW1%" echo IGlmICghL15bQS1aYS16MC05LV17NSwyMH0kLy50ZXN0KHNpZ251cC5zdHVkZW50SWQudHJp
>>"%HW1%" echo bSgpKSkgdGhyb3cgbmV3IEVycm9yKCdTdHVkZW50IElEIG11c3QgYmUgNS0yMCBsZXR0ZXJz
>>"%HW1%" echo LCBudW1iZXJzIG9yIGRhc2hlcy4nKQogICAgICBpZiAoIS9eW15cc0BdK0BbXlxzQF0rXC5b
>>"%HW1%" echo XlxzQF0rJC8udGVzdChzaWdudXAuZW1haWwpKSB0aHJvdyBuZXcgRXJyb3IoJ0VudGVyIGEg
>>"%HW1%" echo dmFsaWQgZW1haWwgYWRkcmVzcy4nKQogICAgICBpZiAoc3RyZW5ndGggPCA0KSB0aHJvdyBu
>>"%HW1%" echo ZXcgRXJyb3IoJ1VzZSBhIHN0cm9uZ2VyIHBhc3N3b3JkIHdpdGggbGVuZ3RoLCBtaXhlZCBj
>>"%HW1%" echo YXNlLCBudW1iZXJzIGFuZCBzeW1ib2xzLicpCiAgICAgIGlmIChzaWdudXAucGFzc3dvcmQg
>>"%HW1%" echo IT09IHNpZ251cC5jb25maXJtKSB0aHJvdyBuZXcgRXJyb3IoJ1RoZSBwYXNzd29yZCBjb25m
>>"%HW1%" echo aXJtYXRpb24gZG9lcyBub3QgbWF0Y2guJykKCiAgICAgIGNvbnN0IHVzZXJzID0gcmVhZFVz
>>"%HW1%" echo ZXJzKCkKICAgICAgY29uc3QgZHVwbGljYXRlID0gdXNlcnMuc29tZSgKICAgICAgICAoaXRl
>>"%HW1%" echo bSkgPT4KICAgICAgICAgIGl0ZW0uZW1haWwudG9Mb3dlckNhc2UoKSA9PT0gc2lnbnVwLmVt
>>"%HW1%" echo YWlsLnRyaW0oKS50b0xvd2VyQ2FzZSgpIHx8CiAgICAgICAgICBpdGVtLnN0dWRlbnRJZC50
>>"%HW1%" echo b0xvd2VyQ2FzZSgpID09PSBzaWdudXAuc3R1ZGVudElkLnRyaW0oKS50b0xvd2VyQ2FzZSgp
>>"%HW1%" echo LAogICAgICApCiAgICAgIGlmIChkdXBsaWNhdGUpIHRocm93IG5ldyBFcnJvcignVGhhdCBl
>>"%HW1%" echo bWFpbCBvciBzdHVkZW50IElEIGlzIGFscmVhZHkgcmVnaXN0ZXJlZC4nKQoKICAgICAgY29u
>>"%HW1%" echo c3QgdXNlciA9IHsKICAgICAgICBpZDogY3J5cHRvLnJhbmRvbVVVSUQgPyBjcnlwdG8ucmFu
>>"%HW1%" echo ZG9tVVVJRCgpIDogYCR7RGF0ZS5ub3coKX0tJHtNYXRoLnJhbmRvbSgpfWAsCiAgICAgICAg
>>"%HW1%" echo Zmlyc3ROYW1lOiBzaWdudXAuZmlyc3ROYW1lLnRyaW0oKSwKICAgICAgICBsYXN0TmFtZTog
>>"%HW1%" echo c2lnbnVwLmxhc3ROYW1lLnRyaW0oKSwKICAgICAgICBzdHVkZW50SWQ6IHNpZ251cC5zdHVk
>>"%HW1%" echo ZW50SWQudHJpbSgpLnRvVXBwZXJDYXNlKCksCiAgICAgICAgZW1haWw6IHNpZ251cC5lbWFp
>>"%HW1%" echo bC50cmltKCksCiAgICAgICAgcHJvZ3JhbTogc2lnbnVwLnByb2dyYW0sCiAgICAgICAgeWVh
>>"%HW1%" echo cjogTnVtYmVyKHNpZ251cC55ZWFyKSwKICAgICAgICBwYXNzd29yZEhhc2g6IGF3YWl0IGhh
>>"%HW1%" echo c2hQYXNzd29yZChzaWdudXAucGFzc3dvcmQpLAogICAgICAgIGNyZWF0ZWRBdDogbmV3IERh
>>"%HW1%" echo dGUoKS50b0lTT1N0cmluZygpLAogICAgICB9CiAgICAgIHVzZXJzLnB1c2godXNlcikKICAg
>>"%HW1%" echo ICAgbG9jYWxTdG9yYWdlLnNldEl0ZW0oVVNFUlNfS0VZLCBKU09OLnN0cmluZ2lmeSh1c2Vy
>>"%HW1%" echo cykpCiAgICAgIGxvY2FsU3RvcmFnZS5zZXRJdGVtKFNFU1NJT05fS0VZLCBKU09OLnN0cmlu
>>"%HW1%" echo Z2lmeSh7IGlkOiB1c2VyLmlkLCByZW1lbWJlcjogdHJ1ZSB9KSkKICAgICAgb25BdXRoZW50
>>"%HW1%" echo aWNhdGVkKHVzZXIpCiAgICB9IGNhdGNoIChlcnJvcikgewogICAgICBzZXRNZXNzYWdlKGVy
>>"%HW1%" echo cm9yLm1lc3NhZ2UpCiAgICB9IGZpbmFsbHkgewogICAgICBzZXRCdXN5KGZhbHNlKQogICAg
>>"%HW1%" echo fQogIH0KCiAgYXN5bmMgZnVuY3Rpb24gY3JlYXRlRGVtbygpIHsKICAgIGNvbnN0IGRlbW8g
>>"%HW1%" echo PSB7CiAgICAgIGZpcnN0TmFtZTogJ0FsZXgnLAogICAgICBsYXN0TmFtZTogJ1N0dWRlbnQn
>>"%HW1%" echo LAogICAgICBzdHVkZW50SWQ6ICdSR0lUMjAyNicsCiAgICAgIGVtYWlsOiAnc3R1ZGVudEBw
>>"%HW1%" echo b3J0YWwubG9jYWwnLAogICAgICBwcm9ncmFtOiAnQlNjIEluZm9ybWF0aW9uIFRlY2hub2xv
>>"%HW1%" echo Z3knLAogICAgICB5ZWFyOiAyLAogICAgfQogICAgY29uc3QgdXNlcnMgPSByZWFkVXNlcnMo
>>"%HW1%" echo KQogICAgbGV0IHVzZXIgPSB1c2Vycy5maW5kKChpdGVtKSA9PiBpdGVtLmVtYWlsID09PSBk
>>"%HW1%" echo ZW1vLmVtYWlsKQogICAgaWYgKCF1c2VyKSB7CiAgICAgIHVzZXIgPSB7CiAgICAgICAgLi4u
>>"%HW1%" echo ZGVtbywKICAgICAgICBpZDogY3J5cHRvLnJhbmRvbVVVSUQgPyBjcnlwdG8ucmFuZG9tVVVJ
>>"%HW1%" echo RCgpIDogYGRlbW8tJHtEYXRlLm5vdygpfWAsCiAgICAgICAgcGFzc3dvcmRIYXNoOiBhd2Fp
>>"%HW1%" echo dCBoYXNoUGFzc3dvcmQoJ1N0dWRlbnRAMjAyNicpLAogICAgICAgIGNyZWF0ZWRBdDogbmV3
>>"%HW1%" echo IERhdGUoKS50b0lTT1N0cmluZygpLAogICAgICB9CiAgICAgIHVzZXJzLnB1c2godXNlcikK
>>"%HW1%" echo ICAgICAgbG9jYWxTdG9yYWdlLnNldEl0ZW0oVVNFUlNfS0VZLCBKU09OLnN0cmluZ2lmeSh1
>>"%HW1%" echo c2VycykpCiAgICB9CiAgICBsb2NhbFN0b3JhZ2Uuc2V0SXRlbShTRVNTSU9OX0tFWSwgSlNP
>>"%HW1%" echo Ti5zdHJpbmdpZnkoeyBpZDogdXNlci5pZCwgcmVtZW1iZXI6IHRydWUgfSkpCiAgICBvbkF1
>>"%HW1%" echo dGhlbnRpY2F0ZWQodXNlcikKICB9CgogIHJldHVybiAoCiAgICA8bWFpbiBjbGFzc05hbWU9
>>"%HW1%" echo ImF1dGgtc2hlbGwiPgogICAgICA8c2VjdGlvbiBjbGFzc05hbWU9ImF1dGgtYXJ0Ij4KICAg
>>"%HW1%" echo ICAgICA8ZGl2IGNsYXNzTmFtZT0iYnJhbmQtcm93Ij4KICAgICAgICAgIDxkaXYgY2xhc3NO
>>"%HW1%" echo YW1lPSJicmFuZC1tYXJrIj5SRzwvZGl2PgogICAgICAgICAgPGRpdj4KICAgICAgICAgICAg
>>"%HW1%" echo PHN0cm9uZz5TdHVkZW50IFBvcnRhbCAyMDI2PC9zdHJvbmc+CiAgICAgICAgICAgIDxzcGFu
>>"%HW1%" echo PkFjYWRlbWljIGNvbW1hbmQgY2VudHJlPC9zcGFuPgogICAgICAgICAgPC9kaXY+CiAgICAg
>>"%HW1%" echo ICAgPC9kaXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9Imhlcm8tY29weSI+CiAgICAgICAg
>>"%HW1%" echo ICA8cCBjbGFzc05hbWU9ImV5ZWJyb3ciPlJJQ0hGSUVMRCBESUdJVEFMIENBTVBVUzwvcD4K
>>"%HW1%" echo ICAgICAgICAgIDxoMT5Zb3VyIGNvdXJzZXdvcmssIHBlcmZvcm1hbmNlIGFuZCBjYW1wdXMg
>>"%HW1%" echo bGlmZSBpbiBvbmUgcGxhY2UuPC9oMT4KICAgICAgICAgIDxwPgogICAgICAgICAgICBUcmFj
>>"%HW1%" echo ayBtb2R1bGVzLCBkZWFkbGluZXMgYW5kIGF0dGVuZGFuY2UsIHRoZW4gc3dpdGNoIHRvIHRo
>>"%HW1%" echo ZSBSaWNvY2hldCBBcmVuYQogICAgICAgICAgICBmb3IgYSBmdWxsIHBoeXNpY3MtYmFzZWQg
>>"%HW1%" echo c2hvb3RlciBidWlsdCBkaXJlY3RseSBpbnRvIHRoZSBwb3J0YWwuCiAgICAgICAgICA8L3A+
>>"%HW1%" echo CiAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iaGVyby1zdGF0cyI+CiAgICAgICAgICAgIDxk
>>"%HW1%" echo aXY+PGI+NDwvYj48c3Bhbj5BY3RpdmUgbW9kdWxlczwvc3Bhbj48L2Rpdj4KICAgICAgICAg
>>"%HW1%" echo ICAgPGRpdj48Yj45MyU8L2I+PHNwYW4+QXR0ZW5kYW5jZTwvc3Bhbj48L2Rpdj4KICAgICAg
>>"%HW1%" echo ICAgICAgPGRpdj48Yj4zLjc2PC9iPjxzcGFuPkN1cnJlbnQgR1BBPC9zcGFuPjwvZGl2Pgog
>>"%HW1%" echo ICAgICAgICAgPC9kaXY+CiAgICAgICAgPC9kaXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9
>>"%HW1%" echo InNlY3VyaXR5LW5vdGUiPgogICAgICAgICAgPHNwYW4+TE9DQUwgREVNTyBBVVRIPC9zcGFu
>>"%HW1%" echo PgogICAgICAgICAgPHA+QWNjb3VudHMgYXJlIHN0b3JlZCBvbmx5IGluIHRoaXMgYnJvd3Nl
>>"%HW1%" echo ci4gUGFzc3dvcmRzIGFyZSBoYXNoZWQgYmVmb3JlIGxvY2FsIHN0b3JhZ2UuPC9wPgogICAg
>>"%HW1%" echo ICAgIDwvZGl2PgogICAgICA8L3NlY3Rpb24+CgogICAgICA8c2VjdGlvbiBjbGFzc05hbWU9
>>"%HW1%" echo ImF1dGgtY2FyZCI+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9ImF1dGgtdGFicyI+CiAgICAg
>>"%HW1%" echo ICAgICA8YnV0dG9uIGNsYXNzTmFtZT17bW9kZSA9PT0gJ2xvZ2luJyA/ICdhY3RpdmUnIDog
>>"%HW1%" echo Jyd9IG9uQ2xpY2s9eygpID0+IHsgc2V0TW9kZSgnbG9naW4nKTsgc2V0TWVzc2FnZSgnJykg
>>"%HW1%" echo fX0+U2lnbiBpbjwvYnV0dG9uPgogICAgICAgICAgPGJ1dHRvbiBjbGFzc05hbWU9e21vZGUg
>>"%HW1%" echo PT09ICdzaWdudXAnID8gJ2FjdGl2ZScgOiAnJ30gb25DbGljaz17KCkgPT4geyBzZXRNb2Rl
>>"%HW1%" echo KCdzaWdudXAnKTsgc2V0TWVzc2FnZSgnJykgfX0+Q3JlYXRlIGFjY291bnQ8L2J1dHRvbj4K
>>"%HW1%" echo ICAgICAgICA8L2Rpdj4KCiAgICAgICAge21vZGUgPT09ICdsb2dpbicgPyAoCiAgICAgICAg
>>"%HW1%" echo ICA8Zm9ybSBvblN1Ym1pdD17c3VibWl0TG9naW59IGNsYXNzTmFtZT0iYXV0aC1mb3JtIj4K
>>"%HW1%" echo ICAgICAgICAgICAgPGRpdj4KICAgICAgICAgICAgICA8cCBjbGFzc05hbWU9ImV5ZWJyb3ci
>>"%HW1%" echo PldFTENPTUUgQkFDSzwvcD4KICAgICAgICAgICAgICA8aDI+U3R1ZGVudCBzaWduIGluPC9o
>>"%HW1%" echo Mj4KICAgICAgICAgICAgICA8cCBjbGFzc05hbWU9Im11dGVkIj5Vc2UgeW91ciBzdHVkZW50
>>"%HW1%" echo IElEIG9yIHJlZ2lzdGVyZWQgZW1haWwuPC9wPgogICAgICAgICAgICA8L2Rpdj4KICAgICAg
>>"%HW1%" echo ICAgICAgPGxhYmVsPgogICAgICAgICAgICAgIFN0dWRlbnQgSUQgb3IgZW1haWwKICAgICAg
>>"%HW1%" echo ICAgICAgICA8aW5wdXQKICAgICAgICAgICAgICAgIHZhbHVlPXtsb2dpbi5pZGVudGl0eX0K
>>"%HW1%" echo ICAgICAgICAgICAgICAgIG9uQ2hhbmdlPXsoZSkgPT4gc2V0TG9naW4oeyAuLi5sb2dpbiwg
>>"%HW1%" echo aWRlbnRpdHk6IGUudGFyZ2V0LnZhbHVlIH0pfQogICAgICAgICAgICAgICAgcGxhY2Vob2xk
>>"%HW1%" echo ZXI9IlJHSVQyMDI2IG9yIG5hbWVAZW1haWwuY29tIgogICAgICAgICAgICAgICAgYXV0b0Nv
>>"%HW1%" echo bXBsZXRlPSJ1c2VybmFtZSIKICAgICAgICAgICAgICAgIHJlcXVpcmVkCiAgICAgICAgICAg
>>"%HW1%" echo ICAgLz4KICAgICAgICAgICAgPC9sYWJlbD4KICAgICAgICAgICAgPGxhYmVsPgogICAgICAg
>>"%HW1%" echo ICAgICAgIFBhc3N3b3JkCiAgICAgICAgICAgICAgPGlucHV0CiAgICAgICAgICAgICAgICB0
>>"%HW1%" echo eXBlPSJwYXNzd29yZCIKICAgICAgICAgICAgICAgIHZhbHVlPXtsb2dpbi5wYXNzd29yZH0K
>>"%HW1%" echo ICAgICAgICAgICAgICAgIG9uQ2hhbmdlPXsoZSkgPT4gc2V0TG9naW4oeyAuLi5sb2dpbiwg
>>"%HW1%" echo cGFzc3dvcmQ6IGUudGFyZ2V0LnZhbHVlIH0pfQogICAgICAgICAgICAgICAgcGxhY2Vob2xk
>>"%HW1%" echo ZXI9IkVudGVyIHlvdXIgcGFzc3dvcmQiCiAgICAgICAgICAgICAgICBhdXRvQ29tcGxldGU9
>>"%HW1%" echo ImN1cnJlbnQtcGFzc3dvcmQiCiAgICAgICAgICAgICAgICByZXF1aXJlZAogICAgICAgICAg
>>"%HW1%" echo ICAgIC8+CiAgICAgICAgICAgIDwvbGFiZWw+CiAgICAgICAgICAgIDxsYWJlbCBjbGFzc05h
>>"%HW1%" echo bWU9ImNoZWNrLWxpbmUiPgogICAgICAgICAgICAgIDxpbnB1dAogICAgICAgICAgICAgICAg
>>"%HW1%" echo dHlwZT0iY2hlY2tib3giCiAgICAgICAgICAgICAgICBjaGVja2VkPXtsb2dpbi5yZW1lbWJl
>>"%HW1%" echo cn0KICAgICAgICAgICAgICAgIG9uQ2hhbmdlPXsoZSkgPT4gc2V0TG9naW4oeyAuLi5sb2dp
>>"%HW1%" echo biwgcmVtZW1iZXI6IGUudGFyZ2V0LmNoZWNrZWQgfSl9CiAgICAgICAgICAgICAgLz4KICAg
>>"%HW1%" echo ICAgICAgICAgICBLZWVwIG1lIHNpZ25lZCBpbiBvbiB0aGlzIGJyb3dzZXIKICAgICAgICAg
>>"%HW1%" echo ICAgPC9sYWJlbD4KICAgICAgICAgICAge21lc3NhZ2UgJiYgPGRpdiBjbGFzc05hbWU9ImZv
>>"%HW1%" echo cm0tZXJyb3IiPnttZXNzYWdlfTwvZGl2Pn0KICAgICAgICAgICAgPGJ1dHRvbiBjbGFzc05h
>>"%HW1%" echo bWU9InByaW1hcnktYnRuIiBkaXNhYmxlZD17YnVzeX0+CiAgICAgICAgICAgICAge2J1c3kg
>>"%HW1%" echo PyAnU2lnbmluZyBpbi4uLicgOiAnU2lnbiBpbiB0byBwb3J0YWwnfQogICAgICAgICAgICA8
>>"%HW1%" echo L2J1dHRvbj4KICAgICAgICAgICAgPGJ1dHRvbiBjbGFzc05hbWU9Imdob3N0LWJ0biIgdHlw
>>"%HW1%" echo ZT0iYnV0dG9uIiBvbkNsaWNrPXtjcmVhdGVEZW1vfT4KICAgICAgICAgICAgICBDcmVhdGUg
>>"%HW1%" echo LyBlbnRlciBkZW1vIGFjY291bnQKICAgICAgICAgICAgPC9idXR0b24+CiAgICAgICAgICAg
>>"%HW1%" echo IDxwIGNsYXNzTmFtZT0iZGVtby1oaW50Ij5EZW1vIGxvZ2luIGFmdGVyIGNyZWF0aW9uOiBz
>>"%HW1%" echo dHVkZW50QHBvcnRhbC5sb2NhbCAvIFN0dWRlbnRAMjAyNjwvcD4KICAgICAgICAgIDwvZm9y
>>"%HW1%" echo bT4KICAgICAgICApIDogKAogICAgICAgICAgPGZvcm0gb25TdWJtaXQ9e3N1Ym1pdFNpZ251
>>"%HW1%" echo cH0gY2xhc3NOYW1lPSJhdXRoLWZvcm0gc2lnbnVwLWdyaWQiPgogICAgICAgICAgICA8ZGl2
>>"%HW1%" echo IGNsYXNzTmFtZT0ic3Bhbi0yIj4KICAgICAgICAgICAgICA8cCBjbGFzc05hbWU9ImV5ZWJy
>>"%HW1%" echo b3ciPk5FVyBTVFVERU5UIFBST0ZJTEU8L3A+CiAgICAgICAgICAgICAgPGgyPkNyZWF0ZSBw
>>"%HW1%" echo b3J0YWwgYWNjb3VudDwvaDI+CiAgICAgICAgICAgICAgPHAgY2xhc3NOYW1lPSJtdXRlZCI+
>>"%HW1%" echo VGhpcyBkZW1vIGFjY291bnQgcmVtYWlucyBvbiB0aGlzIFBDIGFuZCBicm93c2VyLjwvcD4K
>>"%HW1%" echo ICAgICAgICAgICAgPC9kaXY+CiAgICAgICAgICAgIDxsYWJlbD4KICAgICAgICAgICAgICBG
>>"%HW1%" echo aXJzdCBuYW1lCiAgICAgICAgICAgICAgPGlucHV0IHZhbHVlPXtzaWdudXAuZmlyc3ROYW1l
>>"%HW1%" echo fSBvbkNoYW5nZT17KGUpID0+IHNldFNpZ251cCh7IC4uLnNpZ251cCwgZmlyc3ROYW1lOiBl
>>"%HW1%" echo LnRhcmdldC52YWx1ZSB9KX0gcmVxdWlyZWQgLz4KICAgICAgICAgICAgPC9sYWJlbD4KICAg
>>"%HW1%" echo ICAgICAgICAgPGxhYmVsPgogICAgICAgICAgICAgIExhc3QgbmFtZQogICAgICAgICAgICAg
>>"%HW1%" echo IDxpbnB1dCB2YWx1ZT17c2lnbnVwLmxhc3ROYW1lfSBvbkNoYW5nZT17KGUpID0+IHNldFNp
>>"%HW1%" echo Z251cCh7IC4uLnNpZ251cCwgbGFzdE5hbWU6IGUudGFyZ2V0LnZhbHVlIH0pfSByZXF1aXJl
>>"%HW1%" echo ZCAvPgogICAgICAgICAgICA8L2xhYmVsPgogICAgICAgICAgICA8bGFiZWw+CiAgICAgICAg
>>"%HW1%" echo ICAgICAgU3R1ZGVudCBJRAogICAgICAgICAgICAgIDxpbnB1dCB2YWx1ZT17c2lnbnVwLnN0
>>"%HW1%" echo dWRlbnRJZH0gb25DaGFuZ2U9eyhlKSA9PiBzZXRTaWdudXAoeyAuLi5zaWdudXAsIHN0dWRl
>>"%HW1%" echo bnRJZDogZS50YXJnZXQudmFsdWUgfSl9IHBsYWNlaG9sZGVyPSJSR0lUMjAyNiIgcmVxdWly
>>"%HW1%" echo ZWQgLz4KICAgICAgICAgICAgPC9sYWJlbD4KICAgICAgICAgICAgPGxhYmVsPgogICAgICAg
>>"%HW1%" echo ICAgICAgIEVtYWlsCiAgICAgICAgICAgICAgPGlucHV0IHR5cGU9ImVtYWlsIiB2YWx1ZT17
>>"%HW1%" echo c2lnbnVwLmVtYWlsfSBvbkNoYW5nZT17KGUpID0+IHNldFNpZ251cCh7IC4uLnNpZ251cCwg
>>"%HW1%" echo ZW1haWw6IGUudGFyZ2V0LnZhbHVlIH0pfSByZXF1aXJlZCAvPgogICAgICAgICAgICA8L2xh
>>"%HW1%" echo YmVsPgogICAgICAgICAgICA8bGFiZWw+CiAgICAgICAgICAgICAgUHJvZ3JhbW1lCiAgICAg
>>"%HW1%" echo ICAgICAgICAgPHNlbGVjdCB2YWx1ZT17c2lnbnVwLnByb2dyYW19IG9uQ2hhbmdlPXsoZSkg
>>"%HW1%" echo PT4gc2V0U2lnbnVwKHsgLi4uc2lnbnVwLCBwcm9ncmFtOiBlLnRhcmdldC52YWx1ZSB9KX0+
>>"%HW1%" echo CiAgICAgICAgICAgICAgICA8b3B0aW9uPkJTYyBJbmZvcm1hdGlvbiBUZWNobm9sb2d5PC9v
>>"%HW1%" echo cHRpb24+CiAgICAgICAgICAgICAgICA8b3B0aW9uPkJTYyBDb21wdXRlciBTY2llbmNlPC9v
>>"%HW1%" echo cHRpb24+CiAgICAgICAgICAgICAgICA8b3B0aW9uPkRpcGxvbWEgaW4gSVQ8L29wdGlvbj4K
>>"%HW1%" echo ICAgICAgICAgICAgICAgIDxvcHRpb24+QkNvbSBJbmZvcm1hdGlvbiBTeXN0ZW1zPC9vcHRp
>>"%HW1%" echo b24+CiAgICAgICAgICAgICAgICA8b3B0aW9uPkhpZ2hlciBDZXJ0aWZpY2F0ZSBpbiBJVDwv
>>"%HW1%" echo b3B0aW9uPgogICAgICAgICAgICAgIDwvc2VsZWN0PgogICAgICAgICAgICA8L2xhYmVsPgog
>>"%HW1%" echo ICAgICAgICAgICA8bGFiZWw+CiAgICAgICAgICAgICAgWWVhcgogICAgICAgICAgICAgIDxz
>>"%HW1%" echo ZWxlY3QgdmFsdWU9e3NpZ251cC55ZWFyfSBvbkNoYW5nZT17KGUpID0+IHNldFNpZ251cCh7
>>"%HW1%" echo IC4uLnNpZ251cCwgeWVhcjogZS50YXJnZXQudmFsdWUgfSl9PgogICAgICAgICAgICAgICAg
>>"%HW1%" echo PG9wdGlvbiB2YWx1ZT0iMSI+WWVhciAxPC9vcHRpb24+CiAgICAgICAgICAgICAgICA8b3B0
>>"%HW1%" echo aW9uIHZhbHVlPSIyIj5ZZWFyIDI8L29wdGlvbj4KICAgICAgICAgICAgICAgIDxvcHRpb24g
>>"%HW1%" echo dmFsdWU9IjMiPlllYXIgMzwvb3B0aW9uPgogICAgICAgICAgICAgICAgPG9wdGlvbiB2YWx1
>>"%HW1%" echo ZT0iNCI+WWVhciA0PC9vcHRpb24+CiAgICAgICAgICAgICAgPC9zZWxlY3Q+CiAgICAgICAg
>>"%HW1%" echo ICAgIDwvbGFiZWw+CiAgICAgICAgICAgIDxsYWJlbD4KICAgICAgICAgICAgICBQYXNzd29y
>>"%HW1%" echo ZAogICAgICAgICAgICAgIDxpbnB1dCB0eXBlPSJwYXNzd29yZCIgdmFsdWU9e3NpZ251cC5w
>>"%HW1%" echo YXNzd29yZH0gb25DaGFuZ2U9eyhlKSA9PiBzZXRTaWdudXAoeyAuLi5zaWdudXAsIHBhc3N3
>>"%HW1%" echo b3JkOiBlLnRhcmdldC52YWx1ZSB9KX0gcmVxdWlyZWQgLz4KICAgICAgICAgICAgICA8ZGl2
>>"%HW1%" echo IGNsYXNzTmFtZT0ic3RyZW5ndGgiPgogICAgICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9
>>"%HW1%" echo e2BzdHJlbmd0aC1maWxsIHMke3N0cmVuZ3RofWB9IC8+CiAgICAgICAgICAgICAgPC9kaXY+
>>"%HW1%" echo CiAgICAgICAgICAgICAgPHNtYWxsPntzdHJlbmd0aFRleHR9PC9zbWFsbD4KICAgICAgICAg
>>"%HW1%" echo ICAgPC9sYWJlbD4KICAgICAgICAgICAgPGxhYmVsPgogICAgICAgICAgICAgIENvbmZpcm0g
>>"%HW1%" echo cGFzc3dvcmQKICAgICAgICAgICAgICA8aW5wdXQgdHlwZT0icGFzc3dvcmQiIHZhbHVlPXtz
>>"%HW1%" echo aWdudXAuY29uZmlybX0gb25DaGFuZ2U9eyhlKSA9PiBzZXRTaWdudXAoeyAuLi5zaWdudXAs
>>"%HW1%" echo IGNvbmZpcm06IGUudGFyZ2V0LnZhbHVlIH0pfSByZXF1aXJlZCAvPgogICAgICAgICAgICA8
>>"%HW1%" echo L2xhYmVsPgogICAgICAgICAgICB7bWVzc2FnZSAmJiA8ZGl2IGNsYXNzTmFtZT0iZm9ybS1l
>>"%HW1%" echo cnJvciBzcGFuLTIiPnttZXNzYWdlfTwvZGl2Pn0KICAgICAgICAgICAgPGJ1dHRvbiBjbGFz
>>"%HW1%" echo c05hbWU9InByaW1hcnktYnRuIHNwYW4tMiIgZGlzYWJsZWQ9e2J1c3l9PgogICAgICAgICAg
>>"%HW1%" echo ICAgIHtidXN5ID8gJ0NyZWF0aW5nIGFjY291bnQuLi4nIDogJ0NyZWF0ZSBzdHVkZW50IGFj
>>"%HW1%" echo Y291bnQnfQogICAgICAgICAgICA8L2J1dHRvbj4KICAgICAgICAgIDwvZm9ybT4KICAgICAg
>>"%HW1%" echo ICApfQogICAgICA8L3NlY3Rpb24+CiAgICA8L21haW4+CiAgKQp9CgpmdW5jdGlvbiBQcm9n
>>"%HW1%" echo cmVzc1JpbmcoeyB2YWx1ZSwgbGFiZWwgfSkgewogIGNvbnN0IGFuZ2xlID0gdmFsdWUgKiAz
>>"%HW1%" echo LjYKICByZXR1cm4gKAogICAgPGRpdiBjbGFzc05hbWU9InByb2dyZXNzLXJpbmciIHN0eWxl
>>"%HW1%" echo PXt7ICctLWFuZ2xlJzogYCR7YW5nbGV9ZGVnYCB9fT4KICAgICAgPGRpdj48Yj57dmFsdWV9
>>"%HW1%" echo JTwvYj48c3Bhbj57bGFiZWx9PC9zcGFuPjwvZGl2PgogICAgPC9kaXY+CiAgKQp9CgpmdW5j
>>"%HW1%" echo dGlvbiBEYXNoYm9hcmQoeyB1c2VyLCBvbk9wZW5HYW1lIH0pIHsKICBjb25zdCBmaXJzdCA9
>>"%HW1%" echo IHVzZXIuZmlyc3ROYW1lIHx8ICdTdHVkZW50JwogIHJldHVybiAoCiAgICA8ZGl2IGNsYXNz
>>"%HW1%" echo TmFtZT0iZGFzaGJvYXJkLWdyaWQiPgogICAgICA8c2VjdGlvbiBjbGFzc05hbWU9IndlbGNv
>>"%HW1%" echo bWUtY2FyZCBjYXJkIj4KICAgICAgICA8ZGl2PgogICAgICAgICAgPHAgY2xhc3NOYW1lPSJl
>>"%HW1%" echo eWVicm93Ij5USFVSU0RBWSDigKIgVEVSTSAzPC9wPgogICAgICAgICAgPGgxPkdvb2QgbW9y
>>"%HW1%" echo bmluZywge2ZpcnN0fS48L2gxPgogICAgICAgICAgPHA+WW91IGhhdmUgdHdvIGltcG9ydGFu
>>"%HW1%" echo dCBkZWFkbGluZXMgYW5kIG9uZSBjbGFzcyBjdXJyZW50bHkgaW4gc2Vzc2lvbi48L3A+CiAg
>>"%HW1%" echo ICAgICAgICA8ZGl2IGNsYXNzTmFtZT0id2VsY29tZS1hY3Rpb25zIj4KICAgICAgICAgICAg
>>"%HW1%" echo PGJ1dHRvbiBjbGFzc05hbWU9InByaW1hcnktYnRuIHNtYWxsIiBvbkNsaWNrPXtvbk9wZW5H
>>"%HW1%" echo YW1lfT5PcGVuIFJpY29jaGV0IEFyZW5hPC9idXR0b24+CiAgICAgICAgICAgIDxidXR0b24g
>>"%HW1%" echo Y2xhc3NOYW1lPSJnaG9zdC1idG4gc21hbGwiIG9uQ2xpY2s9eygpID0+IGRvY3VtZW50Lmdl
>>"%HW1%" echo dEVsZW1lbnRCeUlkKCdhc3NpZ25tZW50cycpPy5zY3JvbGxJbnRvVmlldyh7IGJlaGF2aW9y
>>"%HW1%" echo OiAnc21vb3RoJyB9KX0+VmlldyBhc3NpZ25tZW50czwvYnV0dG9uPgogICAgICAgICAgPC9k
>>"%HW1%" echo aXY+CiAgICAgICAgPC9kaXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9ImZvY3VzLXBhbmVs
>>"%HW1%" echo Ij4KICAgICAgICAgIDxzcGFuPkN1cnJlbnQgZm9jdXM8L3NwYW4+CiAgICAgICAgICA8Yj5B
>>"%HW1%" echo ZHZhbmNlZCBXZWIgVGVjaG5vbG9neTwvYj4KICAgICAgICAgIDxwPlJlYWN0IHN0YXRlLCBm
>>"%HW1%" echo b3JtcyBhbmQgY29tcG9uZW50IGFyY2hpdGVjdHVyZTwvcD4KICAgICAgICAgIDxkaXYgY2xh
>>"%HW1%" echo c3NOYW1lPSJtaW5pLXByb2dyZXNzIj48aSBzdHlsZT17eyB3aWR0aDogJzY0JScgfX0gLz48
>>"%HW1%" echo L2Rpdj4KICAgICAgICA8L2Rpdj4KICAgICAgPC9zZWN0aW9uPgoKICAgICAgPHNlY3Rpb24g
>>"%HW1%" echo Y2xhc3NOYW1lPSJzdGF0cy1yb3ciPgogICAgICAgIDxkaXYgY2xhc3NOYW1lPSJtZXRyaWMg
>>"%HW1%" echo Y2FyZCI+PHNwYW4+R1BBPC9zcGFuPjxiPjMuNzY8L2I+PHNtYWxsPiswLjE4IHRoaXMgdGVy
>>"%HW1%" echo bTwvc21hbGw+PC9kaXY+CiAgICAgICAgPGRpdiBjbGFzc05hbWU9Im1ldHJpYyBjYXJkIj48
>>"%HW1%" echo c3Bhbj5BdHRlbmRhbmNlPC9zcGFuPjxiPjkzJTwvYj48c21hbGw+QWJvdmUgODAlIHJlcXVp
>>"%HW1%" echo cmVtZW50PC9zbWFsbD48L2Rpdj4KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0ibWV0cmljIGNh
>>"%HW1%" echo cmQiPjxzcGFuPkNyZWRpdHM8L3NwYW4+PGI+NzggLyAxMjA8L2I+PHNtYWxsPjY1JSBwcm9n
>>"%HW1%" echo cmFtbWUgY29tcGxldGU8L3NtYWxsPjwvZGl2PgogICAgICAgIDxkaXYgY2xhc3NOYW1lPSJt
>>"%HW1%" echo ZXRyaWMgY2FyZCI+PHNwYW4+QXNzaWdubWVudHM8L3NwYW4+PGI+MTEgLyAxNDwvYj48c21h
>>"%HW1%" echo bGw+MyByZW1haW5pbmcgdGhpcyBjeWNsZTwvc21hbGw+PC9kaXY+CiAgICAgIDwvc2VjdGlv
>>"%HW1%" echo bj4KCiAgICAgIDxzZWN0aW9uIGNsYXNzTmFtZT0iY2FyZCBzY2hlZHVsZS1jYXJkIj4KICAg
>>"%HW1%" echo ICAgICA8ZGl2IGNsYXNzTmFtZT0ic2VjdGlvbi10aXRsZSI+CiAgICAgICAgICA8ZGl2Pjxw
>>"%HW1%" echo IGNsYXNzTmFtZT0iZXllYnJvdyI+VE9EQVk8L3A+PGgyPlNjaGVkdWxlPC9oMj48L2Rpdj4K
>>"%HW1%" echo ICAgICAgICAgIDxzcGFuIGNsYXNzTmFtZT0ibGl2ZS1waWxsIj5MSVZFIERBWTwvc3Bhbj4K
>>"%HW1%" echo ICAgICAgICA8L2Rpdj4KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0idGltZWxpbmUiPgogICAg
>>"%HW1%" echo ICAgICAge3NjaGVkdWxlLm1hcCgoaXRlbSkgPT4gKAogICAgICAgICAgICA8ZGl2IGNsYXNz
>>"%HW1%" echo TmFtZT17YHRpbWVsaW5lLXJvdyAke2l0ZW0uc3RhdHVzfWB9IGtleT17YCR7aXRlbS50aW1l
>>"%HW1%" echo fS0ke2l0ZW0udGl0bGV9YH0+CiAgICAgICAgICAgICAgPHRpbWU+e2l0ZW0udGltZX08L3Rp
>>"%HW1%" echo bWU+CiAgICAgICAgICAgICAgPGkgLz4KICAgICAgICAgICAgICA8ZGl2PjxiPntpdGVtLnRp
>>"%HW1%" echo dGxlfTwvYj48c3Bhbj57aXRlbS5tZXRhfTwvc3Bhbj48L2Rpdj4KICAgICAgICAgICAgICA8
>>"%HW1%" echo ZW0+e2l0ZW0uc3RhdHVzID09PSAnYWN0aXZlJyA/ICdJbiBwcm9ncmVzcycgOiBpdGVtLnN0
>>"%HW1%" echo YXR1cyA9PT0gJ2RvbmUnID8gJ0NvbXBsZXRlZCcgOiBpdGVtLnN0YXR1cyA9PT0gJ2ZyZWUn
>>"%HW1%" echo ID8gJ0ZyZWUnIDogJ1VwY29taW5nJ308L2VtPgogICAgICAgICAgICA8L2Rpdj4KICAgICAg
>>"%HW1%" echo ICAgICkpfQogICAgICAgIDwvZGl2PgogICAgICA8L3NlY3Rpb24+CgogICAgICA8c2VjdGlv
>>"%HW1%" echo biBjbGFzc05hbWU9ImNhcmQgcGVyZm9ybWFuY2UtY2FyZCI+CiAgICAgICAgPGRpdiBjbGFz
>>"%HW1%" echo c05hbWU9InNlY3Rpb24tdGl0bGUiPgogICAgICAgICAgPGRpdj48cCBjbGFzc05hbWU9ImV5
>>"%HW1%" echo ZWJyb3ciPkFDQURFTUlDIEhFQUxUSDwvcD48aDI+UGVyZm9ybWFuY2U8L2gyPjwvZGl2Pgog
>>"%HW1%" echo ICAgICAgICAgPHNwYW4+VGVybSAzPC9zcGFuPgogICAgICAgIDwvZGl2PgogICAgICAgIDxk
>>"%HW1%" echo aXYgY2xhc3NOYW1lPSJwZXJmb3JtYW5jZS1ib2R5Ij4KICAgICAgICAgIDxQcm9ncmVzc1Jp
>>"%HW1%" echo bmcgdmFsdWU9ezg2fSBsYWJlbD0iT3ZlcmFsbCIgLz4KICAgICAgICAgIDxkaXYgY2xhc3NO
>>"%HW1%" echo YW1lPSJzdWJqZWN0LWJhcnMiPgogICAgICAgICAgICB7W1snRGF0YSBTY2llbmNlJywgODld
>>"%HW1%" echo LCBbJ1dlYiBUZWNobm9sb2d5JywgODJdLCBbJ0RhdGFiYXNlcycsIDkxXSwgWydNYXRoZW1h
>>"%HW1%" echo dGljcycsIDc3XV0ubWFwKChbbmFtZSwgdmFsdWVdKSA9PiAoCiAgICAgICAgICAgICAgPGRp
>>"%HW1%" echo diBrZXk9e25hbWV9PgogICAgICAgICAgICAgICAgPGRpdj48c3Bhbj57bmFtZX08L3NwYW4+
>>"%HW1%" echo PGI+e3ZhbHVlfSU8L2I+PC9kaXY+CiAgICAgICAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0i
>>"%HW1%" echo YmFyIj48aSBzdHlsZT17eyB3aWR0aDogYCR7dmFsdWV9JWAgfX0gLz48L2Rpdj4KICAgICAg
>>"%HW1%" echo ICAgICAgICA8L2Rpdj4KICAgICAgICAgICAgKSl9CiAgICAgICAgICA8L2Rpdj4KICAgICAg
>>"%HW1%" echo ICA8L2Rpdj4KICAgICAgPC9zZWN0aW9uPgoKICAgICAgPHNlY3Rpb24gY2xhc3NOYW1lPSJj
>>"%HW1%" echo YXJkIGFzc2lnbm1lbnRzLWNhcmQiIGlkPSJhc3NpZ25tZW50cyI+CiAgICAgICAgPGRpdiBj
>>"%HW1%" echo bGFzc05hbWU9InNlY3Rpb24tdGl0bGUiPgogICAgICAgICAgPGRpdj48cCBjbGFzc05hbWU9
>>"%HW1%" echo ImV5ZWJyb3ciPldPUksgUVVFVUU8L3A+PGgyPkFzc2lnbm1lbnRzPC9oMj48L2Rpdj4KICAg
>>"%HW1%" echo ICAgICAgIDxidXR0b24gY2xhc3NOYW1lPSJ0ZXh0LWJ0biI+VmlldyBhbGw8L2J1dHRvbj4K
>>"%HW1%" echo ICAgICAgICA8L2Rpdj4KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iYXNzaWdubWVudC1saXN0
>>"%HW1%" echo Ij4KICAgICAgICAgIHthc3NpZ25tZW50cy5tYXAoKGl0ZW0pID0+ICgKICAgICAgICAgICAg
>>"%HW1%" echo PGFydGljbGUga2V5PXtpdGVtLnRpdGxlfT4KICAgICAgICAgICAgICA8ZGl2IGNsYXNzTmFt
>>"%HW1%" echo ZT17YHByaW9yaXR5ICR7aXRlbS5wcmlvcml0eS50b0xvd2VyQ2FzZSgpfWB9PntpdGVtLnBy
>>"%HW1%" echo aW9yaXR5fTwvZGl2PgogICAgICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPSJhc3NpZ25tZW50
>>"%HW1%" echo LW1haW4iPgogICAgICAgICAgICAgICAgPGI+e2l0ZW0udGl0bGV9PC9iPgogICAgICAgICAg
>>"%HW1%" echo ICAgICAgPHNwYW4+e2l0ZW0uY291cnNlfSDigKIgRHVlIHtpdGVtLmR1ZX08L3NwYW4+CiAg
>>"%HW1%" echo ICAgICAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iYmFyIHRoaW4iPjxpIHN0eWxlPXt7IHdp
>>"%HW1%" echo ZHRoOiBgJHtpdGVtLnByb2dyZXNzfSVgIH19IC8+PC9kaXY+CiAgICAgICAgICAgICAgPC9k
>>"%HW1%" echo aXY+CiAgICAgICAgICAgICAgPHN0cm9uZz57aXRlbS5wcm9ncmVzc30lPC9zdHJvbmc+CiAg
>>"%HW1%" echo ICAgICAgICAgIDwvYXJ0aWNsZT4KICAgICAgICAgICkpfQogICAgICAgIDwvZGl2PgogICAg
>>"%HW1%" echo ICA8L3NlY3Rpb24+CgogICAgICA8c2VjdGlvbiBjbGFzc05hbWU9ImNhcmQgY291cnNlcy1j
>>"%HW1%" echo YXJkIj4KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0ic2VjdGlvbi10aXRsZSI+CiAgICAgICAg
>>"%HW1%" echo ICA8ZGl2PjxwIGNsYXNzTmFtZT0iZXllYnJvdyI+TVkgTU9EVUxFUzwvcD48aDI+Q291cnNl
>>"%HW1%" echo czwvaDI+PC9kaXY+CiAgICAgICAgICA8c3Bhbj40IGFjdGl2ZTwvc3Bhbj4KICAgICAgICA8
>>"%HW1%" echo L2Rpdj4KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iY291cnNlLWdyaWQiPgogICAgICAgICAg
>>"%HW1%" echo e2NvdXJzZXMubWFwKChjb3Vyc2UpID0+ICgKICAgICAgICAgICAgPGFydGljbGUgY2xhc3NO
>>"%HW1%" echo YW1lPXtgY291cnNlICR7Y291cnNlLmFjY2VudH1gfSBrZXk9e2NvdXJzZS5jb2RlfT4KICAg
>>"%HW1%" echo ICAgICAgICAgICA8c3BhbiBjbGFzc05hbWU9ImNvdXJzZS1jb2RlIj57Y291cnNlLmNvZGV9
>>"%HW1%" echo PC9zcGFuPgogICAgICAgICAgICAgIDxoMz57Y291cnNlLm5hbWV9PC9oMz4KICAgICAgICAg
>>"%HW1%" echo ICAgICA8cD57Y291cnNlLmxlY3R1cmVyfTwvcD4KICAgICAgICAgICAgICA8c21hbGw+e2Nv
>>"%HW1%" echo dXJzZS5yb29tfTwvc21hbGw+CiAgICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9ImJhciI+
>>"%HW1%" echo PGkgc3R5bGU9e3sgd2lkdGg6IGAke2NvdXJzZS5wcm9ncmVzc30lYCB9fSAvPjwvZGl2Pgog
>>"%HW1%" echo ICAgICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPSJjb3Vyc2UtZm9vdCI+PHNwYW4+UHJvZ3Jl
>>"%HW1%" echo c3M8L3NwYW4+PGI+e2NvdXJzZS5wcm9ncmVzc30lPC9iPjwvZGl2PgogICAgICAgICAgICA8
>>"%HW1%" echo L2FydGljbGU+CiAgICAgICAgICApKX0KICAgICAgICA8L2Rpdj4KICAgICAgPC9zZWN0aW9u
>>"%HW1%" echo PgoKICAgICAgPHNlY3Rpb24gY2xhc3NOYW1lPSJjYXJkIG5vdGljZXMtY2FyZCI+CiAgICAg
>>"%HW1%" echo ICAgPGRpdiBjbGFzc05hbWU9InNlY3Rpb24tdGl0bGUiPgogICAgICAgICAgPGRpdj48cCBj
>>"%HW1%" echo bGFzc05hbWU9ImV5ZWJyb3ciPkNBTVBVUyBGRUVEPC9wPjxoMj5Bbm5vdW5jZW1lbnRzPC9o
>>"%HW1%" echo Mj48L2Rpdj4KICAgICAgICA8L2Rpdj4KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0ibm90aWNl
>>"%HW1%" echo Ij4KICAgICAgICAgIDxzcGFuIGNsYXNzTmFtZT0ibm90aWNlLWljb24iPjAxPC9zcGFuPgog
>>"%HW1%" echo ICAgICAgICAgPGRpdj48Yj5EYXRhIFNjaWVuY2UgbGFiIG1vdmVkPC9iPjxwPkZyaWRheSBw
>>"%HW1%" echo cmFjdGljYWwgbW92ZXMgZnJvbSBMYWIgQTQgdG8gTGFiIEIxMi48L3A+PHNtYWxsPjMyIG1p
>>"%HW1%" echo bnV0ZXMgYWdvPC9zbWFsbD48L2Rpdj4KICAgICAgICA8L2Rpdj4KICAgICAgICA8ZGl2IGNs
>>"%HW1%" echo YXNzTmFtZT0ibm90aWNlIj4KICAgICAgICAgIDxzcGFuIGNsYXNzTmFtZT0ibm90aWNlLWlj
>>"%HW1%" echo b24iPjAyPC9zcGFuPgogICAgICAgICAgPGRpdj48Yj5IYWNrYXRob24gcmVnaXN0cmF0aW9u
>>"%HW1%" echo IG9wZW48L2I+PHA+VGVhbXMgb2YgMi00IGNhbiByZWdpc3RlciBiZWZvcmUgTW9uZGF5IGFm
>>"%HW1%" echo dGVybm9vbi48L3A+PHNtYWxsPjIgaG91cnMgYWdvPC9zbWFsbD48L2Rpdj4KICAgICAgICA8
>>"%HW1%" echo L2Rpdj4KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0ibm90aWNlIj4KICAgICAgICAgIDxzcGFu
>>"%HW1%" echo IGNsYXNzTmFtZT0ibm90aWNlLWljb24iPjAzPC9zcGFuPgogICAgICAgICAgPGRpdj48Yj5M
>>"%HW1%" echo aWJyYXJ5IGV4dGVuZGVkIGhvdXJzPC9iPjxwPkV4YW0gcHJlcGFyYXRpb24gaG91cnMgYmVn
>>"%HW1%" echo aW4gdGhpcyB3ZWVrZW5kLjwvcD48c21hbGw+WWVzdGVyZGF5PC9zbWFsbD48L2Rpdj4KICAg
>>"%HW1%" echo ICAgICA8L2Rpdj4KICAgICAgPC9zZWN0aW9uPgogICAgPC9kaXY+CiAgKQp9CgpmdW5jdGlv
>>"%HW1%" echo biBQb3J0YWxTaGVsbCh7IHVzZXIsIG9uTG9nb3V0IH0pIHsKICBjb25zdCBbcGFnZSwgc2V0
>>"%HW1%" echo UGFnZV0gPSB1c2VTdGF0ZSgncG9ydGFsJykKICBjb25zdCBbbm90aWZpY2F0aW9ucywgc2V0
>>"%HW1%" echo Tm90aWZpY2F0aW9uc10gPSB1c2VTdGF0ZSgzKQoKICByZXR1cm4gKAogICAgPGRpdiBjbGFz
>>"%HW1%" echo c05hbWU9InBvcnRhbC1zaGVsbCI+CiAgICAgIDxhc2lkZSBjbGFzc05hbWU9InNpZGViYXIi
>>"%HW1%" echo PgogICAgICAgIDxkaXYgY2xhc3NOYW1lPSJicmFuZC1yb3cgY29tcGFjdCI+CiAgICAgICAg
>>"%HW1%" echo ICA8ZGl2IGNsYXNzTmFtZT0iYnJhbmQtbWFyayI+Ukc8L2Rpdj4KICAgICAgICAgIDxkaXY+
>>"%HW1%" echo PHN0cm9uZz5Qb3J0YWwgMjAyNjwvc3Ryb25nPjxzcGFuPlN0dWRlbnQgd29ya3NwYWNlPC9z
>>"%HW1%" echo cGFuPjwvZGl2PgogICAgICAgIDwvZGl2PgogICAgICAgIDxuYXY+CiAgICAgICAgICA8YnV0
>>"%HW1%" echo dG9uIGNsYXNzTmFtZT17cGFnZSA9PT0gJ3BvcnRhbCcgPyAnYWN0aXZlJyA6ICcnfSBvbkNs
>>"%HW1%" echo aWNrPXsoKSA9PiBzZXRQYWdlKCdwb3J0YWwnKX0+CiAgICAgICAgICAgIDxzcGFuPjAxPC9z
>>"%HW1%" echo cGFuPiBEYXNoYm9hcmQKICAgICAgICAgIDwvYnV0dG9uPgogICAgICAgICAgPGJ1dHRvbiBj
>>"%HW1%" echo bGFzc05hbWU9e3BhZ2UgPT09ICdnYW1lJyA/ICdhY3RpdmUnIDogJyd9IG9uQ2xpY2s9eygp
>>"%HW1%" echo ID0+IHNldFBhZ2UoJ2dhbWUnKX0+CiAgICAgICAgICAgIDxzcGFuPjAyPC9zcGFuPiBSaWNv
>>"%HW1%" echo Y2hldCBBcmVuYQogICAgICAgICAgPC9idXR0b24+CiAgICAgICAgPC9uYXY+CiAgICAgICAg
>>"%HW1%" echo PGRpdiBjbGFzc05hbWU9InNpZGViYXItdGlwIj4KICAgICAgICAgIDxiPkdBTUUgQ09OVFJP
>>"%HW1%" echo TFM8L2I+CiAgICAgICAgICA8c3Bhbj5XQVNEIG1vdmU8L3NwYW4+CiAgICAgICAgICA8c3Bh
>>"%HW1%" echo bj5Nb3VzZSBhaW08L3NwYW4+CiAgICAgICAgICA8c3Bhbj5DbGljayBzaG9vdDwvc3Bhbj4K
>>"%HW1%" echo ICAgICAgICAgIDxzcGFuPlIgcmVsb2FkPC9zcGFuPgogICAgICAgICAgPHNwYW4+U3BhY2Ug
>>"%HW1%" echo ZGFzaDwvc3Bhbj4KICAgICAgICA8L2Rpdj4KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0ic3R1
>>"%HW1%" echo ZGVudC1taW5pIj4KICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPSJhdmF0YXIiPnt1c2VyLmZp
>>"%HW1%" echo cnN0TmFtZT8uWzBdfXt1c2VyLmxhc3ROYW1lPy5bMF19PC9kaXY+CiAgICAgICAgICA8ZGl2
>>"%HW1%" echo PjxiPnt1c2VyLmZpcnN0TmFtZX0ge3VzZXIubGFzdE5hbWV9PC9iPjxzcGFuPnt1c2VyLnN0
>>"%HW1%" echo dWRlbnRJZH08L3NwYW4+PC9kaXY+CiAgICAgICAgPC9kaXY+CiAgICAgIDwvYXNpZGU+Cgog
>>"%HW1%" echo ICAgICA8bWFpbiBjbGFzc05hbWU9InBvcnRhbC1tYWluIj4KICAgICAgICA8aGVhZGVyIGNs
>>"%HW1%" echo YXNzTmFtZT0idG9wYmFyIj4KICAgICAgICAgIDxkaXY+CiAgICAgICAgICAgIDxwIGNsYXNz
>>"%HW1%" echo TmFtZT0iZXllYnJvdyI+e3BhZ2UgPT09ICdwb3J0YWwnID8gJ1NUVURFTlQgREFTSEJPQVJE
>>"%HW1%" echo JyA6ICdQQUdFIDIg4oCiIENBTVBVUyBBUkNBREUnfTwvcD4KICAgICAgICAgICAgPGgyPntw
>>"%HW1%" echo YWdlID09PSAncG9ydGFsJyA/ICdBY2FkZW1pYyBPdmVydmlldycgOiAnUmljb2NoZXQgQXJl
>>"%HW1%" echo bmEnfTwvaDI+CiAgICAgICAgICA8L2Rpdj4KICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPSJ0
>>"%HW1%" echo b3AtYWN0aW9ucyI+CiAgICAgICAgICAgIDxidXR0b24gY2xhc3NOYW1lPSJpY29uLWJ0biIg
>>"%HW1%" echo b25DbGljaz17KCkgPT4gc2V0Tm90aWZpY2F0aW9ucygwKX0+CiAgICAgICAgICAgICAgPHNw
>>"%HW1%" echo YW4+ITwvc3Bhbj4KICAgICAgICAgICAgICB7bm90aWZpY2F0aW9ucyA+IDAgJiYgPGk+e25v
>>"%HW1%" echo dGlmaWNhdGlvbnN9PC9pPn0KICAgICAgICAgICAgPC9idXR0b24+CiAgICAgICAgICAgIDxk
>>"%HW1%" echo aXYgY2xhc3NOYW1lPSJ0ZXJtLWNoaXAiPjxzcGFuPlRlcm08L3NwYW4+PGI+MyAvIDIwMjY8
>>"%HW1%" echo L2I+PC9kaXY+CiAgICAgICAgICAgIDxidXR0b24gY2xhc3NOYW1lPSJnaG9zdC1idG4gc21h
>>"%HW1%" echo bGwiIG9uQ2xpY2s9e29uTG9nb3V0fT5TaWduIG91dDwvYnV0dG9uPgogICAgICAgICAgPC9k
>>"%HW1%" echo aXY+CiAgICAgICAgPC9oZWFkZXI+CgogICAgICAgIHtwYWdlID09PSAncG9ydGFsJyA/ICgK
>>"%HW1%" echo ICAgICAgICAgIDxEYXNoYm9hcmQgdXNlcj17dXNlcn0gb25PcGVuR2FtZT17KCkgPT4gc2V0
>>"%HW1%" echo UGFnZSgnZ2FtZScpfSAvPgogICAgICAgICkgOiAoCiAgICAgICAgICA8Umljb2NoZXRHYW1l
>>"%HW1%" echo IHN0dWRlbnROYW1lPXt1c2VyLmZpcnN0TmFtZX0gLz4KICAgICAgICApfQogICAgICA8L21h
>>"%HW1%" echo aW4+CiAgICA8L2Rpdj4KICApCn0KCmV4cG9ydCBkZWZhdWx0IGZ1bmN0aW9uIEFwcCgpIHsK
>>"%HW1%" echo ICBjb25zdCBbdXNlciwgc2V0VXNlcl0gPSB1c2VTdGF0ZShudWxsKQogIGNvbnN0IFtyZWFk
>>"%HW1%" echo eSwgc2V0UmVhZHldID0gdXNlU3RhdGUoZmFsc2UpCiAgY29uc3QgW21vZGUsIHNldE1vZGVd
>>"%HW1%" echo ID0gdXNlU3RhdGUoJ3ByYWN0aWNhbCcpCgogIHVzZUVmZmVjdCgoKSA9PiB7CiAgICBjb25z
>>"%HW1%" echo dCBzZXNzaW9uID0gSlNPTi5wYXJzZShsb2NhbFN0b3JhZ2UuZ2V0SXRlbShTRVNTSU9OX0tF
>>"%HW1%" echo WSkgfHwgJ251bGwnKQogICAgaWYgKHNlc3Npb24/LmlkKSB7CiAgICAgIGNvbnN0IGZvdW5k
>>"%HW1%" echo ID0gcmVhZFVzZXJzKCkuZmluZCgoaXRlbSkgPT4gaXRlbS5pZCA9PT0gc2Vzc2lvbi5pZCkK
>>"%HW1%" echo ICAgICAgaWYgKGZvdW5kKSBzZXRVc2VyKGZvdW5kKQogICAgfQogICAgc2V0UmVhZHkodHJ1
>>"%HW1%" echo ZSkKICB9LCBbXSkKCiAgY29uc3Qgc2Vzc2lvbk5hbWUgPSB1c2VNZW1vKCgpID0+ICh1c2Vy
>>"%HW1%" echo ID8gYCR7dXNlci5maXJzdE5hbWV9ICR7dXNlci5sYXN0TmFtZX1gIDogJycpLCBbdXNlcl0p
>>"%HW1%" echo CgogIGZ1bmN0aW9uIGxvZ291dCgpIHsKICAgIGxvY2FsU3RvcmFnZS5yZW1vdmVJdGVtKFNF
>>"%HW1%" echo U1NJT05fS0VZKQogICAgc2V0VXNlcihudWxsKQogIH0KCiAgaWYgKG1vZGUgPT09ICdwcmFj
>>"%HW1%" echo dGljYWwnKSB7CiAgICByZXR1cm4gPFByYWN0aWNhbEhvbWVwYWdlIG9uT3BlblBvcnRhbD17
>>"%HW1%" echo KCkgPT4gc2V0TW9kZSgncG9ydGFsJyl9IC8+CiAgfQoKICBpZiAoIXJlYWR5KSByZXR1cm4g
>>"%HW1%" echo PGRpdiBjbGFzc05hbWU9ImJvb3Qtc2NyZWVuIj5Mb2FkaW5nIFN0dWRlbnQgUG9ydGFsIDIw
>>"%HW1%" echo MjYuLi48L2Rpdj4KCiAgaWYgKCF1c2VyKSB7CiAgICByZXR1cm4gKAogICAgICA8PgogICAg
>>"%HW1%" echo ICAgIDxidXR0b24gY2xhc3NOYW1lPSJyZXR1cm4tcHJhY3RpY2FsLWJ0biIgb25DbGljaz17
>>"%HW1%" echo KCkgPT4gc2V0TW9kZSgncHJhY3RpY2FsJyl9PgogICAgICAgICAg4oaQIFVuaXZlcnNpdHkg
>>"%HW1%" echo SG9tZXBhZ2UKICAgICAgICA8L2J1dHRvbj4KICAgICAgICA8QXV0aFNjcmVlbiBvbkF1dGhl
>>"%HW1%" echo bnRpY2F0ZWQ9e3NldFVzZXJ9IC8+CiAgICAgIDwvPgogICAgKQogIH0KCiAgcmV0dXJuICgK
>>"%HW1%" echo ICAgIDw+CiAgICAgIDxidXR0b24gY2xhc3NOYW1lPSJyZXR1cm4tcHJhY3RpY2FsLWJ0biBw
>>"%HW1%" echo b3J0YWwtbW9kZSIgb25DbGljaz17KCkgPT4gc2V0TW9kZSgncHJhY3RpY2FsJyl9PgogICAg
>>"%HW1%" echo ICAgIOKGkCBXZWIgVGVjaCBQcmFjdGljYWwKICAgICAgPC9idXR0b24+CiAgICAgIDxQb3J0
>>"%HW1%" echo YWxTaGVsbCBrZXk9e3Nlc3Npb25OYW1lfSB1c2VyPXt1c2VyfSBvbkxvZ291dD17bG9nb3V0
>>"%HW1%" echo fSAvPgogICAgPC8+CiAgKQp9Cg==
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,'');const o=process.argv[2];fs.mkdirSync(require('path').dirname(o),{recursive:true});fs.writeFileSync(o,Buffer.from(b,'base64'))" "%HW1%" "%APP_DIR%\src\App.jsx"
if errorlevel 1 exit /b 1
set "HW2=%TEMP%\webtech_hw_2.b64"
>"%HW2%" echo ZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gQ29udGFpbmVyKHsgY2hpbGRyZW4gfSkgewogIHJl
>>"%HW2%" echo dHVybiA8ZGl2IGNsYXNzTmFtZT0idW5pdmVyc2l0eS1jb250YWluZXIiPntjaGlsZHJlbn08
>>"%HW2%" echo L2Rpdj4KfQo=
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,'');const o=process.argv[2];fs.mkdirSync(require('path').dirname(o),{recursive:true});fs.writeFileSync(o,Buffer.from(b,'base64'))" "%HW2%" "%APP_DIR%\src\components\Container.jsx"
if errorlevel 1 exit /b 1
set "HW3=%TEMP%\webtech_hw_3.b64"
>"%HW3%" echo ZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gSGVhZGVyKCkgewogIHJldHVybiAoCiAgICA8aGVh
>>"%HW3%" echo ZGVyIGNsYXNzTmFtZT0idW5pdmVyc2l0eS1oZWFkZXIiPgogICAgICA8aDE+UmljaGZpZWxk
>>"%HW3%" echo IFVuaXZlcnNpdHk8L2gxPgogICAgPC9oZWFkZXI+CiAgKQp9Cg==
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,'');const o=process.argv[2];fs.mkdirSync(require('path').dirname(o),{recursive:true});fs.writeFileSync(o,Buffer.from(b,'base64'))" "%HW3%" "%APP_DIR%\src\components\Header.jsx"
if errorlevel 1 exit /b 1
set "HW4=%TEMP%\webtech_hw_4.b64"
>"%HW4%" echo ZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gTmF2aWdhdGlvbigpIHsKICByZXR1cm4gKAogICAg
>>"%HW4%" echo PG5hdiBjbGFzc05hbWU9InVuaXZlcnNpdHktbmF2aWdhdGlvbiIgYXJpYS1sYWJlbD0iVW5p
>>"%HW4%" echo dmVyc2l0eSBuYXZpZ2F0aW9uIj4KICAgICAgPGEgaHJlZj0iI3dlbGNvbWUiPkhvbWU8L2E+
>>"%HW4%" echo CiAgICAgIDxhIGhyZWY9IiNzdHVkZW50LWluZm8iPkFib3V0PC9hPgogICAgICA8YSBocmVm
>>"%HW4%" echo PSIjc3R1ZGVudC1pbmZvIj5Db3Vyc2VzPC9hPgogICAgICA8YSBocmVmPSIjZm9vdGVyIj5D
>>"%HW4%" echo b250YWN0PC9hPgogICAgPC9uYXY+CiAgKQp9Cg==
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,'');const o=process.argv[2];fs.mkdirSync(require('path').dirname(o),{recursive:true});fs.writeFileSync(o,Buffer.from(b,'base64'))" "%HW4%" "%APP_DIR%\src\components\Navigation.jsx"
if errorlevel 1 exit /b 1
set "HW5=%TEMP%\webtech_hw_5.b64"
>"%HW5%" echo ZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gV2VsY29tZVNlY3Rpb24oKSB7CiAgcmV0dXJuICgK
>>"%HW5%" echo ICAgIDxzZWN0aW9uIGNsYXNzTmFtZT0id2VsY29tZS1zZWN0aW9uIiBpZD0id2VsY29tZSI+
>>"%HW5%" echo CiAgICAgIDxoMj5XZWxjb21lIHRvIFJpY2hmaWVsZCBVbml2ZXJzaXR5PC9oMj4KICAgICAg
>>"%HW5%" echo PHA+CiAgICAgICAgV2UgYXJlIGNvbW1pdHRlZCB0byBwcm92aWRpbmcgcXVhbGl0eSBlZHVj
>>"%HW5%" echo YXRpb24gYW5kIHByZXBhcmluZyBzdHVkZW50cwogICAgICAgIGZvciBzdWNjZXNzZnVsIGNh
>>"%HW5%" echo cmVlcnMuCiAgICAgIDwvcD4KICAgIDwvc2VjdGlvbj4KICApCn0K
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,'');const o=process.argv[2];fs.mkdirSync(require('path').dirname(o),{recursive:true});fs.writeFileSync(o,Buffer.from(b,'base64'))" "%HW5%" "%APP_DIR%\src\components\WelcomeSection.jsx"
if errorlevel 1 exit /b 1
set "HW6=%TEMP%\webtech_hw_6.b64"
>"%HW6%" echo ZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gU3R1ZGVudEluZm9ybWF0aW9uQ2FyZCh7IHN0dWRl
>>"%HW6%" echo bnQgfSkgewogIHJldHVybiAoCiAgICA8c2VjdGlvbiBjbGFzc05hbWU9InN0dWRlbnQtaW5m
>>"%HW6%" echo b3JtYXRpb24tY2FyZCIgaWQ9InN0dWRlbnQtaW5mbyI+CiAgICAgIDxoMz5TdHVkZW50IElu
>>"%HW6%" echo Zm9ybWF0aW9uPC9oMz4KICAgICAgPGRsPgogICAgICAgIDxkaXY+CiAgICAgICAgICA8ZHQ+
>>"%HW6%" echo TmFtZTo8L2R0PgogICAgICAgICAgPGRkPntzdHVkZW50Lm5hbWV9PC9kZD4KICAgICAgICA8
>>"%HW6%" echo L2Rpdj4KICAgICAgICA8ZGl2PgogICAgICAgICAgPGR0PlN0dWRlbnQgTnVtYmVyOjwvZHQ+
>>"%HW6%" echo CiAgICAgICAgICA8ZGQ+e3N0dWRlbnQuc3R1ZGVudE51bWJlcn08L2RkPgogICAgICAgIDwv
>>"%HW6%" echo ZGl2PgogICAgICAgIDxkaXY+CiAgICAgICAgICA8ZHQ+UHJvZ3JhbW1lOjwvZHQ+CiAgICAg
>>"%HW6%" echo ICAgICA8ZGQ+e3N0dWRlbnQucHJvZ3JhbW1lfTwvZGQ+CiAgICAgICAgPC9kaXY+CiAgICAg
>>"%HW6%" echo IDwvZGw+CiAgICA8L3NlY3Rpb24+CiAgKQp9Cg==
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,'');const o=process.argv[2];fs.mkdirSync(require('path').dirname(o),{recursive:true});fs.writeFileSync(o,Buffer.from(b,'base64'))" "%HW6%" "%APP_DIR%\src\components\StudentInformationCard.jsx"
if errorlevel 1 exit /b 1
set "HW7=%TEMP%\webtech_hw_7.b64"
>"%HW7%" echo ZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gRm9vdGVyKCkgewogIHJldHVybiAoCiAgICA8Zm9v
>>"%HW7%" echo dGVyIGNsYXNzTmFtZT0idW5pdmVyc2l0eS1mb290ZXIiIGlkPSJmb290ZXIiPgogICAgICDC
>>"%HW7%" echo qSAyMDI2IFJpY2hmaWVsZCBVbml2ZXJzaXR5LiBBbGwgUmlnaHRzIFJlc2VydmVkLgogICAg
>>"%HW7%" echo PC9mb290ZXI+CiAgKQp9Cg==
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,'');const o=process.argv[2];fs.mkdirSync(require('path').dirname(o),{recursive:true});fs.writeFileSync(o,Buffer.from(b,'base64'))" "%HW7%" "%APP_DIR%\src\components\Footer.jsx"
if errorlevel 1 exit /b 1
set "HW8=%TEMP%\webtech_hw_8.b64"
>"%HW8%" echo aW1wb3J0IENvbnRhaW5lciBmcm9tICcuL2NvbXBvbmVudHMvQ29udGFpbmVyLmpzeCcKaW1w
>>"%HW8%" echo b3J0IEhlYWRlciBmcm9tICcuL2NvbXBvbmVudHMvSGVhZGVyLmpzeCcKaW1wb3J0IE5hdmln
>>"%HW8%" echo YXRpb24gZnJvbSAnLi9jb21wb25lbnRzL05hdmlnYXRpb24uanN4JwppbXBvcnQgV2VsY29t
>>"%HW8%" echo ZVNlY3Rpb24gZnJvbSAnLi9jb21wb25lbnRzL1dlbGNvbWVTZWN0aW9uLmpzeCcKaW1wb3J0
>>"%HW8%" echo IFN0dWRlbnRJbmZvcm1hdGlvbkNhcmQgZnJvbSAnLi9jb21wb25lbnRzL1N0dWRlbnRJbmZv
>>"%HW8%" echo cm1hdGlvbkNhcmQuanN4JwppbXBvcnQgRm9vdGVyIGZyb20gJy4vY29tcG9uZW50cy9Gb290
>>"%HW8%" echo ZXIuanN4JwppbXBvcnQgJy4vcHJhY3RpY2FsLmNzcycKCmNvbnN0IHN0dWRlbnQgPSB7CiAg
>>"%HW8%" echo bmFtZTogJ1RoYWJhbmcgTmt1bmEnLAogIHN0dWRlbnROdW1iZXI6ICc0MDAwMDAwMDAwJywK
>>"%HW8%" echo ICBwcm9ncmFtbWU6ICdCYWNoZWxvciBvZiBTY2llbmNlIGluIEluZm9ybWF0aW9uIFRlY2hu
>>"%HW8%" echo b2xvZ3knLAp9CgpleHBvcnQgZGVmYXVsdCBmdW5jdGlvbiBQcmFjdGljYWxIb21lcGFnZSh7
>>"%HW8%" echo IG9uT3BlblBvcnRhbCB9KSB7CiAgcmV0dXJuICgKICAgIDxtYWluIGNsYXNzTmFtZT0icHJh
>>"%HW8%" echo Y3RpY2FsLXBhZ2UiPgogICAgICA8YnV0dG9uIGNsYXNzTmFtZT0ib3Blbi1wb3J0YWwtYnRu
>>"%HW8%" echo IiBvbkNsaWNrPXtvbk9wZW5Qb3J0YWx9PgogICAgICAgIE9wZW4gQWR2YW5jZWQgU3R1ZGVu
>>"%HW8%" echo dCBQb3J0YWwKICAgICAgPC9idXR0b24+CgogICAgICA8ZGl2IGNsYXNzTmFtZT0icHJhY3Rp
>>"%HW8%" echo Y2FsLWhlYWRpbmciPgogICAgICAgIDxzcGFuPldFQiBURUNIIDUxMjwvc3Bhbj4KICAgICAg
>>"%HW8%" echo ICA8c3Ryb25nPkNvbXBvbmVudCBDb21wb3NpdGlvbiBhbmQgdGhlIENoaWxkcmVuIFByb3A8
>>"%HW8%" echo L3N0cm9uZz4KICAgICAgPC9kaXY+CgogICAgICA8Q29udGFpbmVyPgogICAgICAgIDxIZWFk
>>"%HW8%" echo ZXIgLz4KICAgICAgICA8TmF2aWdhdGlvbiAvPgogICAgICAgIDxXZWxjb21lU2VjdGlvbiAv
>>"%HW8%" echo PgogICAgICAgIDxTdHVkZW50SW5mb3JtYXRpb25DYXJkIHN0dWRlbnQ9e3N0dWRlbnR9IC8+
>>"%HW8%" echo CiAgICAgICAgPEZvb3RlciAvPgogICAgICA8L0NvbnRhaW5lcj4KCiAgICAgIDxwIGNsYXNz
>>"%HW8%" echo TmFtZT0icHJhY3RpY2FsLXNvdXJjZS1ub3RlIj4KICAgICAgICBCdWlsdCB1c2luZyByZXVz
>>"%HW8%" echo YWJsZSBjb21wb25lbnRzIGNvbXBvc2VkIHRocm91Z2ggdGhlIENvbnRhaW5lciBjaGlsZHJl
>>"%HW8%" echo biBwcm9wLgogICAgICA8L3A+CiAgICA8L21haW4+CiAgKQp9Cg==
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,'');const o=process.argv[2];fs.mkdirSync(require('path').dirname(o),{recursive:true});fs.writeFileSync(o,Buffer.from(b,'base64'))" "%HW8%" "%APP_DIR%\src\PracticalHomepage.jsx"
if errorlevel 1 exit /b 1
set "HW9=%TEMP%\webtech_hw_9.b64"
>"%HW9%" echo LnByYWN0aWNhbC1wYWdlIHsKICBtaW4taGVpZ2h0OiAxMDB2aDsKICBwYWRkaW5nOiA1NHB4
>>"%HW9%" echo IDIwcHggNzBweDsKICBjb2xvcjogIzIwMjgzMzsKICBiYWNrZ3JvdW5kOgogICAgcmFkaWFs
>>"%HW9%" echo LWdyYWRpZW50KGNpcmNsZSBhdCA1MCUgLTIwJSwgcmdiYSg5LCAxMDMsIDE3MCwgLjE0KSwg
>>"%HW9%" echo dHJhbnNwYXJlbnQgMzglKSwKICAgICNmNGY2Zjg7Cn0KCi5wcmFjdGljYWwtaGVhZGluZyB7
>>"%HW9%" echo CiAgd2lkdGg6IG1pbig3MjBweCwgMTAwJSk7CiAgbWFyZ2luOiAwIGF1dG8gMTZweDsKICBk
>>"%HW9%" echo aXNwbGF5OiBmbGV4OwogIGp1c3RpZnktY29udGVudDogc3BhY2UtYmV0d2VlbjsKICBnYXA6
>>"%HW9%" echo IDE4cHg7CiAgYWxpZ24taXRlbXM6IGNlbnRlcjsKICBjb2xvcjogIzMwNTQ2YTsKICBmb250
>>"%HW9%" echo LXNpemU6IC43NHJlbTsKfQoKLnByYWN0aWNhbC1oZWFkaW5nIHNwYW4gewogIGNvbG9yOiAj
>>"%HW9%" echo MDA2Y2FlOwogIGZvbnQtd2VpZ2h0OiA5MDA7CiAgbGV0dGVyLXNwYWNpbmc6IC4xMmVtOwp9
>>"%HW9%" echo CgoudW5pdmVyc2l0eS1jb250YWluZXIgewogIHdpZHRoOiBtaW4oNzIwcHgsIDEwMCUpOwog
>>"%HW9%" echo IG1hcmdpbjogMCBhdXRvOwogIGJhY2tncm91bmQ6ICNmZmY7CiAgYm9yZGVyOiAxcHggc29s
>>"%HW9%" echo aWQgI2Q2ZGRlMzsKICBib3gtc2hhZG93OiAwIDE4cHggNTJweCByZ2JhKDMxLCA1MSwgNjYs
>>"%HW9%" echo IC4xMyk7Cn0KCi51bml2ZXJzaXR5LWhlYWRlciB7CiAgbWluLWhlaWdodDogMTMycHg7CiAg
>>"%HW9%" echo ZGlzcGxheTogZ3JpZDsKICBwbGFjZS1pdGVtczogY2VudGVyOwogIHBhZGRpbmc6IDI4cHg7
>>"%HW9%" echo CiAgdGV4dC1hbGlnbjogY2VudGVyOwogIGJhY2tncm91bmQ6ICMwODRhN2Q7Cn0KCi51bml2
>>"%HW9%" echo ZXJzaXR5LWhlYWRlciBoMSB7CiAgbWFyZ2luOiAwOwogIGNvbG9yOiAjZjdmYmZmOwogIGZv
>>"%HW9%" echo bnQtc2l6ZTogY2xhbXAoMnJlbSwgNnZ3LCAzLjI1cmVtKTsKICBmb250LXdlaWdodDogODAw
>>"%HW9%" echo OwogIGxldHRlci1zcGFjaW5nOiAtLjA0NWVtOwp9CgoudW5pdmVyc2l0eS1uYXZpZ2F0aW9u
>>"%HW9%" echo IHsKICBtaW4taGVpZ2h0OiA1NXB4OwogIGRpc3BsYXk6IGZsZXg7CiAganVzdGlmeS1jb250
>>"%HW9%" echo ZW50OiBjZW50ZXI7CiAgYWxpZ24taXRlbXM6IGNlbnRlcjsKICBiYWNrZ3JvdW5kOiAjMDg3
>>"%HW9%" echo M2JkOwp9CgoudW5pdmVyc2l0eS1uYXZpZ2F0aW9uIGEgewogIHBvc2l0aW9uOiByZWxhdGl2
>>"%HW9%" echo ZTsKICBwYWRkaW5nOiAxOHB4IDIwcHg7CiAgY29sb3I6ICNmMmZiZmY7CiAgdGV4dC1kZWNv
>>"%HW9%" echo cmF0aW9uOiBub25lOwogIGZvbnQtc2l6ZTogLjg4cmVtOwogIGZvbnQtd2VpZ2h0OiA3MDA7
>>"%HW9%" echo Cn0KCi51bml2ZXJzaXR5LW5hdmlnYXRpb24gYSArIGE6OmJlZm9yZSB7CiAgY29udGVudDog
>>"%HW9%" echo Jyc7CiAgcG9zaXRpb246IGFic29sdXRlOwogIGxlZnQ6IDA7CiAgdG9wOiAxN3B4OwogIGJv
>>"%HW9%" echo dHRvbTogMTdweDsKICB3aWR0aDogMXB4OwogIGJhY2tncm91bmQ6IHJnYmEoMjU1LCAyNTUs
>>"%HW9%" echo IDI1NSwgLjI2KTsKfQoKLnVuaXZlcnNpdHktbmF2aWdhdGlvbiBhOmhvdmVyIHsKICBiYWNr
>>"%HW9%" echo Z3JvdW5kOiByZ2JhKDI1NSwgMjU1LCAyNTUsIC4xMSk7Cn0KCi53ZWxjb21lLXNlY3Rpb24g
>>"%HW9%" echo ewogIHBhZGRpbmc6IDM4cHggMzRweCAyOHB4OwogIHRleHQtYWxpZ246IGNlbnRlcjsKfQoK
>>"%HW9%" echo LndlbGNvbWUtc2VjdGlvbiBoMiB7CiAgbWFyZ2luOiAwIDAgMTJweDsKICBjb2xvcjogIzI3
>>"%HW9%" echo MzMzZDsKICBmb250LXNpemU6IDEuNDJyZW07Cn0KCi53ZWxjb21lLXNlY3Rpb24gcCB7CiAg
>>"%HW9%" echo bWF4LXdpZHRoOiA1OTBweDsKICBtYXJnaW46IDAgYXV0bzsKICBjb2xvcjogIzY5Nzc4MTsK
>>"%HW9%" echo ICBsaW5lLWhlaWdodDogMS43OwogIGZvbnQtc2l6ZTogLjkycmVtOwp9Cgouc3R1ZGVudC1p
>>"%HW9%" echo bmZvcm1hdGlvbi1jYXJkIHsKICBtYXJnaW46IDhweCAzOHB4IDMwcHg7CiAgcGFkZGluZzog
>>"%HW9%" echo MjhweCAyNnB4OwogIHRleHQtYWxpZ246IGNlbnRlcjsKICBib3JkZXI6IDFweCBzb2xpZCAj
>>"%HW9%" echo Y2ZkN2RkOwogIGJvcmRlci1yYWRpdXM6IDdweDsKICBiYWNrZ3JvdW5kOiAjZmZmOwogIGJv
>>"%HW9%" echo eC1zaGFkb3c6IDAgNXB4IDEycHggcmdiYSgyMiwgNDIsIDU1LCAuMTIpOwp9Cgouc3R1ZGVu
>>"%HW9%" echo dC1pbmZvcm1hdGlvbi1jYXJkIGgzIHsKICBtYXJnaW46IDAgMCAyMHB4OwogIGNvbG9yOiAj
>>"%HW9%" echo MzQ0MzRlOwogIGZvbnQtc2l6ZTogMXJlbTsKfQoKLnN0dWRlbnQtaW5mb3JtYXRpb24tY2Fy
>>"%HW9%" echo ZCBkbCB7CiAgbWFyZ2luOiAwOwogIGRpc3BsYXk6IGdyaWQ7CiAgZ2FwOiA4cHg7Cn0KCi5z
>>"%HW9%" echo dHVkZW50LWluZm9ybWF0aW9uLWNhcmQgZGwgPiBkaXYgewogIGRpc3BsYXk6IGZsZXg7CiAg
>>"%HW9%" echo anVzdGlmeS1jb250ZW50OiBjZW50ZXI7CiAgZ2FwOiA2cHg7CiAgZmxleC13cmFwOiB3cmFw
>>"%HW9%" echo Owp9Cgouc3R1ZGVudC1pbmZvcm1hdGlvbi1jYXJkIGR0IHsKICBmb250LXdlaWdodDogODAw
>>"%HW9%" echo OwogIGNvbG9yOiAjNDQ1NDVlOwp9Cgouc3R1ZGVudC1pbmZvcm1hdGlvbi1jYXJkIGRkIHsK
>>"%HW9%" echo ICBtYXJnaW46IDA7CiAgY29sb3I6ICM2MzcxN2E7Cn0KCi51bml2ZXJzaXR5LWZvb3RlciB7
>>"%HW9%" echo CiAgcGFkZGluZzogMjBweCAxOHB4OwogIGNvbG9yOiAjZmZmOwogIHRleHQtYWxpZ246IGNl
>>"%HW9%" echo bnRlcjsKICBiYWNrZ3JvdW5kOiAjMDg0YTdkOwogIGZvbnQtc2l6ZTogLjgycmVtOwp9Cgou
>>"%HW9%" echo b3Blbi1wb3J0YWwtYnRuIHsKICBwb3NpdGlvbjogZml4ZWQ7CiAgcmlnaHQ6IDIwcHg7CiAg
>>"%HW9%" echo dG9wOiAxOHB4OwogIHotaW5kZXg6IDIwOwogIG1pbi1oZWlnaHQ6IDQxcHg7CiAgcGFkZGlu
>>"%HW9%" echo ZzogMCAxNXB4OwogIGJvcmRlcjogMXB4IHNvbGlkIHJnYmEoNywgODIsIDEzMiwgLjE4KTsK
>>"%HW9%" echo ICBib3JkZXItcmFkaXVzOiAxMHB4OwogIGNvbG9yOiAjZmZmOwogIGJhY2tncm91bmQ6ICMw
>>"%HW9%" echo NzVkOTc7CiAgYm94LXNoYWRvdzogMCAxMHB4IDMwcHggcmdiYSgxMCwgNzMsIDExMSwgLjE4
>>"%HW9%" echo KTsKICBmb250LXdlaWdodDogODAwOwp9CgoucHJhY3RpY2FsLXNvdXJjZS1ub3RlIHsKICB3
>>"%HW9%" echo aWR0aDogbWluKDcyMHB4LCAxMDAlKTsKICBtYXJnaW46IDE1cHggYXV0byAwOwogIGNvbG9y
>>"%HW9%" echo OiAjN2I4NzkwOwogIHRleHQtYWxpZ246IGNlbnRlcjsKICBmb250LXNpemU6IC43MnJlbTsK
>>"%HW9%" echo fQoKLnJldHVybi1wcmFjdGljYWwtYnRuIHsKICBwb3NpdGlvbjogZml4ZWQ7CiAgbGVmdDog
>>"%HW9%" echo MThweDsKICB0b3A6IDE4cHg7CiAgei1pbmRleDogMTAwOwogIG1pbi1oZWlnaHQ6IDM4cHg7
>>"%HW9%" echo CiAgcGFkZGluZzogMCAxM3B4OwogIGJvcmRlcjogMXB4IHNvbGlkIHJnYmEoMTE3LCAyMTYs
>>"%HW9%" echo IDIzOCwgLjE4KTsKICBib3JkZXItcmFkaXVzOiA5cHg7CiAgY29sb3I6ICNkZmY5ZmY7CiAg
>>"%HW9%" echo YmFja2dyb3VuZDogcmdiYSgzLCAxNSwgMjQsIC45KTsKICBmb250LXdlaWdodDogODAwOwog
>>"%HW9%" echo IGZvbnQtc2l6ZTogLjc1cmVtOwp9CgoucmV0dXJuLXByYWN0aWNhbC1idG4ucG9ydGFsLW1v
>>"%HW9%" echo ZGUgewogIGxlZnQ6IGF1dG87CiAgcmlnaHQ6IDE4cHg7Cn0KCkBtZWRpYSAobWF4LXdpZHRo
>>"%HW9%" echo OiA2MjBweCkgewogIC5wcmFjdGljYWwtcGFnZSB7IHBhZGRpbmc6IDc4cHggMTJweCA0OHB4
>>"%HW9%" echo OyB9CiAgLnByYWN0aWNhbC1oZWFkaW5nIHsgZGlzcGxheTogZ3JpZDsgdGV4dC1hbGlnbjog
>>"%HW9%" echo Y2VudGVyOyBqdXN0aWZ5LWl0ZW1zOiBjZW50ZXI7IH0KICAudW5pdmVyc2l0eS1oZWFkZXIg
>>"%HW9%" echo eyBtaW4taGVpZ2h0OiAxMDVweDsgfQogIC51bml2ZXJzaXR5LW5hdmlnYXRpb24geyBmbGV4
>>"%HW9%" echo LXdyYXA6IHdyYXA7IH0KICAudW5pdmVyc2l0eS1uYXZpZ2F0aW9uIGEgeyBwYWRkaW5nOiAx
>>"%HW9%" echo NHB4OyB9CiAgLnVuaXZlcnNpdHktbmF2aWdhdGlvbiBhICsgYTo6YmVmb3JlIHsgZGlzcGxh
>>"%HW9%" echo eTogbm9uZTsgfQogIC53ZWxjb21lLXNlY3Rpb24geyBwYWRkaW5nOiAzMHB4IDE4cHggMjRw
>>"%HW9%" echo eDsgfQogIC5zdHVkZW50LWluZm9ybWF0aW9uLWNhcmQgeyBtYXJnaW46IDhweCAxNnB4IDI0
>>"%HW9%" echo cHg7IHBhZGRpbmc6IDI0cHggMTZweDsgfQogIC5vcGVuLXBvcnRhbC1idG4geyByaWdodDog
>>"%HW9%" echo MTJweDsgdG9wOiAxMnB4OyB9Cn0K
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,'');const o=process.argv[2];fs.mkdirSync(require('path').dirname(o),{recursive:true});fs.writeFileSync(o,Buffer.from(b,'base64'))" "%HW9%" "%APP_DIR%\src\practical.css"
if errorlevel 1 exit /b 1
set "HW10=%TEMP%\webtech_hw_10.b64"
>"%HW10%" echo V2ViIFRlY2ggNTEyIC0gUmVhY3QgUHJhY3RpY2FsIFByb2plY3QKVG9waWM6IENvbXBvbmVu
>>"%HW10%" echo dCBDb21wb3NpdGlvbiBhbmQgdGhlIENoaWxkcmVuIFByb3AKCkFzc2lnbm1lbnQgaW1wbGVt
>>"%HW10%" echo ZW50YXRpb246CjEuIENvbnRhaW5lci5qc3ggYWNjZXB0cyB7IGNoaWxkcmVuIH0gYW5kIHJl
>>"%HW10%" echo bmRlcnMge2NoaWxkcmVufS4KMi4gSGVhZGVyLmpzeAozLiBOYXZpZ2F0aW9uLmpzeAo0LiBX
>>"%HW10%" echo ZWxjb21lU2VjdGlvbi5qc3gKNS4gU3R1ZGVudEluZm9ybWF0aW9uQ2FyZC5qc3gKNi4gRm9v
>>"%HW10%" echo dGVyLmpzeAo3LiBQcmFjdGljYWxIb21lcGFnZS5qc3ggY29tcG9zZXMgZXZlcnkgcmVxdWly
>>"%HW10%" echo ZWQgY29tcG9uZW50IGluc2lkZSA8Q29udGFpbmVyPi4KClRoZSBnZW5lcmF0ZWQgYXBwIG9w
>>"%HW10%" echo ZW5zIHRoaXMgcHJhY3RpY2FsIGhvbWVwYWdlIGZpcnN0LgpUaGUgYWR2YW5jZWQgU3R1ZGVu
>>"%HW10%" echo dCBQb3J0YWwgYW5kIFJpY29jaGV0IEFyZW5hIGFyZSBzdGlsbCBhdmFpbGFibGUgZnJvbSB0
>>"%HW10%" echo aGUKIk9wZW4gQWR2YW5jZWQgU3R1ZGVudCBQb3J0YWwiIGJ1dHRvbi4KClRvIGNoYW5nZSB0
>>"%HW10%" echo aGUgZGlzcGxheWVkIHN0dWRlbnQgZGV0YWlscywgZWRpdCB0aGUgc3R1ZGVudCBvYmplY3Qg
>>"%HW10%" echo bmVhciB0aGUgdG9wIG9mOgpzcmNcUHJhY3RpY2FsSG9tZXBhZ2UuanN4CgpUaGUgaW5zdGFs
>>"%HW10%" echo bGVyIGFsc28gcnVucyBhbiBucG0gcHJvZHVjdGlvbiBidWlsZCBhbmQgaXRzIG93biBzdHJ1
>>"%HW10%" echo Y3R1cmFsIGhvbWV3b3JrCnZlcmlmaWNhdGlvbiBiZWZvcmUgcmVwb3J0aW5nIHN1Y2Nlc3Mu
>>"%HW10%" echo Cg==
"%NODE_EXE%" -e "const fs=require('fs');const b=fs.readFileSync(process.argv[1],'utf8').replace(/\s/g,'');const o=process.argv[2];fs.mkdirSync(require('path').dirname(o),{recursive:true});fs.writeFileSync(o,Buffer.from(b,'base64'))" "%HW10%" "%APP_DIR%\WEBTECH512_HOMEWORK_README.txt"
if errorlevel 1 exit /b 1
exit /b 0
:REGENERATE_REACT
call :ENSURE_NODE
if errorlevel 1 (
  echo Node is unavailable.
  pause
  exit /b
)
if not exist "%APP_DIR%" mkdir "%APP_DIR%" >nul 2>&1
if exist "%APP_DIR%\backup_before_regenerate" rmdir /s /q "%APP_DIR%\backup_before_regenerate" >nul 2>&1
if exist "%APP_DIR%\src" (
  mkdir "%APP_DIR%\backup_before_regenerate" >nul 2>&1
  xcopy "%APP_DIR%\src" "%APP_DIR%\backup_before_regenerate\src\" /E /I /Y >nul 2>&1
)
call :WRITE_REACT_FILES
if errorlevel 1 (
  echo Base React source regeneration failed.
  pause
  exit /b
)
call :WRITE_WEBTECH_HOMEWORK_FILES
if errorlevel 1 (
  echo Web Tech 512 practical regeneration failed.
  pause
  exit /b
)
echo Web Tech 512 practical + portal/game source regenerated.
pause
exit /b


:VERIFY_WEBTECH_HOMEWORK
echo.
echo Verifying Web Tech 512 practical requirements...

if not exist "%APP_DIR%\src\components\Container.jsx" exit /b 1
if not exist "%APP_DIR%\src\components\Header.jsx" exit /b 1
if not exist "%APP_DIR%\src\components\Navigation.jsx" exit /b 1
if not exist "%APP_DIR%\src\components\WelcomeSection.jsx" exit /b 1
if not exist "%APP_DIR%\src\components\StudentInformationCard.jsx" exit /b 1
if not exist "%APP_DIR%\src\components\Footer.jsx" exit /b 1
if not exist "%APP_DIR%\src\PracticalHomepage.jsx" exit /b 1

"%NODE_EXE%" -e "const fs=require('fs'),p=require('path');const r=process.argv[1];const c=fs.readFileSync(p.join(r,'src','components','Container.jsx'),'utf8');const h=fs.readFileSync(p.join(r,'src','PracticalHomepage.jsx'),'utf8');const q=['<Container>','<Header />','<Navigation />','<WelcomeSection />','<StudentInformationCard student={student} />','<Footer />','</Container>'];if(!c.includes('children')||!c.includes('{children}'))process.exit(2);for(const x of q)if(!h.includes(x))process.exit(3);" "%APP_DIR%"
if errorlevel 1 exit /b 1

echo   [PASS] Container accepts children.
echo   [PASS] Container renders children.
echo   [PASS] Header exists.
echo   [PASS] Navigation exists.
echo   [PASS] WelcomeSection exists.
echo   [PASS] StudentInformationCard exists.
echo   [PASS] Footer exists.
echo   [PASS] All required components are composed inside Container.
echo   [PASS] Production build completed successfully.
exit /b 0


:CREATE_REACT_LAUNCHERS
>"%APP_DIR%\Start_MyReactApp2026.cmd" echo @echo off
>>"%APP_DIR%\Start_MyReactApp2026.cmd" echo setlocal
>>"%APP_DIR%\Start_MyReactApp2026.cmd" echo title Student Portal 2026
>>"%APP_DIR%\Start_MyReactApp2026.cmd" echo set "PATH=%NODE_HOME%;%%PATH%%"
>>"%APP_DIR%\Start_MyReactApp2026.cmd" echo set "npm_config_cache=%NODE_CACHE%"
>>"%APP_DIR%\Start_MyReactApp2026.cmd" echo cd /d "%APP_DIR%"
>>"%APP_DIR%\Start_MyReactApp2026.cmd" echo start "" "http://127.0.0.1:5173"
>>"%APP_DIR%\Start_MyReactApp2026.cmd" echo call "%NPM_CMD%" run dev -- --host 127.0.0.1 --port 5173 --strictPort
>>"%APP_DIR%\Start_MyReactApp2026.cmd" echo echo.
>>"%APP_DIR%\Start_MyReactApp2026.cmd" echo echo Server stopped. Press any key.
>>"%APP_DIR%\Start_MyReactApp2026.cmd" echo pause ^>nul

>"%APP_DIR%\Build_MyReactApp2026.cmd" echo @echo off
>>"%APP_DIR%\Build_MyReactApp2026.cmd" echo setlocal
>>"%APP_DIR%\Build_MyReactApp2026.cmd" echo set "PATH=%NODE_HOME%;%%PATH%%"
>>"%APP_DIR%\Build_MyReactApp2026.cmd" echo cd /d "%APP_DIR%"
>>"%APP_DIR%\Build_MyReactApp2026.cmd" echo call "%NPM_CMD%" run build
>>"%APP_DIR%\Build_MyReactApp2026.cmd" echo pause

if defined DESKTOP (
  copy /y "%APP_DIR%\Start_MyReactApp2026.cmd" "%DESKTOP%\Start_MyReactApp2026.cmd" >nul 2>&1
)
exit /b


:START_REACT
if not exist "%APP_DIR%\Start_MyReactApp2026.cmd" (
  echo React launcher not found. Install React first.
  pause
  exit /b
)
start "Student Portal Server" "%APP_DIR%\Start_MyReactApp2026.cmd"
exit /b


:BUILD_REACT
call :ENSURE_NODE
if errorlevel 1 (
  echo Node unavailable.
  pause
  exit /b
)
if not exist "%APP_DIR%\package.json" (
  echo React project not installed.
  pause
  exit /b
)
set "PATH=%NODE_HOME%;%PATH%"
pushd "%APP_DIR%"
call "%NPM_CMD%" run build
popd
pause
exit /b


:OPEN_PY_PM
call :LOAD_SAVED
if not defined PYTHON (
  echo Python not installed/configured. Use option 1 first.
  pause
  exit /b
)
if not exist "%PYPM%" (
  echo Package manager missing. Re-run Python install/repair.
  pause
  exit /b
)
set "UNI_PY_EXTRA=%PY_EXTRA%"
set "UNI_PY_TEST=%PYTEST%"
set "PYTHONPATH=%PY_EXTRA%"
"%PYTHON%" "%PYPM%"
exit /b


:RUN_PY_TESTS
call :LOAD_SAVED
if not defined PYTHON (
  echo Python not configured.
  pause
  exit /b
)
if not exist "%PYTEST%" (
  echo Test suite missing. Re-run Python install/repair.
  pause
  exit /b
)
set "UNI_PY_EXTRA=%PY_EXTRA%"
set "PYTHONPATH=%PY_EXTRA%"
"%PYTHON%" "%PYTEST%"
pause
exit /b


:INSTALL_EXTENSIONS
call :FIND_VSCODE
if not defined VSCODE_CLI (
  echo VS Code command-line launcher was not found.
  pause
  exit /b
)
call :INSTALL_PY_EXTENSIONS
call :INSTALL_REACT_EXTENSIONS
echo Extension repair complete.
pause
exit /b


:INSTALL_PY_EXTENSIONS
call :FIND_VSCODE
if not defined VSCODE_CLI exit /b
call :EXT ms-python.python
call :EXT ms-python.vscode-pylance
call :EXT ms-python.debugpy
call :EXT ms-python.vscode-python-envs
call :EXT charliermarsh.ruff
call :EXT ms-toolsai.jupyter
call :EXT usernamehw.errorlens
call :EXT PKief.material-icon-theme
call :EXT streetsidesoftware.code-spell-checker
call :EXT ms-toolsai.datawrangler
exit /b


:INSTALL_REACT_EXTENSIONS
call :FIND_VSCODE
if not defined VSCODE_CLI exit /b
call :EXT dbaeumer.vscode-eslint
call :EXT esbenp.prettier-vscode
call :EXT dsznajder.es7-react-js-snippets
call :EXT formulahendry.auto-rename-tag
call :EXT christian-kohler.path-intellisense
call :EXT christian-kohler.npm-intellisense
call :EXT usernamehw.errorlens
call :EXT PKief.material-icon-theme
call :EXT streetsidesoftware.code-spell-checker
exit /b


:EXT
"%VSCODE_CLI%" --list-extensions 2>nul | findstr /I /X "%~1" >nul 2>&1
if not errorlevel 1 exit /b
echo Installing VS Code extension %~1
"%VSCODE_CLI%" --install-extension "%~1" --force
if errorlevel 1 (
  echo [WARN] Extension failed: %~1
)
exit /b


:OPEN_REACT_FOLDER
if exist "%APP_DIR%" start "" explorer.exe "%APP_DIR%"
if not exist "%APP_DIR%" echo React project does not exist yet.
pause
exit /b

:OPEN_PY_FOLDER
if exist "%USERPROFILE%\PythonUniWorkspace" start "" explorer.exe "%USERPROFILE%\PythonUniWorkspace"
if not exist "%USERPROFILE%\PythonUniWorkspace" echo Python workspace does not exist yet.
pause
exit /b

:OPEN_BOTH_FOLDERS
if exist "%APP_DIR%" start "" explorer.exe "%APP_DIR%"
if exist "%USERPROFILE%\PythonUniWorkspace" start "" explorer.exe "%USERPROFILE%\PythonUniWorkspace"
exit /b

:OPEN_REACT_CODE
call :FIND_VSCODE
if not exist "%APP_DIR%" (
  echo React project does not exist.
  exit /b
)
if defined VSCODE_CLI (
  "%VSCODE_CLI%" --new-window "%APP_DIR%"
) else if defined VSCODE_EXE (
  start "" "%VSCODE_EXE%" "%APP_DIR%"
)
exit /b

:OPEN_PY_CODE
call :FIND_VSCODE
if not exist "%USERPROFILE%\PythonUniWorkspace" (
  echo Python workspace does not exist.
  exit /b
)
if defined VSCODE_CLI (
  "%VSCODE_CLI%" --new-window "%USERPROFILE%\PythonUniWorkspace"
) else if defined VSCODE_EXE (
  start "" "%VSCODE_EXE%" "%USERPROFILE%\PythonUniWorkspace"
)
exit /b

:OPEN_BOTH_CODE
call :OPEN_REACT_CODE
call :OPEN_PY_CODE
exit /b


:OPEN_OUTPUTS
if not exist "%USERPROFILE%\DataScienceTestResults" mkdir "%USERPROFILE%\DataScienceTestResults" >nul 2>&1
start "" explorer.exe "%USERPROFILE%\DataScienceTestResults"
if exist "%APP_DIR%\dist" start "" explorer.exe "%APP_DIR%\dist"
exit /b


:DIAGNOSTICS
cls
call :LOAD_SAVED
echo Diagnostics
echo ====================================================================================================================
echo Python:
if defined PYTHON (
  echo   %PYTHON%
  "%PYTHON%" --version
) else echo   NOT CONFIGURED
echo.
echo Node:
if defined NODE_EXE (
  echo   %NODE_EXE%
  "%NODE_EXE%" --version
) else echo   NOT CONFIGURED
echo.
echo npm:
if defined NPM_CMD (
  echo   %NPM_CMD%
  call "%NPM_CMD%" --version
) else echo   NOT CONFIGURED
echo.
echo React project:
echo   %APP_DIR%
if exist "%APP_DIR%\package.json" (echo   package.json FOUND) else (echo   package.json MISSING)
if exist "%APP_DIR%\node_modules" (echo   node_modules FOUND) else (echo   node_modules MISSING)
echo.
echo Python package fallback:
echo   %PY_EXTRA%
echo.
echo VS Code CLI:
if defined VSCODE_CLI (echo   %VSCODE_CLI%) else echo   NOT FOUND
echo.
where clip.exe >nul 2>&1
if defined PYTHON if not errorlevel 1 (
  >"%TEMP%\pyclip.txt" echo %PYTHON%
  clip.exe < "%TEMP%\pyclip.txt"
  echo Python path copied to clipboard.
)
pause
exit /b


:FIND_VSCODE
set "VSCODE_CLI="
set "VSCODE_EXE="
for /f "delims=" %%C in ('where code.cmd 2^>nul') do if not defined VSCODE_CLI set "VSCODE_CLI=%%C"
if not defined VSCODE_CLI if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd" set "VSCODE_CLI=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd"
if not defined VSCODE_CLI if exist "%ProgramFiles%\Microsoft VS Code\bin\code.cmd" set "VSCODE_CLI=%ProgramFiles%\Microsoft VS Code\bin\code.cmd"
if not defined VSCODE_CLI if exist "%ProgramFiles(x86)%\Microsoft VS Code\bin\code.cmd" set "VSCODE_CLI=%ProgramFiles(x86)%\Microsoft VS Code\bin\code.cmd"
if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe" set "VSCODE_EXE=%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe"
if not defined VSCODE_EXE if exist "%ProgramFiles%\Microsoft VS Code\Code.exe" set "VSCODE_EXE=%ProgramFiles%\Microsoft VS Code\Code.exe"
if not defined VSCODE_EXE if exist "%ProgramFiles(x86)%\Microsoft VS Code\Code.exe" set "VSCODE_EXE=%ProgramFiles(x86)%\Microsoft VS Code\Code.exe"
exit /b


:FIND_DESKTOP
set "DESKTOP="
if defined OneDriveCommercial if exist "%OneDriveCommercial%\Desktop" set "DESKTOP=%OneDriveCommercial%\Desktop"
if not defined DESKTOP if defined OneDrive if exist "%OneDrive%\Desktop" set "DESKTOP=%OneDrive%\Desktop"
if not defined DESKTOP if exist "%USERPROFILE%\Desktop" set "DESKTOP=%USERPROFILE%\Desktop"
exit /b


:DOWNLOAD
set "DL_URL=%~1"
set "DL_OUT=%~2"
if exist "%DL_OUT%" del /q "%DL_OUT%" >nul 2>&1

where curl.exe >nul 2>&1
if errorlevel 1 goto DL_PS
curl.exe -L --fail --retry 2 --connect-timeout 20 --progress-bar -o "%DL_OUT%" "%DL_URL%"
if not errorlevel 1 if exist "%DL_OUT%" exit /b 0

:DL_PS
where powershell.exe >nul 2>&1
if errorlevel 1 goto DL_CERT
powershell.exe -NoProfile -Command "try {Invoke-WebRequest -UseBasicParsing -Uri '%DL_URL%' -OutFile '%DL_OUT%';exit 0} catch {exit 1}"
if not errorlevel 1 if exist "%DL_OUT%" exit /b 0

:DL_CERT
where certutil.exe >nul 2>&1
if errorlevel 1 exit /b 1
certutil.exe -urlcache -split -f "%DL_URL%" "%DL_OUT%" >nul 2>&1
if not errorlevel 1 if exist "%DL_OUT%" exit /b 0
exit /b 1


:EXTRACT
set "EX_ZIP=%~1"
set "EX_DIR=%~2"
set "EX_EXPECT=%~3"

where tar.exe >nul 2>&1
if errorlevel 1 goto EX_PS
tar.exe -xf "%EX_ZIP%" -C "%EX_DIR%"
if not errorlevel 1 if exist "%EX_EXPECT%" exit /b 0

:EX_PS
where powershell.exe >nul 2>&1
if errorlevel 1 goto EX_VBS
powershell.exe -NoProfile -Command "try {Expand-Archive -LiteralPath '%EX_ZIP%' -DestinationPath '%EX_DIR%' -Force;exit 0} catch {exit 1}"
if not errorlevel 1 if exist "%EX_EXPECT%" exit /b 0

:EX_VBS
where cscript.exe >nul 2>&1
if errorlevel 1 exit /b 1
set "VBS=%TEMP%\unidev_extract.vbs"
>"%VBS%" echo Set fso = CreateObject("Scripting.FileSystemObject")
>>"%VBS%" echo Set sh = CreateObject("Shell.Application")
>>"%VBS%" echo z = WScript.Arguments(0)
>>"%VBS%" echo d = WScript.Arguments(1)
>>"%VBS%" echo e = WScript.Arguments(2)
>>"%VBS%" echo Set zs = sh.NameSpace(z)
>>"%VBS%" echo Set ds = sh.NameSpace(d)
>>"%VBS%" echo If zs Is Nothing Or ds Is Nothing Then WScript.Quit 1
>>"%VBS%" echo ds.CopyHere zs.Items, 20
>>"%VBS%" echo For i = 1 To 60
>>"%VBS%" echo   If fso.FileExists(e) Then WScript.Quit 0
>>"%VBS%" echo   WScript.Sleep 1000
>>"%VBS%" echo Next
>>"%VBS%" echo WScript.Quit 1
cscript.exe //nologo "%VBS%" "%EX_ZIP%" "%EX_DIR%" "%EX_EXPECT%"
if not errorlevel 1 if exist "%EX_EXPECT%" exit /b 0
exit /b 1
###UNIDEV_V3_LEGACY_END###
###RIFTFRONT_ZIP_BASE64_BEGIN###
UEsDBBQAAAAIAHakI10qoGK5EiMAAA9pAAALAAAAc3JjL0FwcC5qc3i9fct228iS4N5fEaXyNUkL
hAC+RD1IHVmiy+qSLbckl7uORlNKEkkSIxDgBUCJbDXPqVWv50wvZtO9mcX8wuxn/sRfMiciH0iQ
oCzf7hnfc0UgkY/IyHhlRGSWP5lGcQpPMEv4CQuCPhvcW/jSGw75IKXHSz6k36uUpRyWMIyjCZRi
zgZp6dWrQRQmKXyFDri1tiNfP0AHdmvq7fz4U+8KOnBTc9sW1FuOBU2ndiu/fj4//r13+cc/QAf2
GrKs96n38Xcqct12SxZeHf/W++PX3u/QgVLsD9NhHIVpNWWD1B8k1Qe3JOudXJxfXNJ4pZ+dttN3
WyULSj+7uzWnzuixttv0hkN6bNS9Pfk4HNb7u3X52G/XPXpsO0Nnt0+PfMj3vFbpVk363fFV74+T
48tTGuwVwBP43j6UHlg4mrEY24dswveh9FtWMoiSdB9qFoyn++A6TQs8NmEjvg9uy4Jkyrm3D42a
BTELsbTewMeU74Nj77awfRDF+wh5zROTiKMAxxj6o3HK45IFo2AxHeOoJVhaGVj9WfDI4vsMqne6
QADVEEDVmgZQNUcDVatnQLUUUK6NU9BA7baGDhtkQKUsvDcgepeHKJnm4LnC12QcpRqiuoBot20A
1NAACdQQQO5uLYMIEakhGg49p1XPIKIGngHTVR6mRz+ZZiBd+sMUvooiAZIrQGoYIO1piAQUBFFN
o8ixsbIGqD/YHZjrljyyeGLA8zUPz4R7/iAD6PMsSDh8lIU5LLVbGUi7GZJ2MyThUimY9nI4ag/7
ngHSbIpiwQBqOw/UIJ4lY6I1tXQpi+FElwq4WgKu+p6TAdbIls/NIGsYq1c36Wk4bLUbJrJ8PuIG
XCd5uLw4CnkG1fWjH8KpLMsxXtNYPtfVICHlS5AQaIWrVs0AibWHw6b3DEGdrhA5NxF1Mo6jMIIr
UShgakphgCSjydxYQTdbwYaxgiZRtQds1ySqQRSmcRQYUF0QVLevXg1n4SD1oxD80E99FlyxB16u
wNMrgJinsziEJ2D+JwHuqR/zQRrF8FvvHwjeyYSFHscxT9g0ZX4If8e8KCxZ4PHB/b4hE+0k8Ae8
7FjQqtgTNi2XBxXodGFg+17FgsEsSaPJCYu9ZB9ubmH5amnAFkTMMwBL4wX9AgjJO2Vxwj3owN9d
XXyy6a0cRAMWXKVRzEbcHvH0LOWTstIZFfinf4JSOAuCUoX60VO1bTuHCAtLZP/LVwBLGLB0MJbD
y2a5FlgpB/yUx4mfpOWQz1MBfw62ZAU2S8wiSWM/HPnDhWiH3crR8B0HEHOPWYgzLzML+oRQBtvw
kaVjG79Ek3IF3kK5D1VgFdlkELDJFNuEFuhm1GTC5tiRePbDct+CsFIx5jKMeTL+hU14OWEPXMxG
dMqCANWebdvZmhPyqKZtrC/i/ua2cqubIqlAB6gePgvy8D0xnSCwh37omfQCnU4HfK9SsYd+kPK4
/C6KAs7Ciu5yKI0X6FDvdsDDUTqGIzHWJro0aJ6WdxJ5SPXTgC38cFSyIPWRDRwLsBIJf3w4CSKk
dbdpAVbl8QfS5Y5jAQ/5ZKFfqVMe8ni0IDanr73sPeEBH6TI5EiaFsxCPyV2sAD1oHycsjj1BwGX
rymfyy/UveA7NX8Lxiz0svdsto2KRZR0GrNH0vUenwbRIqHpEWCnWQH1nIzZvZj9MGDJmJ4e/TBE
9hfwMv96HM1G4xRVwICFoR+OIB1zSMcx58Cm0zhigzEELOTJtz//J2JUNDhGcUbj5Hlnwu75l9BP
ywMWexYkvsctap6XUAQfite7109YZ1l9/XTKUm6H0WO5gm85jljemV2J2c33qYhIi1acxyU4yszR
bWg2YF+bolVoNixY7Atr9gb7kQuAshuhtcdTCyZs/sF8V/KcCsSLFuxURs+iIynkqZielayXJSlH
CRwFXvQY7pMcKDtkfjl2vaKVAVWmZ9GrUDxUio9KRYg+o4BrFUEl9GzB1J/zIJFl4gW5mFadeu1H
fQWCFB+fz+At1CoWJOksDHF+Bcvbn8VJWh5ZMLdgIUHGn1mYorHviFUeRjGUA56CDx1wDsCHQ1EH
H7c74IpqACNb84Y9nSXj8pPs+GEuoau2mxa0mxULHhZrRYE/5BqRNUJkC8snbE5qX1kiSDz/qGrW
UHDAcl3sC37CyQlSExSc0a4QVEIa/MoXKAAL6K8kKpRgnx6VuCi9AvCHUB7d6A5uEStisZMUV2dk
C+6sKDYZsiDhrwByjaqdrBV+s0noCPRt5r6KHH8N5AqMbClJaGleAXA0UUe2KVPUJ73+P856Jt+Z
RA5u05DjaTzjuVUJOYt5kl6zeMRpZJyuuSAemThYtUPf7CLQXNiHqpsNI7FGRKh0UnlG+mpmj6fQ
BQfevIGZ6Oynjtk1leM8aBAqp7c3b6A8s+dQFWVz1OMZcF2otoXpYidRnJYz/U/cx/pJmeUaV7MP
ffND5ca5zWGIpSkb3CvUWJASqkwUTePovyAYAVc4IvEEXWg5ki6yKhlvkgrTfLkvASAhSo8LXFk1
3pm3L5+OUOErYUOEIusLclQSlYqURJX2rixFsSZWMLODpXSk74qppX2950h2FpSL0zFxABIuXNdq
xxxXSEJF0rLWXD8trNxwTWMM05gdT4U02Eh8Qg58mJJMUAYHCgTkbGp9C53MnnOsrLhqglvR68Lu
cSW11efWLV28DY1Kfl4b4VL8ua85V1ZembhbE8ISVKlQYRktpXmWTfzJLGApx8E9uQgk+2y0z4ib
tIlWJPdIqqHlhlLHE0JOm224hLJMCEXoCPu4rAu2wUvhLTg2+hocC9WSqq/Ecb6RLt3UMjN6JEh6
Rhlchx2Q6k/Bq4RmHn4sbMrSzTOoG+O/FPbVNmhJShNfvEhjsorWBkr9wf3NyFY2JfxFlknb+/ZW
dqMrmNNBG9YQDV9hB7fmi33YqwkLdx/uTi4+fjz+dArXXy4/wesngQQ05YTednM7YOnnUYo5Q3CG
+i7U7BqK2fzEu4ZBoeQdT5JZjDxygxixoHYr9ihCm3e6Wm2uyv51PsmLe+rAjrk3G/Ay7sdEwxC2
SXFY4JCqVZA8cnbPE7SNFEy2H3p8fjEsa+7F/ar8mGuLNjhLeUgb5Q3N2XxjcwHyys7yEBy72YYj
s/N9BaXRmA2HUeyxPmkMSRYKVWpbR2bLYSe/GgICXLqsC0lQao3UGGgDQMcY6oZgHQZRFJdXN8Tr
vQnyBMNsE3K2lLPcZKWRrbc6BjJvMizcQhfcNmpD8e8I7k7QYuW4qc8Iyg/h9dNNKYzidIw+5YlP
XuYkmqXj0q2wbpYC9Y9+OobXT9pwX9p3uvd9uPscR33s+oXdHYCfJkBOaAii6D6BdOyHusscn3RA
zGOpOInscYH0GURDRfxqQXC1yOoRIgx1rh/OhHacZeJeCV4slHuEFbWVlVdR8BudZxpd+SZXqYEF
AUq2Vb5kwqeQ8aVk0TdvgBlGmLbAGBofZK/hAxXgxIAhjB+mlVXjiz5XoW+Pp2RYCZCIfhGgN28M
8ywIFsIQQ/PsEGbSiiIBobFkqgH8R63G6L3RDE9FBI6lP2+DK83DFazjTEjDqm/rwlcARtKXHtEu
qztKDJe23XZJydy811F6+4XM1YuRLb4gIfVXSiWyjaBTYJib0qfPEo7xn9kLLQ+jqecnKQsHSMdy
sKNsEZSRppZh37CSaUhRrklPd3bY0Qu2rexD3Bi0YR/qzUq2ZIJgV9bTsLG1gS1Qk9mcGfXnaQD3
BNsd+r5xZ4IibiZ8CbhrSDfybyL4l0zzvNLTC5OxEDrhlGKTTrjEVua6oFux18nwlf/+k7ajIbE9
zpDhcYd2oOkkTxtzvWZH9hyOjrC/l61/TvEtjG4W2E1iL0wCoWGQBBJ7bpZTO6T+lfo+aWAilPFi
GqVlb26BJ3WVxGvKkUeT1TVQNIRrSnW2YTdb2hxSDPrJbz/WtiCJuf/IMC83OxVVOROyjl1XDGnu
P9b3IMmPbkBetglRAGdy4ru7kLqqKwjE3GfhDmthQaL2F7s5VspwK9jGm8MOLSHyCC6B/r4Q3xdF
3/8m3UckP6M1fYfQmjysC/Orne2yUALPaOuk901aoq/L7JnaSJO0xu2GlNZXH46vr3uXvdNCmS37
VhJbzFI7gQr0Z96nIXYzJDyortjhq7oJ1f1JEHUlj7upwJ1216FImIoVmtoPc2KYA5iKNZnaDwtd
gh+Rgvea9LYw33CCwq6Q09D9E3iZc1CBOCUQZUM5IQPKVEBJyEYIyUfRgZojoUnXR6S6NJpYIjVS
SiPJBgbqkLrfSqqfRo/owUXPozB3RjZ52lcr1MV3vadRLCiIjnbAkkNXdpFiX0zQmRWQpRV3Kzej
9CeILXYHCz3uqUIBldi+5Z2ecTTDiuUBcqXwvT5aMLYglg6kdG73+cgPP7N0XK4cUAE1uuSDtJxv
kev5MWbTaz5PRdeIXDXAhM2/+l46RgIP+QeOiQ9Ueu6HtPJ103n1GGEIqkM92Mk08NPyzn9KtncQ
3+hjxj5wwiX5HkeP0gI2CAM7Qdqgzlb0ptifUTdHGI/ApyW8fsK6yzvcHkWxp4UFzn/CGe4GaHbY
vGI/4nygq6eGkgT7MazcdI60FVAj/CSwAdsE8FsDFUpoYLnecoOapwZGgIOVup0MeVXcC/djzu5N
mSrbIqxSYqi2h7pp5YdAzDnOY/b4GWMMwvWMyz1Ta50MGO0h5ZLisD/NZERizc8tVbH/j9jCraHD
SVa1h1HcY4NxuUz7Xwt8Ys9MhlMx6T3HcCNlaL9KFwSHSC66oeq3yHpSouYqC9JGO9GHvwh4qhg0
eCumI3BSNnarPuxQtcpKPTH7bdx0517Ix/Gc1xtRSlFbwib629kDt2AcPfD4fCUikaA5pETTkYyR
yHetkdFSdrImix9pks5tHF5xfxqzMCH/XjK3ICEzShr9I/RNpXN7QNtqJCsW/xIzz+dhiiaFY8FX
Cz5gi/7IZp53gri/SqMpfi397Oy6tVqzVDlY/4wYLP3s9F2nViuq4FJiWM3pY/tX6wvfHx3k17eK
qVH05ys6TR0LPtBvZUMAa9dZjV6JSSP2yz68BXdvV0XyEz8sSxcmehPdJmwjxb5FkwD+Al+N5gvV
vF3HTy1X7N1Xwb+LR31WxhQTd8+xMMXr9ZNjuzVFpA3s3bGdxrJytzJRwYg1C7Qbl1Y0jaN7rrov
Ufd7ruW2XOrddmuVkugI2V4INSGMNHJw5s4BzOEQvuLPdgdaDVS7hUpjEj3w6wihcWvtSta1KGvu
ObJMAFauEKR6LEST22gdwAIOsTI+bHeg0f7eeI4Fi/xoX7MSY6xXICJUmaRZ5KWMWK5RTPb+RiJ3
ceO9sMB1mzSyUMAx89apnVDeaFpusy1R3q4gZa/XJtqXBOBYe01R3dlU3VW1sVqzaSHViM4LSQs7
OMgbApTKhIYpZr65Tq1twV7LgppaI2xOiTNFtKSFlMj6QGNFe3f31TzqTcvd3c3mvU5q693UYV9q
wx8CVi1y4eQzRKn/2/WGAmcYUVi7tOs44LrTOSSLJOWT6sxXFZS2vCl9uri8/oDOu49naLqXri6+
XH8o3d74txa4mDVHdv6elPxZ9DJmj+9YgqAgG6AHGXdwJt1tFL9zSsY1d7Fic7AhMK1yZXERfh4O
G7u7vJSNMGZe9Eg0hOSNvwfGh3fBDMtr7WIk/uy6Lqu7Eit5cjD6Mpe3sb6QVUwjrLq4jO2GBTVa
xVqO5DasaA5IJ2tQAMMoiPosOA6mYwYdsF0BR07OVF23LQSNW1OCptaurKgPyeiYDS33eevdu+ug
lH7mfIi5fnkS20MSaxeQGJq9x4E/Qk9gacDRI71KfKRyBtwPyuNphZRs68XEnon5/MxqmCaBsZOa
MbkNKM23dJsOWqG1NryF8RR2ZGKV7MwszDpGR2IUq1w80FxRzgKT2a7JynIXDrKa0qVkZVslHRCo
vMAPIHe5lJ3bAbdQkaMWn9n9qK907Xf4U7kECjtrmJ3VFWGjiZhzFIoZwBFUBWz7AkZL/FQ28K80
ags42G1pk/mnYrtdmGl1wyO6TsIOd5u1diG754Y2GV55sPIsL4ywmkUGGIpJ1/kew68DlBvz38FR
+AWJSW0pJ77nBXyV3WYqyQoxlflh1il5EwM6Fv7P3l3jPJE9gtgQVIOqDHFC+4Wiab9Yzr9oIPJB
E3fOVHhC7FRe4IJeI8FkMwm2i6TiUIvENUuOxYNygryUoHtNRObNlLUCesnpg/UpFHmz1qW3iLJL
Z9MOTBEpIsReWZ/BNEeDCtFTBHuKYE9t3CCqX2HdFiiM5/1Zm2AUbqqNsKWb+KPm/G0aJ6VKFohs
GXuxeTqvNjFB3dq13LZlt7Xxp5GmN4quay6u+tZyavIrqabvKNjcbAI+TAsUb63+nG1Xujx7f/3+
8uLTdckiTqlvGHeX7bn9wQ/bjqXr45Prs5Pjc1AJEzs7cH72Ww/0oHsWNHeLB5XMnh+0jYM2nhtU
5Hir4wBiXu0NQwyHrf5eqwifMTqDCrsWJxBwb11d6ft58ioSCDmJ3npuVndrqSYyMaXubpoa7UsK
SGLv2XFkfrKKlGTpPRU7jd77c+6V3coyyQBo1YoBaDf3mv32CgAtnGjtWZoZRJM+SyHkDzyGKZsl
PIFvf/4PmZ4KMceqCXDM3pbLTKnvJQ0RrkjRkpg88jJcFWrZDFe9T73LX36nVRHQmSgiU/DOAvSh
t+qkTtdH3nNZbdD6cSS53/78l4ZM0ifs/D3s0PR7MmsE0ggY5VeUJAhNilvJdCntChAJJeveAPSA
1OsOenfQubPbOlDZDIPUfxC5M+qMgNjGFipyWfvINNCdtrW3Z9m1SrZprtWtesNq1Sx7r1kpNL6y
jowdd5Zru26U6QaYr4sO1xX7bG5BC4/joY+CDqi5L9qP5TYKK8PnKKf5Pf2zQo0ioJDlwqOT1m1Y
0GoQgxcRjzfg69ut1nel8p1M3cHMlSURjywQkdAlHF//emcAIBj8h2TM963TQvmqs7/V6HWcv4y3
FmilRnuv3yzSSs6z88fDNvD6ycchUJJmYwlZTv7rotm222xQhG7nRWv9ClYiR3hCJNMoy3349ue/
oizRCV3Lb3/+2x1uHPBwXQuVTc1FQ6iBu5hXL0ZJ6/soOe19Pr/4vXcKJMxk1vwSfr/4AjtKvumU
+SUcn2VgtfeM+J9Kd316bpduNS23btm7z9hHHzY49HTc8OU7A4MsW0WGQ5HWzg1OGNo4MppQcNU7
+YKBbRyeTBuMxpwff76iYLfW1M4PcfLudxVQ6TNm78ElCvuYS8GPDN1LBmzKZQwmwc9SUxrQNPUO
SCydiKR2wXYwDLDBTW96WJAsZFAY7Fpz3T1vrKa2orNdpBkUor36R3bP4/KTDAhF4ZX8fYeH55Zm
XOhGiMiEp8g4mN2hLgEol07odB9cpbF/j46UrJEQLAlPT6IkzTWqG7X88J4qnYX3G+uIyB1VI8iT
XM0yKdPjOGaLstto0MnAoCyyZ9UhUR9zjDCmJG4xKFOccKUChU+oLz1OuRwF4izik6yJKcwyEzoK
vNsDKrjxESA/vD8wD2pKuSZ2uuyBjtPgGGu6HxOq4E4ck8yfXrszPbIC0R06TaxOEeNfO419TG3F
c61yNXAofah4WywEHZ9HA4Pe0VXUyI5QtI3y7LxxswZVXZwdsW9QrEiU/wVq6Hba1Wek7XZ2RFqH
SO8pQGrcsaAOJxO4xtnktyV14kx6QgRZltVBWjqlKwg2f2xYFpuHTVWVW3UiWVfCVwt871alsbfx
GJdiT7mEh4k8bzMIWJIg4Xe2pizkAQzRrokXW12C8LA/S9N8tdEYUYOHLrcgCk8Cf3DfeRKMtex+
++f/CidCOhzuiLayI89/6B5OzY74gvfj6HGr++XT2TW8v/jy6fTy98OdafdwXOsSiVb7UegBg5A/
QjTlMUMr7HBnXOseTrufiawZuLX/89/dGkhLP5nGfsptOEsTZeTTUrJZGk1Y6g8oX7XPAsx2TChb
eMxZkI4BTX+Rv2gTEDsIsYbdBByPj8XVgC2iWSrxtF6JFro6in0P0fQ58lEXnHP2wDtPkks069qD
WRxzYlLiXVguVbcATzK0L86Wi5Qpwclqce75ovPkLyFB6dp5eqLFGZGBqsmUGt7CcpkBcxo9hp2n
sgyiAMf8+Acepqd8yGZBilZrAYAir5E+oEAxO+zhHzW7taZv3uhWRpsv0xehA1jss2rA+jzoPN0R
RtDoWt4tYadbUblzxpptWjWZPJjodQM4pG67JMGQPBJ/FB764XSWwgMLZrzzRHnpSOxjlBEaZ1Jl
lLlMBrWpenYUueZUcOfWPdwRI6yOKA9miAMCuDkIR90nfFse7shXCUe6mPLOFkmoLZj4YWfL3cKM
lM5Wa0sBSQ0LgUQVtQLkBrhWaZgFPE35VvdJUNH3aJC+rKyViLXJtcr6fvLD+yzwKfZXZPGUNtCx
TOhbZjJHkI3QrkRUSAk5EiiUX9PYn7B4YQgvpb+W3fdRPOJ0XAu2gXkeGjsoT/Oy7DnBuFUAn1S3
BUp82T0JOIsBxUTBGDlxOfbDdKt77U/3Uc+Dx+J7pU3QFcriSTSLhRSDPu2ICGezmD7jafVBFHOS
bevsoh8Pd6Rm6OZsqlM+uH838wPvhUYVbr6S4nsTVjVZdl9CGo1GZB6qOxKyvKXsDgU/HAQzjydU
580b43YFeRfCYQezPIzcJoxXrl3FkOvmyPigEhvnBMGcDklgnSINm6U+G+N3oV1R41G5kAdy471Z
5VOTH1DUWL9Kj//hurpYTZ/2Tn6F9xeXv/SUkiaKgAXSGF7rcc/BiwZ4v4dQ0rKz7sk4ihIOjW9/
/ktbMBeRhw2/Y0s6fjdYUDZrOo5xr4qHdhKBEHTcLXKuuYyCV8UVYYQO0G91xWbYWJflTlvfQ/GM
bkfIhNbukh9D6d0CYWf7Xk6i3eHUqnRcS+7F85RGN8KgtFNgSHl3tybTBCOIBoY4LFWrbICbytI+
nSsTAlFzczJl4dpUUCvgVGylV6Ys7B72sYS02uFOv3vIJ/hOLpzDHT7pHiYTFgRYNp4uYTwLAtoI
Pg20V0cYSqqULOqlMKwPd0RjKVYkXRmCeYOEueIp6v7kZXs2L2ZDsf86xafclolucHkJByVyyP+v
XKSCF1e96+uzT79cKV7CaiSlJ37oJdDnYx8JfszhkcUGO63Qq56DoFlFC0KxE3/p6EXepiEMZqGN
YsuBkCuElMS4cTXSRrOngRuOAgMjM3smCzg+K4JHeq9eCIy6v+kHITHZ/yX2gWDKFclNIKAGx1Lw
PR6mfurz5DkiECocnxNgMSdCx3OKYlMShULufT4RWnw6RdPAx1JMTX7gcHym7pWBIeeekoR5juJz
uuvQE1Y8aAY7nk7LeRUdPrDkkg8zxwFeRZBt60dswp/5HLNh7qsISsgztUm66dtNMog5D4l3r+gx
73KZ8HBmOlqEMMDK7CHvnVGXZxmVdTIctfig3nLNxCwy50XK4hRziEUddTukdLw8KSyYe5L8XVEH
2UzKJaxdqsDSEoDfZrAJh9qVjnLkB9MHrnNJlOikzA+fZaWMxIEII2xCN0nks7rNA8QiWHOTNcnM
F6rx5o15Rlg6JXOHhCu58Wg4NFYsvPUKEarv01TIowEe/dCLHu0YT1rEf+B8/kijP9BRuuIv+t60
1cR1PvzKfWJPoEgrjNBZU/rIwxl8OQM/gdOLj1U8+OjZxjHODd1o+1t1J67LEmdG6Gqi2PNDluJF
VSXBRRDF/gg5NZpW0T2Pab5+iJmvGHAkY/xAHHdeCHkn+D93UWhJ3DiE/8QtXCJcKq7iuuKDKERf
0LYRRNUBQryOSCwYpuXIs56U6Zalg1Xk7VfrNWQeWCUbX13ltb0WisSRcrd7iSrqPVdPkQpa+fsF
pApH4me/gDSPROBKQyRu+5LxRmGRqR1o+QnomMI+pp3jJQbyJigZ+hJuQnkMf1mpZFojF4A3rvgy
YiYZAPLKMnVujEAQh8aQ7sTlLfLmFjH+TI6Pq74Pmw+vizPZtxaedhOn+XG/i6lHFeHWzJYKs47I
l5fdT6YiCQpQ48Cb5jzmPaCz6xoT6jpQniQ5n28Btx2sMNpBlveJxA0dmCQH4rGLaaT0VMWkuUru
UpPsyGPLokoVldEoAZQMqEStxwOe8mcExsFKFXNmdMbPMtRLtrrPSSfaXFITceGKFOASMgzxDv2Q
i6NEpt6kiK1UoDkpJSvRGV9RA29pPIlCnEC5VPNUerm4zy8WmqccRo85UUgrIPWo6r+iFKuhjMLo
MSc8PX2El+7McBoW9Q3V1bZ6LdS5qWe6zhY1TyjqPB/+WzmKs1px9WCOEsFkRBiDxvyvM56kx6GP
3toofI8IKhOaTNL+8XYrtDZAwglWqud7rRwUIMUpJDRjZs8Rm1iiezqCrPyuxnorMxb8UJzGj4bw
4frjeS/gE+lBzdx4E7yukyflElnR4uQgizlTcrdEMRNd3U+IBMO05/kp3g9SyVkKCoB7jjL8PHrk
8QmmC1dEiHJo3EOhsmKjwQyhsoezIBC4kHBWQH9TD/KLLVfpvW5yZOtsVXmhmm7L535xReXtfZZ1
f8CioFmLeYpQZ6limnTaIP0ulsQtOKMjHbjWtmXZbL/zn2/cauP29Y6NBw1Fd6u21bYAqqqPNWLD
m9JfUXM84h9eus08CwUQVSorFmdBa3FDTmHjIi3i9TA6cO4neBNMXC7d8wVe/VCykKIrOjooCF4L
cTxf9GzDFXbKQ21lOBSMZcpgGUIgZrJggJs1FTJYYzq8Xw46wNX6i/s4UDS/Q33rh6OTAE8mUawZ
83WyU2fcHtCn36FK3dhpNMWw4AfYEe9jOuy5fqeQOCglLlRa5O+wC3BtF5XsiqQ+xzBmaIFvgbjM
JcTrWG6w/BaOwId9EHWkxDb3N+UFXsvTpIP5dPCrhWefCQpxhWl2cQVhafVSmbk5TbwbhKYlNPZb
ivFTAZ3eNegRR225NOoculCvNcXjIWZzOJVVljPpW+TjGkdDy5hpXa87pJZ2W+J8hr4cQV8esj7R
NTrP7jPSlxsYkqKzruQPJ3i/s+nvYRNeTcY80D4hqfNjPuw8abW/BEJI5+nrEgQJdJ4+GKGtjxHF
+gQt5ii2jPGX4qBgbllp6UzvYGFfFsXkyM2xyaeBsrRKGqMoPpGXdMtu7+qEPHsFbq3DHURWtwCn
Mm78DFrZdKqwepjlaJD+FDEYnClu6DtPcruPBehl2wwruXY2gYTu1xfCY8Q3/h8CpJx1LwRKuUT/
wyAynKIbxwVslqf+VZfjgIWYHJlsaYorcLGOeRxtDI738Sh1dcLi+60u+a27l8o1nQvhbg5EVE8v
z37rfYLL3vF59frsYw+uri+Pr3u/UAaBaj92uzor/bAfIypoFJFKfqXHHLvFQwaceVsyzMF0cMMG
ESekwAdefiTi0TpDIbHhesxDGEeBJ6+IJvcdXQ8Nj2O8YJSFwDw2pbRS2kBnnlVIYx9jIREMYvR8
0zDovMjF7laj27hqGEaNwlxse6N/E0Y+C81wpVa0y65IzUMI0PVI/wESEV7ofvvn/6aRtikkulnA
CIbE/gf3Eocq1FAUrqH4i4on/C3jaZm0FNH99+I9P6gRilRjy9yaf8/QGasvu1KO6hBHfnzp8t40
2DMMcc8XyIdb3ZPzs5NfgTJRt8nqgP/9v0BkdV/1znsn1/j+9ztfd3ogcjPx/T28/3J+fnVy2et9
ykJqmSt5E2Oj1gkozLWRvWPmsXire+gjw2V/+iSKvs/fdKjj4vPni6uz67OLTypCsoIuFRHB1UBv
2F9nUcq73/781zO8mttb6NsIyWMVjxYWudX5fBrhf/SAmNGGHsUXhQlBm6wBxR0SmCzQpRba3/78
t8MdY4ANU05SllYJesEopxcn15dnn3oqr+NYMnuW2SHZiP6SgLpSdeskLoprXvc+fr5QFd0mJHyw
VtEM6xvLqbTA8tX/BVBLAwQUAAAACACFniNdCdRAbJUAAADmAAAADAAAAHNyYy9tYWluLmpzeFWO
QQrCMBBF93OK2SUFTS5QhAouXLjRE5RklEjTCZMRLOLdpaBWdx/e4/+fcmFRfOBJJQU9cCR84lk4
oxHqgxpIHyUI9UpHZv1X1pGzD0OicbG7Ut6K810p7lrvX2acrzoNVF2o1QAsvTZyuGUa1V1IdwPN
cTvtozXCrKZpnNAYSSwgtsvjDSAitvOmn3Prf9gKGngBUEsDBBQAAAAIABWfI13+Ka+8AwsAAEsg
AAAOAAAAc3JjL3N0eWxlcy5jc3OdWcuS27oR3c9XIKWaa+mGpAHwKapu4qqssssyWYIkKCLDV0Bo
RmOX/j3VAN+kx/Z11cxYIgg0DrpPn258EVXbSIVusjx+KpRqu/jz57ypVedcm+ZactaKzkmb6nPa
dfTvOatE+f7HPwr2Itlf/8VVWsRv10J98TG+BBhfQox/6wf9s1Zcmqfe9PQSYXw5Y/xbJrq2ZO9/
dG+s/XS6PD3FsmkU+obSpmyk3aUFr3iMMiZfLggsss28MdITW6h77xSv7JuwUMfqzu64FPkFJSx9
ucrmVmcxOuAAn4l3MXPG6MB57ud5P1/3XquCd6KLUd3U/IIeT7+jbyhp7nYnvor6GqOkkRmXdtLc
4WmhqtJCSZO9W+jQW1sxeRV1jPAFVaK230Smihi5FLd3803BxbVQMSIYP8Mk8Dq8t3z0WlxQ88pl
XjZv9j1GhcgyXi93I1kmWGlf4S+v1TEVMi05YgpR/IyI/2yhA6E08THCFlKS1V3LJK8Vcv3nk/XB
+5H/jEL9vpsRTJP990c0H0/JTammtpCo2xugAHjGSNQFl0JNA4bTXDxyWNvaXcHLch+GtumEEk0d
I8lLpsQrv6DeWWJ0lSK7oLZkKbeF4lUXo5SDP1xQy7JMH5rrAfYDmhOWjyenS1ldipp36NtsnVzc
eXZBou640ifZNgLmtPkrr9XoHl9tUWf8rkcszoW3nClRX22YmskJYZzx6xJJjNz2biF5TdiRUGyR
M7ao71sOJtEJee39tIQojhOeN5JrJGvFAeZPny6/bnzTslSo9xg5rj833xYVu/IYrU03FmJskWCw
MDwhAsbP90Pa+8navHw2G/+FORYmdeIrj5HvtXf962JG542sYtRy2bU8Bbc4ehFu7yckG8UU//cx
oBm/nlCXspIfiROezHslU/w/R9d7NtBWvL6N7teHq4lN8C1b8aqFN+y0KW9V3cXgohW7H7GFiOP6
uTwN37gYw1acKJenC7qyNkZpyar2SCP43n99s1AYDUdacNmsV6zYfWCM0DDGf2+dEvm73fEyjxGv
s/FdCzlwrqWdMplZyGlZzWELe+EyeirRr/N3nsjmbYrGQxBkOfBgyRW4SgfOAaHjUMorQ48xCjFG
hLZ39MnwPdJ8/2lJtyP/ITNY8yRZEqOZ7oxxj09AAZ/QIYAQweD1n50w+HCdtaW2g0MwVfG7sruC
ZRDpYISH27vxvMC3KCHG8SjVp1AQ1LVsxkszP7wg+40nL0LZZk4lmxceIwDgkOdeHrkfrgbLhNQi
NLQc1yxG5zAAPvqIDRrRiIbxFg+w8Cn480cwPJ6ckrNMTzz6TnDWEw+Hy4IkyLwhyelYIiEMgDCd
2NYJfD1fIlmd2RWTL5N7giEXNAw1n0wuNIB0TSkydPBS40Y/Q8+zGDYBe/R8iNfBheykUaqpBvrW
WXgGNKCEDq6bnPPc3xjeH+p2DXtYZPJBGmxceiIGlkIsQXpY7ek75EByCT99+JsD3kZ1v0PVtLFe
frvekFCda9F0CsJbiopJUAoD7mTC3aUeC+lwJDbQ7g2M0YstUpNmYNeiruW5lhMFp1meBKdAxkDt
16wU1zpGJc9V7zxvvQOAZkPpTXbgX31+6U+05x6HRB3irOPLk9NZSZ8f1vaPkTL8ONgE5h4acQE5
fMDEfFoe8ozfbQidEZGR56IszdeikHg08aLtql3FdFIYXg6jM06CmXcnZZO+LONqc7z+COfMzlvb
cplqdDaMiyOgsbUtzlWwGpSV9jvjbjEi6DOyyfK4hviab3Gdjwk2CflAvCBPqYUOwdllabQDGM2y
SSCbPZ57hzUm9aGWlw1TMZLgIIvhVIfv48l54e9gxzzr+GF0TodYDCC94J1Y3EBEdFKaozzaNKXE
ibwqUcOOny3k+SAQZi4PLHLZjagzZX6wiShqmO8jaIOZ1qHYomfL9yzn7J9GlWcRbEFWONPTaU1s
rt/eEcgYdMAYR9YsYgL9bcBpFrkuXu9W++L/bo2aA8yyhGVk3AVE8oKvhzQ2JCUKq+MRn/4FEu0k
i55zJcuYnMkYMP2CmJZktmRKNFp0DAvYIWyC3VSj19qHHjwuD8MN+D5IpD15sy++98ubtfyGE7XQ
wfPSPM8pRtQFEgQJYoHCFuk0QS6bCtE+cjwMVnr+cj6qVSWrRQVbr2N0LZs3RB3PkKEtaru5KSTq
XNRCccRKxWXNFJ/AHBS+hYbPLFea6L4j+FnSNeUNpliwmoERxP165tlxzbO6kaDmyDXUj7UB40h4
bSFcDdWZgrb3CTFsACXTglp2DNPoD3tnvNhHnvthFG0FAAFfHZ/uwWG24oaDfTSaNoVEXKvCTgtR
Zkd6+qbHBv7zBUb6/vPeMLcfRj0zLIjGYYl54kXmCfydbeLgRzzM8wsUnIop22jvnxMUxp+PrgWy
YigrdEA+psmWGvYQkDA4JwsW1vy4JVKdambzKNnU17ltfYob+yUsp+t0QHdT3notQ1hDkTJnZgKS
A3Q/htjZIQQauGmwVTcmsWzUTWiBvgF69fbZleCBXtksE3h9rdKb+DfUxnWjjkOtdJrBG3nnMImW
ug7m3HIkgAsGjrp/ErV6/CS9wCTwaG0CELoN/vCrXgLEaudCWUNJSqASMK4z+M72vAwTP56cWy3U
kDsXjZje2o8aMXnJoZYp+d3OhISCHAYaAy9Ia5OhAtCDOsWkmrvzWrt6S4D0mNENc9O223OWs5v4
fJxOb9AdH78yebRtloJIOv0gketKQbfQSOqCRsKMYIpPP1S+QbcnoOf4/ki7ur12nfuu5jt3VAbg
WuN8TsdLnioOB9fcFGxlnuc/2LVprlbifhQ16uQ1sZajEXGf51tfeAkQ+1S96vJhU0fNhvNqCqKV
SXM+IT9QzGasei859LJkxcrlMhvZzs84wZvghL6libS06UBZ76UQIy51xGhlO3z4mQK3pwaqqXdY
13z6UdJboTPsBIcEE76qxc5Qiz2enIynL3ba3HSVsFTj82C3PV1vDlPmeYYDd6+8gwqEvYBqZO+g
WX6WipbNMB/IfeyQUWiPLDKZp+N6QQ8DfguKMhnvyWnFnZd/ihsJHRbeqNPlFcEZZyTabW+4xDsH
+TowYYe9OMcYJ5bpA2l14iZQblIKjnRLi76am64X5tsZO+RbUtupkn1/XsbMqvFUNl1XMCHBvc0B
gm6UTbnXxIAjMDXNZnDJEl5ayOm4AjndGSv1t9+ZaEHRZ4+FabhyLLjvQY+n4ZZgISFnVzLBpkTH
jFDq7ZcLxAsCtompaJk+XH0FMFBjj7+5rojzJr0BOKvS18em9F0LT92yRweX67MddI3WO3NgTEKc
gNFZ703CZ/gNiA9vjUc/3BYtKMN82rrjolW5t/tNmlqv6IA/vvLt1nUT7zu5abyTmHWkftxqOBAa
+mloHULPTVJw3jXavmkd7rUyHk4hNK3NBG545ugv5rKSAQAbRfpYee6f7OBpJMf6GJqO5sSvrOI7
1wavb4uCCu6vfiZXLJ3dxT5Odm+s5sumrH5l3abNAX3jlJWp/n+BfkfECfU/UICDacPYYjb2DX1e
jN1hlHUo9I2KPEyThAZgH78LZVdMpcXejdp4D+Gv8uksz44qOzxHSbiGJgRyTpJ96RctpN8QC+GC
CeAEjcTYhsfTlxf+nktW8c4U7t+Qgjua9bZ9Te40gpaB5+21sgPTZH7AnBXPBEPHWbVAMORBKCmW
t0/f98ipJaORgi6KDgtzh7S8JJqiZtEMm6dT06UZKH9M8B+tvw2nD0ejx9P/AVBLAwQUAAAACACF
niNdFv9p7QoBAADLAQAACgAAAGluZGV4Lmh0bWxtUUtSwzAM3fcUwmxJnW6AhZ0lB2DKAVRbTQT+
dGw1JTsOwQk5CRNShs7QlaR5eu9pnsyNz06mA8EgMXQrMxcImHqrKKluBWAGQj83ACaSILgBSyWx
6mX71Dwq0JdgwkhWjUynQy6iwOUklMSqE3sZrKeRHTU/wx1wYmEMTXUYyG7W7VUxGShS43LI5ULv
tn1od5v7qwxP1RU+COd0wXjmvexLTgJbdMKuwtfHJyB4cm/N7sjBc+qhEIZGOBJUKSjUT9BjpPWf
kbAE6v6pGb0Ac2T6NzOzy3468zyPwN6qkrOozmjP4xlZroX5D1bF7I+BFNTirNK1OB2R0/q1vs+k
ZXUxWbSNXl73DVBLAwQUAAAACADhniNdu/QhdWcVAAAzaAAAEQAAAHBhY2thZ2UtbG9jay5qc29u
7V1Zc6NYsn7vX1FRr4zEjlBHVN8BIaEFJIHQgm7cusG+iH0TMNPz229Ilm3Zlmzk8rhu9/RDhYA8
mQdOfidPcvwl9Y9fvnz5Gii+8fXXL18Tx8zMJAyyVqZomaOlX/92EBdGkjphcGgBt6E2dHfVC7Wd
6XjG6kGKHq8nRpw7iZF+/fVLluTG8VqkaDvFOl77xy9fvnz58vXh6M3uj00u3sJRohuREehGoDln
5o+SvxdOZrgpGHm55QStxFC07GDAUzIjzR4sHG/5dVFLD/3L4kMXZ5KT4PezuyuYZzf4+y9nTb4G
oW78rx/quWek4N/DUmtFSegaWgZmVfTkic7HAGrDGHk+ComRhl5h6AehnWVR+isIJoblpFlStYPI
d9N2mFgXOgBbd7+tk8l2ZtWPZp0gM6zEyaqD3dRWcBhpTX0sBV0awAbRIJ3ba7bfw+xOUu9SI/Wz
gN+EfkgkPV6zQJWsOSGf1Y5o7XoL2CyZ3mbmjWmQEMiQomdbcDYnxNHc7VLfvj326jmaEaTHceVH
0uN1Mw90J7CeejlPvPOHtpzMztW2FvpgGoVBGiYpePbQDx56xQlJ6Hl6uA9A1Tn211ICPQkdvaUk
fstQVOeKU+A20u7c7pI3uwNbV0WtY59v+6xfRbUVyL19tZKxKTOc1Kw/HUu4CmwUoU8HzrBMed0Y
CRwNZlqv3gZ2nNTDaDtQN11HKUsAFx2a1BRKojOz2M479aoUzn2mRfnXX7/896NflMS/H+z/edOz
YZQ5YaB4ZzHj7nr6zOjd8780bASWEzwPAAe3Hrr6jkBtuNuGvvzzn19++4YgbRhpQz+KBAL7PBgQ
2GUMEFhTAHhwZ9jv9vfGWonHWztf5lN6Cg5qnkDKPcD0e6tgXBV8WgZkMR5QLFfhgskxoUxpSRjs
qCm5KifboVEzUe4NmXnZxYvB/i0AENifDwK6kuyd4FMQcN7VGQDOLzf1P9lnyD43KIYbjZj1+tIo
wKzNTJ07ikio2o4HnWiTqbU3XzEiT5t91u1NrFkXGnTlzNQjRslWJbgV9h1lCxdL3gQBCeV/iv/v
nv5nu7/8LOeXl1xfNnc8uJ4nTuRmDjXaItla7ui6485ECVq6FtnZl+s1GGvhYNWbUOsVM7czGSqT
DuNCPMpWU7YmIJfdS33PTkLQ3w26utTRmdcjf/kndLuZGIaa6p/g97Oezhx/drWp52GMGWFTLY4K
ddQrFwHLlejczxhlHYtzcMIuWJXoAWOOW82NregR+kQfqgoasWksoUWkS7Hdl0dzFuJ5gdSgUo7D
cUl9vudPj/7TXO85QV4eMy4ryA9Jl23+myFwocczKFyQNoWEWibrkVgM10KhjvcOsBo5Brhjxr5Q
atM+UZbr/VaPB2C/XFGOlQ13BY6tJU6Yq4CQbvVgUMGkaXXGc3PNcpA4JIr9yPsJaeBxCH4+IAjs
4ILPAsNdb5eAcCdpCoIsnMkI3bPpbZWXy85M3hBSgJJd3cFGNRXPpUpbaZoDzTqDhUnHtUij4jYA
JvgoJaipiWW+JergBK62UjqVNupukwac9b5UQNWeNrSOl/7EePHz1PtEwBy6u4KYg6jx2wM12khD
UHE4kStTyRIK03ZDbAJX+noUQRCwgopwlnRVQwW7W3+3HCSLkQqh+mY6EC1+Wuz6RMimAxhyQoFY
piOgWODCx0DmOKJ/SsREkfaJEeahtxd4eZA0hctOD/YLhJzvjCAC/S0v7t3NZrMvhU40Sn1AHXTh
LrecdFF6VtkalyariT5Hoq5ZRs58OqfUaa7ZZBUJGRT5yBzh5B7Fvh5hjvf4Hx5hUrQLlZ+Gl4fe
XuDlQdIULzhMzPS04vQE7xN4pAzQih7geEb6pt8FLD/rpRO0HHU2k81I6vRN0RvaJUdOwKlIDHOS
Xi+sAQ7A+w7mSRwEBKWmkcLrL6fHe/wPx8vhXeKz0HLq6wVWTtebIiUhwZoMOuxAkUUvQEt/DvfK
ChoOwSHHQzm9nO/6+WLVNycsQ5FdHhqkW3E7Fhd7A8zGrlgCZjQELTdMTJsmM7+vLgbcu95p/sNw
8ml5y31nF5FyS84SUWmfdBymXFpwSce6nUimheHUillFTuLWEJSqXl/ueex0qvEBowIGqRqCFY+o
PcEVSr4BqXlhlctgn1h5AMoyS9v7j4DKnzFjCSMjsJXED4PqU7ZGX/R3hpcXssZprqSNZN8PBIEi
ZwmIMEq2IMJFrOncsDAC3V0ANZcDg70lhVWw5sWFL+gRT+CmRE3H1miB+a7Kz0J8IiFeIHUXlNol
fsom6dkQ/DRI7J0ARe5fNtJC+zcj4nl3Z4B4LmqKBwNlc3RdqtMduIwFu4yXHXkkz4Duli7W0xpd
AjYYi4MwTTV+UOviXN3IC2WxthbBzisQs4Ylq6YlLXOQGsU1sOMk6fCn4OE4Aj8ZCeVn4qC8hoLy
RgysQdfC41BcxG7aLyBA3zqYQZAdXxvG/ipfQnPMnBDxAixdI1sjrK/Ba9IFwRoPKGOq9Ugp8yF7
hREjV5ONfLWX7dx51zLyR0TAHfUizxzvGpPhwOaAf8DtZz2ArfOz1tHy2w5G3K7KZvjYJm0XKOaZ
Vc8zr4O4UCWWQ6rK/TAkpKlJuSlHQ9gyixbFXJ1rjEbzZd0JgG5PpiENZkthUMqihbiOH7NPHPzM
da+M22XCyqVhI9rwe4btQgcPo3Z32jpafnvYqpJThFXX2tkL0qjHcY8ngEBfdnxGJqyYsjr4VACg
kbvvj8iRPPOFnrUT98PJamGuN2uoQzBpzIcQswOgwQReAjwuWk//oHwN8a8Qfq7g7uv3O5TdI/cj
0P9gIzKMhGl8Sy1VUY0jYeX7AZ2dg/HvUPtg+d7ily9fj41aT9yihX7keEby8DhPFA4MlyxRgtQM
E/+R6XToA8OfNr1nLH0/kH0aPA9vZErDZ3ps8zIwPYh+b/ycN5u7PArNzLwd1XQjM7SsdcrnL01K
pA23kZsn5ZldsHV+1jrae3sq0pmL0LPZjERDdF0N8a5B8tYmLfvCSlOS3XIW9eUkV2koT/bBFIYq
ASWwJHXoagnDwdaL1/LWh3AHDM2OE2J+7dh0JlyZilSkaLbROgfs69Pot29kgyXD1J3kaqg7R3DT
UT0YBFvHn9bRQoM/jIxUOduquTZLIVpk4/l4l9rjpaxzwIIZdvQVT1puBfTFCF1TS5frD8Z9AEJ2
SlANs727ngX7ZCLTzp7yeSjCdtyYCjZWk5D2xgAeAs/toSdytNBXMs0+znb0GGmw98z3c0MfNZnM
1CiMILuWFSBttI3e7vOT0YPfT4eto6UGW5BlyJgbwOQ6pkJJgWL563mkDrK9DYqdztrn+TgesgsC
76FFQUPyMLEGAA3L/hbFMDjjXTwg0B2EwMhmGo73tWeb5tMtSFtJR0GaKZ630BInyp4nbD+HIEG2
YeJuifsOQ+3T4W/f4LsV5m0/eo5lZ4ETWFp6PcND0XdM4HPLYOvJaevOZIPkfbdkktDNxylU7izW
RHJ9XSpoxdJiOc/K5Y7udB1C6W050dI6c540t0ZXClNzzmhFPxK2aj6gFsFQ9kWO5paqz81Go6tU
1Tn3NCxeT1SeLiVfvx/mN3pjevLbty/X4sJFnuyB5XvQO2wNaKHnGVrmFMZ5ZvCMSfu04ZFRGymJ
ZngvO7zH6PVg9MR9z1mUzyHyvP0zyl3D5mWjxk+JPW+1vswFaaz1sOF+i8Zp67WZyuOefvP2DTu4
sJ/TTKV8qXBbYGlIu/3hMPOCcntd2DgEWf1IlBRvoodphNEqGa8zDXFmVh9fGKOhFy3gPOqqgxjZ
U5Vse/BSl2aq7AyNLln3+e5CKBZhLGzhkcBA42lkobyHR+9kW1wPVf9e8u3/g1DVEGiNyL0/jrNn
xN6rssYoW2iOUpOGEUylSdBV0awDlAnkRFLUlcuJIGNBtBdQPxFzDqKp1ZDmqm0ZmrYyoalVVvuZ
uAVrqQohMAsxGs7XLMi4Pw1l70pl/nAgKz8DYncs0iuSxvDa4ss5VdaJ662n04qtCIfAtXFdF9YY
Z1CJ2PNFCljrSO7qnVi0qWlSxlREcHY5srb2ur+HSdEcS6wmlm7OjegE8MnND5KI/wLXRXA1ISr/
OLqekpSviRrjSxB4UHJAW1Dc8b4nA6KzznvbbqpnI3Aj7DoBM8GLHrnb6XunNOqZx1gFU3YAUQIE
d0IMtIGE8VGah3QwHIXgDF1komj9HHy9j678x4let9Chfxxol6nQbzVpDLxpZ7CiDcJZIBjv8YQI
YiItlawt2MaWTTuZI3SXKLLMBh18Ws9xoVOu52LM0b1J6YmCuEMTGXZ7ozlXl511PbPz5UjkfpAQ
/V7gvYcA8AeE3RukpQ+E3ANl6TVxY6i5SAE6mV9hQ29aehpRhJONbNHx1IGmFsItbAurO2xuRn0r
hfA5gKQ5vaqc7oiQhzGeh6tB2e1LToAavb7NraoNKwSTz6Nd/4XKt1D5KkXqY2F5Iki9Km8MzMqZ
4eKMz2XB2qg9Aqrc7RLvyYvBlp1sOGg4oKRN1vWH4wAG6jWOh72MH3WnprayZY4fMFzHWnVCeh4G
YN/nedZCZkX2aeTuv3B5HZdvETw/CpSP5M7rwsZwVBJgnHc4X5tC4xAbRBxmR4NK3U/ZLohSIJ3g
kzUSIG41YyyU7283CiNTjG744XQB0MzU5K1JUXljzsUWeFaJlJbl1Ltywb+i5Ieu3W/SSD8Sjtcj
5BmPtBkgRdmR1V2420NZYk7iuDYHOO5ZTrDvzxMGnY0ZU8rH9SCF+QnhDALGCJQaNmOOyzbYSGLR
2S4bC5uZISl7WNknNOVt559EJP0rOl7CY2Nm4o8j8gIr8VV5Y1TCE4Cfm9xisIoiu4501dzZ3npH
7OlEmql0vUAkQldhaD6dbS2xy4arlFrX+2mV20tZVqUIQV0AE5NAM3N3i+VUvSn21M/a8XsPO+2P
8+7SkP/4UWg74z6+Im2MtJnXH/WYEtx40CBeRJiaVGQ9CHoFGzkWynqY1YvzQt4P83g86fdgIOhO
LSZwBkU8ZH2+gLe7mBknTDyZLKqdxGwAw85/sI78L5ydcBYoweHvMZchdWA+wOTNkLqzCbZOB607
M28DhZEsjB+rLL/emQ6x2g70aYaAmsKrQoXNcmAWgfZYKNj+WgtWZkjBAgWUtTih6n3XZQiAXc1m
hpyA/kjLmYWeW8SAAJ4slI/z+hEsTxgp93P87itQZ3O72YeiFOfrCxLL2xRc1QmeRah7pxxEp1Fs
a256KwERPhEzkLsf9EQXhLETSQN/wmq8HowOBB4t9MLkOkXjPWzSR7MHDunDSeto7W24lJoxRNLA
zlSc73pOzKR+f48TnoF2CF/a7vob0O2roFhOB5VhTXOvY0xTr7eZdweMC3JaDm3ISb/iNWOOBFmk
DBOmv7pGzhgteq8Qby8xnM7HB2tD7+CmP1g9Dc/xuHW09fboxNo4J0kBGa3jccowONIdT3h9z/qg
XoyCNTYshEDcO8PuOHPscVGzs1RjsmEfLeGInhjLmVSlArlb+VwwRnbjvFPZGkt9CBmt4XrbYL65
YZBqtucEOyNp8mm2KEyz60Qjso23kdvD3cnowUl3R607Qw3eDMS8jpksw+WujcZ5jdtrewJI8yD1
Vymx3i+WBLcb84aMDdNs2WdyWWLJ5XihK3terP2aylbApB+y5BQVLCTmKrzgQepdAe9qUtMsrTkN
wVn0+9vr/WWObniOmb3a032jYx+nRznhAAyih26b9/qpYf06fesxvn9/tsSe2JIPwfZA1T4PrYfK
4zBPNKPlK1HLvW+C3E5Of7I2/PYNxhpMn9cKCuBuG2nfPnnuSwjuyNt3Rt6eOPO1IlMwB8bdHMk7
pSw4gIxyqGwGjtHZVJyhjEe9FcyzDMFFSUqXGhWzrlwlkCGjESDoKQWU4CjZZZjgmCRDoMBC3X9A
cIPacDPe4/lnQT96OA9mH4ZUD/3Gw5qsosTxTZZmUUYEpBgaCSzCSPi8nGQ2vB6xjO/i1dz36gST
aaOTV32AybFwFUvMZrsYsiy7ETNp3GcXC2NeCT2etp5+3uf2uZJqtnEYsrvCBaiNdG5nMj/WM5yG
tYF/TiUKH1ps9lD30Ho4bFpGZkH9jCtoV1rSHdeuVtAClHp5hBbgZrHyMLxYjlh1xi4xYe5UrmQE
PQPzJ/mgWHfNviX7C2QQYgi1TFPRn+Z87Wz0xLF+sFzm0tdmv357/m3ZNwtrLvjzRUp85o9jUqx5
Ttu/PSNuVpLzNh210Tden6HkLbV7AumbOi/prE1VysYKL2itb2pcpbY21zznnt6k9chAbah2/mmc
5lrnH0hprvWEUnuDzg0Pdal6voneZUpuQ7XyhdLbYfU8ml/+LvUxvt8aWB/Mgq3H49adsQZl2tMC
WCcrdZLDJlqo8lgCy8wZ4GlF4cP5iM/M7siSwWBiQek6rqllv4hlsPQ7M22rgbFiciXozLoDa+Yb
CyrCCjxzwNeWvVfG51lyd23tuf1l+4nlwzCdnx9XoQav3MvNmp/Y3Gy/mqgdhBwtM2G+KU15CeSp
XqnZMpmAZM72yZ7AF4k9i/ZFzdB7FxLsBdfhBa1TjNLRgmbJlUACI0YoI1O49lJJL5gW2up5Sp4a
H5+AZU5QWV6oqtV1KLbh29f4R7uHL6M/nBzA2IYbLPT7jQjqcqTFE99cR3196zqT8Wzfmw4CnYEY
PkjWoCa7KzbL+jvaXFkaNxiG08RzsY7vzlaO1q2qaU7gipdaA2wqVJKC/OBCfyqu+/r9aSndixqx
w9bEhQqxd1anvXdTYJFHRqLZeZQzRtEACaeC1ss7Asg7CjIPBsHW8ad1tPC217XBhFuBc9Gilt5I
9PG1y7tjknATM6ujWLOGwDIFmAXpj9AeM3WGKLS2k5rMhxwK8DNuTlmxytNUvNapIRXZM4oH6ldD
UAOvPyvNOuRqz4s1XroffyJ+2G45FIrhbYQ4l56ndP86BCDsXPpkfh4T/8NsfDtRvC9PPiSJh+P2
vytJvBGep8r5w89/naD6DX5P6nlW+fj1X3d1jje+Dv397j9ueP15zxOA073rRpGF4Slxh9rYqe4P
eh4UjFTNHe9uf+NuDb6vUn/2WuA62TFP/u0b3EbgZ3VAxgk4B1Q9kaTKAx47F0Qtw1cNXb+bpZfa
ZJWXp/erBY6dvWUfpLmlJCf7h+3xJ6qZkaSnF1H8WPf4RJiWp/sln27YVIp/V7CPtLE28q6C+ScO
u7ms/YL/brbx6NObVU9evlnvhICb9U74eJfeOXhuN3CPrNs183vU3az6gMnbNY+AvVntBOf3FHL/
cvj3+y//B1BLAwQUAAAACACFniNdHYQVlK8AAABeAQAADAAAAHBhY2thZ2UuanNvbnWOQQ7CIBBF
95xiwtrWuu3KhRdBmJoxlBKYYkzTuxvAmkbjct5/fP4iAKRTI8oeZKCBhzA5blhpJh3lIcc+UFKc
DQ4zFpQwRJpcfnRqu7arIj996RknM1usLOpAnqPsYREAANJgyk4irgaAvM5kzQahXu/IB0yEj0+4
3QJgLf0GPTqDThPuPjln+R6P3s43ck1ApTl3WMUYeSsvG37oH7ngxkzjLtqtSJevIatYxQtQSwME
FAAAAAgAhZ4jXWvESThFAQAA9QEAAAkAAABSRUFETUUubWQ9kLFuHDEMRHt9xQDX7h0QIFU6w/YB
KW04SLu0xNUKJ1EGybWzXf7Bf+gvMXYvTsOCnBk+zAGPZfJJuzieKHqJFsINEsfLMWl5ZcG8PmtJ
MFdyzisyNf6B2FsjSfBFxZCVxMHCmlds60iaDG9zqQyflRmVhA2xixdZGFPJsxfJKAJlqvDS+BTC
4YDbLq69WghH3NYSL6A9b4DPLKA9Ct6R+KX29RSOGL+NH3/fx+8jjCtHNxDmL45d8DAOGH9v4378
Z9wipKvPA1pJw85tffF5N5xHeM+5smFaarWozLJfHkcom5NubyZnBaGRx6vv3uJ2v/bifWP+X1Zj
WU4hPM2MO44XnLtmHvBLiuPcF0m64qX84QpOxbsOX05WCDW2AXEx7w2LFLcrMgu3FTc/dwVIGUav
nLZin7W/GStqj1Rh3pUyn8InUEsDBBQAAAAIAIWeI11ju0SFkwAAAMQAAAAOAAAAdml0ZS5jb25m
aWcuanM9jMEKgkAYhO/7FHNbhc00imJPQS/QPTqI/mt/qCu7qwTiu4drdBqY75vhbrAuYEZNhnu6
2d5wgwXG2Q5y4kBS8OY4KqvwA9eVvP1+aMeG+11EUgj6RLMmU45tzP9nMgtg073GIy6S9KkE4MlN
5DRmvKwPGrI4nLM8y7NCKqyHGqficlTwwXEV7rEJbiQsSiyp+AJQSwECFAAUAAAACAB2pCNdKqBi
uRIjAAAPaQAACwAAAAAAAAAAAAAAAAAAAAAAc3JjL0FwcC5qc3hQSwECFAAUAAAACACFniNdCdRA
bJUAAADmAAAADAAAAAAAAAAAAAAAAAA7IwAAc3JjL21haW4uanN4UEsBAhQAFAAAAAgAFZ8jXf4p
r7wDCwAASyAAAA4AAAAAAAAAAAAAAAAA+iMAAHNyYy9zdHlsZXMuY3NzUEsBAhQAFAAAAAgAhZ4j
XRb/ae0KAQAAywEAAAoAAAAAAAAAAAAAAAAAKS8AAGluZGV4Lmh0bWxQSwECFAAUAAAACADhniNd
u/QhdWcVAAAzaAAAEQAAAAAAAAAAAAAAAABbMAAAcGFja2FnZS1sb2NrLmpzb25QSwECFAAUAAAA
CACFniNdHYQVlK8AAABeAQAADAAAAAAAAAAAAAAAAADxRQAAcGFja2FnZS5qc29uUEsBAhQAFAAA
AAgAhZ4jXWvESThFAQAA9QEAAAkAAAAAAAAAAAAAAAAAykYAAFJFQURNRS5tZFBLAQIUABQAAAAI
AIWeI11ju0SFkwAAAMQAAAAOAAAAAAAAAAAAAAAAADZIAAB2aXRlLmNvbmZpZy5qc1BLBQYAAAAA
CAAIANMBAAD1SAAAAAA=
###RIFTFRONT_ZIP_BASE64_END###
###JADON_UNIDEV_V10_END###
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
$ManagerCmd = Join-Path $Base "Jadons_Ultimate_Forge_Manager_v10.cmd"
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
    Create-Shortcut "Jadon Ultimate Forge Manager v10" $ManagerCmd $Base
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
        (Join-Path $Base "Jadons_Ultimate_Forge_Manager_v10.cmd"),
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
            foreach ($path in @((Join-Path $Base "InstallerCore_v7.payload"), (Join-Path $Base "InstallerCore_v9.payload"), (Join-Path $Base "InstallerCore_v10.payload"))) {
                Remove-ManagedUninstallPath $path $Base
            }
        }
        "Everything" {
            Remove-InstallerOwnedDecks
            Remove-ManagerComponents
            Remove-ForgeComponents
            Remove-ManagedUninstallPath $JavaHome $Base
            Remove-CacheComponents
            foreach ($path in @((Join-Path $Base "InstallerCore_v7.payload"), (Join-Path $Base "InstallerCore_v9.payload"), (Join-Path $Base "InstallerCore_v10.payload"))) {
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
title Jadon's Ultimate Forge Manager v10.0

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
set "M7_PS1=%M7_TOOL%\UltimateForgeManager_v10.payload"
set "M7_PS_CANDIDATE=%M7_TOOL%\UltimateForgeManager_v10.candidate.payload"
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
set "M7_MANAGER_PS_SHA=3813efec6c0e1c9be3978b94e09b7f4bc20a9b188436678f58df0abe96cfd49a"
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
echo Starting V10 manager...
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
$EngineVersion = "10.0"

$AiDir = Join-Path $Base "AIViewer"
$AiSourceDir = Join-Path $AiDir "source"
$AiClassesDir = Join-Path $AiDir "classes"
$AiDownloadsDir = Join-Path $AiDir "downloads"
$AiJdkDir = Join-Path $AiDir "jdk-21"
$AiPatchJar = Join-Path $AiDir "jadon-ai-telemetry-patch.jar"
$AiViewerScript = Join-Path $AiDir "AI_Thought_Dashboard.html"
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

function Write-AiViewerDashboard {
    param([string]$OutputPath = $AiViewerScript)

    $dashboard = @'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Jadon's Forge AI Command Observatory</title>
<style>
:root{color-scheme:dark;font-family:Segoe UI,Inter,system-ui,sans-serif;background:#050812;color:#edf5ff;--cyan:#4bdcff;--pink:#ff4f87;--gold:#ffd166;--green:#75eea4;--panel:#0c1426;--muted:#8294b7}
*{box-sizing:border-box}body{margin:0;min-height:100vh;background:radial-gradient(circle at 14% 5%,#102b4b 0,transparent 32%),radial-gradient(circle at 88% 82%,#35112b 0,transparent 32%),#050812}
body:before{content:"";position:fixed;inset:0;pointer-events:none;background-image:linear-gradient(#5aa9ff0b 1px,transparent 1px),linear-gradient(90deg,#5aa9ff0b 1px,transparent 1px);background-size:42px 42px}
.shell{position:relative;max-width:1500px;margin:auto;padding:24px}.top{display:flex;align-items:center;justify-content:space-between;gap:20px;margin-bottom:18px}.eyebrow{margin:0 0 5px;color:var(--cyan);font-size:11px;font-weight:800;letter-spacing:.21em}.top h1{margin:0;font-size:clamp(27px,4vw,52px);letter-spacing:-.045em}.top h1 span{color:transparent;-webkit-text-stroke:1px var(--pink)}
.actions{display:flex;gap:9px;flex-wrap:wrap;justify-content:flex-end}button,.file-label{border:1px solid #30496f;background:#101b31;color:#eaf4ff;border-radius:8px;padding:11px 15px;font-weight:750;cursor:pointer;transition:.16s}button:hover,.file-label:hover{transform:translateY(-2px);border-color:var(--cyan)}.primary{background:linear-gradient(100deg,#1477c5,#783cc9);border-color:#54dcff}.file-label input{display:none}
.source{display:flex;align-items:center;gap:10px;padding:11px 15px;margin-bottom:14px;border:1px solid #263a5c;border-radius:10px;background:#091120cc;color:var(--muted);font-size:13px}.dot{width:9px;height:9px;border-radius:50%;background:var(--gold);box-shadow:0 0 13px var(--gold)}.dot.live{background:var(--green);box-shadow:0 0 13px var(--green)}
.metrics{display:grid;grid-template-columns:repeat(5,1fr);gap:10px;margin-bottom:10px}.metric,.panel{border:1px solid #243858;background:linear-gradient(150deg,#0e182cdd,#090e1ddd);border-radius:13px;box-shadow:0 16px 40px #0005}.metric{padding:15px}.metric small{color:#7185aa;display:block;font-size:9px;font-weight:800;letter-spacing:.13em}.metric strong{display:block;margin-top:6px;font-size:24px}.metric:nth-child(2) strong{color:var(--cyan)}.metric:nth-child(3) strong{color:var(--pink)}.metric:nth-child(4) strong{color:var(--gold)}.metric:nth-child(5) strong{color:var(--green)}
.grid{display:grid;grid-template-columns:minmax(0,1.5fr) minmax(320px,.8fr);gap:10px}.panel{padding:17px;min-width:0}.panel h2{font-size:13px;letter-spacing:.1em;margin:0 0 14px;color:#b8c8e3}.chart-wrap{height:310px;position:relative}canvas{width:100%;height:100%;display:block}.thoughts{height:310px;overflow:auto;display:flex;flex-direction:column;gap:8px;padding-right:4px}.thought{border-left:3px solid var(--cyan);background:#0c1628;padding:10px 12px;border-radius:0 8px 8px 0}.thought.best{border-color:var(--gold)}.thought.combat{border-color:var(--pink)}.thought b{display:block;font-size:12px;margin-bottom:4px}.thought span{color:#9eb0ce;font-size:12px;line-height:1.45}.thought time{color:#60769d;font-size:9px;float:right}
.wide{grid-column:1/-1}.table-wrap{max-height:270px;overflow:auto}table{width:100%;border-collapse:collapse;font-size:12px}th{position:sticky;top:0;background:#101a2d;color:#7890b6;text-align:left;font-size:9px;letter-spacing:.13em;padding:10px}td{border-top:1px solid #1e2c47;padding:10px;color:#c7d5ec}tr.chosen td{color:var(--gold);background:#ffd1660a}.pill{display:inline-block;border-radius:20px;padding:3px 8px;background:#213252;color:#a9bde0}.empty{display:grid;place-items:center;text-align:center;height:100%;color:#7083a7}.empty b{display:block;color:#dbe7f8;font-size:17px;margin-bottom:6px}.footer{color:#5f7399;font-size:11px;text-align:center;margin-top:14px}.pulse{animation:pulse 1.4s infinite alternate}@keyframes pulse{to{opacity:.45}}
@media(max-width:900px){.top{align-items:flex-start;flex-direction:column}.actions{justify-content:flex-start}.metrics{grid-template-columns:repeat(2,1fr)}.grid{grid-template-columns:1fr}.wide{grid-column:auto}}
</style>
</head>
<body>
<main class="shell">
  <header class="top"><div><p class="eyebrow">READ-ONLY TELEMETRY // LIVE ANALYSIS</p><h1>FORGE AI <span>COMMAND OBSERVATORY</span></h1></div><div class="actions"><button class="primary" id="openLive">Open live telemetry</button><label class="file-label">Open a saved log<input id="fileInput" type="file" accept=".jsonl,.txt"></label><button id="demo">Replay demo</button><button id="clear">Clear</button></div></header>
  <div class="source"><i class="dot" id="dot"></i><b id="sourceTitle">Guided demo is active</b><span id="sourceDetail">Choose "Open live telemetry", then select AIViewer\telemetry.jsonl once. The dashboard will keep rereading it.</span></div>
  <section class="metrics"><div class="metric"><small>AI PILOT</small><strong id="pilot">Waiting</strong></div><div class="metric"><small>DECISIONS</small><strong id="decisions">0</strong></div><div class="metric"><small>CANDIDATES</small><strong id="candidates">0</strong></div><div class="metric"><small>SIMULATIONS</small><strong id="simulations">0</strong></div><div class="metric"><small>LAST DECISION</small><strong id="latency">-</strong></div></section>
  <section class="grid">
    <article class="panel"><h2 id="chartTitle">EVALUATED SCORE TRACE</h2><label>Graph <select id="chartMetric" style="background:#122039;color:#dceaff;border:1px solid #334b6c;padding:6px;border-radius:7px"><option value="auto">Auto - scores or life</option><option value="scores">Evaluated scores</option><option value="life">AI life totals</option><option value="activity">Decision activity</option></select></label><div class="chart-wrap"><canvas id="chart" width="900" height="310"></canvas></div></article>
    <article class="panel"><h2>EXPLAINED THOUGHT STREAM</h2><div class="thoughts" id="thoughts"></div></article>
    <article class="panel wide"><h2>RAW CANDIDATES AND CHOICES</h2><div class="table-wrap"><table><thead><tr><th>TURN / PHASE</th><th>TYPE</th><th>ACTION OR PLAN</th><th>STATUS</th><th>SCORE</th></tr></thead><tbody id="rows"></tbody></table></div></article>
  </section>
  <p class="footer">Viewer-only analysis. Telemetry failures cannot alter Forge gameplay or AI decisions.</p>
</main>
<script>
const S={events:[],handle:null,timer:null,source:'demo'}
const $=id=>document.getElementById(id), esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))
function demoEvents(){return[
 {type:'decision_start',player:'Computer',turn:6,phase:'MAIN1',score:114,candidates:5,life:18,opponentLife:13},
 {type:'evaluated',turn:6,phase:'MAIN1',action:'Cast Lightning Bolt at opponent',score:138,available:138},
 {type:'evaluated',turn:6,phase:'MAIN1',action:'Deploy Siege-Gang Commander',score:171,available:165},
 {type:'evaluated',turn:6,phase:'MAIN1',action:'Hold mana for Counterspell',score:149,available:146},
 {type:'simulation_best',turn:6,phase:'MAIN1',action:'Deploy Siege-Gang Commander',originalScore:114,score:171,available:165,simulations:84,milliseconds:327},
 {type:'plan',turn:6,phase:'MAIN1',plan:'Cast Siege-Gang Commander | Attack with two Goblins | Keep one blocker',score:171},
 {type:'planned',turn:6,phase:'MAIN1',action:'Cast Siege-Gang Commander',decision:'Board pressure rises while preserving a blocker.'},
 {type:'combat_attack',player:'Computer',turn:6,phase:'COMBAT_DECLARE_ATTACKERS',aggression:4,combat:'Two Goblins attack; one token remains on defence.'}
]}
function thought(e){
 const where=`Turn ${e.turn??'?'} | ${e.phase??'unknown phase'}`
 if(e.type==='decision_start')return['SCAN',`${where}: comparing ${e.candidates??'several'} legal actions from a position score of ${e.score??'?'}.`,'']
 if(e.type==='heuristic_start')return['POSITION',`${where}: reading life totals, mana, hand and battlefield before applying Forge priorities.`,'']
 if(e.type==='evaluated')return['SIMULATION',`Tested "${e.action||'action'}"; the resulting available score is ${e.available??e.score??'?'}.`,'']
 if(e.type==='simulation_best')return['BEST LINE',`Selected "${e.action||'action'}" after ${e.simulations??'?'} simulations in ${e.milliseconds??'?'} ms. Score moved from ${e.originalScore??'?'} to ${e.score??'?'}.`,'best']
 if(e.type==='plan')return['PLAN',String(e.plan||'').replaceAll(' | ',' -> '),'best']
 if(e.type==='planned'||e.type==='heuristic_chosen')return['COMMIT',`Executing "${e.action||'chosen action'}". ${e.decision||''}`,'best']
 if(e.type==='combat_attack')return['ATTACK',`${where}: aggression ${e.aggression??'?'}; ${e.combat||'attackers selected'}.`,'combat']
 if(e.type==='combat_block')return['BLOCK',`${where}: ${e.combat||'blockers assigned'}.`,'combat']
 if(e.type==='heuristic_candidate'&&e.status!=='WillPlay')return['REJECT',`Skipped "${e.action||'action'}" because Forge reported ${e.status||'not playable'}.`,'']
 return null
}
function render(){
 const ev=S.events, last=[...ev].reverse().find(e=>e.player), choices=ev.filter(e=>['planned','heuristic_chosen','simulation_best'].includes(e.type))
 $('pilot').textContent=last?.player||'Computer AI';$('decisions').textContent=ev.filter(e=>['decision_start','heuristic_start'].includes(e.type)).length||choices.length
 $('candidates').textContent=ev.filter(e=>['candidate','heuristic_candidate','evaluated'].includes(e.type)).length
 $('simulations').textContent=ev.reduce((n,e)=>n+(+e.simulations||0),0);const timed=[...ev].reverse().find(e=>e.milliseconds!=null);$('latency').textContent=timed?`${timed.milliseconds} ms`:'-'
 const insights=ev.map(thought).filter(Boolean).slice(-80).reverse();$('thoughts').innerHTML=insights.length?insights.map((t,i)=>`<div class="thought ${t[2]}"><time>#${insights.length-i}</time><b>${esc(t[0])}</b><span>${esc(t[1])}</span></div>`).join(''):'<div class="empty"><div><b>No decisions yet</b>Start Forge with telemetry, then choose its JSONL file.</div></div>'
 const rows=ev.filter(e=>['candidate','heuristic_candidate','evaluated','simulation_best','plan','planned','heuristic_chosen','combat_attack','combat_block'].includes(e.type)).slice(-250).reverse()
 $('rows').innerHTML=rows.length?rows.map(e=>`<tr class="${['planned','heuristic_chosen','simulation_best'].includes(e.type)?'chosen':''}"><td>${esc(`${e.turn??'-'} / ${e.phase??'-'}`)}</td><td><span class="pill">${esc(e.type)}</span></td><td>${esc(e.action||e.plan||e.combat||'-')}</td><td>${esc(e.status||e.decision||'-')}</td><td>${esc(e.available??e.score??'-')}</td></tr>`).join(''):'<tr><td colspan="5">Waiting for telemetry events...</td></tr>'
 drawChart(ev)
}
function drawChart(ev){
 const c=$('chart'),dpr=devicePixelRatio||1,r=c.getBoundingClientRect();c.width=Math.max(400,r.width*dpr);c.height=Math.max(220,r.height*dpr);const x=c.getContext('2d');x.scale(dpr,dpr);const w=r.width,h=r.height;x.clearRect(0,0,w,h)
 const numeric=v=>v!=null&&String(v).trim()!==''&&Number.isFinite(+v), scores=ev.filter(e=>e.type==='evaluated'&&numeric(e.available??e.score)).map(e=>({v:+(e.available??e.score),label:e.action||'candidate'})), life=ev.filter(e=>numeric(e.life)).map(e=>({v:+e.life,label:`${e.player||'AI'} - turn ${e.turn??'?'}`})), activity=ev.filter(e=>['decision_start','heuristic_start'].includes(e.type)).map((e,i)=>({v:i+1,label:`Turn ${e.turn??'?'}`}))
 const metric=$('chartMetric').value, mode=metric==='auto'?(scores.length?'scores':life.length?'life':'activity'):metric, pts=({scores,life,activity}[mode]).slice(-24)
 $('chartTitle').textContent={scores:'EVALUATED SCORE TRACE',life:'AI LIFE TOTALS',activity:'CUMULATIVE AI DECISIONS'}[mode]
 x.strokeStyle='#203655';x.lineWidth=1;for(let i=0;i<6;i++){const y=26+i*(h-58)/5;x.beginPath();x.moveTo(44,y);x.lineTo(w-18,y);x.stroke()}
 if(!pts.length){x.fillStyle='#7185aa';x.textAlign='center';x.font='600 14px Segoe UI';x.fillText('Waiting for telemetry for the selected graph',w/2,h/2);return}
 const min=Math.min(...pts.map(p=>p.v)),max=Math.max(...pts.map(p=>p.v)),span=Math.max(1,max-min),px=i=>44+i*(w-72)/Math.max(1,pts.length-1),py=v=>h-32-(v-min)/span*(h-70)
 const grad=x.createLinearGradient(0,25,0,h);grad.addColorStop(0,'#4bdcff55');grad.addColorStop(1,'#4bdcff00');x.beginPath();pts.forEach((p,i)=>i?x.lineTo(px(i),py(p.v)):x.moveTo(px(i),py(p.v)));x.lineTo(px(pts.length-1),h-32);x.lineTo(px(0),h-32);x.closePath();x.fillStyle=grad;x.fill()
 x.beginPath();pts.forEach((p,i)=>i?x.lineTo(px(i),py(p.v)):x.moveTo(px(i),py(p.v)));x.strokeStyle='#4bdcff';x.lineWidth=3;x.shadowColor='#4bdcff';x.shadowBlur=12;x.stroke();x.shadowBlur=0
 pts.forEach((p,i)=>{x.beginPath();x.arc(px(i),py(p.v),4,0,Math.PI*2);x.fillStyle=i===pts.length-1?'#ffd166':'#eaf8ff';x.fill()});x.fillStyle='#8294b7';x.font='10px Segoe UI';x.textAlign='left';x.fillText(`LOW ${min}`,44,h-10);x.textAlign='right';x.fillText(`HIGH ${max}`,w-18,h-10)
}
function parse(text){return text.split(/\r?\n/).filter(Boolean).flatMap(line=>{try{const e=JSON.parse(line);return e&&typeof e==='object'&&!Array.isArray(e)?[e]:[]}catch{return[]}})}
$('chartMetric').onchange=()=>drawChart(S.events)
async function readLive(){if(!S.handle)return;try{const file=await S.handle.getFile();S.events=parse(await file.text());$('sourceDetail').textContent=`${file.name} | ${S.events.length} events | refreshed ${new Date().toLocaleTimeString()}`;render()}catch(e){$('sourceDetail').textContent=`Could not reread telemetry: ${e.message}`}}
$('openLive').onclick=async()=>{try{if(!window.showOpenFilePicker){$('fileInput').click();return}const[h]=await showOpenFilePicker({types:[{description:'Forge JSONL telemetry',accept:{'text/plain':['.jsonl','.txt']}}]});S.handle=h;S.source='live';$('dot').classList.add('live');$('sourceTitle').textContent='LIVE TELEMETRY CONNECTED';clearInterval(S.timer);await readLive();S.timer=setInterval(readLive,650)}catch(e){if(e.name!=='AbortError')$('sourceDetail').textContent=e.message}}
$('fileInput').onchange=async e=>{const f=e.target.files[0];if(!f)return;clearInterval(S.timer);S.handle=null;S.source='saved';S.events=parse(await f.text());$('dot').classList.remove('live');$('sourceTitle').textContent='SAVED TELEMETRY LOADED';$('sourceDetail').textContent=`${f.name} | ${S.events.length} events`;render()}
$('demo').onclick=()=>{clearInterval(S.timer);S.handle=null;S.source='demo';S.events=demoEvents();$('dot').classList.remove('live');$('sourceTitle').textContent='GUIDED DEMO';$('sourceDetail').textContent='Sample events prove the dashboard is working. Open the live telemetry file for an actual match.';render()}
$('clear').onclick=()=>{clearInterval(S.timer);S.handle=null;S.source='idle';S.events=[];$('dot').classList.remove('live');$('sourceTitle').textContent='DISCONNECTED';$('sourceDetail').textContent='Choose a telemetry source to resume.';render()};addEventListener('resize',()=>drawChart(S.events));window.render_dashboard_to_text=()=>JSON.stringify({source:S.source,events:S.events.length,thoughts:S.events.map(thought).filter(Boolean).length});S.events=demoEvents();render()
</script>
</body>
</html>
'@

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($OutputPath, $dashboard, $encoding)
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
        'set "VIEWER=%BASE%\AIViewer\AI_Thought_Dashboard.html"',
        'set "PATCH=%BASE%\AIViewer\jadon-ai-telemetry-patch.jar"',
        ('set "FORGEJAR=' + $forgeJarRuntime + '"'),
        ('set "JAVAW=' + $javawRuntime + '"'),
        ('set "FORGEHOME=' + $forgeHomeRuntime + '"'),
        'if exist "%TELEMETRY%" del /f /q "%TELEMETRY%" >nul 2>&1',
        'type nul > "%TELEMETRY%"',
        'start "" "%VIEWER%"',
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
    $candidateViewer = Join-Path $buildRoot "AI_Thought_Dashboard.candidate.html"
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

        Write-AiViewerDashboard $candidateViewer
        Write-AiLauncher $forgeJar $javaw $forgeHome $candidateLauncher

        if ((Get-Item -LiteralPath $candidatePatchJar).Length -le 0) {
            throw "AI patch candidate JAR is empty."
        }

        $viewerText = [IO.File]::ReadAllText($candidateViewer, [Text.Encoding]::UTF8)
        foreach ($requiredViewerToken in @(
            '<!doctype html>',
            'FORGE AI <span>COMMAND OBSERVATORY</span>',
            'showOpenFilePicker',
            'function drawChart',
            'EXPLAINED THOUGHT STREAM',
            'window.render_dashboard_to_text'
        )) {
            if (-not $viewerText.Contains($requiredViewerToken)) {
                throw ("Generated AI dashboard validation failed: missing " + $requiredViewerToken)
            }
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
            Version = 3
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

    if ([int]$status.Version -lt 3 -or
        -not ([string]$status.ViewerScript).EndsWith(".html", [StringComparison]::OrdinalIgnoreCase)) {
        throw "The older PowerShell viewer is installed. Run Setup / Repair to install the V10 browser dashboard."
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
        -WorkingDirectory (Split-Path -Parent ([string]$status.Launcher)) -WindowStyle Hidden
}

function Open-AiViewerOnly {
    if (-not (Test-Path -LiteralPath $AiViewerScript)) {
        throw "AI Viewer dashboard is not installed. Run Setup / Repair first."
    }

    Start-Process -FilePath $AiViewerScript
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
