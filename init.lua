local http = minetest.request_http_api()
if not http then
    print("[mtadmin] mod not allowed to use the http api, aborting")
    return
end

print("[mtadmin] initializing")
mtadmin = {
    url = minetest.settings:get("mtadmin.url") or "http://127.0.0.1:8080",
    key = minetest.settings:get("mtadmin.key")
}

local MP = minetest.get_modpath("mtadmin")
loadfile(MP.."/bridge.lua")(http)

dofile(MP.."/stats.lua")
dofile(MP.."/handlers/ping.lua")
