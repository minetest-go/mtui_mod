local has_respawn = minetest.get_modpath("respawn") ~= nil
local global_stats = {}

local function get_biome_of_player(player)
   local biome_data = core.get_biome_data(player:get_pos())
   if biome_data and (biome_data.biome ~= nil) then
      local biome = core.get_biome_name(biome_data.biome)
      if biome ~= nil and biome ~= "" then
         return biome
      end
   end
   return nil
end

local function get_respawn_place(player)
    local location = false
    local pos = ""
    if has_respawn then
        local max_dist = 80
        local place_name, place = respawn.closest_place_or_player_place("", pos, max_dist)
        if place_name then
            location = true
            pos = "near " .. place_name
            -- place.full_name
        end
        if not location then -- try using biome name
            local biome = get_biome_of_player(player)
            if biome ~= nil and biome ~= "" then
                location = true
                pos = "near " .. tostring(biome)
            end
        end
    end
    return pos
end

-- post player and server-stats to the ui
local function post_stats()
    local players = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        local playername = player:get_player_name()
        local info = minetest.get_player_information(playername)
        if info then
            info.address = mtui.sanitize_ip(info.address)
        end
        local location = get_respawn_place(player)

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
