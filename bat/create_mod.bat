@echo off
setlocal enabledelayedexpansion

:: Variable pour stocker le chemin de staging_area
set "staging_path="
set "count=0"

:: Lister tous les lecteurs disponibles et rechercher staging_area
echo Recherche des dossiers 'staging_area' sur les lecteurs...
for /f "tokens=2 delims=:" %%D in ('wmic logicaldisk where "drivetype=3" get deviceid ^| find ":"') do (
    set "drive=%%D:"
    for /d /r "%drive%\" %%G in (staging_area) do (
        if exist "%%G" (
            :: Vérifier que ce chemin n’a pas déjà été ajouté
            set "duplicate=0"
            for /L %%I in (1,1,%count%) do (
                if "%%G"=="!staging_path[%%I]!" set "duplicate=1"
            )
            if "!duplicate!"=="0" (
                set /a count+=1
                set "staging_path[!count!]=%%G"
                echo 'staging_area' trouvé dans : %%G
            )
        )
    )
)

:: Si aucun dossier n'est trouvé, afficher un message d'erreur
if "%count%"=="0" (
    echo ERREUR : Aucun dossier 'staging_area' trouvé sur les lecteurs disponibles.
    pause
    exit /b
)

:: Si un seul dossier est trouvé, utiliser ce chemin automatiquement
if "%count%"=="1" (
    set "staging_path=!staging_path[1]!"
    echo Utilisation du seul dossier 'staging_area' trouvé : %staging_path%
) else (
    :: Si plusieurs dossiers sont trouvés, proposer un choix à l'utilisateur
    echo Plusieurs dossiers 'staging_area' trouvés :
    for /L %%I in (1,1,%count%) do (
        echo   %%I. !staging_path[%%I]!
    )
    
    :: Demander à l'utilisateur de choisir un dossier
    set /p "choice=Entrez le numéro du dossier 'staging_area' à utiliser : "
    set "staging_path=!staging_path[%choice%]!"
)

:: Vérifier que staging_path est défini
if "%staging_path%"=="" (
    echo ERREUR : Sélection invalide. Veuillez relancer le script et entrer un numéro correct.
    pause
    exit /b
)



:: Demande à l'utilisateur le nom du mod
set /p "mod_name=Entrez le nom du mod (les espaces seront remplacés par des underscores) : "

:: Remplacement des espaces par des underscores et ajout du suffixe _1
set "mod_name=%mod_name: =_%_1"

:: Utiliser PowerShell pour convertir le nom en minuscules
for /f %%A in ('powershell -command "'%mod_name%'.ToLower()"') do set "mod_name=%%A"

:: Demande à l'utilisateur l'emplacement du dossier du mod
set "mod_dir=%staging_path%\%mod_name%"

:: Confirmation de l'emplacement
echo L'emplacement de votre mod sera : %mod_dir%
echo.
pause

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
echo Nom du mod : %mod_name% >> "%log_file%"
echo Emplacement du mod : %mod_dir% >> "%log_file%"
echo. >> "%log_file%"

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

:: Création de l'arborescence de base en parcourant le tableau
if not exist "%mod_dir%" (
    mkdir "%mod_dir%"
)
echo Démarrage de la création de l'arborescence pour le mod : %mod_name% > "%log_file%"

set "index=0"
:loop
if defined folders[%index%] (
    set "folder=!folders[%index%]!"
    if not exist "%mod_dir%\!folder!" (
        mkdir "%mod_dir%\!folder!"
        echo "Dossier créé : !folder!" >> "%log_file%"
    )
    set /a index+=1
    goto :loop
)

:: Copie des fichiers de configuration depuis le dossier "config"
if exist "%config_dir%\mod.lua" (
    copy "%config_dir%\mod.lua" "%mod_dir%\mod.lua" /Y
    echo Fichier mod.lua copié depuis le dossier config vers %mod_dir% >> "%log_file%"
) else (
    echo ERREUR : Le fichier mod.lua est introuvable dans %config_dir% >> "%log_file%"
)

if exist "%config_dir%\string.lua" (
    copy "%config_dir%\string.lua" "%mod_dir%\string.lua" /Y
    echo Fichier string.lua copié depuis le dossier config vers %mod_dir% >> "%log_file%"
) else (
    echo ERREUR : Le fichier string.lua est introuvable dans %config_dir% >> "%log_file%"
)

if exist "%config_dir%\image_00.tga" (
    copy "%config_dir%\image_00.tga" "%mod_dir%\image_00.tga" /Y
    echo Fichier image_00.tga copié depuis le dossier config vers %mod_dir% >> "%log_file%"
) else (
    echo ERREUR : Le fichier image_00.tga est introuvable dans %config_dir% >> "%log_file%"
)

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
