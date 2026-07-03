@echo off
setlocal
cd /d "%~dp0"
for %%D in (db incremental_db output_files simulation) do (
  if exist "%%D" rmdir /s /q "%%D"
)
del /q *.rpt *.summary *.done *.jdi *.qws *.smsg *.pin *.qdf 2>nul
echo Quartus build files cleaned.
