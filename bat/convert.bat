@echo off
setlocal enabledelayedexpansion

:: Définir le fichier de log
set "log_file=conversion_log_%date:/=_%_%time::=%.log"
echo Démarrage du script de conversion > "%log_file%"
echo Date et heure de début : %date% %time% >> "%log_file%"
echo. >> "%log_file%"

:: Vérifier si ImageMagick est installé
magick -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR : ImageMagick n'est pas installé ou n'est pas dans le PATH.
    echo ERREUR : ImageMagick n'est pas installé ou n'est pas dans le PATH. >> "%log_file%"
    pause
    exit /b
)

:: Demander à l'utilisateur de choisir la direction de conversion
set /p direction="Choisissez la direction de conversion (1 pour TGA -> DDS, 2 pour DDS -> TGA) : "

:: Vérifier si l'utilisateur a choisi une option valide
if not "%direction%"=="1" if not "%direction%"=="2" (
    echo Option invalide. Veuillez choisir 1 ou 2.
    echo Option invalide : %direction% >> "%log_file%"
    pause
    exit /b
)

:: Demander à l'utilisateur de saisir le chemin du dossier contenant les fichiers à convertir
set /p folder="Entrez le chemin complet du dossier contenant les fichiers (dossiers inclus) : "

:: Vérifier si le dossier existe
if not exist "%folder%" (
    echo Le dossier "%folder%" n'existe pas. Veuillez vérifier le chemin et réessayer.
    echo ERREUR : Dossier introuvable : %folder% >> "%log_file%"
    pause
    exit /b
)

:: Demander si l'utilisateur souhaite conserver les fichiers originaux
set /p keep_files="Voulez-vous conserver les fichiers originaux après conversion ? (o/n) : "
if /i "%keep_files%"=="o" (
    set "delete_originals=0"
) else (
    set "delete_originals=1"
)

:: Début de la conversion
if "%direction%"=="1" (
    echo Conversion TGA vers DDS en cours...
    echo Conversion TGA vers DDS en cours... >> "%log_file%"
    set /a count=0
    for /r "%folder%" %%f in (*.tga) do (
        set /a count+=1
        echo Conversion de "%%f" en DDS... (%count%)
        
        :: Détection du mot "Normal" dans le nom du fichier pour compression spécifique
        echo %%~nxf | find /i "Normal" >nul
        if !errorlevel! == 0 (
            magick "%%f" -flip -define dds:compression=bc5 "%%~dpnf.dds"
            echo "Normal map détectée : compression BC5 appliquée" >> "%log_file%"
        ) else (
            :: Vérifier si le TGA contient de la transparence pour choisir le format de compression
            magick identify -format "%%[channels]" "%%f" | find "alpha" >nul
            if !errorlevel! == 0 (
                magick "%%f" -flip -define dds:compression=dxt5 "%%~dpnf.dds"
                echo "Compression DXT5 avec transparence appliquée pour %%f" >> "%log_file%"
            ) else (
                magick "%%f" -flip -define dds:compression=dxt1 "%%~dpnf.dds"
                echo "Compression DXT1 sans transparence appliquée pour %%f" >> "%log_file%"
            )
        )

        :: Ajouter un mipmap à 13 niveaux
        magick "%%~dpnf.dds" -define dds:mipmaps=13 "%%~dpnf.dds"
        echo "Mipmap de 13 niveaux ajouté pour %%f" >> "%log_file%"

        :: Supprimer le fichier TGA après conversion si option choisie
        if %delete_originals%==1 (
            del "%%f"
            echo "Fichier TGA supprimé : %%f" >> "%log_file%"
        ) else (
            echo "Fichier TGA conservé : %%f" >> "%log_file%"
        )
    )
) else (
    echo Conversion DDS vers TGA en cours...
    echo Conversion DDS vers TGA en cours... >> "%log_file%"
    set /a count=0
    for /r "%folder%" %%f in (*.dds) do (
        set /a count+=1
        echo Conversion de "%%f" en TGA... (%count%)
        magick "%%f" -flip "%%~dpnf.tga"
        echo "Fichier converti en TGA : %%f" >> "%log_file%"

        :: Supprimer le fichier DDS après conversion si option choisie
        if %delete_originals%==1 (
            del "%%f"
            echo "Fichier DDS supprimé : %%f" >> "%log_file%"
        ) else (
            echo "Fichier DDS conservé : %%f" >> "%log_file%"
        )
    )
)

echo Conversion terminée. Voir le log pour les détails : %log_file%
echo Date et heure de fin : %date% %time% >> "%log_file%"
pause
exit /b
