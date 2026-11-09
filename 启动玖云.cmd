@echo off
chcp 65001 >nul
title 玖云输入法
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo 请先安装 Node.js 20 或更新版本。
  pause
  exit /b 1
)
echo 请打开 http://127.0.0.1:4317
echo 关闭此窗口可以停止本地服务。
node scripts/serve.mjs
pause
