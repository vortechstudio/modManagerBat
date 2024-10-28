@echo off
:: Demander à l'utilisateur de choisir la direction de conversion
set /p direction="Choisissez la direction de conversion (1 pour TGA -> DDS, 2 pour DDS -> TGA) : "

:: Vérifier si l'utilisateur a choisi une option valide
if not "%direction%"=="1" if not "%direction%"=="2" (
    echo Option invalide. Veuillez choisir 1 ou 2.
    pause
    exit /b
)

:: Demander à l'utilisateur de saisir le chemin du dossier contenant les fichiers à convertir
set /p folder="Entrez le chemin complet du dossier contenant les fichiers (dossiers inclus) : "

:: Vérifier si le dossier existe
if not exist "%folder%" (
    echo Le dossier "%folder%" n'existe pas. Veuillez vérifier le chemin et réessayer.
    pause
    exit /b
)

:: Si la conversion TGA -> DDS est choisie
if "%direction%"=="1" (
    echo Conversion TGA vers DDS en cours...
    for /r "%folder%" %%f in (*.tga) do (
        echo Conversion de "%%f" en DDS...
        
        :: Détection du mot "Normal" dans le nom du fichier pour appliquer une compression spécifique
        echo %%~nxf | find /i "Normal" >nul
        if %errorlevel%==0 (
            :: Utiliser la compression BC5 pour les normal maps
            magick "%%f" -flip -define dds:compression=bc5 "%%~dpnf.dds"
        ) else (
            :: Vérifier si le TGA contient de la transparence pour choisir le format de compression
            magick identify -format "%%[channels]" "%%f" | find "alpha" >nul
            if %errorlevel%==0 (
                :: Utiliser la compression DXT5 si alpha est présent (transparence)
                magick "%%f" -flip -define dds:compression=dxt5 "%%~dpnf.dds"
            ) else (
                :: Utiliser la compression DXT1 si pas de transparence
                magick "%%f" -flip -define dds:compression=dxt1 "%%~dpnf.dds"
            )
        )

        :: Ajouter un mipmap à 13 niveaux
        magick "%%~dpnf.dds" -define dds:mipmaps=13 "%%~dpnf.dds"

        :: Supprimer le fichier TGA après conversion
        del "%%f"
        echo "Fichier TGA supprimé : %%f"
    )
) else (
    :: Si la conversion DDS -> TGA est choisie
    echo Conversion DDS vers TGA en cours...
    for /r "%folder%" %%f in (*.dds) do (
        echo Conversion de "%%f" en TGA...
        magick "%%f" -flip "%%~dpnf.tga"
        
        :: Supprimer le fichier DDS après conversion
        del "%%f"
        echo "Fichier DDS supprimé : %%f"
    )
)

echo Conversion terminée.
pause