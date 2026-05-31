if unsupported then return end


langdata = {}


local LANGUAGES = { "en", "es", "fr" }

for _, lang in ipairs(LANGUAGES) do
    require("lang-tags/tag-lang-" .. lang)
end


local lang_list = "[es|en|fr]"

local function get_current_lang()
    if _G.LANG and _G.LANG.current then
        return _G.LANG.current
    end
end

function trans(id, format, format2, lang_)
    local usingLang = lang_ or get_current_lang()

    local translation =
        (langdata[usingLang] and langdata[usingLang][id])
        or (langdata["en"] and langdata["en"][id])
        or id

    if format ~= nil then
        return string.format(translation, format, format2)
    end

    return translation
end

local function refresh_lang_list()
    local t = {}
    for code in pairs(langdata) do
        table.insert(t, code)
    end
    table.sort(t)
    lang_list = "\\#2BC3FF\\[" .. table.concat(t, "|") .. "]\\#DCDCDC\\"
end

---------------
--- WRAPPER ---
---------------

local function on_mods_loaded()
    refresh_lang_list()
end

-------------
--- HOOKS ---
-------------

hook_event(HOOK_ON_MODS_LOADED, on_mods_loaded)