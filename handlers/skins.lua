if not minetest.get_modpath("skinsdb") then
    return
end

local skins_path = skins.modpath.."/textures"

local shim_current_modname = nil
local old_get_current_modname = minetest.get_current_modname
function minetest.get_current_modname()
    if shim_current_modname then
        return shim_current_modname
    else
        return old_get_current_modname()
    end
end

mtui.register_on_command("set_png_skin", function(data)
    local skin = skins.get(data.skin_name)
    if not skin and type(skins.register_skin) == "function" then
        -- skin slot not registered yet

        shim_current_modname = "skinsdb"
        skins.register_skin(skins_path, data.skin_name .. ".png")
        shim_current_modname = nil

        skin = skins.get(data.skin_name)
    end
    if not skin then
        -- abort
        return false
    end

    -- set png data for texture at runtime
    skin:set_texture("[png:" .. data.png)
    local player = minetest.get_player_by_name(data.playername)
    if player then
        skins.update_player_skin(player)
    end
    return true
end)