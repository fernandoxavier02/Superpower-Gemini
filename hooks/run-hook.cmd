@echo off
REM Cross-platform launcher for hook scripts.
REM Usage: run-hook.cmd <script-name> [args...]

setlocal

if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)

set "HOOK_SCRIPT=%~1"
shift
set "HOOK_DIR=%~dp0"
set "SCRIPT_PATH=%HOOK_DIR%%HOOK_SCRIPT%"

if not exist "%SCRIPT_PATH%" (
    echo run-hook.cmd: script not found: "%SCRIPT_PATH%" >&2
    exit /b 1
)

set "BASH_EXE="

REM Try Git for Windows bash in standard locations
if exist "C:\Program Files\Git\bin\bash.exe" (
    set "BASH_EXE=C:\Program Files\Git\bin\bash.exe"
)
if "%BASH_EXE%"=="" if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    set "BASH_EXE=C:\Program Files (x86)\Git\bin\bash.exe"
)

REM Try bash on PATH (e.g. user-installed Git Bash, MSYS2, Cygwin)
if "%BASH_EXE%"=="" (
    where bash >nul 2>nul && set "BASH_EXE=bash"
)

REM No bash found - exit silently rather than error
if "%BASH_EXE%"=="" (
    exit /b 0
)

if defined BASH_EXE (
    "%BASH_EXE%" "%SCRIPT_PATH%" %*
)
exit /b %ERRORLEVEL%
