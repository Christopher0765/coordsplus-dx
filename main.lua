-- name: \\#ffff1e\\Coords \\#00ff00\\+ \\#00ffff\\DX\\#dcdcdc\\ [WIP]
-- description: Una revolucion de los mods de utilidad. Se tomaron ideas de varios mods, mas notablemente el modo de juego \\#3df5ff\\Flood \\#00ff00\\+\\#dcdcdc\\ y de algunos mods de un desarrollador llamado\n\\\#9b9b9b\\Agent \\#ec7731\\X\\#dcdcdc\\, de ellos se tomaron ideas y se aprendio de sus mods, para hacer este increible mod.\n\nPuedes consultar los comandos del mod al escribir "/help" en el chat.\n\n \\#1892f5\\Creado por\\#dcdcdc\\: el equipo de devs de\n\ \\#ffa700\\Coords +\\#dcdcdc\\.\n\n--------------------------------\n\-\\#00ff00\\Version: 1.2.1\\#dcdcdc\\-\n\--------------------------------
-- category: utility
-- deluxe: true

require("a-lang")
require("b-tags")
require("b-tags-lang-loader")
require("z-menu")

require("lang-tags/tag-lang-es")
require("lang-tags/tag-lang-en")
require("lang-tags/tag-lang-fr")

menu_state = "closed"
startup_timer = 0
lang_fade_timer = 0
lang_text_alpha = 255
pending_lang_change = nil

M = { xyz = true, spd = false, anim = true }

notifs = {}

r, g, b = 255, 255, 30
m_r, m_g, m_b = 0, 255, 255
tm_r, tm_g, tm_b = 0, 255, 255
glitch_intensity = 0
last_health = 0x0880
anim_x_xyz = -400
anim_x_spd = -400
exiting_xyz = false
exiting_spd = false
current_y_offset = 0

function play_select_sound()
    if gMarioStates[0] and gMarioStates[0].marioObj then
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    end
end

function play_error_sound()
    if gMarioStates[0] and gMarioStates[0].marioObj then
        play_sound(SOUND_MENU_REVERSE_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    end
end

function notify(txt, pos) 
    table.insert(notifs, {t = txt, tm = 90, p = pos, a = 0}) 
end

function lerp(a, b, t) return a + (b - a) * t end

function format_num(val) 
    return tostring(tonumber(string.format("%.6f", tonumber(val) or 0))) 
end

function save_config()
    local str = string.format("%d %d %d %d %d %d %d %d %d %s", 
        math.floor(r), math.floor(g), math.floor(b), 
        math.floor(tm_r), math.floor(tm_g), math.floor(tm_b), 
        M.xyz and 1 or 0, M.spd and 1 or 0, M.anim and 1 or 0,
        _G.LANG and _G.LANG.current or "es")
    mod_storage_save("cp-dx", str)
end

function load_config()
    local data = mod_storage_load("cp-dx")
    if data ~= nil and data ~= "" then
        local t = {}
        for val in string.gmatch(data, "%S+") do table.insert(t, val) end
        if #t >= 9 then
            r, g, b = tonumber(t[1]), tonumber(t[2]), tonumber(t[3])
            tm_r, tm_g, tm_b = tonumber(t[4]), tonumber(t[5]), tonumber(t[6])
            m_r, m_g, m_b = tm_r, tm_g, tm_b
            M.xyz = (tonumber(t[7]) == 1)
            M.spd = (tonumber(t[8]) == 1)
            M.anim = (tonumber(t[9]) == 1)
            exiting_xyz = not M.xyz
            exiting_spd = not M.spd
        end
        if #t >= 10 and _G.LANG then
            _G.LANG.current = tostring(t[10])
        end
    end
end

load_config()

local function refresh_chat_command_descriptions()
    if not update_chat_command_description then return end
    update_chat_command_description("s", _T("s_cmd_desc"))
    update_chat_command_description("c", _T("c_cmd_desc"))
    update_chat_command_description("a", _T("a_cmd_desc"))
    update_chat_command_description("cpmenu", _T("cpmenu_cmd_desc"))
end


local function on_hud_render_main()
    local m = gMarioStates[0]
    if not m or not m.marioObj then return end

    -- Sistema de suavizado (Lerp) para los colores del menú
    m_r = lerp(m_r, tm_r, 0.15)
    m_g = lerp(m_g, tm_g, 0.15)
    m_b = lerp(m_b, tm_b, 0.15)
    
    -- Lógica de transición suave para el cambio de idioma
    if lang_fade_timer > 0 then
        lang_fade_timer = lang_fade_timer + 1
        
        if lang_fade_timer < 10 then
            lang_text_alpha = lerp(lang_text_alpha, 0, 0.4)
        elseif lang_fade_timer == 10 then
            if pending_lang_change and _G.LANG then
                _G.LANG.current = pending_lang_change
                notify(_T("notify_lang"), true)
                save_config()
                refresh_chat_command_descriptions()
            end
        elseif lang_fade_timer > 10 and lang_fade_timer < 20 then
            lang_text_alpha = lerp(lang_text_alpha, 255, 0.4)
        else
            lang_text_alpha = 255
            lang_fade_timer = 0
            pending_lang_change = nil
        end
    end

    if startup_timer < 30 then startup_timer = startup_timer + 1 end
    local can_show_hud = (startup_timer >= 30)
    
    local FONT_USER = djui_menu_get_font()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_USER)
    
    local health_loss = last_health - m.health
    if health_loss > 10 then glitch_intensity = 10 end
    last_health = m.health

    if glitch_intensity > 0 then glitch_intensity = glitch_intensity - 0.3 else glitch_intensity = 0 end

    local cur_t_in = M.anim and 0.09 or 1
    local cur_t_out = M.anim and 0.05 or 1

    local target_x_xyz = (M.xyz and not exiting_xyz and can_show_hud) and 0 or -400
    anim_x_xyz = anim_x_xyz + (target_x_xyz - anim_x_xyz) * ((target_x_xyz == 0) and cur_t_in or cur_t_out)
    if not M.xyz and anim_x_xyz < -390 then exiting_xyz = false end

    local target_x_spd = (M.spd and not exiting_spd and can_show_hud) and 0 or -400
    anim_x_spd = anim_x_spd + (target_x_spd - anim_x_spd) * ((target_x_spd == 0) and cur_t_in or cur_t_out)
    if not M.spd and anim_x_spd < -390 then exiting_spd = false end
    
    local target_y_offset = M.xyz and 110 or 0
    current_y_offset = current_y_offset + (target_y_offset - current_y_offset) * cur_t_in

    local base_y = djui_hud_get_screen_height() - 420
    
    local function render_text(text, x, y)
        local x_cursor = x
        local s_int = math.floor(glitch_intensity)
        for i = 1, #text do
            local char = text:sub(i, i)
            local rx, ry = 0, 0
            if s_int > 0 then rx = math.random(-s_int, s_int); ry = math.random(-s_int, s_int) end
            djui_hud_set_color(0, 0, 0, 255)
            djui_hud_print_text(char, x_cursor + rx + 2, y + ry + 2, 1)
            djui_hud_set_color(r, g, b, 255)
            djui_hud_print_text(char, x_cursor + rx, y + ry, 1)
            x_cursor = x_cursor + djui_hud_measure_text(char)
        end
    end

    if M.xyz or exiting_xyz or anim_x_xyz > -395 then
        render_text("X: " .. format_num(m.pos.x), 40 + anim_x_xyz, base_y + 30)
        render_text("Y: " .. format_num(m.pos.y), 40 + anim_x_xyz, base_y + 60)
        render_text("Z: " .. format_num(m.pos.z), 40 + anim_x_xyz, base_y + 90)
    end

    if M.spd or exiting_spd or anim_x_spd > -395 then
        local py_base = base_y + current_y_offset
        render_text("Vel X: " .. format_num(m.vel.x), 40 + anim_x_spd, py_base + 30)
        render_text("Vel Y: " .. format_num(m.vel.y), 40 + anim_x_spd, py_base + 60)
        render_text("Vel Z: " .. format_num(m.vel.z), 40 + anim_x_spd, py_base + 90)
    end

    local sw = djui_hud_get_screen_width()
    local y_off = 20
    for i = #notifs, 1, -1 do
        local n = notifs[i] 
        n.tm = n.tm - 1
        n.a = n.tm < 10 and n.tm / 10 or (n.tm > 80 and (90 - n.tm) / 10 or 1)
        if n.tm <= 0 then table.remove(notifs, i) else
            local tw = djui_hud_measure_text(n.t) * 0.6 
            local nx = sw - tw - 20
            djui_hud_set_color(12, 14, 24, 220 * n.a) 
            djui_hud_render_rect(nx - 10, y_off - 5, tw + 20, 26)
            if n.p then djui_hud_set_color(50, 255, 150, 255 * n.a) else djui_hud_set_color(255, 50, 80, 255 * n.a) end
            djui_hud_render_rect(nx - 10, y_off - 5, 4, 26)
            djui_hud_set_color(255, 255, 255, 255 * n.a) 
            djui_hud_print_text(n.t, nx, y_off, 0.6) 
            y_off = y_off + 35
        end
    end
