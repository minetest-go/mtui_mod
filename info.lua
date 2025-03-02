
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

        local privs = def.privs or {}
        if type(privs) == "string" then
            -- privs should be table, not plain string
            privs = {privs}
        elseif type(privs) == "table" and #privs > 0 then
            -- an array, somehow, convert to map
            privs = {}
            for _,p in ipairs(def.privs) do
                if type(p) == "string" then
                    privs[p] = true
                end
            end
        end

        chatcommand_info[name] = {
            params = mtui.strip_escapes(def.params),
            description = mtui.strip_escapes(def.description),
            privs = privs
        }
    end
    mtui.mod_storage:set_string("chatcommand_info", minetest.write_json(chatcommand_info))
end

minetest.register_on_mods_loaded(update_game_info)
