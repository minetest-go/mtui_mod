
local function check_registered_items()
    mtui.items = minetest.parse_json(mtui.mod_storage:get_string("registered_items") or "{}") or {}

    -- assemble node-list from registered lbm's
    local lbm_nodes = {}
    for _, lbm in ipairs(minetest.registered_lbms) do
        if type(lbm.nodenames) == "string" then
            -- duh, list as string
            lbm_nodes[lbm.nodenames] = true
        else
            -- proper list, add all regardless if they are a "group:*"
            for _, nodename in ipairs(lbm.nodenames) do
                lbm_nodes[nodename] = true
            end
        end
    end

    -- mark all currently registered items
    for name in pairs(minetest.registered_items) do
        mtui.items[name] = true
    end

    -- check for items that don't exist anymore
    for name in pairs(mtui.items) do
        if not minetest.registered_items[name] and
            not minetest.registered_aliases[name] and
            not lbm_nodes[name] then
            -- item does not exist anymore, mark it as such
            mtui.items[name] = false
        end
    end

    -- save current list back
    mtui.mod_storage:set_string("registered_items", minetest.write_json(mtui.items))
end

-- execute check after mods loaded and other things are set up
minetest.register_on_mods_loaded(function()
    minetest.after(0, check_registered_items)
end)

