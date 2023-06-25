
if not minetest.get_modpath("technic_chests") then
    -- mod not loaded
    return
end

if not technic or not technic.chests or type(technic.chests.log_inv_change) ~= "function" then
    -- function not found
    return
end

-- override technic inv change function
local old_log_inv_change = technic.chests.log_inv_change
technic.chests.log_inv_change = function(pos, name, change, items)
	local spos = minetest.pos_to_string(pos)

    mtui.log({
        event = "inventory",
        username = name,
        nodename = items,
        message = "inventory-" .. change .. " of " .. items .. " into " .. spos,
        posx = pos.x,
        posy = pos.y,
        posz = pos.z
    })


    old_log_inv_change(pos, name, change, items)
end