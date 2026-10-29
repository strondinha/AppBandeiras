@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Flag Game - Atlas
where flutter >nul 2>&1
if errorlevel 1 (
    echo O Flutter nao foi encontrado no PATH.
    echo Confira a instalacao e abra novamente este arquivo.
    pause
    exit /b 1
)
if not exist pubspec.yaml (
    echo Extraia o ZIP inteiro antes de iniciar.
    pause
    exit /b 1
)
call flutter pub get
if errorlevel 1 (
    echo Nao foi possivel instalar as dependencias. Confira a conexao e a versao do Flutter.
    pause
    exit /b 1
)
call flutter run -d chrome
pause
