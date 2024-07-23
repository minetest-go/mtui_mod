
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

local function check_item_overrides()
    local json = mtui.mod_storage:get_string("item_overrides")
    if not json or json == "" then
        -- not configured
        return
    end

    -- apply custom overrides
    local item_overrides = minetest.parse_json(json)
    for name, override_def in pairs(item_overrides) do
        if minetest.registered_items[name] then
            minetest.override_item(name, override_def)
        end
    end
end

-- execute check after mods loaded and other things are set up
minetest.register_on_mods_loaded(function()
    check_item_overrides()
    minetest.after(0, check_registered_items)
end)

