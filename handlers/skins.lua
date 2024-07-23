if not minetest.get_modpath("skinsdb") then
    return
end

local skins_path = skins.modpath.."/textures"

mtui.register_on_command("set_png_skin", function(data)
    local skin = skins.get(data.skin_name)
    if not skin and type(skins.register_skin) == "function" then
        -- skin slot not registered yet
        skins.register_skin(skins_path, data.skin_name .. ".png")
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