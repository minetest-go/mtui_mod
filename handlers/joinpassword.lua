local function get_store()
    return minetest.parse_json(mtui.mod_storage:get_string("join_passwords")) or {}
end

local function set_store(e)
    mtui.mod_storage:set_string("join_passwords", minetest.write_json(e))
end

-- sets a temporary join-password (to be set via web, for the wasm client)
mtui.register_on_command("set_join_password", function(data)

    -- store old password
    local store = get_store()
    local auth = minetest.get_auth_handler().get_auth(data.username)
    if not auth then
        return false
    end
    store[data.username] = {
        time = os.time(),
        password = auth.password
    }
    set_store(store)

    -- set new join password
    minetest.log("action", "[mtui] setting join-password for '" .. data.username .."'")
    minetest.get_auth_handler().set_password(data.username, data.password)

    return true
end)


-- replace previously set join-passwords with original value
local function restore_join_passwords()
    local store = get_store()
    local now = os.time()
    for playername, entry in pairs(store) do
        local diff = now - entry.time
        if diff > 60 then
            -- restore password and clear entry
            minetest.log("action", "[mtui] restoring join-password for '" .. playername .."' (timeout)")
            minetest.get_auth_handler().set_password(playername, entry.password)
            store[playername] = nil
        end
    end
    set_store(store)

    minetest.after(10, restore_join_passwords)
end
minetest.after(10, restore_join_passwords)

-- restore old password on login
minetest.register_on_joinplayer(function(player)
    local playername = player:get_player_name()

    local store = get_store()
    if not store[playername] then
        return
    end
    minetest.log("action", "[mtui] restoring join-password for '" .. playername .."' (successful login)")
    minetest.get_auth_handler().set_password(playername, store[playername].password)
    store[playername] = nil
    set_store(store)
end)