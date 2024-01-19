if not minetest.get_modpath("skinsdb") then
    return
end

mtui.register_on_command("set_png_skin", function(data)
    local skin = skins.get(data.skin_name)
    if skin then
        skin:set_texture("[png:" .. data.png)
    end

    local player = minetest.get_player_by_name(data.playername)
    if player then
        skins.update_player_skin(player)
    end
    return true
end)