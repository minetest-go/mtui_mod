
local function register_all(prefix)
    for a = 0, 1 do -- 0 = off  1 = on
    for b = 0, 1 do
    for c = 0, 1 do
    for d = 0, 1 do
        local cid = tostring(d)..tostring(c)..tostring(b)..tostring(a)
        local node_name = prefix..cid
        mtui.mesecons.allowed_nodes[node_name] = true
    end
    end
    end
    end
end

if minetest.get_modpath("mesecons_luacontroller") then
    register_all("mesecons_luacontroller:luacontroller")
end

if minetest.get_modpath("mooncontroller") then
    register_all(mooncontroller.BASENAME)
end

-- ui -> game
mtui.register_on_command("luacontroller_set_program", function(data)
    minetest.load_area(data.pos)
    local node = minetest.get_node_or_nil(data.pos)
    if node == nil then
        -- not loaded
        return { success = false, errmsg = "not loaded" }
    end

    if not mtui.mesecons.allowed_nodes[node.name] then
        -- unexpected node
        return { success = false, errmsg = "unexpected node: " .. node.name }
    end

    local def = minetest.registered_nodes[node.name]
    if not def or type(def.on_receive_fields) ~= "function" then
        -- node definition doesn't make sense
        return { success = false, errmsg = "nodedef error" }
    end

    -- shim player (the formspec callback only uses the `get_player_name` field)
    -- TODO: replace with proper fakeplayer someday
    local player = {
        get_player_name = function()
            return data.playername
        end
    }

    local fields = {
        code = data.code,
        program = true
    }

    def.on_receive_fields(data.pos, nil, fields, player)

    -- this only works with the mooncontroller
    local meta = minetest.get_meta(data.pos)
    local errmsg = meta:get_string("errmsg")

    return {
        success = errmsg == "",
        errmsg = errmsg
    }
end)

mtui.register_on_command("luacontroller_get_program", function(data)
    minetest.load_area(data.pos)
    local node = minetest.get_node_or_nil(data.pos)
    if node == nil then
        -- not loaded
        return { success = false, errmsg = "not loaded" }
    end

    if not mtui.mesecons.allowed_nodes[node.name] then
        -- unexpected node
        return { success = false, errmsg = "unexpected node: " .. node.name }
    end

    if minetest.is_protected(data.pos, data.playername) then
        -- protected
        return { success = false, errmsg = "protected" }
    end

    local meta = minetest.get_meta(data.pos)
    return {
        success = true,
        code = meta:get_string("code"),
        errmsg = meta:get_string("errmsg")
    }
end)