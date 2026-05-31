-- lang.lua
_G.LANG = {
    current = "es", -- Idioma por defecto al iniciar por primera vez

    es = {
        -- Pestañas del menú
        tab_coords = "Coords +",
        tab_colors = "Color del HUD",
        tab_style  = "Estilo Del Menú",
        tab_lang   = "Idiomas",

        -- Items de Configuración
        xyz_name = "Visualizar XYZ",
        xyz_desc = "Muestra u oculta tu posición exacta en tiempo real.",
        spd_name = "Visualizar Velocidad",
        spd_desc = "Muestra u oculta los vectores de movimiento actuales.",
        anim_name = "Efectos Visuales (HUD)",
        anim_desc = "Activa animaciones fluidas de entrada y salida para el HUD.",

        -- Opciones de colores
        h_yel_name = "Amarillo Eléctrico", h_yel_desc = "Tono amarillo brillante y clásico al texto.",
        h_red_name = "Rojo Carmesí",      h_red_desc = "Cambia el texto a un tono rojo intenso y agresivo.",
        h_grn_name = "Verde Esmeralda",   h_grn_desc = "Color verde vibrante estilo retro.",
        h_blu_name = "Azul Zafiro",       h_blu_desc = "Color azul claro y limpio para la interfaz.",
        h_wht_name = "Blanco Puro",       h_wht_desc = "Color blanco minimalista y nítido para máxima lectura.",

        m_cyn_name = "Cyan Neón",         m_cyn_desc = "Bordes y efectos a un tono cyan cibernético.",
        m_red_name = "Rojo Fuego",        m_red_desc = "Estética del menú con detalles en rojo vivo.",
        m_grn_name = "Verde Matrix",      m_grn_desc = "Estilo verde digital y limpio a los bordes.",
        m_pur_name = "Morado Premium",    m_pur_desc = "Aspecto exclusivo y elegante en tono violeta.",
        m_gld_name = "Dorado Midas",      m_gld_desc = "Acabado dorado digno de una edición premium.",

        -- Opciones de Idioma
        lang_es_name = "Español",         lang_es_desc = "Cambia el texto del menú e interfaz al Español.",
        lang_en_name = "Inglés (English)",lang_en_desc = "Cambia el texto del menú e interfaz al Inglés.",
        lang_fr_name = "Francés (Français)",lang_fr_desc = "Cambia el texto del menú e interfaz al Francés.",

        -- Sistema y UI
        status_on  = "On",
        status_off = "Off",
        loading    = "Cargando",
        footer     = "D-PAD: Navegar  |  A: Elegir  |  B: Cerrar",
        
        -- Notificaciones y Errores
        err_cmd = "\\#ff3333\\Error: Comando incorrecto.",
        err_s = "\\#ff3333\\Error: Usa /s on, /s off o solo /s",
        err_c = "\\#ff3333\\Error: Usa /c on, /c off o solo /c",
        err_a = "\\#ff3333\\Error: Usa /a on, /a off o solo /a",
        err_rgb = "\\#ff3333\\Error: /cc necesita 3 números (Ej: /cc 255 255 30)",
        on_c = "Coords: \\#00ff00\\ON",
        off_c = "Coords: \\#ff0000\\OFF",
        on_s = "Speed: \\#00ff00\\ON",
        off_s = "Speed: \\#ff0000\\OFF",
        on_a = "Animaciones: \\#00ff00\\ON",
        off_a = "Animaciones: \\#ff0000\\OFF",
        notify_hud = "Color HUD: ",
        notify_menu = "Color Menú: ",
        notify_lang = "Idioma cambiado a: Español"
    },

    en = {
        -- Menu Tabs
        tab_coords = "Coords +",
        tab_colors = "HUD Color",
        tab_style  = "Menu Style",
        tab_lang   = "Language",

        -- Configuration Items
        xyz_name = "Show XYZ",
        xyz_desc = "Show or hide your exact position in real time.",
        spd_name = "Show Speed",
        spd_desc = "Show or hide current movement vectors.",
        anim_name = "Visual Effects (HUD)",
        anim_desc = "Toggle smooth entry and exit animations for the HUD.",

        -- Color options
        h_yel_name = "Electric Yellow",   h_yel_desc = "Bright and classic yellow tone for text.",
        h_red_name = "Crimson Red",       h_red_desc = "Changes text to an intense, aggressive red.",
        h_grn_name = "Emerald Green",     h_grn_desc = "Vibrant retro-style green color.",
        h_blu_name = "Sapphire Blue",     h_blu_desc = "Clean, light blue color for the interface.",
        h_wht_name = "Pure White",        h_wht_desc = "Crisp, minimalist white for maximum readability.",

        m_cyn_name = "Neon Cyan",         m_cyn_desc = "Cybernetic cyan borders and effects.",
        m_red_name = "Fire Red",          m_red_desc = "Menu aesthetics with vivid red details.",
        m_grn_name = "Matrix Green",      m_grn_desc = "Clean digital green style for borders.",
        m_pur_name = "Premium Purple",    m_pur_desc = "Exclusive and elegant violet look.",
        m_gld_name = "Midas Gold",        m_gld_desc = "Golden finish worthy of a premium edition.",

        -- Language Options
        lang_es_name = "Spanish (Español)",lang_es_desc = "Change the menu and interface text to Spanish.",
        lang_en_name = "English",         lang_en_desc = "Change the menu and interface text to English.",
        lang_fr_name = "French (Français)",lang_fr_desc = "Change the menu and interface text to French.",

        -- System & UI
        status_on  = "On",
        status_off = "Off",
        loading    = "Loading",
        footer     = "D-PAD: Navigate  |  A: Select  |  B: Close",
        
        
        -- Notifications & Errors
        err_cmd = "\\#ff3333\\Error: Incorrect command.",
        err_s = "\\#ff3333\\Error: Use /s on, /s off or just /s",
        err_c = "\\#ff3333\\Error: Use /c on, /c off or just /c",
        err_a = "\\#ff3333\\Error: Use /a on, /a off or just /a",
        err_rgb = "\\#ff3333\\Error: /cc requires 3 numbers (Ex: /cc 255 255 30)",
        on_c = "Coords: \\#00ff00\\ON",
        off_c = "Coords: \\#ff0000\\OFF",
        on_s = "Speed: \\#00ff00\\ON",
        off_s = "Speed: \\#ff0000\\OFF",
        on_a = "Animations: \\#00ff00\\ON",
        off_a = "Animations: \\#ff0000\\OFF",
        notify_hud = "HUD Color: ",
        notify_menu = "Menu Color: ",
        notify_lang = "Language changed to: English"
    },
    
    fr = {
        tab_coords  = "Coords +",
        tab_colors  = "Couleur HUD",
        tab_style   = "Style du Menu",
        tab_lang    = "Langue",

        xyz_name    = "Voir XYZ",
        xyz_desc    = "Affiche ou cache votre position exacte en temps réel.",
        spd_name    = "Voir Vitesse",
        spd_desc    = "Affiche la vitesse de Mario sur les axes X, Y et Z.",
        anim_name   = "Animations",
        anim_desc   = "Active ou désactive les effets de transition du menu.",

        h_yel_name  = "Jaune Premium",
        h_yel_desc  = "Change la couleur du HUD en jaune classique.",
        h_red_name  = "Rouge Écarlate",
        h_red_desc  = "Change la couleur du HUD en rouge vif.",
        h_grn_name  = "Vert Émeraude",
        h_grn_desc  = "Change la couleur du HUD en vert néon.",
        h_blu_name  = "Bleu Cobalt",
        h_blu_desc  = "Change la couleur du HUD en bleu ciel.",
        h_wht_name  = "Blanc Pur",
        h_wht_desc  = "Change la couleur du HUD en blanc minimaliste.",

        m_cyn_name  = "Cyan Matrice",
        m_cyn_desc  = "Change le thème du menu en cyan technologique.",
        m_red_name  = "Rouge Alerte",
        m_red_desc  = "Change le thème du menu en rouge dynamique.",
        m_grn_name  = "Vert Terminal",
        m_grn_desc  = "Change le thème du menu en vert hacker.",
        m_pur_name  = "Violet Néon",
        m_pur_desc  = "Change le thème du menu en violet premium.",
        m_gld_name  = "Or Sombre",
        m_gld_desc  = "Change le thème du menu en or classique.",

        lang_es_name = "Espagnol (Español)",
        lang_es_desc = "Changer la langue en Espagnol.",
        lang_en_name = "Anglais (English)",
        lang_en_desc = "Changer la langue en Anglais.",
        lang_fr_name = "Français",
        lang_fr_desc = "Changer la langue en Français.",
        
        status_on   = "On",
        status_off  = "Off",
        loading     = "Chargement",
        footer      = "D-PAD: Naviguer  |  A: Choisir  |  B: Fermer",
        
        err_cmd = "\\#ff3333\\Erreur : Commande incorrecte.",
        err_s = "\\#ff3333\\Erreur : Utilisez /s on, /s off ou juste /s",
        err_c = "\\#ff3333\\Erreur : Utilisez /c on, /c off ou juste /c",
        err_a = "\\#ff3333\\Erreur : Utilisez /a on, /a off ou juste /a",
        err_rgb = "\\#ff3333\\Erreur : /cc nécessite 3 nombres (Ex : /cc 255 255 30)",
        on_c = "Coords : \\#00ff00\\ON",
        off_c = "Coords : \\#ff0000\\OFF",
        on_s = "Vitesse : \\#00ff00\\ON",
        off_s = "Vitesse : \\#ff0000\\OFF",
        on_a = "Animations : \\#00ff00\\ON",
        off_a = "Animations : \\#ff0000\\OFF",
        notify_hud = "Couleur HUD : ",
        notify_menu = "Couleur Menu : ",
        notify_lang = "Langue changée en : Français"
    }
}

function _T(key)
    if not _G.LANG then return key end
    local l = _G.LANG[_G.LANG.current]
    if l and l[key] then return l[key] end
    return key
end
