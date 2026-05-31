if unsupported then return end

----------------
--- TAG DATA ---
----------------

local TAG_DATA = {
    { key = "AUTHOR",     name = "tag_author",                          color = "\\#FF8800\\" },
    { key = "LEAD_DEV",   name = "tag_lead_dev",                        color = "\\#FF8EB2\\" },
    { key = "OG_AUTHOR",  name = "tag_og_author",                       color = "\\#DCDCDC\\" },
    { key = "FE_AUTHOR",  name = "tag_fe_author",                       color = "\\#7089B8\\" },
    { key = "DEV_EMR",    name = "tag_dev",                             color = "\\#A5AE8F\\" },
    { key = "DEV_BLU",    name = "tag_dev",                             color = "\\#617BFF\\" },
    { key = "DEV_GLD",    name = "tag_dev",                             color = "\\#FFC500\\" },
    { key = "DEV_GRN",    name = "tag_dev",                             color = "\\#009C36\\" },
    { key = "DEV_LIM",    name = "tag_dev",                             color = "\\#00FF00\\" },
    { key = "PORTER_1",   name = "tag_flood_porter",                    color = "\\#EC7731\\" },
    { key = "PORTER_CT",  name = "tag_flood_porter_contributor_tester", color = "\\#00FF00\\" },
    { key = "PORTER_2",   name = "tag_flood_porter",                    color = "\\#29CCA6\\" },
    { key = "DEV_ORG",    name = "tag_dev_short",                       color = "\\#E18B00\\" },
    { key = "TESTER_ORG", name = "tag_tester",                          color = "\\#FF8800\\" },
    { key = "TESTER_MAG", name = "tag_tester",                          color = "\\#FF18FF\\" },
    { key = "TEST_ST_1",  name = "tag_tester_special_thanks",           color = "\\#316BE8\\" },
    { key = "TEST_ST_2",  name = "tag_tester_special_thanks",           color = "\\#FFAA00\\" },
    { key = "TESTER_GRY", name = "tag_tester",                          color = "\\#8A8A8A\\" },
    { key = "TESTER_LIM", name = "tag_tester",                          color = "\\#00FF00\\" },
    { key = "TESTER_RED", name = "tag_tester",                          color = "\\#8C0000\\" },
    { key = "CONTRIB_1",  name = "tag_contributor",                     color = "\\#F7B2F3\\" },
    { key = "CONTRIB_2",  name = "tag_contributor",                     color = "\\#54708C\\" },
    { key = "CONTRIB_3",  name = "tag_contributor",                     color = "\\#9C0072\\" },
    { key = "CONTRIB_4",  name = "tag_contributor",                     color = "\\#480207\\" },
    { key = "DEV_FER",    name = "tag_dev",                             color = "\\#FFCDAB\\" },
    { key = "CONT_ST",    name = "tag_contributor_special_thanks",      color = "\\#6D9FC9\\" },
    { key = "CONTRIB_6",  name = "tag_contributor",                     color = "\\#FF3030\\" },
    { key = "CONTRIB_7",  name = "tag_contributor",                     color = "\\#823A9E\\" },
    { key = "CONTRIB_8",  name = "tag_contributor",                     color = "\\#FF0000\\" },
    { key = "SP_THANKS",  name = "tag_special_thanks",                  color = "\\#000050\\" },
    { key = "YT_SIMPLE",  name = "tag_normal",                          color = "\\#050577\\" },
    { key = "TRANS",      name = "tag_translator",                      color = "\\#FFFFFF\\" },
    { key = "PORTER_3",   name = "tag_flood_porter",                    color = "\\#A05F2E\\" },
    { key = "PORTER_4",   name = "tag_flood_porter",                    color = "\\#00EBFF\\" },
    { key = "PORTER_5",   name = "tag_flood_porter",                    color = "\\#00DE00\\" },
    { key = "PORT_COMP",  name = "tag_flood_porter_composer",           color = "\\#B48D57\\" },
    { key = "PORT_COMP2", name = "tag_flood_porter_composer",           color = "\\#FFBDE3\\" },
}

TAG_TYPE = {}
DEF_TAGS = {}

for i, data in ipairs(TAG_DATA) do
    local id = i
    TAG_TYPE[data.key] = id
    DEF_TAGS[id] = {
        name = data.name,
        color = data.color
    }
end

-----------------
--- DC TO TAG ---
-----------------

local discordToTag = {
    ["974541020446478336"]  = TAG_TYPE.AUTHOR,     --Random
}

----------------------
--- COOPNET TO TAG ---
----------------------

-- add your coopNet id here
local coopnetToTag = {
    ["519366380293270131"]      = TAG_TYPE.AUTHOR,  --ChristopherYT
}

-----------------
--- TAG LOGIC ---
-----------------

gPlayerSyncTable[0].tagId = 0
local connectQueue = {}
local myTagResolved = false
local myCachedTagId = 0
local initTimer = 0

