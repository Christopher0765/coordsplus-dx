-- name: \\#ffff1e\\Coords\\#00ff00\\ + \\#00ffff\\DX \\#ffffff\\[WIP]
-- description: Herramienta de telemetría y HUD premium para SM64 Coop DX. Soporte Multi-idioma y sistema de animaciones. ¡Usa /cpmenu para configurar!

local menu_state = "closed"
local s_lerp = 0
local a_lerp = 0
local fade_alpha = 0
local fake_loading_frame = 0
local loading_dots = ""
local startup_timer = 0 -- Temporizador para el delay inicial

local t_c = 0
local c_tab = 1
local c_item = 1
local a_tab = 0
local a_item = 0
local s_off = 0
local a_scroll = 0
local parts = {}
local notifs = {}
local M = {}

for i = 1, 50 do 
    parts[i] = { x = math.random(100), y = math.random(100), s = math.random(3, 8) * 0.1, z = math.random(2, 4) } 
end

local r, g, b = 255, 255, 30
local m_r, m_g, m_b = 0, 255, 255
local glitch_intensity = 0
local last_health = 0x0880
local anim_x_xyz = -400
local anim_x_spd = -400
local exiting_xyz = false
local exiting_spd = false
local current_y_offset = 0

local tabs = {
    { 
        n_key = "tab_coords", 
        i = {
            {id = "xyz",  n_key = "xyz_name",  d_key = "xyz_desc"}, 
            {id = "spd",  n_key = "spd_name",  d_key = "spd_desc"}, 
            {id = "anim", n_key = "anim_name", d_key = "anim_desc"}
        } 
    },
    { 
        n_key = "tab_colors", 
        i = {
            {id = "h_yel", n_key = "h_yel_name", d_key = "h_yel_desc"}, 
            {id = "h_red", n_key = "h_red_name", d_key = "h_red_desc"}, 
            {id = "h_grn", n_key = "h_grn_name", d_key = "h_grn_desc"}, 
            {id = "h_blu", n_key = "h_blu_name", d_key = "h_blu_desc"}, 
            {id = "h_wht", n_key = "h_wht_name", d_key = "h_wht_desc"}
        } 
    },
    { 
        n_key = "tab_style", 
        i = {
            {id = "m_cyn", n_key = "m_cyn_name", d_key = "m_cyn_desc"}, 
            {id = "m_red", n_key = "m_red_name", d_key = "m_red_desc"}, 
            {id = "m_grn", n_key = "m_grn_name", d_key = "m_grn_desc"}, 
            {id = "m_pur", n_key = "m_pur_name", d_key = "m_pur_desc"}, 
            {id = "m_gld", n_key = "m_gld_name", d_key = "m_gld_desc"}
        } 
    },
    { 
        n_key = "tab_lang", 
        i = {
            {id = "lang_es", n_key = "lang_es_name", d_key = "lang_es_desc"}, 
            {id = "lang_en", n_key = "lang_en_name", d_key = "lang_en_desc"}
        } 
    }
}

M.xyz = true
M.spd = false
M.anim = true

local function play_select_sound()
    if gMarioStates[0] and gMarioStates[0].marioObj then
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    end
end

