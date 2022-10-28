minetest.register_on_prejoinplayer(function(name, ip)
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "prejoin",
            username = name,
            message = "'" .. name .. "' prejoins from '" .. ip .. "'",
            ip_address = mtui.sanitize_ip(ip)
        }
    })
end)

minetest.register_on_joinplayer(function(player, last_login)
    local name = player:get_player_name()
    local pos = player:get_pos()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "join",
            username = name,
            message = "'" .. name .. "' joins" .. (last_login and "" or " (new)"),
            posx = pos.x,
            posy = pos.y,
            posz = pos.z
        }
    })
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    local name = player:get_player_name()
    local pos = player:get_pos()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "leave",
            username = name,
            message = "'" .. name .. "' left" .. (timed_out and " (timed out)" or ""),
            posx = pos.x,
            posy = pos.y,
            posz = pos.z
        }
    })
end)

minetest.register_on_authplayer(function(name, ip, is_success)
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "authplayer",
            username = name,
            message = "'" .. name .. "' authenticates from '" .. ip .. "' " ..
                (is_success and "(success)" or "(failed)"),
            ip_address = mtui.sanitize_ip(ip)
        }
    })
end)

minetest.register_on_dieplayer(function(player, reason)
    local name = player:get_player_name()
    local pos = player:get_pos()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "dieplayer",
            username = name,
            message = "'" .. name .. "' dies: " .. (reason and reason.type or "<no reason>"),
            posx = pos.x,
            posy = pos.y,
            posz = pos.z
        }
    })
end)

minetest.register_on_cheat(function(player, cheat)
    local name = player:get_player_name()
    local pos = player:get_pos()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "cheat",
            username = name,
            message = "'" .. name .. "' cheats: " .. (cheat and cheat.type or "<unknown>"),
            posx = pos.x,
            posy = pos.y,
            posz = pos.z
        }
    })
end)

minetest.register_on_chat_message(function(name, message)
    local player = minetest.get_player_by_name(name)
    local pos = player:get_pos()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "chat",
            username = name,
            message = "'" .. name .. "' writes: '" .. message .. "'",
            posx = pos.x,
            posy = pos.y,
            posz = pos.z
        }
    })
end)

minetest.register_on_mods_loaded(function()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "system",
            message = "started"
        }
    })
end)

minetest.register_on_shutdown(function()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "system",
            message = "shutdown"
        }
    })
end)

minetest.register_on_generated(function(minp, maxp)
    -- center of the chunk
    local center = vector.add(minp, 40)
    -- nearest player
    local playername, playerdistance

    for _, player in ipairs(minetest.get_connected_players()) do
        local distance = vector.distance(player:get_pos(), center)
        if not distance or distance < playerdistance then
            -- player is near or no player found yet
            playername = player:get_player_name()
            playerdistance = distance
        end
    end

    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "on_generated",
            username = playername,
            message = "map generated between " ..
                minetest.pos_to_string(minp) .. " and " .. minetest.pos_to_string(maxp),
            posx = minp.x,
            posy = minp.y,
            posz = minp.z
        }
    })
end)

minetest.register_on_protection_violation(function(pos, name)
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "protection_violation",
            username = name,
            message = "'" .. name .. "' violated a protection",
            posx = pos.x,
            posy = pos.y,
            posz = pos.z
        }
    })
end)