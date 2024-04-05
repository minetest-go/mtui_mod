
--[[
restart_condition_empty == 1: restart if possible
restart_condition_empty == 0: do nothing
--]]

local function get_condition_empty()
    return mtui.mod_storage:get_int("restart_condition_empty") == 1
end

local function set_condition_empty(state)
    mtui.mod_storage:set_int("restart_condition_empty", state and 1 or 0)
end

local function check_restart()
    if get_condition_empty() and #minetest.get_connected_players() == 0 then
        -- reset condition
        set_condition_empty(false)

        -- no one online, restart
        if minetest.get_modpath("beerchat") then
            beerchat.send_on_channel({
                name = "SYSTEM",
                channel = "main",
                message = "➢ Scheduled restart"
            })
        end
        minetest.request_shutdown("scheduled", true)
    end
end

minetest.register_on_leaveplayer(function()
    minetest.after(1, check_restart)
end)

minetest.register_chatcommand("restart_if_empty", {
    description = "restarts the server when the last player leaves",
    privs = { ban = true },
    func = function()
        -- set condition
        set_condition_empty(true)
        check_restart()
    end
})
