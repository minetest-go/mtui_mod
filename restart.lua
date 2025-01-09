
-- set to true if the mods have changed since startup
local mods_changed = false

-- true if restart in progress
local restart_pending = false

local function check_restart()
    if restart_pending then
        -- restart already pending
        return
    end

    -- get mod storage values
    local restart_if_empty = mtui.mod_storage:get_int("restart_condition_empty") == 1
    local restart_if_mods_changed = mtui.mod_storage:get_int("restart_condition_mods_changed") == 1
    local max_uptime = mtui.mod_storage:get_int("restart_condition_max_uptime")
    local restart_method = mtui.mod_storage:get_string("restart_method")

    local server_empty = #minetest.get_connected_players() == 0
    local schedule_restart = false
    local restart_reason

    -- check for empty server and condition
    if restart_if_empty and server_empty then
        -- reset condition
        mtui.mod_storage:set_int("restart_condition_empty", 0)
        schedule_restart = true
        restart_reason = "server is empty"
    end

    -- check for changed mods condition
    if restart_if_mods_changed and mods_changed then
        schedule_restart = true
        restart_reason = "mods changed"
    end

    -- max uptime condition
    if max_uptime > 0 and minetest.get_server_uptime() > max_uptime then
        schedule_restart = true
        restart_reason = "max uptime exceeded"
    end

    if schedule_restart then
        -- schedule a restart
        local delay = 120
        if restart_method == "INSTANT" or server_empty then
            -- no delay
            delay = 0
        end
        if restart_method == "EMPTY" and not server_empty then
            -- empty condition not met
            return
        end

        if minetest.get_modpath("beerchat") then
            beerchat.send_on_channel({
                name = "SYSTEM",
                channel = "main",
                message = "➢ Scheduled restart, reason: " .. restart_reason
            })
        end
        minetest.chat_send_all("Restarting server, reason: " .. restart_reason)
        minetest.log("action", "[mtui] restarting, reason: " .. restart_reason)
        minetest.request_shutdown("scheduled, reason: " .. restart_reason, true, delay)
        restart_pending = true
    end
end

local function check_loop()
    check_restart()
    minetest.after(5, check_loop)
end

-- start check loop
minetest.after(5, check_loop)

mtui.register_on_command("notify_mods_changed", function()
    mods_changed = true
    return {}
end)

-- check after every player leave event
minetest.register_on_leaveplayer(function()
    minetest.after(1, check_restart)
end)

-- manual trigger for server-empty condition
minetest.register_chatcommand("restart_if_empty", {
    description = "restarts the server when the last player leaves",
    privs = { ban = true },
    func = function()
        -- set condition
        mtui.mod_storage:set_int("restart_condition_empty", 1)
        check_restart()
    end
})
