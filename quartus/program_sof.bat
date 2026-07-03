@echo off
setlocal
cd /d "%~dp0"

set "QBIN=D:\altera_web\13.0sp1\quartus\bin64"
if exist "%QBIN%\quartus_pgm.exe" (
  set "PATH=%QBIN%;%PATH%"
)

if not exist "output_files\fpga_qpsk_baseband_visual_system.sof" (
  echo SOF file not found. Run run_compile_web.bat first.
  exit /b 1
)

quartus_pgm -m JTAG -o "p;output_files\fpga_qpsk_baseband_visual_system.sof"
exit /b %ERRORLEVEL%
