@echo off
setlocal
cd /d "%~dp0"

set "QBIN=D:\altera_web\13.0sp1\quartus\bin64"
if exist "%QBIN%\quartus_sh.exe" (
  set "PATH=%QBIN%;%PATH%"
)

quartus_sh --flow compile fpga_qpsk_baseband_visual_system
set "RC=%ERRORLEVEL%"
echo compile_exit=%RC%
exit /b %RC%
