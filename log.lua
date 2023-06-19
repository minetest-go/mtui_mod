
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
        if not playerdistance or distance < playerdistance then
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
    if not name or name == "" then
        return
    end
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

minetest.register_on_placenode(function(pos, newnode, placer)
    if not placer or not placer.get_player_name or not pos or not newnode then
        return
    end
    local name = placer:get_player_name()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "placenode",
            username = name,
            nodename = newnode.name,
            message = name .. " places node " .. newnode.name .. " at " .. minetest.pos_to_string(pos),
            posx = pos.x,
            posy = pos.y,
            posz = pos.z
        }
    })
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
    if not digger or not digger.get_player_name or not pos or not oldnode then
        return
    end
    local name = digger:get_player_name()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "dignode",
            username = name,
            nodename = oldnode.name,
            message = name .. " digs node " .. oldnode.name .. " at " .. minetest.pos_to_string(pos),
            posx = pos.x,
            posy = pos.y,
            posz = pos.z
        }
    })
end)

minetest.register_on_punchnode(function(pos, node, puncher)
    if not puncher or not puncher.get_player_name or not pos or not node then
        return
    end
    local name = puncher:get_player_name()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "punchnode",
            username = name,
            nodename = node.name,
            message = name .. " punches node " .. node.name .. " at " .. minetest.pos_to_string(pos),
            posx = pos.x,
            posy = pos.y,
            posz = pos.z
        }
    })
end)

minetest.register_on_craft(function(itemstack, player)
    if not player or not player.get_player_name or not itemstack then
        return
    end
    local name = player:get_player_name()
    local pos = player:get_pos()
    mtui.send_command({
        type = "log",
        data = {
            category = "minetest",
            event = "craft",
            username = name,
            nodename = itemstack:get_name(),
            message = name .. " crafts " .. itemstack:get_name(),
            posx = pos.x,
            posy = pos.y,
            posz = pos.z
        }
    })
end)