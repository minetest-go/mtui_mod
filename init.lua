local http = minetest.request_http_api()
if not http then
    print("[mtui] mod not allowed to use the http api, aborting")
    return
end

print("[mtui] initializing")
mtui = {
    mod_storage = minetest.get_mod_storage(),
    url = minetest.settings:get("mtui.url") or "http://127.0.0.1:8080",
    key = minetest.settings:get("mtui.key"),
    -- map of name to bool (known node)
    items = {}
}
assert(mtui.key, "no key found")

local MP = minetest.get_modpath("mtui")
loadfile(MP.."/bridge_rx.lua")(http)
loadfile(MP.."/bridge_tx.lua")(http)

dofile(MP.."/common.lua")
dofile(MP.."/info.lua")
dofile(MP.."/tan.lua")
dofile(MP.."/stats.lua")
dofile(MP.."/items.lua")
dofile(MP.."/log.lua")
dofile(MP.."/log_file.lua")
dofile(MP.."/log_technic.lua")
dofile(MP.."/prejoin_ratelimit.lua")

dofile(MP.."/handlers/ping.lua")
dofile(MP.."/handlers/items.lua")
dofile(MP.."/handlers/chat.lua")
dofile(MP.."/handlers/joinpassword.lua")
dofile(MP.."/handlers/execute_command.lua")
dofile(MP.."/handlers/lua.lua")
dofile(MP.."/handlers/controls.lua")
dofile(MP.."/handlers/skins.lua")

dofile(MP.."/restart.lua")

if minetest.get_modpath("mesecons_switch") and minetest.get_modpath("mesecons_lightstone") then
    dofile(MP.."/mesecons/common.lua")
    dofile(MP.."/mesecons/lightstones.lua")
    dofile(MP.."/mesecons/switch.lua")
    dofile(MP.."/mesecons/luacontroller.lua")
    dofile(MP.."/mesecons/register_tool.lua")

    if minetest.get_modpath("digilines") then
        dofile(MP.."/mesecons/lcd.lua")
    end
end

if not minetest.get_modpath("xp_redo") then
    -- enable per-player stats
    -- note: the xp_redo has the same module, only enable if it isn't present
    dofile(MP.."/player_stats.lua")
end

if minetest.get_modpath("atm") then
    dofile(MP.."/handlers/atm.lua")
end

if minetest.get_modpath("mail") then
    dofile(MP.."/mail.lua")
end

if minetest.get_modpath("mtt") and mtt.enabled then
    dofile(MP.."/mtt.lua")
    dofile(MP.."/common.spec.lua")
    dofile(MP.."/items.spec.lua")
end
