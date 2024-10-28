@echo off
chcp 65001 >nul
:menu
cls
echo ===========================
echo      Mod Manager Menu
echo ===========================
echo.
echo 1. Créer un nouveau mod
echo 2. Convertir TGA/DDS
echo 3. Vérifier un mod
powershell -command "Write-Host '4. Tester le mod (BETA !!!)' -ForegroundColor Yellow"
echo 5. Quitter
echo.
set /p choice="Sélectionnez une option (1-5) : "

if "%choice%"=="1" goto creer_mod
if "%choice%"=="2" goto convertir_tga_dds
if "%choice%"=="3" goto verifier_mod
if "%choice%"=="4" goto test_mod
if "%choice%"=="5" goto quitter

:: Si l'utilisateur entre une option incorrecte
echo Option invalide, veuillez choisir entre 1 et 4.
pause
goto menu

:creer_mod
cls
call bat/create_mod.bat
goto menu

:convertir_tga_dds
cls
call bat/convert.bat
goto menu

:verifier_mod
cls
call bat/verif_mod.bat
goto menu

:test_mod
cls
call bat/test_mod.bat
goto menu

:quitter
cls
echo Merci d'avoir utilisé le Mod Manager.
pause
exit
