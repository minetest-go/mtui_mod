
local function post_stats()
    local players = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        local playername = player:get_player_name()
        table.insert(players, {
            name = playername,
            info = minetest.get_player_information(playername),
            hp = player:get_hp(),
            breath = player:get_breath(),
            physics = player:get_physics_override(),
            control = player:get_player_control(),
            pos = player:get_pos()
        })
    end

    mtui.send_command({
        type = "stats",
        data = {
            players = players,
            player_count = #minetest.get_connected_players(),
            uptime = minetest.get_server_uptime(),
            max_lag = minetest.get_server_max_lag(),
            time_of_day = minetest.get_timeofday()
        }
    })

    minetest.after(2, post_stats)
end

-- update stats on join/leave
minetest.register_on_joinplayer(post_stats)
minetest.register_on_leaveplayer(post_stats)

minetest.after(1, post_stats)