local function play_error_sound()
    if gMarioStates[0] and gMarioStates[0].marioObj then
        play_sound(SOUND_MENU_REVERSE_PAUSE, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    end
end

local function notify(txt, pos) 
    table.insert(notifs, {t = txt, tm = 90, p = pos, a = 0}) 
end

local function lerp(a, b, t) return a + (b - a) * t end
local function format_num(val) return tostring(tonumber(string.format("%.10f", tonumber(val) or 0))) end

-- Actualizado para guardar 10 parámetros, incluyendo el string del idioma ("es" o "en")
local function save_config()
    local str = string.format("%d %d %d %d %d %d %d %d %d %s", 
        math.floor(r), math.floor(g), math.floor(b), 
        math.floor(m_r), math.floor(m_g), math.floor(m_b), 
        M.xyz and 1 or 0, M.spd and 1 or 0, M.anim and 1 or 0,
        _G.LANG and _G.LANG.current or "es")
    mod_storage_save("coords_dx_save", str)
end

local function load_config()
    local data = mod_storage_load("coords_dx_save")
    if data ~= nil and data ~= "" then
        local t = {}
        for val in string.gmatch(data, "%S+") do table.insert(t, val) end
        if #t >= 9 then
            r, g, b = tonumber(t[1]), tonumber(t[2]), tonumber(t[3])
            m_r, m_g, m_b = tonumber(t[4]), tonumber(t[5]), tonumber(t[6])
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

function on_mario_update(m)
    if m.playerIndex ~= 0 then return end
    
    if menu_state == "closed" then 
        if m.action == ACT_WAITING_FOR_DIALOG then set_mario_action(m, ACT_IDLE, 0) end 
        return 
    end

    if m.action ~= ACT_WAITING_FOR_DIALOG then set_mario_action(m, ACT_WAITING_FOR_DIALOG, 0) end
    local p = m.controller.buttonPressed
    
    if (p & B_BUTTON) ~= 0 then 
        menu_state = "closed"; play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource); return 
    end
    
    if menu_state ~= "ready" then return end

    if (p & R_JPAD) ~= 0 then 
        c_tab = math.min(c_tab + 1, #tabs); c_item = 1; s_off = 0; play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
    elseif (p & L_JPAD) ~= 0 then 
        c_tab = math.max(c_tab - 1, 1); c_item = 1; s_off = 0; play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource) 
    end

    local max_i = #tabs[c_tab].i
    if (p & D_JPAD) ~= 0 and c_item < max_i then 
        c_item = c_item + 1; play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource) 
        if c_item > s_off + 4 then s_off = s_off + 1 end
    elseif (p & U_JPAD) ~= 0 and c_item > 1 then 
        c_item = c_item - 1; play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource) 
        if c_item <= s_off then s_off = s_off - 1 end 
    end

    if (p & A_BUTTON) ~= 0 then
        local it = tabs[c_tab].i[c_item]
        local id = it.id
        
        if c_tab == 1 then
            M[id] = not M[id]
            if id == "xyz" then exiting_xyz = not M.xyz end
            if id == "spd" then exiting_spd = not M.spd end
            play_sound(M[id] and SOUND_GENERAL_COIN or SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
            notify(_T(it.n_key) .. (M[id] and " ON" or " OFF"), M[id])
        elseif c_tab == 2 then
            if id == "h_yel" then r, g, b = 255, 255, 30
            elseif id == "h_red" then r, g, b = 255, 50, 50
            elseif id == "h_grn" then r, g, b = 50, 255, 50
            elseif id == "h_blu" then r, g, b = 50, 150, 255
            elseif id == "h_wht" then r, g, b = 255, 255, 255 end
            play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
            notify(_T("notify_hud") .. _T(it.n_key), true)
        elseif c_tab == 3 then
            if id == "m_cyn" then m_r, m_g, m_b = 0, 255, 255
            elseif id == "m_red" then m_r, m_g, m_b = 255, 50, 50
            elseif id == "m_grn" then m_r, m_g, m_b = 50, 255, 50
            elseif id == "m_pur" then m_r, m_g, m_b = 200, 50, 255
            elseif id == "m_gld" then m_r, m_g, m_b = 255, 200, 0 end
            play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
            notify(_T("notify_menu") .. _T(it.n_key), true)
        elseif c_tab == 4 then
            if id == "lang_es" and _G.LANG then _G.LANG.current = "es"
            elseif id == "lang_en" and _G.LANG then _G.LANG.current = "en" end
            play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
            notify(_T("notify_lang"), true)
        end
        save_config()
    end
end

function on_hud_render()
    local m = gMarioStates[0]
    if not m or not m.marioObj then return end

    -- Temporizador de arranque (espera aprox 1 segundo antes de mostrar todo)
    if startup_timer < 30 then startup_timer = startup_timer + 1 end
    local can_show_hud = (startup_timer >= 30)

    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_ALIASED)

    local health_loss = last_health - m.health
    if health_loss > 10 then glitch_intensity = 10 end
    last_health = m.health

    if glitch_intensity > 0 then glitch_intensity = glitch_intensity - 0.3 else glitch_intensity = 0 end

    local cur_t_in = M.anim and 0.09 or 1
    local cur_t_out = M.anim and 0.05 or 1

    -- Se condiciona el objetivo en pantalla a "can_show_hud" para el delay inicial
    local target_x_xyz = (M.xyz and not exiting_xyz and can_show_hud) and 0 or -400
    anim_x_xyz = anim_x_xyz + (target_x_xyz - anim_x_xyz) * ((target_x_xyz == 0) and cur_t_in or cur_t_out)
    if not M.xyz and anim_x_xyz < -390 then exiting_xyz = false end

    local target_x_spd = (M.spd and not exiting_spd and can_show_hud) and 0 or -400
    anim_x_spd = anim_x_spd + (target_x_spd - anim_x_spd) * ((target_x_spd == 0) and cur_t_in or cur_t_out)
    if not M.spd and anim_x_spd < -390 then exiting_spd = false end
    
    local target_y_offset = M.xyz and 110 or 0
    current_y_offset = current_y_offset + (target_y_offset - current_y_offset) * cur_t_in

    local base_y = djui_hud_get_screen_height() - 420
    
    local function dibujar_dato_glitch(texto, x, y)
        local x_cursor = x
        local s_int = math.floor(glitch_intensity)
        for i = 1, #texto do
            local char = texto:sub(i, i)
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
        dibujar_dato_glitch("X: " .. format_num(m.pos.x), 40 + anim_x_xyz, base_y + 30)
        dibujar_dato_glitch("Y: " .. format_num(m.pos.y), 40 + anim_x_xyz, base_y + 60)
        dibujar_dato_glitch("Z: " .. format_num(m.pos.z), 40 + anim_x_xyz, base_y + 90)
    end

    if M.spd or exiting_spd or anim_x_spd > -395 then
        local py_base = base_y + current_y_offset
        dibujar_dato_glitch("Vel X: " .. format_num(m.vel.x), 40 + anim_x_spd, py_base + 30)
        dibujar_dato_glitch("Vel Y: " .. format_num(m.vel.y), 40 + anim_x_spd, py_base + 60)
        dibujar_dato_glitch("Vel Z: " .. format_num(m.vel.z), 40 + anim_x_spd, py_base + 90)
    end

    t_c = t_c + 0.04
    local sw = djui_hud_get_screen_width()
    local sh = djui_hud_get_screen_height()

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

    s_lerp = lerp(s_lerp, (menu_state ~= "closed") and 1 or 0, 0.14)
    a_lerp = lerp(a_lerp, (menu_state ~= "closed") and 1 or 0, 0.11)

    if menu_state == "closed" then
        fade_alpha = 0
        fake_loading_frame = 0
    elseif menu_state == "loading" then
        fake_loading_frame = fake_loading_frame + 1
        if fake_loading_frame % 45 < 15 then loading_dots = "."
        elseif fake_loading_frame % 45 < 30 then loading_dots = ".."
        else loading_dots = "..." end
        if fake_loading_frame > 60 then 
            menu_state = "ready"
            fake_loading_frame = 0 
        end
    elseif menu_state == "ready" then
        fade_alpha = lerp(fade_alpha, 1, 0.12)
    end

    if s_lerp < 0.01 then return end

    local w, h = 560 * s_lerp, 400 * s_lerp
    local x, y = (sw - w) / 2, (sh - h) / 2

    djui_hud_set_color(4, 6, 14, 130 * a_lerp) 
    djui_hud_render_rect(0, 0, sw, sh)
    djui_hud_set_color(11, 14, 26, 235 * a_lerp) 
    djui_hud_render_rect(x, y, w, h)

    for _, p in ipairs(parts) do
        p.y = p.y - p.s 
        if p.y < 0 then p.y = 100; p.x = math.random(100) end
        local p_alpha = (40 + 90 * ((math.sin(t_c * 1.5 + p.x) + 1) / 2)) * s_lerp * a_lerp
        djui_hud_set_color(m_r, m_g, m_b, p_alpha * 0.5)
        djui_hud_render_rect(x + (p.x / 100) * w, y + (p.y / 100) * h, p.z * s_lerp, p.z * s_lerp)
    end

    djui_hud_set_color(m_r, m_g, m_b, 25 * a_lerp)
    local wave_segments = 20
    local segment_w = w / wave_segments
    for i = 0, wave_segments - 1 do
        local wave_h = 18 * math.sin(t_c * 2 + i * 0.6) * s_lerp
        djui_hud_render_rect(x + (i * segment_w), y + h - (35 * s_lerp) + wave_h, segment_w + 1, 35 * s_lerp - wave_h)
    end

    local p_g = (math.sin(t_c * 2.5) + 1) / 2
    djui_hud_set_color(m_r, m_g, m_b, (170 + 85 * p_g) * a_lerp)
    djui_hud_render_rect(x, y, w, 4 * s_lerp) 
    djui_hud_render_rect(x, y + h - 4 * s_lerp, w, 4 * s_lerp)

    if menu_state == "loading" then
        local txt_load = _T("loading") .. loading_dots
        djui_hud_set_color(255, 255, 255, 255 * a_lerp)
        djui_hud_print_text(txt_load, x + (w / 2) - (djui_hud_measure_text(txt_load) * 0.7 * s_lerp), y + (h / 2) - 10 * s_lerp, 1.4 * s_lerp)
    end

    local f_a = a_lerp * fade_alpha
    if f_a > 0.01 then
        local t_w = w / #tabs
        a_tab = lerp(a_tab, x + ((c_tab - 1) * t_w), 0.18)
        
        djui_hud_set_color(m_r, m_g, m_b, 65 * f_a)
        djui_hud_render_rect(a_tab + 4 * s_lerp, y + 6 * s_lerp, t_w - 8 * s_lerp, 42 * s_lerp)
        djui_hud_set_color(m_r, m_g, m_b, 230 * f_a)
        djui_hud_render_rect(a_tab + 12 * s_lerp, y + 45 * s_lerp, t_w - 24 * s_lerp, 3 * s_lerp)

        for i, t in ipairs(tabs) do
            djui_hud_set_color(255, 255, 255, (i == c_tab and 255 or 120) * f_a)
            local txt_tab = _T(t.n_key)
            djui_hud_print_text(txt_tab, x + ((i - 1) * t_w) + (t_w / 2) - (djui_hud_measure_text(txt_tab) * 0.43 * s_lerp), y + 15 * s_lerp, 0.9 * s_lerp)
        end
        
        djui_hud_set_color(m_r, m_g, m_b, 50 * f_a) 
        djui_hud_render_rect(x + 15 * s_lerp, y + 54 * s_lerp, w - 30 * s_lerp, 1 * s_lerp)

        local itms = tabs[c_tab].i
        a_scroll = lerp(a_scroll, s_off, 0.18)
        local i_st = y + 66 * s_lerp
        a_item = lerp(a_item, i_st + ((c_item - 1 - a_scroll) * 56 * s_lerp), 0.22)

        djui_hud_set_color(m_r, m_g, m_b, 35 * f_a) 
        djui_hud_render_rect(x + 15 * s_lerp, a_item, w - 30 * s_lerp, 50 * s_lerp)
        djui_hud_set_color(m_r, m_g, m_b, 240 * f_a) 
        djui_hud_render_rect(x + 15 * s_lerp, a_item, 4 * s_lerp, 50 * s_lerp)

        for i = 1, #itms do
            local r_i = i - a_scroll
            if r_i > 0 and r_i <= 5 then
                local iy = i_st + ((r_i - 1) * 56 * s_lerp)
                if iy > i_st - 10 and iy < y + h - 65 * s_lerp then
                    djui_hud_set_color(255, 255, 255, (i == c_item and 255 or 200) * f_a) 
                    djui_hud_print_text(_T(itms[i].n_key), x + 35 * s_lerp, iy + 6 * s_lerp, 0.8 * s_lerp)
                    djui_hud_set_color(160, 185, 225, (i == c_item and 220 or 140) * f_a) 
                    djui_hud_print_text(_T(itms[i].d_key), x + 35 * s_lerp, iy + 28 * s_lerp, 0.5 * s_lerp)
                    
                    local status_on = false
                    if c_tab == 1 then status_on = M[itms[i].id]
                    elseif c_tab == 2 then 
                        if itms[i].id == "h_yel" and r==255 and b==30 then status_on = true
                        elseif itms[i].id == "h_red" and r==255 and g==50 then status_on = true
                        elseif itms[i].id == "h_grn" and r==50 and g==255 then status_on = true
                        elseif itms[i].id == "h_blu" and r==50 and b==255 then status_on = true
                        elseif itms[i].id == "h_wht" and r==255 and g==255 and b==255 then status_on = true end
                    elseif c_tab == 3 then
                        if itms[i].id == "m_cyn" and m_r==0 and m_b==255 then status_on = true
                        elseif itms[i].id == "m_red" and m_r==255 and m_g==50 then status_on = true
                        elseif itms[i].id == "m_grn" and m_r==50 and m_g==255 then status_on = true
                        elseif itms[i].id == "m_pur" and m_r==200 and m_b==255 then status_on = true
                        elseif itms[i].id == "m_gld" and m_r==255 and m_b==0 then status_on = true end
                    elseif c_tab == 4 then
                        if itms[i].id == "lang_es" and _G.LANG and _G.LANG.current == "es" then status_on = true
                        elseif itms[i].id == "lang_en" and _G.LANG and _G.LANG.current == "en" then status_on = true end
                    end

                    local bx = x + w - 95 * s_lerp
                    local by_btn = iy + 12 * s_lerp
                    local bw_btn = 65 * s_lerp
                    local bh_btn = 24 * s_lerp

                    local txt_status = status_on and _T("status_on") or _T("status_off")

                    if status_on then 
                        djui_hud_set_color(22, 64, 44, 180 * f_a)
                        djui_hud_render_rect(bx, by_btn, bw_btn, bh_btn)
                        djui_hud_set_color(50, 255, 150, 240 * f_a)
                        djui_hud_print_text(txt_status, bx + (bw_btn / 2) - (djui_hud_measure_text(txt_status) * 0.35 * s_lerp), by_btn + 2 * s_lerp, 0.7 * s_lerp)
                    else 
                        djui_hud_set_color(64, 24, 34, 180 * f_a)
                        djui_hud_render_rect(bx, by_btn, bw_btn, bh_btn)
                        djui_hud_set_color(255, 50, 80, 240 * f_a)
                        djui_hud_print_text(txt_status, bx + (bw_btn / 2) - (djui_hud_measure_text(txt_status) * 0.35 * s_lerp), by_btn + 2 * s_lerp, 0.7 * s_lerp) 
                    end
                end
            end
        end

        if #itms > 4 then
            local sb_h = (4 / #itms) * (h - 145 * s_lerp)
            djui_hud_set_color(24, 28, 48, 200 * f_a) 
            djui_hud_render_rect(x + w - 14 * s_lerp, i_st, 4 * s_lerp, h - 145 * s_lerp)
            djui_hud_set_color(m_r, m_g, m_b, 255 * f_a) 
            djui_hud_render_rect(x + w - 14 * s_lerp, i_st + (a_scroll / (#itms - 4)) * (h - 145 * s_lerp - sb_h), 4 * s_lerp, sb_h)
        end

        local txt_footer = _T("footer")
        djui_hud_set_color(140, 170, 210, 190 * f_a)
        djui_hud_print_text(txt_footer, x + (w / 2) - (djui_hud_measure_text(txt_footer) * 0.25 * s_lerp), y + h - 24 * s_lerp, 0.5 * s_lerp)
    end
end

hook_chat_command("s", "[on|off]", function(msg)
    local arg = msg:lower():gsub("%s+", "")
    if arg == "on" then M.spd = true; exiting_spd = false
    elseif arg == "off" then M.spd = false; exiting_spd = true
    elseif arg == "" then M.spd = not M.spd; exiting_spd = not M.spd
    else play_error_sound(); djui_chat_message_create(_T("err_cmd")); return true end
    play_select_sound(); save_config(); return true
end)

hook_chat_command("c", "[on|off]", function(msg)
    local arg = msg:lower():gsub("%s+", "")
    if arg == "on" then M.xyz = true; exiting_xyz = false
    elseif arg == "off" then M.xyz = false; exiting_xyz = true
    elseif arg == "" then M.xyz = not M.xyz; exiting_xyz = not M.xyz
    else play_error_sound(); djui_chat_message_create(_T("err_cmd")); return true end
    play_select_sound(); save_config(); return true
end)

hook_chat_command("a", "[on|off]", function(msg)
    local arg = msg:lower():gsub("%s+", "")
    if arg == "on" then M.anim = true
    elseif arg == "off" then M.anim = false
    elseif arg == "" then M.anim = not M.anim
    else play_error_sound(); djui_chat_message_create(_T("err_cmd")); return true end
    play_select_sound(); save_config(); return true
end)

hook_chat_command("cc", "[R G B]", function(msg)
    local col = {}
    for w in string.gmatch(msg, "%S+") do table.insert(col, tonumber(w)) end
    if #col >= 3 and col[1] and col[2] and col[3] then 
        r = math.max(0, math.min(255, col[1])); g = math.max(0, math.min(255, col[2])); b = math.max(0, math.min(255, col[3]))
        play_select_sound(); save_config() 
    else play_error_sound(); djui_chat_message_create(_T("err_rgb")) end
    return true
end)

hook_chat_command("cpmenu", "Abre el menú", function() 
    if menu_state == "closed" then menu_state = "loading"; play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource) 
    else menu_state = "closed"; play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource) end
    return true 
end)

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_MARIO_UPDATE, on_mario_update)
