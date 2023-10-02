
local restart = false

local function check_restart()
    if restart and #minetest.get_connected_players() == 0 then
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
        restart = true
        check_restart()
    end
})

mtui.register_control("mtui:restart_if_empty", {
    type = "bool",
    label = "Restart as soon as the server is empty",
    action = {
        get = function()
            return restart
        end,
        set = function(v)
            restart = v
            check_restart()
        end
    }
})