local function get_my_discord_id()
    local id = "0"
    if network_discord_id_from_local_index then
        id = network_discord_id_from_local_index(0)
    elseif get_local_discord_id then
        id = get_local_discord_id()
    end

    if not id or id == "" then return "0" end
    return tostring(id)
end

local function get_my_coopnet_id()
    local id = "0"
    if get_coopnet_id then
        id = get_coopnet_id(0)
    end

    if not id or id == "" then return "0" end
    return tostring(id)
end

local function resolve_my_tag()

    if myTagResolved then
        if gPlayerSyncTable[0].tagId ~= myCachedTagId then
            gPlayerSyncTable[0].tagId = myCachedTagId
        end
        return
    end

    local discordId = get_my_discord_id()
    local coopnetId = get_my_coopnet_id()

    if (discordId ~= "0" and discordId ~= "") or (coopnetId ~= "0" and coopnetId ~= "") then
        if discordToTag[discordId] then
            gPlayerSyncTable[0].tagId = discordToTag[discordId]
        elseif coopnetToTag[coopnetId] then
            gPlayerSyncTable[0].tagId = coopnetToTag[coopnetId]
        else
            gPlayerSyncTable[0].tagId = 0
        end

        myCachedTagId = gPlayerSyncTable[0].tagId
        myTagResolved = true
    else
        initTimer = initTimer + 1
        if initTimer > 90 then
            gPlayerSyncTable[0].tagId = 0
            myCachedTagId = 0
            myTagResolved = true
        end
    end
end

local function on_sync_valid()
    if myTagResolved then
        local currentTag = gPlayerSyncTable[0].tagId
        gPlayerSyncTable[0].tagId = 0
        gPlayerSyncTable[0].tagId = currentTag
    end
end

local function get_formatted_tag(playerIndex)
    local tagId = gPlayerSyncTable[playerIndex].tagId
    if tagId and tagId > 0 and DEF_TAGS[tagId] then
        local def = DEF_TAGS[tagId]
        return def.color .. trans(def.name) .. " "
    end
    return ""
end

local function get_player_display_name(playerIndex)
    local np = gNetworkPlayers[playerIndex]
    local playerColor = network_get_player_text_color_string(playerIndex)
    local tagStr = get_formatted_tag(playerIndex)
    return string.format("%s%s%s", tagStr, playerColor, np.name)
end

local function main_update()
    resolve_my_tag()

    if not network_is_server() then return end

    for playerIndex, timer in pairs(connectQueue) do
        local np = gNetworkPlayers[playerIndex]
        local s = gPlayerSyncTable[playerIndex]

        if not np.connected then
            connectQueue[playerIndex] = nil
        else
            if (s.tagId and s.tagId > 0) or timer <= 0 then
                if network_player_connected_count() > 1 then
                    local displayName = get_player_display_name(playerIndex)
                    djui_chat_message_create(displayName .. "\\#ffff50\\ ¡Se ha conectado!")
                end
                connectQueue[playerIndex] = nil
            else
                connectQueue[playerIndex] = timer - 1
            end
        end
    end
end

local function on_chat_message(m, msg)
    local s = gPlayerSyncTable[m.playerIndex]

    if s and s.tagId and s.tagId > 0 and DEF_TAGS[s.tagId] then
        local displayName = get_player_display_name(m.playerIndex)
        local formattedMsg = string.format("%s\\#dcdcdc\\: %s", displayName, msg)

        djui_chat_message_create(formattedMsg)

        if m.playerIndex == 0 then
            play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        else
            play_sound(SOUND_MENU_MESSAGE_APPEAR, gGlobalSoundSource)
        end
        return false
    end
end

------------------
--- C/D Message ---
------------------

local function on_player_connected(m)
    if myTagResolved then
        local currentTag = gPlayerSyncTable[0].tagId
        gPlayerSyncTable[0].tagId = 0
        gPlayerSyncTable[0].tagId = currentTag
    end

    if not network_is_server() then return end
    connectQueue[m.playerIndex] = 90
end

local function on_player_disconnected(m)
    if not network_is_server() then return end
    if network_player_connected_count() > 0 then
        local displayName = get_player_display_name(m.playerIndex)
        djui_chat_message_create(displayName .. "\\#ffff50\\ Se ha desconectado.")
    end
    connectQueue[m.playerIndex] = nil
    
    if gPlayerSyncTable[m.playerIndex] then
        gPlayerSyncTable[m.playerIndex].tagId = 0
    end
end

-------------
--- HOOKS ---
-------------

hook_event(HOOK_UPDATE, main_update)
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)
hook_event(HOOK_ON_SYNC_VALID, on_sync_valid)
hook_event(HOOK_ON_PLAYER_CONNECTED, on_player_connected)
hook_event(HOOK_ON_PLAYER_DISCONNECTED, on_player_disconnected)
