local global_stats = {}

-- post player and server-stats to the ui
local function post_stats()
    local players = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        local playername = player:get_player_name()
        local info = minetest.get_player_information(playername)
        if info then
            info.address = mtui.sanitize_ip(info.address)
        end

        table.insert(players, {
            name = playername,
            info = info,
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
            time_of_day = minetest.get_timeofday(),
            version = minetest.get_version().string,
            mem = collectgarbage("count"), -- in kilobytes, https://www.lua.org/manual/5.1/manual.html
            global_stats = global_stats
        }
    })
end

-- periodic stats updater
local function stats_updater()
    post_stats()
    minetest.after(2, stats_updater)
end

-- update stats on join/leave
minetest.register_on_joinplayer(post_stats)
minetest.register_on_leaveplayer(post_stats)

-- https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
local function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

-- start stat-update loop after mods loaded and global stats gathered
minetest.register_on_mods_loaded(function()
    -- gather global stats
    global_stats["registered_nodes"] = tablelength(minetest.registered_nodes)
    global_stats["registered_items"] = tablelength(minetest.registered_items)
    global_stats["registered_entities"] = tablelength(minetest.registered_entities)
    global_stats["registered_abms"] = tablelength(minetest.registered_abms)

    -- start main update loop
    minetest.after(1, stats_updater)
end)