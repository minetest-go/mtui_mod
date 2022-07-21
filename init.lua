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

local MP = minetest.get_modpath("mtui")
loadfile(MP.."/bridge_rx.lua")(http)
loadfile(MP.."/bridge_tx.lua")(http)

dofile(MP.."/common.lua")
dofile(MP.."/tan.lua")
dofile(MP.."/stats.lua")
dofile(MP.."/handlers/ping.lua")
dofile(MP.."/handlers/chat.lua")
dofile(MP.."/handlers/execute_command.lua")
