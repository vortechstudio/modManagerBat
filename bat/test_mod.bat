@echo off
set /p mod_path="Entrez le chemin du mod:"
set "game_path=D:\SteamLibrary\steamapps\common\Transport Fever 2"
set "log_file=%mod_path%/test_log.txt"

:: Lancer Transport Fever 2
echo Lancement de Transport Fever 2 avec le mod en cours... >> "%log_file%"
start "" "%game_path%\TransportFever2.exe" -debug -enable_mods "%mod_path%"
timeout /t 30  :: Attendre 30 secondes pour que le jeu charge le mod

:: Vérifier si le processus existe encore
tasklist | find /i "TransportFever2.exe" >nul
if errorlevel 1 (
    echo "ERREUR : Le jeu a crashé pendant le chargement du mod." >> "%log_file%"
) else (
    echo "Mod chargé avec succès." >> "%log_file%"
)