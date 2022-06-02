
local function post_stats()
    local players = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        players[player:get_player_name()] = {}
    end

    mtui.send_command({
        type = "stats",
        data = {
            players = players,
            uptime = minetest.get_server_uptime(),
            max_lag = minetest.get_server_max_lag(),
            time_of_day = minetest.get_timeofday()
        }
    })


    minetest.after(2, post_stats)
end

minetest.after(1, post_stats)