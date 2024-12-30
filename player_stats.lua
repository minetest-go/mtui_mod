local increase_stat = function(player, name, value)
	if player == nil or player.get_meta == nil then
		-- fake player
		return
	end

	local meta = player:get_meta()
	local count = meta:get_int(name)
	if not count then
		count = 0
	end

	local newValue = count + value

	meta:set_int(name, newValue)
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer > 5 then
		for _,player in ipairs(minetest.get_connected_players()) do
			increase_stat(player, "played_time", timer)
		end
		timer = 0
	end
end)

minetest.register_on_dignode(function(_, _, player)
	if player and player:is_player() then
		increase_stat(player, "digged_nodes", 1)
	end
end)

minetest.register_on_placenode(function(_, _, player)
	if player and player:is_player() then
		increase_stat(player, "placed_nodes", 1)
	end
end)

minetest.register_on_dieplayer(function(player)
	increase_stat(player, "died", 1)
end)

minetest.register_on_craft(function(itemstack, player)
	increase_stat(player, "crafted", itemstack:get_count())
end)

-- last-ip tracking
local last_ips = {}

minetest.register_on_authplayer(function(name, ip, is_success)
	if is_success then
		-- store ip temporarily
		last_ips[name] = ip
	end
end)

minetest.register_on_joinplayer(function(player)
	-- store ip in player meta permanently
	local playername = player:get_player_name()
	local meta = player:get_meta()
	meta:set_string("last_ip", last_ips[playername])
	last_ips[playername] = nil
end)