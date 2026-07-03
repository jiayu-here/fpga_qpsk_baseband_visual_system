@echo off
setlocal
cd /d "%~dp0"

set "QBIN=D:\altera_web\13.0sp1\quartus\bin64"
if exist "%QBIN%\quartus_map.exe" (
  set "PATH=%QBIN%;%PATH%"
)

quartus_map fpga_qpsk_baseband_visual_system --read_settings_files=on --write_settings_files=off
exit /b %ERRORLEVEL%
