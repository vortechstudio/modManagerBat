@echo off
echo ===========================
echo       Vérification d'un Mod
echo ===========================
:: Demander au moddeur de spécifier le chemin du mod à vérifier
set /p modpath="Entrez le chemin complet du dossier du mod à vérifier : "

:: Vérifier si le chemin existe
if not exist "%modpath%" (
    echo Le dossier spécifié n'existe pas. Veuillez vérifier le chemin et réessayer.
    pause
    exit /b
)

:: Exécuter le programme modvalidator.exe avec le chemin du mod
echo Exécution de la vérification avec modvalidator.exe...
bin\modvalidator.exe "%modpath%" --nopause

:: Vérification terminée
echo Vérification terminée pour le mod dans %modpath%.
pause