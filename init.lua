local http = minetest.request_http_api()
if not http then
    print("[mtui] mod not allowed to use the http api, aborting")
    return
end

print("[mtui] initializing")
mtui = {
    url = minetest.settings:get("mtui.url") or "http://127.0.0.1:8080",
    key = minetest.settings:get("mtui.key")
}
assert(mtui.key, "no key found")

local MP = minetest.get_modpath("mtui")
loadfile(MP.."/bridge_rx.lua")(http)
loadfile(MP.."/bridge_tx.lua")(http)

dofile(MP.."/common.lua")
dofile(MP.."/tan.lua")
dofile(MP.."/stats.lua")
dofile(MP.."/log.lua")
dofile(MP.."/log_file.lua")
dofile(MP.."/log_technic.lua")
dofile(MP.."/register_wand.lua")

dofile(MP.."/control.lua")
dofile(MP.."/controls/builtin.lua")
dofile(MP.."/controls/restart_if_empty.lua")

dofile(MP.."/handlers/ping.lua")
dofile(MP.."/handlers/chat.lua")
dofile(MP.."/handlers/execute_command.lua")
dofile(MP.."/handlers/lua.lua")
dofile(MP.."/handlers/controls.lua")

if minetest.get_modpath("mesecons_switch") and minetest.get_modpath("mesecons_lightstone") then
    dofile(MP.."/handlers/mesecons.lua")
end

if not minetest.get_modpath("xp_redo") then
    -- enable per-player stats
    -- note: the xp_redo has the same module, only enable if it isn't present
    dofile(MP.."/player_stats.lua")
end

if minetest.get_modpath("mail") then
    dofile(MP.."/mail.lua")
end

if minetest.get_modpath("mtt") and mtt.enabled then
    dofile(MP.."/mtt.lua")
    dofile(MP.."/common.spec.lua")
end

if minetest.get_modpath("monitoring") then
    dofile(MP.."/monitoring.lua")
end
