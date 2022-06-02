
local function post_stats()
    mtui.send_command({
        type = "stats",
        data = {
            player_count = #minetest.get_connected_players(),
            uptime = minetest.get_server_uptime(),
            max_lag = minetest.get_server_max_lag(),
            time_of_day = minetest.get_timeofday()
        }
    })

    minetest.after(2, post_stats)
end

minetest.after(1, post_stats)