@echo off
setlocal
cd /d "%~dp0"

set "MSIM=D:\altera_web\13.0sp1\modelsim_ase\win32aloem"
if exist "%MSIM%\vsim.exe" (
  set "PATH=%MSIM%;%PATH%"
)

vsim -c -do run_msim.do
exit /b %ERRORLEVEL%