end

hook_chat_command("s", (_T("s_cmd_desc")), function(msg)
    local arg = msg:lower():gsub("%s+", "")
    if arg == "on" then M.spd = true; exiting_spd = false
    elseif arg == "off" then M.spd = false; exiting_spd = true
    elseif arg == "" then M.spd = not M.spd; exiting_spd = not M.spd
    else play_error_sound(); djui_chat_message_create(_T("err_s")); return true end
    
    play_select_sound()
    save_config()
    
    if M.spd then
        djui_chat_message_create(_T("on_s"))
    else
        djui_chat_message_create(_T("off_s"))
    end
    
    return true
end)

hook_chat_command("c", (_T("c_cmd_desc")), function(msg)
    local arg = msg:lower():gsub("%s+", "")
    if arg == "on" then M.xyz = true; exiting_xyz = false
    elseif arg == "off" then M.xyz = false; exiting_xyz = true
    elseif arg == "" then M.xyz = not M.xyz; exiting_xyz = not M.xyz
    else play_error_sound(); djui_chat_message_create(_T("err_c")); return true end
    
    play_select_sound()
    save_config()
    
    if M.xyz then
        djui_chat_message_create(_T("on_c"))
    else
        djui_chat_message_create(_T("off_c"))
    end
    
    return true
end)

hook_chat_command("a", (_T("a_cmd_desc")), function(msg)
    local arg = msg:lower():gsub("%s+", "")
    if arg == "on" then M.anim = true
    elseif arg == "off" then M.anim = false
    elseif arg == "" then M.anim = not M.anim
    else play_error_sound(); djui_chat_message_create(_T("err_a")); return true end
    
    play_select_sound()
    save_config()
    
    if M.anim then
        djui_chat_message_create(_T("on_a"))
    else
        djui_chat_message_create(_T("off_a"))
    end
    
    return true
end)


hook_chat_command("cpmenu", (_T("cpmenu_cmd_desc")), function() 
    if menu_state == "closed" then menu_state = "loading"; play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource) 
    else menu_state = "closed"; play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource) end
    return true 
end)

hook_event(HOOK_ON_HUD_RENDER, on_hud_render_main)
hook_event(HOOK_ON_MODS_LOADED, refresh_chat_command_descriptions)
