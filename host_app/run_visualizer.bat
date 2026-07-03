@echo off
setlocal
cd /d "%~dp0"
python qpsk_visualizer.py
exit /b %ERRORLEVEL%
