@setlocal enableextensions enabledelayedexpansion
@echo off
echo Starting...
for %%i in (*.lua) do (
set nam=%%i
echo Converting %%i
luajit -bg "%%i" "!nam:~0,-4!.o"
)
echo Done
pause