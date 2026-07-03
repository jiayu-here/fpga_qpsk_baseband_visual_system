@echo off
setlocal
cd /d "%~dp0"
if exist work rmdir /s /q work
del /q transcript qpsk_samples.csv 2>nul
echo ModelSim files cleaned.
