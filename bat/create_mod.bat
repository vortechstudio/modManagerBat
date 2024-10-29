@echo off
setlocal enabledelayedexpansion

:: Définir le chemin du fichier config.ini
set "config_file=%~dp0config.ini"

:: Vérifier si le fichier config.ini existe
if not exist "%config_file%" (
    echo ERREUR : Le fichier config.ini est introuvable. Veuillez le créer et définir le chemin de staging_area.
    pause
    exit /b
)

:: Lire la valeur de staging_area depuis config.ini
for /f "tokens=1,2 delims==" %%A in ('findstr /i "staging_area" "%config_file%"') do (
    if "%%A"=="staging_area" set "staging_path=%%B"
)

:: Supprimer les espaces en début et fin de la variable staging_path (optionnel)
set "staging_path=%staging_path:~1,-1%"

:: Vérifier si staging_path est défini
if not defined staging_path (
    echo ERREUR : Le chemin staging_area n'est pas défini dans config.ini.
    pause
    exit /b
)

:: Définition des chemins pour le dossier config et logs
set "config_dir=%~dp0config"
set "log_dir=%~dp0logs"

:: Création du dossier de logs s'il n'existe pas
if not exist "%log_dir%" mkdir "%log_dir%"

:: Création du fichier de log avec le format log_dd_mm_yyyy_hh_ii.log
for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value') do set datetime=%%i
set "log_file=%log_dir%\log_%datetime:~6,2%_%datetime:~4,2%_%datetime:~0,4%_%datetime:~8,2%_%datetime:~10,2%.log"

:: Initialisation du log
echo Démarrage du script create_mod.bat > "%log_file%"
echo Date et heure de début : %date% %time% >> "%log_file%"
echo dir_config: "%config_dir%" >> "%log_file%"

:: Log du chemin staging_area trouvé
echo 'staging_area' trouvé dans : %staging_path% >> "%log_file%"

:: Demande à l'utilisateur le nom du mod
set /p "mod_name=Entrez le nom du mod (les espaces seront remplacés par des underscores) : "

:: Remplacement des espaces par des underscores et ajout du suffixe _1
set "mod_name=%mod_name: =_%_1"

:: Utiliser PowerShell pour convertir le nom en minuscules
for /f %%A in ('powershell -command "'%mod_name%'.ToLower()"') do set "mod_name=%%A"

:: Définir le dossier final du mod dans staging_area sélectionné
set "mod_dir=%staging_path%\%mod_name%"

echo Nom du mod : %mod_name% >> "%log_file%"
echo Emplacement du mod : %mod_dir% >> "%log_file%"

if not exist "%mod_dir%" (
    mkdir "%mod_dir%"
)


:: Définir l'arborescence de base comme un tableau
set folders[0]=res\
set folders[1]=res\audio\effects
set folders[2]=res\config\multiple_unit
set folders[3]=res\config\sound_set
set folders[4]=res\config\ui
set folders[5]=res\construction
set folders[6]=res\construction\asset
set folders[7]=res\models\animations
set folders[8]=res\models\materials
set folders[9]=res\models\mesh
set folders[10]=res\models\model
set folders[11]=res\scripts
set folders[12]=res\textures
set folders[13]=res\textures\models
set folders[14]=res\textures\ui
set folders[15]=res\textures\ui\construction\asset
set folders[16]=res\textures\ui\construction\categories

:: Définir la taille du tableau
set "folders_count=17"

:: Création de l'arborescence de base en parcourant le tableau

echo Démarrage de la création de l'arborescence pour le mod : %mod_name% >> "%log_file%"

set "index=0"
:loop
if %index% geq %folders_count% goto :after_loop
set "folder=!folders[%index%]!"
if not exist "%mod_dir%\!folder!" (
    mkdir "%mod_dir%\!folder!"
    echo "Dossier créé : !folder!" >> "%log_file%"
)
set /a index+=1
goto :loop

:after_loop
:: Débogage : Afficher les chemins avant la copie
echo Chemin du fichier mod.lua : %config_dir%\mod.lua >> "%log_file%"
echo Chemin de destination : %mod_dir%\mod.lua >> "%log_file%"

copy "%config_dir%\mod.lua" "%mod_dir%\mod.lua" /Y
echo Fichier mod.lua copié depuis le dossier config vers %mod_dir% >> "%log_file%"
copy "%config_dir%\string.lua" "%mod_dir%\string.lua" /Y
echo Fichier string.lua copié depuis le dossier config vers %mod_dir% >> "%log_file%"
copy "%config_dir%\image_00.tga" "%mod_dir%\image_00.tga" /Y
echo Fichier image_00.tga copié depuis le dossier config vers %mod_dir% >> "%log_file%"

:: Finalisation du log
echo Script terminé avec succès >> "%log_file%"
echo Date et heure de fin : %date% %time% >> "%log_file%"

:: Message de fin pour l'utilisateur
echo.
echo ==============================
echo Le script est terminé avec succès !
echo Votre mod est prêt dans le dossier : %mod_dir%
echo ==============================
echo.

:: Retour au menu principal avec start.bat
pause
call "%~dp0start.bat"
endlocal
exit /b 0
