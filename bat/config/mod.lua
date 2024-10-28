function data()

    return {
        info = {
            minorVersion = 1, -- Version mineure
            severityAdd = "NONE", -- Définit l'importance des messages dans le gestionnaire de mods (NONE, WARNING, CRITICAL)
            severityRemove = "CRITICAL", -- Ce qui se passe quand on retire le mod
            name = _("NAME_MOD"), -- Nom du mod, défini dans le fichier strings.lua pour la localisation
            description = _("DESC_MOD"), -- Description également dans le fichier strings.lua
            authors = {
                {
                    name = "Auteur", -- Ton pseudo ou ton nom
                    role = "CREATOR", -- Ton rôle (CREATOR, ARTIST, PROGRAMMER, etc.)
                },
            },
            tags = { "" }, -- Des tags pour catégoriser ton mod
            visible = true,
        },
    }
end
