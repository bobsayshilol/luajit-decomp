@setlocal enableextensions enabledelayedexpansion
@echo off
echo Starting...
for %%i in (*.lua) do (
set nam=%%i
echo Converting %%i
luajit -blg "%%i" "!nam:~0,-4!.asm"
)
echo Done
pause