
local function update_game_info()
    local priv_info = {}
    for name, def in pairs(minetest.registered_privileges) do
        priv_info[name] = {
            description = mtui.strip_escapes(def.description),
            give_to_singleplayer = def.give_to_singleplayer,
            give_to_admin = def.give_to_admin
        }
    end
    mtui.mod_storage:set_string("priv_info", minetest.write_json(priv_info))

    local chatcommand_info = {}
    for name, def in pairs(minetest.registered_chatcommands) do
        chatcommand_info[name] = {
            params = mtui.strip_escapes(def.params),
            description = mtui.strip_escapes(def.description),
            privs = def.privs
        }
    end
    mtui.mod_storage:set_string("chatcommand_info", minetest.write_json(chatcommand_info))
end

minetest.register_on_mods_loaded(update_game_info)
