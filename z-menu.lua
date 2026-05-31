if unsupported then return end

local s_lerp = 0
local a_lerp = 0
local fade_alpha = 0
local fake_loading_frame = 0
local loading_dots = ""

local t_c = 0
local c_tab = 1
local c_item = 1
local a_tab = 0
local a_item = 0
local s_off = 0
local a_scroll = 0
local menu_cooldown = 0 -- Variable añadida para controlar la velocidad del joystick
local parts = {}

for i = 1, 50 do 
    parts[i] = { x = math.random(100), y = math.random(100), s = math.random(3, 8) * 0.1, z = math.random(2, 4) } 
end

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
            {id = "lang_en", n_key = "lang_en_name", d_key = "lang_en_desc"},
            {id = "lang_fr", n_key = "lang_fr_name", d_key = "lang_fr_desc"}
        } 
    }
}

local function on_mario_update_menu(m)
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

    -- LÓGICA DE CONTROLES AÑADIDA: Joystick + D-Pad con Deadzone y Cooldown
    local stickX = m.controller.stickX
    local stickY = m.controller.stickY

    local rightPressed = (stickX > 40) or ((p & R_JPAD) ~= 0)
    local leftPressed = (stickX < -40) or ((p & L_JPAD) ~= 0)
    local downPressed = (stickY < -40) or ((p & D_JPAD) ~= 0)
    local upPressed = (stickY > 40) or ((p & U_JPAD) ~= 0)

    -- Si se suelta el control, el cooldown se resetea inmediatamente
    if not (rightPressed or leftPressed or downPressed or upPressed) then
        menu_cooldown = 0
    end

    if menu_cooldown > 0 then
        menu_cooldown = menu_cooldown - 1
    else
        if rightPressed then 
            c_tab = math.min(c_tab + 1, #tabs); c_item = 1; s_off = 0; play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
            menu_cooldown = 8
        elseif leftPressed then 
            c_tab = math.max(c_tab - 1, 1); c_item = 1; s_off = 0; play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource) 
            menu_cooldown = 8
        end

        local max_i = #tabs[c_tab].i
        if downPressed and c_item < max_i then 
            c_item = c_item + 1; play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource) 
            if c_item > s_off + 4 then s_off = s_off + 1 end
            menu_cooldown = 8
        elseif upPressed and c_item > 1 then 
            c_item = c_item - 1; play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource) 
            if c_item <= s_off then s_off = s_off - 1 end 
            menu_cooldown = 8
        end
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
            if id == "m_cyn" then tm_r, tm_g, tm_b = 0, 255, 255
            elseif id == "m_red" then tm_r, tm_g, tm_b = 255, 50, 50
            elseif id == "m_grn" then tm_r, tm_g, tm_b = 50, 255, 50
            elseif id == "m_pur" then tm_r, tm_g, tm_b = 200, 50, 255
            elseif id == "m_gld" then tm_r, tm_g, tm_b = 255, 200, 0 end
            play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
            notify(_T("notify_menu") .. _T(it.n_key), true)
        elseif c_tab == 4 then
            if lang_fade_timer == 0 then
                if id == "lang_es" then pending_lang_change = "es"
                elseif id == "lang_en" then pending_lang_change = "en"
                elseif id == "lang_fr" then pending_lang_change = "fr" end
                lang_fade_timer = 1
                play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
            end
        end
        save_config()
    end
end

local function on_hud_render_menu()
    local m = gMarioStates[0]
    if not m or not m.marioObj then return end

    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_ALIASED)

    t_c = t_c + 0.04
    local sw = djui_hud_get_screen_width()
    local sh = djui_hud_get_screen_height()

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
            djui_hud_set_color(255, 255, 255, (i == c_tab and 255 or 120) * f_a * (lang_text_alpha / 255))

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
                    djui_hud_set_color(255, 255, 255, (i == c_item and 255 or 200) * f_a * (lang_text_alpha / 255))
                    djui_hud_print_text(_T(itms[i].n_key), x + 35 * s_lerp, iy + 6 * s_lerp, 0.8 * s_lerp)
                    djui_hud_set_color(160, 185, 225, (i == c_item and 220 or 140) * f_a * (lang_text_alpha / 255))
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
                        if itms[i].id == "m_cyn" and tm_r==0 and tm_b==255 then status_on = true
                        elseif itms[i].id == "m_red" and tm_r==255 and tm_g==50 then status_on = true
                        elseif itms[i].id == "m_grn" and tm_r==50 and tm_g==255 then status_on = true
                        elseif itms[i].id == "m_pur" and tm_r==200 and tm_b==255 then status_on = true
                        elseif itms[i].id == "m_gld" and tm_r==255 and tm_b==0 then status_on = true end
                    elseif c_tab == 4 then
                        if itms[i].id == "lang_es" and _G.LANG and _G.LANG.current == "es" then status_on = true
                        elseif itms[i].id == "lang_en" and _G.LANG and _G.LANG.current == "en" then status_on = true
                        elseif itms[i].id == "lang_fr" and _G.LANG and _G.LANG.current == "fr" then status_on = true end
                    end

                    local bx = x + w - 95 * s_lerp
                    local by_btn = iy + 12 * s_lerp
                    local bw_btn = 65 * s_lerp
                    local bh_btn = 24 * s_lerp

                    local txt_status = status_on and _T("status_on") or _T("status_off")

                    if status_on then 
                        djui_hud_set_color(22, 64, 44, 180 * f_a)
                        djui_hud_render_rect(bx, by_btn, bw_btn, bh_btn)
                        djui_hud_set_color(50, 255, 150, 240 * f_a * (lang_text_alpha / 255))
                        djui_hud_print_text(txt_status, bx + (bw_btn / 2) - (djui_hud_measure_text(txt_status) * 0.35 * s_lerp), by_btn + 0 * s_lerp, 0.7 * s_lerp)
                    else 
                        djui_hud_set_color(64, 24, 34, 180 * f_a)
                        djui_hud_render_rect(bx, by_btn, bw_btn, bh_btn)
                        djui_hud_set_color(255, 50, 80, 240 * f_a * (lang_text_alpha / 255))
                        djui_hud_print_text(txt_status, bx + (bw_btn / 2) - (djui_hud_measure_text(txt_status) * 0.35 * s_lerp), by_btn + 0 * s_lerp, 0.7 * s_lerp) 
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

hook_event(HOOK_ON_HUD_RENDER, on_hud_render_menu)
hook_event(HOOK_MARIO_UPDATE, on_mario_update_menu)
