@echo off
setlocal
cd /d "%~dp0\.."

set "PKG_DIR=release\fpga_qpsk_baseband_visual_system_release"
set "ZIP_FILE=release\fpga_qpsk_baseband_visual_system_release.zip"

if exist "%PKG_DIR%" rmdir /s /q "%PKG_DIR%"
if exist "%ZIP_FILE%" del /q "%ZIP_FILE%"
mkdir "%PKG_DIR%"

for %%D in (rtl tb sim quartus host_app docs tools) do (
  xcopy /e /i /y "%%D" "%PKG_DIR%\%%D" >nul
)
copy /y README.md "%PKG_DIR%\" >nul
copy /y .gitignore "%PKG_DIR%\" >nul
copy /y .gitattributes "%PKG_DIR%\" >nul

for %%D in (
  "%PKG_DIR%\quartus\db"
  "%PKG_DIR%\quartus\incremental_db"
  "%PKG_DIR%\quartus\output_files"
  "%PKG_DIR%\quartus\simulation"
  "%PKG_DIR%\sim\work"
) do (
  if exist %%D rmdir /s /q %%D
)
del /q "%PKG_DIR%\sim\transcript" "%PKG_DIR%\sim\qpsk_samples.csv" 2>nul
if exist "quartus\output_files\fpga_qpsk_baseband_visual_system.sof" (
  mkdir "%PKG_DIR%\quartus\output_files"
  copy /y "quartus\output_files\fpga_qpsk_baseband_visual_system.sof" "%PKG_DIR%\quartus\output_files\" >nul
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '%PKG_DIR%\*' -DestinationPath '%ZIP_FILE%' -Force"
echo Release package created:
echo %CD%\%ZIP_FILE%
